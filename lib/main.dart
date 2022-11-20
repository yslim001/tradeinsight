import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tradeinsight/exif/collector.dart';
import 'package:tradeinsight/src/algorithm.dart';

import 'models/global.dart';

var collectorBTC = Collector(symbol: 'btcusdt', precision: 2);
var collectorETH = Collector(symbol: 'ethusdt', precision: 2);
var collectorCoins = <Collector>[];

void main() {
  M();
  AlgoMngr();
  for (int i = 0; i < M.targets.length; ++i) {
    collectorCoins.add(Collector(symbol: M.targets[i].symbol, precision: 2));
  }
  runApp(MaterialApp(home: Home2()));
}

class Home2 extends StatelessWidget {
  var bRunning = false.obs;
  var btcPrice = '1111'.obs;
  var calcScore = '1111'.obs;
  var tmpList = <Overview>[].obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      onPressed: () {
                        if (bRunning.value) {
                          collectorBTC.stop();
                          collectorETH.stop();
                          for (var c in collectorCoins) {
                            c.stop();
                          }
                          AlgoMngr.reset();
                        } else {
                          collectorBTC.run().listen((event) {
                            M.btc = event;
                            if (event != null) {
                              btcPrice.value =
                                  '${event.kListShort!.last.close.toStringAsFixed(2)}  \t${event.kListShort!.last.macd.toStringAsFixed(2)}';
                              tmpList.value = AlgoMngr.refresh();
                            }
                          });
                          collectorETH.run().listen((event) {
                            if (event != null) {
                              M.eth = event;
                              tmpList.value = AlgoMngr.refresh();
                            }
                          });
                          for (int i = 0; i < collectorCoins.length; ++i) {
                            collectorCoins[i].run().listen((event) {
                              if (event != null) {
                                M.targets[i] = event;
                                tmpList.value = AlgoMngr.refresh();
                              }
                            });
                          }
                        }
                        bRunning.value = !bRunning.value;
                      },
                      icon: Obx(() => Icon(
                          bRunning.value ? Icons.stop : Icons.play_arrow))),
                ),
                Obx(() => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(btcPrice.value),
                    )),
              ],
            ),
            Row(
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                        onPressed: () {
                          tmpList.value = AlgoMngr.refresh();
                          // tmpList.add(tmpList.length * 2);
                          // tmpList.removeWhere((element) => true);
                          // tmpList.addAll(AlgoMngr.summaries);
                          // tmpList.value = AlgoMngr.overviews;
                        },
                        icon: Icon(Icons.calculate)))
              ],
            ),
            Obx((() => Expanded(
                  child: ListView.separated(
                    itemCount: tmpList.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          print('tap $index');
                          showDialog(
                              context: context,
                              builder: (c) {
                                return AlertDialog(
                                  title: Text(tmpList[index].name),
                                  scrollable: true,
                                  content: SizedBox(
                                    width: 300,
                                    height: 300,
                                    child: ListView.separated(
                                        shrinkWrap: true,
                                        itemBuilder: ((context, ii) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${M.targets[AlgoMngr.algos[index].summary[ii].index].symbol.toUpperCase()} ${AlgoMngr.algos[index].summary[ii].buy ? '롱' : '숏'}  ${AlgoMngr.algos[index].summary[ii].per.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AlgoMngr
                                                                .algos[index]
                                                                .summary[ii]
                                                                .per >
                                                            0
                                                        ? Colors.green
                                                        : Colors.red),
                                              ),
                                              Text(
                                                  '${DateFormat('dd)HH:mm:ss').format(AlgoMngr.algos[index].summary[ii].startt)}~${DateFormat('HH:mm:ss').format(AlgoMngr.algos[index].summary[ii].endt)}')
                                            ],
                                          );
                                        }),
                                        separatorBuilder: ((context, index) =>
                                            Divider(
                                              height: 4,
                                            )),
                                        itemCount: AlgoMngr
                                            .algos[index].summary.length),
                                  ),
                                );
                              });
                        },
                        child: ListTile(
                            title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                    width: 80,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 2, bottom: 2),
                                      child: Text(tmpList[index].name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    )),
                                Text(AlgoMngr.algos[index].position.p == 0
                                    ? ''
                                    : '${M.targets[AlgoMngr.algos[index].position.index].symbol} ${AlgoMngr.algos[index].position.buy ? '롱' : '숏'}  ${((AlgoMngr.algos[index].position.buy ? 1 : -1) * ((M.targets[AlgoMngr.algos[index].position.index].kListShort!.last.close - AlgoMngr.algos[index].position.p) * 100 / AlgoMngr.algos[index].position.p)).toStringAsFixed(2)}%')
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: Text('승:${tmpList[index].win}',
                                      style: TextStyle(color: Colors.green)),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: Text('패:${tmpList[index].lose}',
                                      style: TextStyle(color: Colors.red)),
                                ),
                                Text(
                                    '수익:${tmpList[index].per.toStringAsFixed(2)}'),
                              ],
                            ),
                          ],
                        )),
                      );
                    },
                  ),
                )))
          ],
        )));
  }
}
