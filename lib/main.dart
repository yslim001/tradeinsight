import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradeinsight/exif/collector.dart';
import 'package:tradeinsight/veiws/charttable.dart';

import 'entity/coininfo.dart';
import 'exif/exapi.dart';

void main() => runApp(MaterialApp(home: Home()));

class Home extends StatelessWidget {
  var count = 0.obs;
  var string = ''.obs;
  var btcstring = ''.obs;
  var collectorBTC = Collector(symbol: 'btcusdt', precision: 2);
  var collectorBCH = Collector(symbol: 'bchusdt', precision: 2);
  var collectorETH = Collector(symbol: 'ethusdt', precision: 2);
  var collectorETC = Collector(symbol: 'etcusdt', precision: 2);
  late Stream<CoinInfo?> streamBTC;
  late Stream<CoinInfo?> streamETH;
  late Stream<CoinInfo?> streamBCH;
  late Stream<CoinInfo?> streamETC;
  late var _dt;
  late InsightView _iv;
  @override
  Widget build(context) => Scaffold(
      body: Center(
        child: Obx(() {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Text("$count"),
            Text("a $string"),
            Text("a $btcstring"),
            TextButton(
                onPressed: () async {
                  print('button press');
                  await BNCF.getKline('btcusdt', 60);
                  print('button press end');
                },
                child: Text('K라인 얻기 API')),
            TextButton(
                onPressed: () {
                  print('button press');
                  print('button press end');
                  streamBTC = collectorBTC.run();
                  streamBTC.listen((event) {
                    print('-----------------------------------------------');
                    print(collectorBTC.kListShort.last);
                    // print(collectorBTC.kListMed.la st);
                    // print(collectorBTC.kListLong.last);
                    btcstring(collectorBTC.kListShort.last.toString());
                    _iv.setPrice(collectorBTC.kListShort.last.close.toString());
                  });

                  streamETH = collectorETH.run();
                  streamETH.listen((event) {
                    print('-----------------------------------------------');
                    print(collectorETH.kListShort.last);
                    // print(collectorETH.kListMed.last);
                    // print(collectorETH.kListLong.last);
                  });
                  streamBCH = collectorBCH.run();
                  streamBCH.listen((event) {
                    print('-----------------------------------------------');
                    print(collectorBCH.kListShort.last);
                    // print(collectorBTG.kListMed.last);
                    // print(collectorBTG.kListLong.last);
                  });
                  streamETC = collectorETC.run();
                  streamETC.listen((event) {
                    print('-----------------------------------------------');
                    print(collectorETC.kListShort.last);
                    // print(collectorETC.kListMed.last);
                    // print(collectorETC.kListLong.last);
                  });
                },
                child: Text('스트림 시작 API')),
            TextButton(
                onPressed: () {
                  print('button press');
                  collectorBTC.stop();
                  collectorETH.stop();
                  collectorBCH.stop();
                  // collectorETC.stop();
                  print('button press end');
                },
                child: Text('스트림 종료 API')),
            _iv = InsightView(),
            _dt = DataTable(columns: const [
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('MACD')),
              DataColumn(label: Text('KDJ-J'))
            ], rows: [
              DataRow(
                cells: [
                  DataCell(Text(btcstring.value)),
                  DataCell(Text(btcstring.value)),
                  DataCell(Text(btcstring.value))
                ],
              ),
              DataRow(
                cells: [
                  DataCell(Text(btcstring.value)),
                  DataCell(Text(btcstring.value)),
                  DataCell(Text(btcstring.value))
                ],
              )
            ])
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
}
