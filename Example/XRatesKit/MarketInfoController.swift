import UIKit
import RxSwift
import SnapKit
import XRatesKit

class MarketInfoController: UITableViewController {
    private let disposeBag = DisposeBag()

    private let xRatesKit: XRatesKit
    private let currencyCode: String
    private let coinCodes: [String]

    private var marketInfos = [String: MarketInfo]()

    init(xRatesKit: XRatesKit, currencyCode: String, coinCodes: [String]) {
        self.xRatesKit = xRatesKit
        self.currencyCode = currencyCode
        self.coinCodes = coinCodes

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Market Info"

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(onTapRefresh))

        tableView.register(MarketInfoCell.self, forCellReuseIdentifier: String(describing: MarketInfoCell.self))
        tableView.separatorInset = .zero
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()

        fillInitialData()

        xRatesKit.marketInfosObservable(currencyCode: currencyCode)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] marketInfos in
                    self?.marketInfos = marketInfos
                    self?.tableView.reloadData()
                })
                .disposed(by: disposeBag)
    }

    @objc func onTapRefresh() {
        xRatesKit.refresh()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        coinCodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MarketInfoCell.self)) {
            return cell
        }

        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? MarketInfoCell else {
            return
        }

        let coinCode = coinCodes[indexPath.row]

        cell.bind(coinCode: coinCode, marketInfo: marketInfos[coinCode])
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    private func fillInitialData() {
        for coinCode in coinCodes {
            marketInfos[coinCode] = xRatesKit.marketInfo(coinCode: coinCode, currencyCode: currencyCode)
        }
    }

}
