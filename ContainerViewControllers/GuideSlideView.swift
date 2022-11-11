
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class GuideSlideView: UIView {
    
    var childrenViewControllers: [UIViewController] {
        get {
            _childrenViewControllers.value
        }
        set(vcs) {
            _childrenViewControllers.accept(vcs)
        }
    }
    
    var currentPage: Observable<Int> {
        _currentPage.asObservable()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(page: Int, animated: Bool) {
        let size = scrollView.frame.size
        let rect = CGRect(origin: .init(x: page * Int(size.width), y: 0), size: size)
        scrollView.scrollRectToVisible(rect, animated: animated)
        _currentPage.accept(page)
    }
    
    func previousPage() {
        set(page: max(_currentPage.value - 1, 0), animated: true)
    }
    
    func nextPage() {
        set(page: min(_currentPage.value + 1, childrenViewControllers.count - 1), animated: true)
    }
    
    private let _childrenViewControllers = BehaviorRelay<[UIViewController]>(value: [])
    private let _currentPage = BehaviorRelay<Int>(value: 0)
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let baseViewController = UIViewController()
    private let disposeBag = DisposeBag()
}

// MARK: - Setup UI
private extension GuideSlideView {

    func setupUI() {
        setupBaseViewController()
        setupScrollView()
        setupStackView()
    }
    
    func setupBaseViewController() {
        addSubview(baseViewController.view)
        baseViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupScrollView() {
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func setupStackView() {
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - Bind
private extension GuideSlideView {
    func bind() {
        _childrenViewControllers
            .filter { !$0.isEmpty }
            .withUnretained(self)
            .subscribe(onNext: { owner, vcs in
                guard owner.stackView.arrangedSubviews.isEmpty else {
                    // remove subviews
                    return
                }
                
                vcs.forEach {
                    owner.configureChildrenVC($0)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension GuideSlideView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = (scrollView.contentOffset.x / scrollView.frame.width).rounded()
        _currentPage.accept(Int(page))
    }
}

// MARK: - Private Functions
private extension GuideSlideView {
    func configureChildrenVC(_ vc: UIViewController) {
        let contentView = UIView()
        stackView.addArrangedSubview(contentView)

        baseViewController.addChild(vc)
        baseViewController.view.addSubview(vc.view)
        vc.didMove(toParent: baseViewController)
        
        contentView.addSubview(vc.view)

        vc.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(baseViewController.view)
            $0.height.equalTo(baseViewController.view)
        }
    }
}
