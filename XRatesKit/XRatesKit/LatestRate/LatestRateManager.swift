import RxSwift

class LatestRateManager {
    weak var delegate: ILatestRateManagerDelegate?

    private let storage: ILatestRateStorage
    private let expirationInterval: TimeInterval

    private var subjects = [RateKey: PublishSubject<Rate>]()

    init(storage: ILatestRateStorage, expirationInterval: TimeInterval) {
        self.storage = storage
        self.expirationInterval = expirationInterval
    }

    private func subject(key: RateKey) -> PublishSubject<Rate> {
        if let subject = subjects[key] {
            return subject
        }

        let subject = PublishSubject<Rate>()
        subjects[key] = subject
        return subject
    }

    private func rateInfo(rate: LatestRate) -> Rate {
        Rate(rateRecord: rate, expirationInterval: expirationInterval)
    }

    private func notify(rates: [LatestRate]) {
        rates.forEach { rate in
            delegate?.didUpdate(rateInfo: rateInfo(rate: rate), key: rate.key)
        }
    }

}

extension LatestRateManager: ILatestRateManager {

    func lastSyncDate(coinCodes: [String], currencyCode: String) -> Date? {
        let rates = storage.latestRatesSortedByDate(coinCodes: coinCodes, currencyCode: currencyCode)

        // not all rates for coin codes are stored in database - force sync required
        guard rates.count == coinCodes.count else {
            return nil
        }

        // return date of the most expired stored rate
        return rates.first?.date
    }

    func latestRate(key: RateKey) -> Rate? {
        storage.latestRate(key: key).map { rateInfo(rate: $0) }
    }

    func latestRateObservable(key: RateKey) -> Observable<Rate> {
        subject(key: key).asObservable()
    }

    func handleUpdated(rates: [LatestRate]) {
        storage.save(latestRates: rates)
        notify(rates: rates)
    }

    func notifyExpiredRates(coinCodes: [String], currencyCode: String) {
        let rates = storage.latestRatesSortedByDate(coinCodes: coinCodes, currencyCode: currencyCode)
        notify(rates: rates)
    }

}
