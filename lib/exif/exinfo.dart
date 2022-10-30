import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ExInfo {
  static final Map<String, int> _precisionInfo = <String, int>{};

  static void init() async {
    var url = 'https://fapi.binance.com/fapi/v1/exchangeInfo';

    Uri turl = Uri.parse(url);
    Response r = await http.get(turl);
    List sym = jsonDecode(r.body)['symbols'];
    sym.forEach((element) {
      // precisionInfo
      _precisionInfo[element['symbol'].toString().toLowerCase()] =
          element['pricePrecision'];
    });
    // print(_precisionInfo);
  }

  static int? getPrecision(String symbol) {
    return _precisionInfo[symbol];
  }
}
