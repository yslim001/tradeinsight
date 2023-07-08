import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';

import 'exif/collector.dart';
import 'models/global.dart';
import 'src/algorithm.dart';
import 'utils/strutil.dart';

var collectorBTC = Collector(symbol: 'btcusdt', precision: 2);
var collectorETH = Collector(symbol: 'ethusdt', precision: 2);
var collectorCoins = <Collector>[];

void main() {
  runApp(const ExampleApp());
}

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  int _eventCount = 0;

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;

    // You can use the getData function to get the stored data.
    final customData =
        await FlutterForegroundTask.getData<String>(key: 'customData');
    print('customData: $customData');

    M();
    AlgoMngr();
    collectorBTC = Collector(symbol: 'btcusdt', precision: 2);
    collectorETH = Collector(symbol: 'ethusdt', precision: 2);
    collectorCoins = <Collector>[];
    for (var c in M.targets) {
      collectorCoins.add(Collector(symbol: c.symbol, precision: 2));
    }

    collectorBTC.run().listen((event) async {
      // print('BTC LISTENER ~~~~~~~~~~~~~~~~~~~~~~ ~~~~~~~${event.toString()}');
      // print('listen BTC2:' + M.btc.toString());
      if (event != null) {
        M.btc = event;
        AlgoMngr.refresh();

        // sendPort?.send(getMap(M.btc));
        sendPort?.send(buildViewData());
      }
    });
    collectorETH.run().listen((event) {
      // print('listen BTC4:' + M.btc.toString());
      if (event != null) {
        M.eth = event;
        AlgoMngr.refresh();
      }
    });
    for (int i = 0; i < collectorCoins.length; ++i) {
      collectorCoins[i].run().listen((event) {
        if (event != null) {
          M.targets[i] = event;
          AlgoMngr.refresh();
        }
      });
    }
  }

  // Called every [interval] milliseconds in [ForegroundTaskOptions].
  @override
  Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    FlutterForegroundTask.updateService(
      notificationTitle: 'MyTaskHandler',
      notificationText: 'bitprice: ',
    );

    // Send data to the main isolate.
    sendPort?.send(_eventCount);

    _eventCount++;
  }

  // Called when the notification button on the Android platform is pressed.
  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print('onDestroy');
    collectorBTC.stop();
    collectorETH.stop();
    for (var c in collectorCoins) {
      c.stop();
    }
    AlgoMngr.reset();
  }

  // Called when the notification button on the Android platform is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed >> $id');
  }

  // Called when the notification itself on the Android platform is pressed.
  //
  // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
  // this function to be called.
  @override
  void onNotificationPressed() {
    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const ExamplePage(),
        '/resume-route': (context) => const ResumeRoutePage(),
      },
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  ReceivePort? _receivePort;
  double prc = 0.11;
  List<double> prcList = <double>[];

  Future<void> _requestPermissionForAndroid() async {
    if (!Platform.isAndroid) {
      return;
    }

    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // onNotificationPressed function to be called.
    //
    // When the notification is pressed while permission is denied,
    // the onNotificationPressed function is not called and the app opens.
    //
    // If you do not use the onNotificationPressed or launchApp function,
    // you do not need to write this code.
    if (!await FlutterForegroundTask.canDrawOverlays) {
      // This function requires `android.permission.SYSTEM_ALERT_WINDOW` permission.
      await FlutterForegroundTask.openSystemAlertWindowSettings();
    }

    // Android 12 or higher, there are restrictions on starting a foreground service.
    //
    // To restart the service on device reboot or unexpected problem, you need to allow below permission.
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    // Android 13 and higher, you need to allow notification permission to expose foreground service notification.
    final NotificationPermission notificationPermissionStatus =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        id: 500,
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          backgroundColor: Colors.orange,
        ),
        buttons: [
          const NotificationButton(
            id: 'sendButton',
            text: 'Send',
            textColor: Colors.orange,
          ),
          const NotificationButton(
            id: 'testButton',
            text: 'Test',
            textColor: Colors.grey,
          ),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<bool> _startForegroundTask() async {
    // You can save data using the saveData function.
    await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    // Register the receivePort before starting the service.
    final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
    final bool isRegistered = _registerReceivePort(receivePort);
    if (!isRegistered) {
      print('Failed to register receivePort!');
      return false;
    }

    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }
  }

  Future<bool> _stopForegroundTask() {
    return FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? newReceivePort) {
    if (newReceivePort == null) {
      return false;
    }

    _closeReceivePort();

    _receivePort = newReceivePort;
    _receivePort?.listen((data) {
      if (data is int) {
        print('eventCount: $data');
        print('setState');

        setState(() {});
      } else if (data is String) {
        if (data == 'onNotificationPressed') {
          Navigator.of(context).pushNamed('/resume-route');
        }
      } else if (data is DateTime) {
        print('timestamp: ${data.toString()}');
      } else if (data is List<double>) {
        // print('List: ${data.toString()}');
        prcList = data;
      } else if (data is Map) {
        print(
            'MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM: ${data.toString()}');

        setState(() {
          prc = data['prc'];
        });
      } else {
        print(
            'MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM1111: ${data.toString()}');
      }
    });

    return _receivePort != null;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestPermissionForAndroid();
      _initForegroundTask();

      // You can get the previous ReceivePort without restarting the service.
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
    });
  }

  @override
  void dispose() {
    _closeReceivePort();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A widget that prevents the app from closing when the foreground service is running.
    // This widget must be declared above the [Scaffold] widget.
    return WithForegroundTask(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Foreground Task'),
          centerTitle: true,
        ),
        body: _buildContentView(),
      ),
    );
  }

  Widget _buildContentView() {
    buttonBuilder(String text, {VoidCallback? onPressed}) {
      return ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buttonBuilder('start', onPressed: _startForegroundTask),
          buttonBuilder('stop', onPressed: _stopForegroundTask),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal, child: _getDataTable(prcList))
        ],
      ),
    );
  }
}

class ResumeRoutePage extends StatelessWidget {
  const ResumeRoutePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Route'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
            Navigator.of(context).pop();
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}

DataTable _getDataTable(List<double> prc) {
  int i = 0;

  return DataTable(
    columns: const <DataColumn>[
      // DataColumn(
      //   label: Expanded(
      //     child: Text(
      //       'Sym',
      //       style: TextStyle(fontStyle: FontStyle.italic),
      //     ),
      //   ),
      // ),
      // DataColumn(
      //   label: Expanded(
      //     child: Text(
      //       'Prc',
      //       style: TextStyle(fontStyle: FontStyle.italic),
      //     ),
      //   ),
      // ),
      DataColumn(
        label: Expanded(
          child: Text(
            '1H M',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            '1M M',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'RSI',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'KDJ',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ),
    ],
    rows: prc.length < 15
        ? <DataRow>[]
        : <DataRow>[
            DataRow(
              cells: <DataCell>[
                DataCell(Text(U.pra(prc[i++]))),
                DataCell(Text(U.pra(prc[i++]))),
                DataCell(Text(U.pra(prc[i++]))),
                DataCell(Text(U.pra(prc[i++]))),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                DataCell(Text(U.pra(prc[i++]))),
                DataCell(Text(U.pra(prc[i++]))),
                DataCell(Text(U.pra(prc[i++]))),
                DataCell(Text(U.pra(prc[i++]))),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                DataCell(Text(U.pra(prc[i++]))),
                DataCell(Text(U.pra(prc[i++]))),
                DataCell(Text(U.pra(prc[i++]))),
                DataCell(Text(U.pra(prc[i++]))),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                DataCell(Text(U.pra(prc[i++]))),
                DataCell(Text(U.pra(prc[i++]))),
                DataCell(Text(U.pra(prc[i++]))),
                DataCell(Text(U.pra(prc[i++]))),
              ],
            ),
          ],
  );
}

List<double> buildViewData() {
  var v = <double>[];
  try {
    v.add(M.btc.kListShort!.last.close);
    v.add(M.btc.kListLong!.last.close);
    v.add(M.btc.kListLong!.last.rsi);
    v.add(M.btc.kListLong!.last.j);

    v.add(M.eth.kListShort!.last.close);
    v.add(M.eth.kListLong!.last.close);
    v.add(M.eth.kListLong!.last.rsi);
    v.add(M.eth.kListLong!.last.j);
    print('buildViewData 1:');

    for (var t in M.targets) {
      print('buildViewData:' + t.symbol);
      v.add(t.kListShort!.last.close);
      v.add(t.kListLong!.last.close);
      v.add(t.kListLong!.last.rsi);
      v.add(t.kListLong!.last.j);
    }
  } catch (e) {
    print(e.toString());
  }

  return v;
}
