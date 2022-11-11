//
// Created on 2022/5/26.
//

import UIKit
import RxSwift
import RxCocoa

class PageSegmentView: UIView {

    let selectedIndex = BehaviorRelay<Int>(value: 0)
    let tappedIndex = BehaviorRelay<Int>(value: 0)
    var titles: [String] = []
    
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
    
    private let underlineImageView = UIImageView()
    private let segmentSize = BehaviorRelay<CGSize>(value: .zero)
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private let collectionFlowLayout = UICollectionViewFlowLayout()
    private let disposeBag = DisposeBag()
}

// MARK: - Setup UI

private extension PageSegmentView {
    func setupUI() {
        setupFlowLayout()
        setupCollectionView()
        setupUnderlineImageView()
    }
    
    func setupFlowLayout() {
        collectionFlowLayout.scrollDirection = .horizontal
        collectionFlowLayout.sectionInset = .zero
        collectionFlowLayout.minimumInteritemSpacing = .zero
        collectionFlowLayout.minimumLineSpacing = .zero
    }
    
    func setupCollectionView() {
        collectionView.collectionViewLayout = collectionFlowLayout
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceHorizontal = false
        collectionView.alwaysBounceVertical = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PageSegmentCollectionViewCell.self,
                                forCellWithReuseIdentifier: "Cell")
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupUnderlineImageView() {
        underlineImageView.alpha = 0
        collectionView.addSubview(underlineImageView)
    }
    
    func draw(at item: Int) {
        let index = IndexPath(item: item, section: 0)
        guard let cell = collectionView.cellForItem(at: index) else { return }
        
        let rect = convert(cell.frame, to: self)
        if rect.height != 0 {
            underlineImageView.alpha = 1
            underlineImageView.frame.size.height = 3
            underlineImageView.frame.origin.y = rect.maxY - underlineImageView.frame.height
        }
        
        UIViewPropertyAnimator
            .runningPropertyAnimator(
                withDuration: 0.2,
                delay: .zero,
                options: [
                    .curveEaseInOut,
                    .beginFromCurrentState
                ],
                animations: {
                    self.underlineImageView.frame.origin.x = rect.minX
                    self.underlineImageView.frame.size.width = rect.width
                    self.underlineImageView.backgroundColor = .white
                },
                completion: nil)
            .startAnimation()
    }
}

// MARK: - Bind

private extension PageSegmentView {
    func bind() {
        rx
            .observe(\.bounds)
            .withUnretained(self)
            .subscribe(onNext: { owner, bounds in
                let size = bounds.size
                owner.segmentSize.accept(size)
            })
            .disposed(by: disposeBag)
        
        selectedIndex
            .delay(.microseconds(1), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { owner, index in
                owner.draw(at: index)
                owner.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Collection View Delegate

extension PageSegmentView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let title = titles[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                            for: indexPath) as? PageSegmentCollectionViewCell else {
           return .init()
        }
        cell.titleText.accept(title)
        
        let state = (indexPath.item == selectedIndex.value) ? State.selected : State.normal
        cell.state.accept(state)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let count = CGFloat(titles.count)
        guard count > 0 else { return .zero }
        
        let size = segmentSize.value
        return .init(width: size.width / count, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex.accept(indexPath.item)
        tappedIndex.accept(indexPath.item)
    }
}
