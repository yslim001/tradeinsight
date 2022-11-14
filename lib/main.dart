import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradeinsight/exif/collector.dart';
import 'package:tradeinsight/veiws/charttable.dart';

import 'entity/coininfo.dart';
import 'entity/k_line_entity.dart';
import 'exif/exapi.dart';
import 'exif/tradeapi.dart';
import 'models/global.dart';
import 'src/algo.dart';
import 'utils/strutil.dart';

void main() => runApp(MaterialApp(home: Home()));

class Home extends StatelessWidget {
  var count = 0.obs;
  var string = ''.obs;
  var btcstring = ''.obs;
  var monitoring = true.obs;
  var normalize = false.obs;
  var collectorBTC = Collector(symbol: 'btcusdt', precision: 2);
  var collectorBCH = Collector(symbol: 'bchusdt', precision: 2);
  var collectorETH = Collector(symbol: 'ethusdt', precision: 2);
  var collectorETC = Collector(symbol: 'etcusdt', precision: 2);
  @override
  Widget build(context) => Scaffold(
      body: Center(
        child: Obx(() {
          return !monitoring.value
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      const Text('Waiting....'),
                      TextButton(
                          onPressed: () async {
                            monitoring.value = !monitoring.value;
                          },
                          child: const Text('토글 API')),
                      TextButton(
                          onPressed: () {
                            Trade.test();
                          },
                          child: const Text('트레이드 API'))
                    ])
              : SingleChildScrollView(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      StreamBuilder<MarketInfo?>(
                          stream: collectorBTC.run(),
                          builder: (context, snapshot) {
                            G.btc.m = snapshot.data;
                            return insightView(G.btc);
                          }),
                      const Divider(
                        thickness: 4,
                      ),
                      StreamBuilder<MarketInfo?>(
                          stream: collectorETH.run(),
                          builder: (context, snapshot) {
                            G.eth.m = snapshot.data;
                            if (G.eth.m != null) var score = Algo.calculate();

                            return insightView(G.eth);
                          }),
                      const Divider(
                        thickness: 4,
                      ),
                      StreamBuilder<MarketInfo?>(
                          stream: collectorBCH.run(),
                          builder: (context, snapshot) {
                            G.btc1.m = snapshot.data;
                            return insightView(G.btc1);
                          }),
                      const Divider(
                        thickness: 4,
                      ),
                      StreamBuilder<MarketInfo?>(
                          stream: collectorETC.run(),
                          builder: (context, snapshot) {
                            G.eth1.m = snapshot.data;
                            return insightView(G.eth1);
                          }),
                      TextButton(
                          onPressed: () async {
                            monitoring.value = !monitoring.value;
                            collectorBTC.stop();
                            collectorETH.stop();
                            collectorETC.stop();
                            collectorBCH.stop();
                          },
                          child: const Text('토글 API')),
                      TextButton(
                          onPressed: () async {
                            normalize.value = !normalize.value;
                          },
                          child: const Text('노말라이즈 API')),
                    ]));
        }),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          count++;
          string.value = '$count $count';
        },
      ));

  Widget insightView(CoinInfo? k) {
    if (k == null) return const Text('Waiting...');
    return Column(children: [tradeRow(k), kdjRow(k.m), macdRow(k.m)]);
  }

  Widget tradeRow(CoinInfo? traget) {
    if (traget!.m == null) return const Text('Waiting...');
    MarketInfo mi = traget.m as MarketInfo;
    return Row(
      children: [
        Text(traget.m!.symbol.toUpperCase().replaceFirst('USDT', ' ')),
        traget.position.p == 0
            ? Row(children: [
                TextButton(
                    onPressed: () {
                      traget.position.p = mi.kListShort!.last.close;
                      traget.position.buy = true;
                      traget.position.t = DateTime.now();
                    },
                    child: Text(
                      'BUY',
                      style: TextStyle(backgroundColor: Colors.green),
                    )),
                TextButton(
                    onPressed: () {
                      traget.position.p = mi.kListShort!.last.close;
                      traget.position.buy = false;
                      traget.position.t = DateTime.now();
                    },
                    child: Text('SELL',
                        style: TextStyle(backgroundColor: Colors.red)))
              ])
            : Row(children: [
                Text(U.pr(traget.position.p),
                    style: TextStyle(
                        backgroundColor:
                            traget.position.buy ? Colors.green : Colors.red)),
                TextButton(
                    onPressed: () {
                      traget.position.p = 0;
                    },
                    child: Text(' Close',
                        style: TextStyle(backgroundColor: Colors.grey)))
              ]),
        Text(traget.position.p == 0
            ? ''
            : '  ${traget.position.buy ? ((mi.kListShort!.last.close - traget.position.p) * 100 / traget.position.p).toStringAsFixed(2) : ((traget.position.p - mi.kListShort!.last.close) * 100 / traget.position.p).toStringAsFixed(2)}')
      ],
    );
  }

  Widget kdjRow(MarketInfo? k) {
    if (k == null) return const Text('Waiting...');
    return Row(
      children: [
        pV(k.kListShort!.last.close),
        const Text('KDJ S'),
        vV(k.kListShort!.last.j!),
        const Text(' M'),
        vV(k.kListMed!.last.j!),
        const Text(' L'),
        vV(k.kListLong!.last.j!),
      ],
    );
  }

  Widget macd1Row(List<KLineEntity> e) {
    int len = e.length;
    double basePrice = normalize.value ? 1000 / e.last.close : 1;
    return Row(
      children: [
        vV2(e[len - 6].macd! * basePrice,
            (e[len - 6].macd! - e[len - 7].macd!) * 100 / e[len - 6].macd!),
        vV2(e[len - 5].macd! * basePrice,
            (e[len - 5].macd! - e[len - 6].macd!) * 100 / e[len - 5].macd!),
        vV2(e[len - 4].macd! * basePrice,
            (e[len - 4].macd! - e[len - 5].macd!) * 100 / e[len - 5].macd!),
        vV2(e[len - 3].macd! * basePrice,
            (e[len - 3].macd! - e[len - 4].macd!) * 100 / e[len - 3].macd!),
        vV2(e[len - 2].macd! * basePrice,
            (e[len - 2].macd! - e[len - 3].macd!) * 100 / e[len - 2].macd!),
        vV2(e[len - 1].macd! * basePrice,
            (e[len - 1].macd! - e[len - 2].macd!) * 100 / e[len - 1].macd!),
      ],
    );
  }

  Widget macdRow(MarketInfo? k) {
    if (k == null) return const Text('Waiting...');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      macd1Row(k.kListShort!),
      macd1Row(k.kListMed!),
      macd1Row(k.kListLong!),
    ]);
  }

  Widget pV(double p) {
    //price View
    const double boxWidth = 200;
    return Padding(
        padding: const EdgeInsets.all(4),
        child: Text(
          U.pr(p),
        ));
    // return SizedBox(width: boxWidth, child: Center(child: Text(U.pr(p))));
  }

  Widget vV(double p) {
    //value View
    const double boxWidth = 50;
    return SizedBox(
        width: boxWidth, child: Center(child: Text(p.toStringAsFixed(2))));
  }

  Widget vV2(double p, double per) {
    //value View
    const double boxWidth = 50;
    return SizedBox(
        width: boxWidth,
        child: Center(
            child: Column(children: [
          Text(p.toStringAsFixed(2)),
          Text(
            per.toStringAsFixed(2),
            style: TextStyle(
                color: per > 0 ? Colors.green : Colors.red, fontSize: 10),
          )
        ])));
  }
}
