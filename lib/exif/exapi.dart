import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:convert/convert.dart';
import '../entity/k_line_entity.dart';
import '../utils/data_util.dart';

class BNCF {
  static String APIKEY =
      'HYr4iyuvWpVisv49XRkPpd8LPnfJxkPaXTmgkXE2UgBXWbM7yByXmJbZzb5bOEHv';
  static String SECKEY =
      'gVXSYFcf7dcvo0GwjhRm3p6JLqikoimOQJ9ogi0HPBk5N7LtNb3SMeeqeH4z8jkA';

  static Future<String> _genSecReq(String endpoint) async {
    String baseUrl = 'https://fapi.binance.com/fapi/${endpoint}?';
    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    String queryParams =
        'recvWindow=5000' + '&timestamp=' + timeStamp.toString();
    var secret = SECKEY;
    var messageBytes = utf8.encode(queryParams);
    List<int> key = utf8.encode(secret);
    Hmac hmac = new Hmac(sha256, key);
    Digest digest = hmac.convert(messageBytes);
    String signature = hex.encode(digest.bytes);
    String url = "$baseUrl$queryParams&signature=$signature";
    Uri turl = Uri.parse(url);
    var response = await http.get(turl, headers: {
      "Accept": "application/json",
      "HTTP_ACCEPT_LANGUAGE": "en-US",
      "Accept-Language": "en-US",
      "X-MBX-APIKEY": APIKEY
    });
    if (response.statusCode != 200)
      print(
          '@@@@@@@@@@@@@@@@@@@@@@status:${response.statusCode}\n${response.body}');
    return response.body;
  }

  static testReq() async {
    String endpoint = '/v1/positionSide/dual';
    String res = await _genSecReq(endpoint);
    print(res);
    // Map<String, dynamic> acc = jsonDecode(res);
    // print(acc['assets']);
  }

//   static Future<List<Ticker>> getAccount() async {
//     String endpoint = '/v2/account';
//     String res = await _genSecReq(endpoint);
//     Map<String, dynamic> acc = jsonDecode(res);
//     print(acc['assets']);
//   }

//   static Future<List<Ticker>> getPositionRisk() async {
//     String endpoint = '/v2/positionRisk';
//     String res = await _genSecReq(endpoint);
//     List acc = jsonDecode(res);
//     double profitsum = 0.0;
//     double buysum = 0.0;
//     double mktsum = 0.0;
//     print('List len:' + acc.length.toString());
//     acc.forEach((element) {
//       double ent = double.parse(element['entryPrice']);
//       double mkt = double.parse(element['markPrice']);
//       double vol = double.parse(element['positionAmt']);
//       double profit = double.parse(element['unRealizedProfit']);
//       if (ent != 0) {
//         profitsum += profit;
//         buysum += ent * vol;
//         mktsum += mkt * vol;
//         print(element['symbol'] +
//             '   \t' +
//             getPriceStr(ent) +
//             '/' +
//             getPriceStr(mkt) +
//             '\t' +
//             getPriceStr((mkt - ent) / mkt * 100) +
//             '%\t\t' +
//             getPriceStr(profit) +
//             '\t\t' +
//             ' USD:' +
//             (ent * vol).toStringAsFixed(1) +
//             '/' +
//             (mkt * vol).toStringAsFixed(1));
//         // print(element);
//       }
//     });
//     print('-------------------------------');
//     print('Profit SUM:\t' + getPriceStr(profitsum));
//     print(
//         'TOTAL PRICE:\t' + getPriceStr(buysum) + ' MKT:' + getPriceStr(mktsum));

//     print('-------------------------------');
//   }

// //////////////////////-----------------------------------------------------------------
//   static Future<List<Ticker>> getMarket() async {
//     print('https://fapi.binance.com/fapi/v1/ticker/24hr');
//     Response r = await http
//         .get(Uri.parse('https://fapi.binance.com/fapi/v1/ticker/24hr'));
//     List c = jsonDecode(r.body);
//     List<Ticker> result = [];
//     c.forEach((e) {
//       result.add(Ticker(
//           name: e['symbol'],
//           price: double.parse(e['lastPrice']),
//           change: double.parse(e['priceChangePercent'])));
//     });

//     return result;
//   }

  static Future<List<KLineEntity>> getKline(String symbol, int interval) async {
    String intervals = getIntervalString(interval);

    var url =
        'https://fapi.binance.com/fapi/v1/klines?symbol=$symbol&interval=$intervals&limit=100';

    List<KLineEntity> datas = [];
    Uri turl = Uri.parse(url);
    Response response = await http.get(turl);
    print(response);
    if (response.statusCode == 200) {
      List list = json.decode(response.body);
      double o, h, l, c, v, v2;
      list.forEach((element) {
        o = double.parse(element[1].toString());
        h = double.parse(element[2].toString());
        l = double.parse(element[3].toString());
        c = double.parse(element[4].toString());
        v = double.parse(element[5].toString());
        v2 = (c - o) / (h - l) * v;
        KLineEntity k = KLineEntity.fromCustom(
          time: int.parse(element[0].toString()),
          open: o,
          high: h,
          low: l,
          close: c,
          vol: v,
          amount: double.parse(element[7].toString()),
        );
        datas.add(k);
      });

      DataUtil.calculate(datas);
      print(datas.last);
    } else {
      print('${url}\nFailed getting IP address rescode:$response');
      print('Failed getting IP address${response.reasonPhrase}');
    }
    return datas;
  }

  static KLineEntity getKEntityWebSocket(Map kdata) {
    double o, h, l, c, v, v2;
    o = double.parse(kdata['k']['o']);
    h = double.parse(kdata['k']['h']);
    l = double.parse(kdata['k']['l']);
    c = double.parse(kdata['k']['c']);
    v = double.parse(kdata['k']['v']);
    return KLineEntity.fromCustom(
      time: kdata['k']['t'],
      open: o,
      high: h,
      low: l,
      close: c,
      vol: v,
      amount: v,
    );
  }

  static int precision(double val1) {
    int digits = 8;
    double val = val1.abs();

    if (val >= 100000)
      digits = 0;
    else if (val >= 10000)
      digits = 1;
    else if (val >= 1000)
      digits = 2;
    else if (val >= 100)
      digits = 3;
    else if (val >= 10)
      digits = 4;
    else if (val >= 1)
      digits = 5;
    else if (val >= 0.1)
      digits = 5;
    else if (val >= 0.01)
      digits = 6;
    else if (val >= 0.001)
      digits = 7;
    else if (val >= 0.0001) digits = 8;
    return digits;
  }

  static String getIntervalString(int interval) {
    String intervals;
    if (interval == 60)
      intervals = '1m';
    else if (interval == 60 * 5)
      intervals = '5m';
    else if (interval == 60 * 15)
      intervals = '15m';
    else if (interval == 60 * 60)
      intervals = '1h';
    else if (interval == 60 * 60 * 4)
      intervals = '4h';
    else
      intervals = '1d';
    return intervals;
  }

  static String getPriceStr(double p) {
    return p.toStringAsFixed(precision(p));
  }
}
