import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../entity/coininfo.dart';
import '../entity/k_line_entity.dart';
import '../models/global.dart';
import '../utils/calcutil.dart';
import '../utils/data_util.dart';
import '../exif/exapi.dart';

//The REST baseurl for testnet is "https://testnet.binancefuture.com"
//The Websocket baseurl for testnet is "wss://stream.binancefuture.com"
class Collector {
  final String symbol;
  static const int TIMEWINDOW = 200;
  final int precision;
  final int _monitorDuration = 3600;
  late WebSocketChannel _channel;

  bool bRunning = false;

  int count = 0;
  double slotVol1m = 0;

  late String _klineSymbol;
  // late String _tradeSymbol;
  // late String _orderSymbol;

  late List<KLineEntity> kListShort;
  late List<KLineEntity> kListMed;
  late List<KLineEntity> kListLong;
  // OrderBookInfo? _ordbookInfo;
  // final List<TradeInfo> _trList = [];

  Collector({required this.symbol, required this.precision});

  Stream<MarketInfo?> run() async* {
    print('Target: $symbol');
    bRunning = true;
    _klineSymbol = '${symbol.toLowerCase()}@kline_1m';
    // _tradeSymbol = '${symbol.toLowerCase()}@aggTrade';

    kListShort = await BNCF.getKline(symbol, Config.SHORT);
    kListMed = await BNCF.getKline(symbol, Config.MED);
    kListLong = await BNCF.getKline(symbol, Config.LONG);
    Timer.periodic(
        Duration(milliseconds: 500 * (Config.SHORT + Random().nextInt(20))),
        (Timer t) async {
      // print('Timer Expiry! Running:$bRunning');
      if (!bRunning) {
        t.cancel();
        return;
      }
      kListMed = await BNCF.getKline(symbol, Config.MED);
      kListLong = await BNCF.getKline(symbol, Config.LONG);
      DataUtil.calculate(kListMed);
      DataUtil.calculate(kListLong);
    });
    print(
        '===================================================================');
    print('=== Monitor:$symbol precision:$precision');
    print('price:${kListMed!.last.close}');
    print('==================================================================');

    _channel = WebSocketChannel.connect(
        Uri.parse('wss://fstream.binance.com/stream?streams=$_klineSymbol'));
    int startTime = DateTime.now().millisecondsSinceEpoch;
    yield* _channel.stream.asyncMap((message) {
      // print('received!\n$message');
      Map<String, dynamic> jdata = jsonDecode(message);

      fillData(jdata);

      MarketInfo ds = MarketInfo(symbol: symbol)
        ..symbol = symbol
        ..kListShort = kListShort
        ..kListMed = kListMed
        ..kListLong = kListLong;
      // ..trList = _trList
      // ..ordbookInfo = _ordbookInfo;

      if (kListShort.last.time! > startTime + _monitorDuration * 1000) stop();
      return ds;
    });
  }

  void stop() {
    _channel.sink.close();
    bRunning = false;
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
    } else {
      print(
          'KNOWN FORMAT@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n $streamData');
    }
    // else if (type == _tradeSymbol) {
    //   double volscale = 2;
    //   TradeInfo _trdInfo = TradeInfo()
    //     ..id = kdata['a']
    //     ..buy = !kdata['m']
    //     ..price = double.parse(kdata['p'])
    //     ..vol = double.parse(kdata['q'])
    //     ..time = kdata['T'];
    //   if (_trList.isEmpty) {
    //     _trList.add(_trdInfo);
    //   } else if (_trList.last.id != _trdInfo.id) {
    //     _trList.add(_trdInfo);
    //     int lastTime = _trdInfo.time;

    //     _trList.removeWhere((element) {
    //       if (element.time < lastTime - TIMEWINDOW) {
    //         return true;
    //       } else {
    //         return false;
    //       }
    //     });

    //     // for (int i = 0; i < _trList.length; ++i) {
    //     //   _trdSummary.vol += _trList[i].buy ? _trList[i].vol : -_trList[i].vol;
    //     // }
    //     // _trdSummary.price = _trList.last.price - _trList[0].price;
    //     // _trdSummary.dur = TIMEWINDOW;
    //     // if (_trdSummary.vol.abs() >
    //     //     _kListShort.last.MA10Volume * volscale / (60000 / TIMEWINDOW)) {
    //     //   print(_trList.last.price.toStringAsFixed(2) +
    //     //       ' ' +
    //     //       _trdSummary.toString() +
    //     //       ' v:' +
    //     //       _kListShort.last.MA10Volume.toStringAsFixed(3) +
    //     //       ' ' +
    //     //       _trList.length.toString());
    //     //   _trList = [];
    //     // }
    //   }

    //   print(
    //       'T ${DateFormat('HHmmss:SSS').format(DateTime.fromMillisecondsSinceEpoch(_trList.last.time))},${_trList.last.price.toString()}');

    //   return;
    // }
  }

  static void printTr(List<TradeInfo> tr) {
    print('---------------------------');
    tr.forEach((element) {
      print(element.toString());
    });
    print('---------------------------END');
  }
}
