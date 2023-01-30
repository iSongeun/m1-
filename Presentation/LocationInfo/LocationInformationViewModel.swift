//
//  LocationInformationViewModel.swift
//  FindCVS
//
//  Created by 이송은 on 2022/12/05.
//

import UIKit
import RxSwift
import RxCocoa


struct LocationInformationViewModel{
    let disposeBag = DisposeBag()
    
    let detailListBackgroundViewModel = DetailListBackgroundViewModel()
    
    
    let setMapCenter : Signal<MTMapPoint>
    let errorMessage : Signal<String>
    
    let detailListCellData : Driver<[DetailListCellData]>
    let scrollToSelectedLocation : Signal<Int>
    
    let currentLocation = PublishRelay<MTMapPoint>()
    let mapCenterPoint = PublishRelay<MTMapPoint>()
    let selectPOIItem = PublishRelay<MTMapPOIItem>()
    let mapViewError = PublishRelay<String>()
    let currentLocationButtonTapped = PublishRelay<Void>()
    let detailListItemSelected = PublishRelay<Int>()
    
    private let documentData = PublishSubject<[KLDocument]>()
    
    init(model : LocationIInformationModel = LocationIInformationModel()){
        let cvsLocationDataResult = mapCenterPoint
            .flatMapLatest(model.getLocation)
            .share()
        
        let cvsLocationDataValue = cvsLocationDataResult
            .compactMap{ data -> LocationData? in
                guard case let .success(value) = data else{
                    return nil
                }
                
                return value
            }
        
        let cvsLocationDataErrorMessage = cvsLocationDataResult
            .compactMap{ data -> String? in
                switch data {
                case let .success(data) where data.documents.isEmpty :
                    return """
                    500m no cvs.
                    """
                case let .failure(error) :
                    return error.localizedDescription
                default:
                    return nil
                    
                }
            }
        
        cvsLocationDataValue
            .map { $0.documents }
            .bind(to: documentData)
            .disposed(by: disposeBag)
        
        let selectDatailListItem = detailListItemSelected
            .withLatestFrom(documentData) {$1[$0]}
            .map { data -> MTMapPoint in
                guard let longtitue = Double(data.x),
                      let latitue = Double(data.y) else{
                    return MTMapPoint()
                }
                let geoCoord = MTMapPointGeo(latitude: latitue, longitude: longtitue)
                return MTMapPoint(geoCoord: geoCoord)
            }
        let moveToCurrentLocation = currentLocationButtonTapped.withLatestFrom(currentLocation)
        
        let currentMapCenter = Observable.merge(
            selectDatailListItem,
            currentLocation.take(1),
            moveToCurrentLocation
        )
        
        setMapCenter = currentMapCenter.asSignal(onErrorSignalWith: .empty())
        
        errorMessage = Observable
            .merge(
                cvsLocationDataErrorMessage,
                mapViewError.asObservable()
            ).asSignal(onErrorJustReturn: "try later")
        
        //??
        detailListCellData = documentData
            .map(model.documentsToCellData)
            .asDriver(onErrorDriveWith: .empty())
        
        documentData
            .map{!$0.isEmpty}
            .bind(to: detailListBackgroundViewModel.shouldHideStatusLabel)
            .disposed(by: disposeBag)
        
        scrollToSelectedLocation = selectPOIItem
            .map { $0.tag}
        .asSignal(onErrorJustReturn: 0)    }
}
