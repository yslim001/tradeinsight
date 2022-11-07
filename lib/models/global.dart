import '../entity/coininfo.dart';
import '../entity/k_line_entity.dart';

class G {
  static CoinInfo btc = CoinInfo();
  static CoinInfo eth = CoinInfo();
  static CoinInfo bch = CoinInfo();
  static CoinInfo etc = CoinInfo();
}

class PositionInfo {
  bool buy = true;
  double p = 0;
  PositionInfo({buy, p}) {
    buy = buy;
    p = p;
  }
}

class MarketInfo {
  late String symbol;
  List<KLineEntity>? kListShort;
  List<KLineEntity>? kListMed;
  List<KLineEntity>? kListLong;
  OrderBookInfo? ordbookInfo;
  List<TradeInfo>? trList;

  MarketInfo({required String symbol}) {
    symbol = symbol;
  }
}

class CoinInfo {
  MarketInfo? m;
  PositionInfo position = PositionInfo(buy: true, p: 0);
}
