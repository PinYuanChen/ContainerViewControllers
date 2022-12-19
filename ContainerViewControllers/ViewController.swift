
import UIKit
import SnapKit
import RxSwift
import RxCocoa

infix operator -->

func --><T>(obj: T, closure:(T) -> Void) -> T {
    closure(obj)
    return obj
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    private let pageSegment = PageSegmentView(frame: .zero)
    private let slideView = GuideSlideView(frame: .zero)
    private let leftArrowButton = UIButton() --> {
        $0.setTitle("◀︎", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitleColor(.lightGray, for: .disabled)
    }
    private let rightArrowButton = UIButton() --> {
        $0.setTitle("▶︎", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitleColor(.lightGray, for: .disabled)
    }
    private let vc1 = TestTableViewController()
    private let vc2 = UIViewController() --> {
        $0.view.backgroundColor = .systemRed.withAlphaComponent(0.5)
    }
    private let vc3 = UIViewController() --> {
        $0.view.backgroundColor = .systemPurple.withAlphaComponent(0.5)
    }
    private lazy var vcs = [vc1, vc2, vc3]
    private let pageControl = UIPageControl() --> {
        $0.currentPageIndicatorTintColor = .systemBlue.withAlphaComponent(0.4)
        $0.pageIndicatorTintColor = .white
    }
    private let disposeBag = DisposeBag()
}

// MARK: - Setup UI
private extension ViewController {

    func setupUI() {
        view.backgroundColor = .black
        setupPageSegment()
        setupSlideView()
        setupPageControl()
        setupArrowButtons()
    }
    
    func setupPageSegment() {
        pageSegment.titles = ["vc1", "vc2", "vc3"]
        view.addSubview(pageSegment)
        pageSegment.snp.makeConstraints {
            $0.width.equalToSuperview().offset(-60)
            $0.height.equalTo(60)
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.centerX.equalToSuperview()
        }
    }
    
    func setupSlideView() {
        slideView.childrenViewControllers = vcs
        view.addSubview(slideView)
        slideView.snp.makeConstraints {
            $0.width.equalToSuperview().offset(-60)
            $0.height.equalToSuperview().offset(-200)
            $0.top.equalTo(pageSegment.snp.bottom)
            $0.centerX.equalToSuperview()
        }
    }
    
    func setupPageControl() {
        pageControl.numberOfPages = vcs.count
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints {
            $0.width.equalTo(300)
            $0.height.equalTo(20)
            $0.centerX.equalTo(slideView)
            $0.top.equalTo(slideView.snp.bottom).offset(20)
        }
    }
    
    func setupArrowButtons() {
        view.addSubview(leftArrowButton)
        leftArrowButton.snp.makeConstraints {
            $0.size.equalTo(30)
            $0.centerY.equalTo(slideView)
            $0.trailing.equalTo(slideView.snp.leading)
        }
        
        view.addSubview(rightArrowButton)
        rightArrowButton.snp.makeConstraints {
            $0.size.centerY.equalTo(leftArrowButton)
            $0.leading.equalTo(slideView.snp.trailing)
        }
    }
}

// MARK: - Bind
private extension ViewController {
    func bind() {
        slideView
            .currentPage
            .asDriver(onErrorJustReturn: 0)
            .drive( pageControl.rx.currentPage)
            .disposed(by: disposeBag)
        
        slideView
            .currentPage
            .bind(to: pageSegment.selectedIndex)
            .disposed(by: disposeBag)
        
        pageSegment
            .tappedIndex
            .withUnretained(slideView)
            .subscribe(onNext: { owner, index in
                owner.set(page: index, animated: false)
            })
            .disposed(by: disposeBag)
        
        slideView
            .currentPage
            .withUnretained(self)
            .subscribe(onNext: { owner, page in
                owner.leftArrowButton.isEnabled = page > 0
                owner.rightArrowButton.isEnabled = page < owner.vcs.count-1
            })
            .disposed(by: disposeBag)
        
        leftArrowButton
            .rx
            .tap
            .withUnretained(slideView)
            .subscribe(onNext: { slideView, _ in
                slideView.previousPage()
            })
            .disposed(by: disposeBag)
        
        rightArrowButton
            .rx
            .tap
            .withUnretained(slideView)
            .subscribe(onNext: { slideView, _ in
                slideView.nextPage()
            })
            .disposed(by: disposeBag)
    }
}
