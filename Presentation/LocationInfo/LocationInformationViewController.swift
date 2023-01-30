//
//  LocationInformationViewController.swift
//  FindCVS
//
//  Created by 이송은 on 2022/12/05.
//

import UIKit
import RxCocoa
import SnapKit
import CoreLocation
import RxSwift

class LocationInformationViewController : UIViewController{
    let disposeBag = DisposeBag()
    let locationManager = CLLocationManager()
    let mapView = MTMapView()
    let currentLocationButton = UIButton()
    let detailList = UITableView()
    let detailListBackgroundView = DetailListBackgroundView()
    let viewModel = LocationInformationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        bind(viewModel: viewModel)
        attribute()
        layout()
    }
    
    private func bind(viewModel : LocationInformationViewModel){
        detailListBackgroundView
            .bind(viewModel: viewModel
                .detailListBackgroundViewModel)
        
        viewModel.setMapCenter.emit(to: mapView.rx.setMapCenterPoint)
            .disposed(by: disposeBag)
        
        viewModel.errorMessage.emit(to: self.rx.presentAlert)
            .disposed(by: disposeBag)
        
        viewModel.detailListCellData
            .drive(detailList.rx.items){ tv, row, data in
                let cell = tv.dequeueReusableCell(withIdentifier: "DetailListCell", for: IndexPath(row: row, section: 0)) as! DetailListCell
                
                cell.setData(data: data)
                
                return cell
                
            }.disposed(by: disposeBag)
        ////////
        viewModel.detailListCellData
            .map { $0.compactMap{$0.point } }
            .drive(self.rx.addPOIItems)
            .disposed(by: disposeBag)
        
        viewModel.scrollToSelectedLocation
            .emit(to: self.rx.showSelectedLocation)
            .disposed(by: disposeBag)
        
        detailList.rx.itemSelected
            .map {$0.row}
            .bind(to: viewModel.detailListItemSelected)
            .disposed(by: disposeBag)
        
        currentLocationButton.rx.tap
            .bind(to: viewModel.currentLocationButtonTapped)
            .disposed(by: disposeBag)
    }
    
    private func attribute(){
        title = "내 주변 편의점 찾기"
        view.backgroundColor = .white
        mapView.currentLocationTrackingMode = .onWithHeadingWithoutMapMoving
        currentLocationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        currentLocationButton.backgroundColor = .white
        currentLocationButton.layer.cornerRadius = 20
        
        detailList.register(DetailListCell.self, forCellReuseIdentifier: "DetailListCell")
        detailList.separatorStyle = .none
        detailList.backgroundView = detailListBackgroundView
    }
    
    private func layout(){
        [mapView, currentLocationButton, detailList]
            .forEach{view.addSubview($0)}
        
        mapView.snp.makeConstraints{
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.snp.centerY).offset(100)
        }
        
        currentLocationButton.snp.makeConstraints{
            $0.bottom.equalTo(detailList.snp.top).offset(-12)
            $0.leading.equalToSuperview().offset(12)
            $0.width.height.equalTo(40)
        }
        
        detailList.snp.makeConstraints{
            $0.centerX.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
            $0.top.equalTo(mapView.snp.bottom)
        }
    }
}

extension LocationInformationViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status{
        case .authorizedAlways, .authorizedWhenInUse, .notDetermined : return
        default :
            viewModel.mapViewError.accept(MTMapViewError.locationAuthorizationDenied.errorDescription)
            return
        }
    }
}

extension LocationInformationViewController : MTMapViewDelegate{
    func mapView( mapview : MTMapView!, updateCurrentLocation location : MTMapPoint!, withAccuracy accuracy : MTMapLocationAccuracy){
        #if DEBUG
        viewModel.currentLocation.accept(MTMapPoint(geoCoord: MTMapPointGeo(latitude: 37, longitude: 127)))
        #else
        viewModel.currentLocation.accept(location)
        #endif
    }
    
    func mapView(_ mapView: MTMapView!, finishedMapMoveAnimation mapCenterPoint : MTMapPoint!){
        viewModel.mapCenterPoint.accept(mapCenterPoint)
    }
    
    func mapView ( mapView : MTMapView!, selectedPOIIten poiItem : MTMapPOIItem) -> Bool{
        viewModel.selectPOIItem.accept(poiItem)
        return false
    }
    
    func mapView(_ mapView: MTMapView!, failedUpdatingCurrentLocationWithError error: Error!) {
        viewModel.mapViewError.accept(error.localizedDescription)
    }
}

extension Reactive where Base : MTMapView{
    var setMapCenterPoint : Binder<MTMapPoint>{
        return Binder(base){ base, point in
            base.setMapCenter(point, animated : true)}
    }
}

extension Reactive where Base : LocationInformationViewController{
    var presentAlert : Binder<String>{
        return Binder(base){ base, message in
            let alertController = UIAlertController(title: "error", message: message, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "ok", style: .default)
            
            alertController.addAction(action)
            base.present(alertController, animated: true)
        }
    }
    
    var showSelectedLocation : Binder<Int>{
        return Binder(base){ base, row in
            let indexPath = IndexPath(row: row, section: 0)
            base.detailList.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        }
    }
    
    var addPOIItems : Binder<[MTMapPoint]>{
        return Binder(base){ base,points in
            let items = points
                .enumerated()
                .map { offset,point -> MTMapPOIItem in
                    let mapPOIItem = MTMapPOIItem()
                    
                    mapPOIItem.mapPoint = point
                    mapPOIItem.markerType = .bluePin
                    mapPOIItem.showAnimationType = .springFromGround
                    mapPOIItem.tag = offset
                    
                    return mapPOIItem
                    
                }
            base.mapView.removeAllPOIItems()
            base.mapView.addPOIItems(items)
        }
    }
}


