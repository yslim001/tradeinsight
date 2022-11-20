import 'package:intl/intl.dart';

import '../entity/coininfo.dart';
import '../entity/k_line_entity.dart';

class Config {
  static int TARGET_COIN_NUM = 60;
  static int SHORT = 60;
  static int MED = 60 * 15;
  static int LONG = 60 * 60;

  static int BUYSCORE = 80;
  static int SELLSCORE = -80;
  static int BuyCloseScore = -40;
  static int SellCloseScore = 40;
}

class Targets {
  static var coins = ['bchusdt', 'etcusdt', 'ltcusdt'];
}

class M {
  static MarketInfo? btc;
  static MarketInfo? eth;
  static List<MarketInfo> targets = [];

  M() {
    if (targets.isEmpty) {
      for (var s in Targets.coins) {
        targets.add(MarketInfo(symbol: s));
      }
    }
  }
}

class PositionInfo {
  int index = -1;
  bool buy = true;
  double p = 0;
  late DateTime t;
  PositionInfo({symbol, buy, p, t});
  @override
  String toString() {
    if (index < 0) {
      return 'PosInfo: No Position';
    } else {
      return '${M.targets[index].symbol} ${buy ? '롱' : '숏'} \t$p ';
    }
  }
}

class TradeSummary {
  int index = -1;
  bool buy = true;
  late DateTime startt;
  double startp = 0;
  late DateTime endt;
  double endp = 0;

  double per = 0;
  @override
  String toString() {
    if (index < 0) {
      return 'TradeInfo: No Trades';
    } else {
      return 'Trade::${M.targets[index].symbol} ${buy ? '롱' : '숏'} \t${per.toStringAsFixed(2)}\n${DateFormat('dd)HH:mm:ss').format(startt)}-${DateFormat('HH:mm:ss').format(endt)} [${startp.toStringAsFixed(2)} ~ ${endp.toStringAsFixed(2)}]';
    }
  }
}

class MarketInfo {
  String symbol = '';
  List<KLineEntity>? kListShort;
  List<KLineEntity>? kListMed;
  List<KLineEntity>? kListLong;
  OrderBookInfo? ordbookInfo;
  List<TradeInfo>? trList;

  MarketInfo({required this.symbol});
}

class CoinInfo {
  late MarketInfo? m;
  PositionInfo position = PositionInfo(buy: true, p: 0);
}
