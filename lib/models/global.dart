import '../entity/coininfo.dart';
import '../entity/k_line_entity.dart';

class Config {
  static int SHORT = 60;
  static int MED = 60 * 15;
  static int LONG = 60 * 60;

  static int BUYSCORE = 80;
  static int SELLSCORE = -80;
  static int BUYMSCORE = -20;
  static int SELLMSCORE = 20;
}

class G {
  static CoinInfo btc = CoinInfo();
  static CoinInfo eth = CoinInfo();
  static CoinInfo btc1 = CoinInfo();
  static CoinInfo eth1 = CoinInfo();
}

class PositionInfo {
  bool buy = true;
  double p = 0;
  late DateTime t;
  PositionInfo({buy, p, t}) {
    buy = buy;
    p = p;
    t = t;
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
  late MarketInfo? m;
  PositionInfo position = PositionInfo(buy: true, p: 0);
}
