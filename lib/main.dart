import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradeinsight/exif/collector.dart';
import 'package:tradeinsight/veiws/charttable.dart';

import 'entity/coininfo.dart';
import 'exif/exapi.dart';
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
  late Stream<CoinInfo?> streamBTC;
  late Stream<CoinInfo?> streamETH;
  late Stream<CoinInfo?> streamBCH;
  late Stream<CoinInfo?> streamETC;
  @override
  Widget build(context) => Scaffold(
      body: Center(
        child: Obx(() {
          return !monitoring.value
              ? Column(children: [
                  Text('Waiting....'),
                  TextButton(
                      onPressed: () async {
                        monitoring.value = !monitoring.value;
                      },
                      child: Text('토글 API'))
                ])
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text("$count"),
                      Text("a $string"),
                      Text("a $btcstring"),
                      StreamBuilder<CoinInfo?>(
                          stream: collectorBTC.run(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                    ConnectionState.active ||
                                snapshot.data == null) {
                              return const CircularProgressIndicator();
                            } else {
                              return drawRow(snapshot.data!);
                            }
                          }),
                      StreamBuilder<CoinInfo?>(
                          stream: collectorETH.run(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                    ConnectionState.active ||
                                snapshot.data == null) {
                              return const CircularProgressIndicator();
                            } else {
                              return drawRow(snapshot.data!);
                            }
                          }),
                      StreamBuilder<CoinInfo?>(
                          stream: collectorBCH.run(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                    ConnectionState.active ||
                                snapshot.data == null) {
                              return const CircularProgressIndicator();
                            } else {
                              return drawRow(snapshot.data!);
                            }
                          }),
                      StreamBuilder<CoinInfo?>(
                          stream: collectorETC.run(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                    ConnectionState.active ||
                                snapshot.data == null) {
                              return const CircularProgressIndicator();
                            } else {
                              return drawRow(snapshot.data!);
                            }
                          }),
                      TextButton(
                          onPressed: () async {
                            monitoring.value = !monitoring.value;
                          },
                          child: Text('토글 API')),
                      TextButton(
                          onPressed: () async {
                            normalize.value = !normalize.value;
                          },
                          child: Text('노말라이즈 API')),
                      TextButton(
                          onPressed: () {
                            print('button press');
                            print('button press end');
                            // streamBTC = collectorBTC.run();
                            // streamBTC.listen((event) {
                            //   print('-----------------------------------------------');
                            //   print(collectorBTC.kListShort.last);
                            //   // print(collectorBTC.kListMed.la st);
                            //   // print(collectorBTC.kListLong.last);
                            //   btcstring(collectorBTC.kListShort.last.toString());
                            //   _iv.setPrice(collectorBTC.kListShort.last.close.toString());
                            // });

                            streamETH = collectorETH.run();
                            streamETH.listen((event) {
                              print(
                                  '-----------------------------------------------');
                              print(collectorETH.kListShort.last);
                              // print(collectorETH.kListMed.last);
                              // print(collectorETH.kListLong.last);
                            });
                            streamBCH = collectorBCH.run();
                            streamBCH.listen((event) {
                              print(
                                  '-----------------------------------------------');
                              print(collectorBCH.kListShort.last);
                              // print(collectorBTG.kListMed.last);
                              // print(collectorBTG.kListLong.last);
                            });
                            streamETC = collectorETC.run();
                            streamETC.listen((event) {
                              print(
                                  '-----------------------------------------------');
                              print(collectorETC.kListShort.last);
                              // print(collectorETC.kListMed.last);
                              // print(collectorETC.kListLong.last);
                            });
                          },
                          child: Text('스트림 시작 API')),
                      TextButton(
                          onPressed: () {
                            print('button press');
                            // collectorBTC.stop();
                            collectorETH.stop();
                            collectorBCH.stop();
                            collectorETC.stop();
                            print('button press end');
                          },
                          child: Text('스트림 종료 API')),
                    ]);
        }),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          count++;
          string.value = '$count $count';
        },
      ));

  Widget drawRow(CoinInfo k) {
    int len = k.kListShort!.length;
    double basePrice = normalize.value ? 1000 / k.kListShort!.last.close : 1;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pV(k.kListShort!.last.close),
      Row(
        children: [
          vV(k.kListShort![len - 5].macd! * basePrice),
          vV(k.kListShort![len - 4].macd! * basePrice),
          vV(k.kListShort![len - 3].macd! * basePrice),
          vV(k.kListShort![len - 2].macd! * basePrice),
          vV(k.kListShort![len - 1].macd! * basePrice),
          Text('||'),
          vV(k.kListShort!.last.k!),
          vV(k.kListShort!.last.d!),
          vV(k.kListShort!.last.j!),
        ],
      ),
      Row(
        children: [
          vV(k.kListMed![len - 5].macd! * basePrice),
          vV(k.kListMed![len - 4].macd! * basePrice),
          vV(k.kListMed![len - 3].macd! * basePrice),
          vV(k.kListMed![len - 2].macd! * basePrice),
          vV(k.kListMed![len - 1].macd! * basePrice),
          Text('||'),
          vV(k.kListMed!.last.k!),
          vV(k.kListMed!.last.d!),
          vV(k.kListMed!.last.j!),
        ],
      ),
      Row(
        children: [
          vV(k.kListLong![len - 5].macd! * basePrice),
          vV(k.kListLong![len - 4].macd! * basePrice),
          vV(k.kListLong![len - 3].macd! * basePrice),
          vV(k.kListLong![len - 2].macd! * basePrice),
          vV(k.kListLong![len - 1].macd! * basePrice),
          Text('||'),
          vV(k.kListLong!.last.k!),
          vV(k.kListLong!.last.d!),
          vV(k.kListLong!.last.j!),
        ],
      )
    ]);
  }

  Widget pV(double p) {
    //price View
    const double boxWidth = 200;
    return Padding(
        padding: EdgeInsets.all(4),
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
}
