// import 'package:intl/intl.dart';

// import '../models/data.dart';
// import '../utils/strutil.dart';
// import 'tradeapi.dart';
// import 'package:collection/collection.dart';

// class FakeBNC extends TradeAPI {
//   List<OrderRequest> orders = [];
//   List<OrderRequest> positions = [];
//   int winCount = 0, loseCount = 0;
//   double totalProfit = 0;

//   @override
//   void updatePrice(String symbol, double price) {
//     _procPositions(symbol, price);
//     _procOrders(symbol, price);
//   }

//   @override
//   void createOrder(OrderRequest or) {
//     if (or.type == ORDERTYPE.SELL_MARKET || or.type == ORDERTYPE.BUY_MARKET) {
//       positions.add(or);
//     } else if (or.type == ORDERTYPE.SELL_LIMIT ||
//         or.type == ORDERTYPE.BUY_LIMIT) {
//       orders.add(or);
//     }
//   }

//   @override
//   void deleteOrder(String symbol) {
//     orders.removeWhere((element) => element.symbol == symbol);
//   }

//   @override
//   void deletePosition(OrderRequest org, OrderRequest newor) {
//     if (org.type == ORDERTYPE.BUY_MARKET) {
//       print('CANCELED ' +
//           DateFormat('MM-dd HH:mm:ss').format(DateTime.now()) +
//           ' ${org.symbol} ' +
//           ((newor.orderPrice - org.orderPrice) > 0 ? 'WIN ' : 'LOSE ') +
//           ((newor.orderPrice - org.orderPrice) * 100 / org.orderPrice)
//               .toStringAsFixed(2) +
//           '%');
//     } else if (org.type == ORDERTYPE.SELL_MARKET) {
//       print('CANCELED ' +
//           DateFormat('MM-dd HH:mm:ss').format(DateTime.now()) +
//           ' ${org.symbol} ' +
//           ((newor.orderPrice - org.orderPrice) < 0 ? 'WIN ' : 'LOSE ') +
//           ((org.orderPrice - newor.orderPrice) * 100 / org.orderPrice)
//               .toStringAsFixed(2) +
//           '%');
//     }
//   }

//   void _procOrders(String symbol, double price) {
//     OrderRequest or;
//     for (int index = orders.length - 1; index >= 0; --index) {
//       or = orders[index];
//       if (or.symbol == symbol) {
//         if (or.type == ORDERTYPE.BUY_LIMIT) {
//           if (or.orderPrice >= price) {
//             positions.add(orders.removeAt(index));
//             printStatus(symbol);
//           }
//         } else if (or.type == ORDERTYPE.SELL_LIMIT) {
//           if (or.orderPrice <= price) {
//             positions.add(orders.removeAt(index));
//             printStatus(symbol);
//           }
//         }
//       }
//     }
//   }

//   void _procPositions(String symbol, double price) {
//     OrderRequest or;
//     for (int index = positions.length - 1; index >= 0; --index) {
//       or = positions[index];
//       if (or.symbol != symbol) return;
//       if (or.type == ORDERTYPE.BUY_MARKET || or.type == ORDERTYPE.BUY_LIMIT) {
//         if (or.slPrice >= price) {
//           _logResult(false, or, price);
//           positions.removeAt(index);
//         } else if (or.tpPrice <= price) {
//           _logResult(true, or, price);
//           positions.removeAt(index);
//         }
//       } else if (or.type == ORDERTYPE.SELL_MARKET ||
//           or.type == ORDERTYPE.SELL_LIMIT) {
//         if (or.slPrice <= price) {
//           _logResult(false, or, price);
//           positions.removeAt(index);
//         } else if (or.tpPrice >= price) {
//           _logResult(true, or, price);
//           positions.removeAt(index);
//         }
//       }
//     }
//   }

//   void _logResult(bool win, OrderRequest or, double price) {
//     double ratio = (price - or.orderPrice).abs() * 100 / or.orderPrice;
//     win ? winCount++ : loseCount++;
//     win ? totalProfit += ratio : totalProfit -= ratio;
//     print('******************************************* RESULT');
//     print((win ? 'WIN' : 'LOSE') +
//         ':: ($winCount/$loseCount) ${totalProfit.toStringAsFixed(2)}% ' +
//         DateFormat('MM-dd HH:mm:ss')
//             .format(DateTime.fromMillisecondsSinceEpoch(or.time)) +
//         ' ~ ' +
//         DateFormat(' HH:mm:ss').format(DateTime.now()) +
//         ' ' +
//         or.id);
//     print(or.toString());
//     print('Ratio:${win ? '+' : '-'}${ratio.toStringAsFixed(2)}% ' +
//         'Market Price:' +
//         price.toStringAsFixed(2));
//     print('******************************************* END');
//   }

//   @override
//   OrderRequest? getOrder(String symbol) {
//     OrderRequest? result;

//     result = orders
//         .firstWhereOrNull((OrderRequest element) => element.symbol == symbol);

//     return result;
//   }

//   @override
//   OrderRequest? getPosition(String symbol) {
//     OrderRequest? result;

//     result = positions.firstWhereOrNull(
//       (OrderRequest element) => element.symbol == symbol,
//     );

//     return result;
//   }

//   @override
//   void printStatus(String title) {
//     print('----------- printStatus $title -----------');
//     orders.isEmpty
//         ? print('No Orders')
//         : orders.forEach((element) {
//             print('Ord: ' + element.toString());
//           });
//     positions.isEmpty
//         ? print('No Positions')
//         : positions.forEach((element) {
//             print('Pos: ' + element.toString());
//           });
//     print('-------------------------------------- END');
//   }

//   static void resultCheck() {}
// }
