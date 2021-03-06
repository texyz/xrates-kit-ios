import GRDB

class MarketInfoRecord: Record {
    let key: PairKey
    let timestamp: TimeInterval
    let rate: Decimal
    let open24Hour: Decimal
    let diff: Decimal
    let volume: Decimal
    let marketCap: Decimal
    let supply: Decimal

    init(coinCode: String, currencyCode: String, response: ResponseMarketInfo) {
        key = PairKey(coinCode: coinCode, currencyCode: currencyCode)
        timestamp = Date().timeIntervalSince1970
        rate = response.rate
        open24Hour = response.open24Hour
        diff = response.diff
        volume = response.volume
        marketCap = response.marketCap
        supply = response.supply

        super.init()
    }

    override open class var databaseTableName: String {
        "market_info"
    }

    enum Columns: String, ColumnExpression {
        case coinCode, currencyCode, timestamp, rate, open24Hour, diff, volume, marketCap, supply
    }

    required init(row: Row) {
        key = PairKey(coinCode: row[Columns.coinCode], currencyCode: row[Columns.currencyCode])
        timestamp = row[Columns.timestamp]
        rate = row[Columns.rate]
        open24Hour = row[Columns.open24Hour]
        diff = row[Columns.diff]
        volume = row[Columns.volume]
        marketCap = row[Columns.marketCap]
        supply = row[Columns.supply]

        super.init(row: row)
    }

    override open func encode(to container: inout PersistenceContainer) {
        container[Columns.coinCode] = key.coinCode
        container[Columns.currencyCode] = key.currencyCode
        container[Columns.timestamp] = timestamp
        container[Columns.rate] = rate
        container[Columns.open24Hour] = open24Hour
        container[Columns.diff] = diff
        container[Columns.volume] = volume
        container[Columns.marketCap] = marketCap
        container[Columns.supply] = supply
    }

}

extension MarketInfoRecord: CustomStringConvertible {

    var description: String {
        "MarketInfo [coinCode: \(key.coinCode); currencyCode: \(key.currencyCode); timestamp: \(timestamp); rate: \(rate); open24Hour: \(open24Hour); diff: \(diff)]"
    }

}
