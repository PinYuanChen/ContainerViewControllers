
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class TestTableViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    private let tableView = UITableView()
    private let disposeBag = DisposeBag()
}

// MARK: - Setup UI
private extension TestTableViewController {

    func setupUI() {
        setupTableView()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

}

// MARK: - Bind
private extension TestTableViewController {
    func bind() {
        
    }
}

// MARK: - TableView Delegate
extension TestTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .black
        return cell
    }
}
