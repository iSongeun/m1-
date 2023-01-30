//
//  LocalNetwork.swift
//  FindCVS
//
//  Created by 이송은 on 2022/12/07.
//

import Foundation
import RxSwift

class LocalNetwork {
    private let session : URLSession
    let api = LocalAPI()
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func getLocation(by mapPoint : MTMapPoint) -> Single<Result<LocationData,URLError>>{
        guard let url = api.getLocation(by: mapPoint).url else{
            return .just(.failure(URLError(.badURL)))
        }
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("KakaoAK f49602f6ed15dfcc89f30a4fc7ed327f", forHTTPHeaderField : "Authorization")
        
        return session.rx.data(request: request as URLRequest)
            .map { data in
                do{
                    let locationData = try JSONDecoder().decode(LocationData.self, from: data)
                    return .success(locationData)
                } catch {
                    return .failure(URLError(.cannotParseResponse))
                }
            }.catch{ _ in .just(Result.failure(URLError(.cannotLoadFromNetwork)))}
            .asSingle()
    }
}
