import '../entity/k_entity.dart';

class KLineEntity extends KEntity {
  late double open;
  late double high;
  late double low;
  late double close;
  late double vol;
  late double? amount;
  double? change;
  double? ratio;
  int? time;

  KLineEntity.fromCustom({
    this.amount,
    required this.open,
    required this.close,
    this.change,
    this.ratio,
    required this.time,
    required this.high,
    required this.low,
    required this.vol,
  });

  KLineEntity.fromJson(Map<String, dynamic> json) {
    open = json['open']?.toDouble() ?? 0;
    high = json['high']?.toDouble() ?? 0;
    low = json['low']?.toDouble() ?? 0;
    close = json['close']?.toDouble() ?? 0;
    vol = json['vol']?.toDouble() ?? 0;
    amount = json['amount']?.toDouble();
    int? tempTime = json['time']?.toInt();
    //兼容火币数据
    if (tempTime == null) {
      tempTime = json['id']?.toInt() ?? 0;
      tempTime = tempTime! * 1000;
    }
    time = tempTime;
    ratio = json['ratio']?.toDouble();
    change = json['change']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time'] = this.time;
    data['open'] = this.open;
    data['close'] = this.close;
    data['high'] = this.high;
    data['low'] = this.low;
    data['vol'] = this.vol;
    data['amount'] = this.amount;
    data['ratio'] = this.ratio;
    data['change'] = this.change;
    return data;
  }

  @override
  String toString() {
    return 'Model{time: $time, close: ${close.toStringAsFixed(2)}, macd: ${macd?.toStringAsFixed(2)} , KDJ j: ${k?.toStringAsFixed(2)} ${d?.toStringAsFixed(2)} ${j?.toStringAsFixed(2)} }';
//  return 'MarketModel{open: $open, high: $high, low: $low, close: $close, vol: $vol, time: $time, amount: $amount, ratio: $ratio, change: $change}';
  }
}
