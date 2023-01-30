//
//  DetailListBackgroundView.swift
//  FindCVS
//
//  Created by 이송은 on 2022/12/07.
//

import RxCocoa
import RxSwift
import SnapKit

class DetailListBackgroundView : UIView{
    let disposeBag = DisposeBag()
    let statusLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(viewModel : DetailListBackgroundViewModel){
        viewModel.isStatusLabelHidden
            .emit(to: statusLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func attribute(){
        backgroundColor = .white
        statusLabel.text = "🏪"
        statusLabel.textAlignment = .center
    }
    
    private func layout(){
        addSubview(statusLabel)
        
        statusLabel.snp.makeConstraints{
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
