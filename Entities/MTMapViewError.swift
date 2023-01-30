//
//  MTMapViewError.swift
//  FindCVS
//
//  Created by 이송은 on 2022/12/06.
//

import Foundation

enum MTMapViewError : Error {
    case failedUpdatingCurrentLocation
    case locationAuthorizationDenied
    
    var errorDescription : String{
        switch self{
        case .failedUpdatingCurrentLocation : return "fail location load"
        case .locationAuthorizationDenied : return "location info undefined"
        }
    }
}
