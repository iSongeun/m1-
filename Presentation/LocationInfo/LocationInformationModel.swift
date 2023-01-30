//
//  LocationInformationModel.swift
//  FindCVS
//
//  Created by 이송은 on 2022/12/07.
//

import Foundation
import RxSwift

struct LocationIInformationModel{
    let localNetwork : LocalNetwork
    
    init(localNetwork: LocalNetwork = LocalNetwork()) {
        self.localNetwork = localNetwork
    }
    
    func getLocation(by mapPoint: MTMapPoint) ->Single<Result<LocationData,URLError>>{
        return localNetwork.getLocation(by: mapPoint)
    }
    
    func documentsToCellData( data: [KLDocument]) -> [DetailListCellData] {
        return data.map{
            let address = $0.roadAddressName.isEmpty ? $0.addressName : $0.roadAddressName
            let point = documentToMTMapPoint(doc: $0)
            return DetailListCellData(placeName: $0.placeName, address: address, distance: $0.distance, point: point)
        }
    }
    func documentToMTMapPoint(doc : KLDocument) -> MTMapPoint {
        let latitude = Double(doc.x) ?? .zero
        let longtitude = Double(doc.y) ?? .zero
        
        return MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude, longitude: longtitude))
    }
}
