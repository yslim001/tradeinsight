import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradeinsight/exif/collector.dart';
import 'package:tradeinsight/veiws/charttable.dart';

import 'entity/coininfo.dart';
import 'exif/exapi.dart';
import 'models/global.dart';
import 'utils/strutil.dart';

void main() => runApp(MaterialApp(home: Home()));

class Home extends StatelessWidget {
  var count = 0.obs;
  var string = ''.obs;
  var btcstring = ''.obs;
  var monitoring = true.obs;
  var normalize = true.obs;
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
                          child: const Text('토글 API'))
                    ])
              : SingleChildScrollView(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      StreamBuilder<CoinInfo?>(
                          stream: collectorBTC.run(),
                          builder: (context, snapshot) {
                            return insightView(G.btc = snapshot.data);
                          }),
                      const Divider(
                        thickness: 4,
                      ),
                      StreamBuilder<CoinInfo?>(
                          stream: collectorETH.run(),
                          builder: (context, snapshot) {
                            return insightView(G.eth = snapshot.data);
                          }),
                      const Divider(
                        thickness: 4,
                      ),
                      StreamBuilder<CoinInfo?>(
                          stream: collectorBCH.run(),
                          builder: (context, snapshot) {
                            return insightView(G.bch = snapshot.data);
                          }),
                      const Divider(
                        thickness: 4,
                      ),
                      StreamBuilder<CoinInfo?>(
                          stream: collectorETC.run(),
                          builder: (context, snapshot) {
                            return insightView(G.etc = snapshot.data);
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
    return Column(children: [kdjRow(k), macdRow(k)]);
  }

  Widget kdjRow(CoinInfo? k) {
    if (k == null) return const Text('Waiting...');
    return Row(
      children: [
        Text(k.symbol.toUpperCase().replaceFirst('USDT', '')),
        pV(k.kListShort!.last.close),
        const Text(' S'),
        vV(k.kListShort!.last.j!),
        const Text(' M'),
        vV(k.kListMed!.last.j!),
        const Text(' L'),
        vV(k.kListLong!.last.j!),
      ],
    );
  }

  Widget macdRow(CoinInfo? k) {
    if (k == null) return const Text('Waiting...');
    int len = k.kListShort!.length;
    double basePrice = normalize.value ? 1000 / k.kListShort!.last.close : 1;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          vV2(
              k.kListShort![len - 5].macd! * basePrice,
              (k.kListShort![len - 5].macd! - k.kListShort![len - 6].macd!) *
                  100 /
                  k.kListShort![len - 5].macd!),
          vV2(
              k.kListShort![len - 4].macd! * basePrice,
              (k.kListShort![len - 4].macd! - k.kListShort![len - 5].macd!) *
                  100 /
                  k.kListShort![len - 5].macd!),
          vV2(
              k.kListShort![len - 3].macd! * basePrice,
              (k.kListShort![len - 3].macd! - k.kListShort![len - 4].macd!) *
                  100 /
                  k.kListShort![len - 3].macd!),
          vV2(
              k.kListShort![len - 2].macd! * basePrice,
              (k.kListShort![len - 2].macd! - k.kListShort![len - 3].macd!) *
                  100 /
                  k.kListShort![len - 2].macd!),
          vV2(
              k.kListShort![len - 1].macd! * basePrice,
              (k.kListShort![len - 1].macd! - k.kListShort![len - 2].macd!) *
                  100 /
                  k.kListShort![len - 1].macd!),
        ],
      ),
      Row(
        children: [
          vV2(
              k.kListMed![len - 5].macd! * basePrice,
              (k.kListMed![len - 5].macd! - k.kListMed![len - 6].macd!) *
                  100 /
                  k.kListMed![len - 5].macd!),
          vV2(
              k.kListMed![len - 4].macd! * basePrice,
              (k.kListMed![len - 4].macd! - k.kListMed![len - 5].macd!) *
                  100 /
                  k.kListMed![len - 5].macd!),
          vV2(
              k.kListMed![len - 3].macd! * basePrice,
              (k.kListMed![len - 3].macd! - k.kListMed![len - 4].macd!) *
                  100 /
                  k.kListMed![len - 3].macd!),
          vV2(
              k.kListMed![len - 2].macd! * basePrice,
              (k.kListMed![len - 2].macd! - k.kListMed![len - 3].macd!) *
                  100 /
                  k.kListMed![len - 2].macd!),
          vV2(
              k.kListMed![len - 1].macd! * basePrice,
              (k.kListMed![len - 1].macd! - k.kListMed![len - 2].macd!) *
                  100 /
                  k.kListMed![len - 1].macd!),
        ],
      ),
      Row(
        children: [
          vV2(
              k.kListLong![len - 5].macd! * basePrice,
              (k.kListLong![len - 5].macd! - k.kListLong![len - 6].macd!) *
                  100 /
                  k.kListLong![len - 5].macd!),
          vV2(
              k.kListLong![len - 4].macd! * basePrice,
              (k.kListLong![len - 4].macd! - k.kListLong![len - 5].macd!) *
                  100 /
                  k.kListLong![len - 5].macd!),
          vV2(
              k.kListLong![len - 3].macd! * basePrice,
              (k.kListLong![len - 3].macd! - k.kListLong![len - 4].macd!) *
                  100 /
                  k.kListLong![len - 3].macd!),
          vV2(
              k.kListLong![len - 2].macd! * basePrice,
              (k.kListLong![len - 2].macd! - k.kListLong![len - 3].macd!) *
                  100 /
                  k.kListLong![len - 2].macd!),
          vV2(
              k.kListLong![len - 1].macd! * basePrice,
              (k.kListLong![len - 1].macd! - k.kListLong![len - 2].macd!) *
                  100 /
                  k.kListLong![len - 1].macd!),
        ],
      )
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
