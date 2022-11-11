//
// Created on 2022/5/26.
//

import UIKit
import RxSwift
import RxCocoa

enum State {
    case normal
    case selected
    case disabled
    
    var stateColor: UIColor {
        switch self {
        case .normal:
            return .systemGray
        case .selected:
            return .white
        case .disabled:
            return .lightGray
        }
    }
}

class PageSegmentCollectionViewCell: UICollectionViewCell {
    
    let state = BehaviorRelay<State>(value: .normal)
    let titleText = BehaviorRelay<String?>(value: nil)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        bind()
    }
    
    private let titleLabel = UILabel()
    private let disposeBag = DisposeBag()
}

private extension PageSegmentCollectionViewCell {
    func setupUI() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

private extension PageSegmentCollectionViewCell {
    func bind() {
        titleText
            .compactMap { $0 }
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        state
            .map { $0.stateColor }
            .bind(to: titleLabel.rx.textColor)
            .disposed(by: disposeBag)
    }
}
