//
//  DetailListBackgroundViewModel.swift
//  FindCVS
//
//  Created by 이송은 on 2022/12/07.
//

import RxSwift
import RxCocoa

struct DetailListBackgroundViewModel {
    let isStatusLabelHidden : Signal<Bool>
    let shouldHideStatusLabel = PublishSubject<Bool>()
    
    init(){
        isStatusLabelHidden = shouldHideStatusLabel
            .asSignal(onErrorJustReturn: true)
    }
}
