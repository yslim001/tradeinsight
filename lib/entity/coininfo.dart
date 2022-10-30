import 'package:intl/intl.dart';

import 'k_line_entity.dart';

class OrderBookInfo {
  late double bPrice;
  late double bVolSum;
  late double sPrice;
  late double sVolSum;
}

class TradeInfo {
  late int id;
  late int time;
  late bool buy;
  late double price;
  late double vol;

  @override
  String toString() {
    return '$time ${buy ? 'B' : 'S'} p:$price v:${vol.toStringAsFixed(2)}';
  }

  String toLog() {
    return '${DateFormat('HHmmss:SSS').format(DateTime.fromMillisecondsSinceEpoch(time))},${buy ? 'B' : 'S'},$price,${vol.toStringAsFixed(2)}';
  }
}

class CoinInfo {
  late String symbol;
  List<KLineEntity>? kListShort;
  List<KLineEntity>? kListMed;
  List<KLineEntity>? kListLong;
  OrderBookInfo? ordbookInfo;
  List<TradeInfo>? trList;

  CoinInfo({required String symbol}) {
    symbol = symbol;
  }
}
