import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../entity/coininfo.dart';
import '../entity/k_line_entity.dart';
import '../utils/calcutil.dart';
import '../utils/data_util.dart';
import '../exif/exapi.dart';

//The REST baseurl for testnet is "https://testnet.binancefuture.com"
//The Websocket baseurl for testnet is "wss://stream.binancefuture.com"
class Collector {
  final String symbol;
  static const int TIMEWINDOW = 200;
  static const int shortTerm = 60;
  static const int medTerm = 60 * 15;
  static const int longTerm = 60 * 60;
  final int precision;
  final int _monitorDuration = 600;
  late WebSocketChannel _channel;

  late Timer _fetchTimer;

  int count = 0;
  double slotVol1m = 0;

  late String _klineSymbol;
  late String _tradeSymbol;
  late String _orderSymbol;

  late List<KLineEntity> kListShort;
  late List<KLineEntity> kListMed;
  late List<KLineEntity> kListLong;
  OrderBookInfo? _ordbookInfo;
  final List<TradeInfo> _trList = [];

  Collector({required this.symbol, required this.precision});

  Stream<CoinInfo?> run() async* {
    print('Target:$symbol');
    _klineSymbol = '${symbol.toLowerCase()}@kline_1m';
    _tradeSymbol = '${symbol.toLowerCase()}@aggTrade';

    kListShort = await BNCF.getKline(symbol, shortTerm);
    kListMed = await BNCF.getKline(symbol, medTerm);
    kListLong = await BNCF.getKline(symbol, longTerm);
    _fetchTimer = Timer.periodic(
        Duration(milliseconds: 500 * (shortTerm + Random().nextInt(20))),
        (Timer t) async {
      kListMed = await BNCF.getKline(symbol, medTerm);
      kListLong = await BNCF.getKline(symbol, longTerm);
      DataUtil.calculate(kListMed);
      DataUtil.calculate(kListLong);
    });
    print(
        '===================================================================');
    print('=== Monitor:$symbol precision:$precision');
    print('price:${kListMed!.last.close}');
    print('==================================================================');

    _channel = WebSocketChannel.connect(Uri.parse(
        'wss://fstream.binance.com/stream?streams=$_tradeSymbol/$_klineSymbol'));
    int startTime = DateTime.now().millisecondsSinceEpoch;
    yield* _channel.stream.asyncMap((message) {
      // print('received!\n$message');
      Map<String, dynamic> jdata = jsonDecode(message);

      fillData(jdata);

      if (_trList.isEmpty ||
          kListShort == null ||
          kListMed == null ||
          kListLong == null) {
        return null;
      }
      CoinInfo ds = CoinInfo(symbol: symbol)
        ..symbol = symbol
        ..kListShort = kListShort
        ..kListMed = kListMed
        ..kListLong = kListLong
        ..trList = _trList
        ..ordbookInfo = _ordbookInfo;

      if (_trList.last.time > startTime + _monitorDuration * 1000) stop();
      return ds;
    });
  }

  void stop() {
    _channel.sink.close();
    _fetchTimer.cancel();
  }

  void fillData(Map<String, dynamic> streamData) {
    String type = streamData['stream'];
    var kdata = streamData['data'];
    if (type == _klineSymbol) {
      KLineEntity? k = BNCF.getKEntityWebSocket(kdata);
      if (kListShort.last.time == k.time) {
        kListShort.removeLast();
        kListShort.add(k);
      } else {
        kListShort.removeAt(0);
        kListShort.add(k);
      }
      DataUtil.calculate(kListShort);
      // print(
      //     'K ${DateFormat('HHmmss:SSS').format(DateTime.fromMillisecondsSinceEpoch(kListShort.last.time))},${kListShort.last.close.toString()}');
    } else if (type == _tradeSymbol) {
      double volscale = 2;
      TradeInfo _trdInfo = TradeInfo()
        ..id = kdata['a']
        ..buy = !kdata['m']
        ..price = double.parse(kdata['p'])
        ..vol = double.parse(kdata['q'])
        ..time = kdata['T'];
      if (_trList.isEmpty) {
        _trList.add(_trdInfo);
      } else if (_trList.last.id != _trdInfo.id) {
        _trList.add(_trdInfo);
        int lastTime = _trdInfo.time;

        _trList.removeWhere((element) {
          if (element.time < lastTime - TIMEWINDOW) {
            return true;
          } else {
            return false;
          }
        });

        // for (int i = 0; i < _trList.length; ++i) {
        //   _trdSummary.vol += _trList[i].buy ? _trList[i].vol : -_trList[i].vol;
        // }
        // _trdSummary.price = _trList.last.price - _trList[0].price;
        // _trdSummary.dur = TIMEWINDOW;
        // if (_trdSummary.vol.abs() >
        //     _kListShort.last.MA10Volume * volscale / (60000 / TIMEWINDOW)) {
        //   print(_trList.last.price.toStringAsFixed(2) +
        //       ' ' +
        //       _trdSummary.toString() +
        //       ' v:' +
        //       _kListShort.last.MA10Volume.toStringAsFixed(3) +
        //       ' ' +
        //       _trList.length.toString());
        //   _trList = [];
        // }
      }

      // print(
      //     'T ${DateFormat('HHmmss:SSS').format(DateTime.fromMillisecondsSinceEpoch(_trList.last.time))},${_trList.last.price.toString()}');

      return;
    } else if (type == _orderSymbol) {
      // _ordbookInfo = OrderBookInfo();
      // List tmp = kdata['b'];
      // _ordbookInfo.bPrice = double.parse(tmp[0][0]);
      // _ordbookInfo.bVolSum = 0;
      // tmp.forEach((element) {
      //   _ordbookInfo.bVolSum += double.parse(element[1]);
      // });
      // tmp = kdata['a'];
      // _ordbookInfo.sPrice = double.parse(tmp[0][0]);
      // _ordbookInfo.sVolSum = 0;
      // tmp.forEach((element) {
      //   _ordbookInfo.sVolSum += double.parse(element[1]);
      // });
    } else {
      print(
          'KNOWN FORMAT@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n $streamData');
    }
  }

  static void printTr(List<TradeInfo> tr) {
    print('---------------------------');
    tr.forEach((element) {
      print(element.toString());
    });
    print('---------------------------END');
  }
}
