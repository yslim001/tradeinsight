import '../models/global.dart';
import '../src/algorithm.dart';

class Trade {
  static trade(Score sc, PositionInfo pos) {
    if (pos.p != 0) {
      if (pos.buy) {
        if (sc.targets[pos.index] < Config.BUYMSCORE) {
          //BUY 유지 점수 보다 낮은경우
          sell(pos.index, M.targets[pos.index].kListShort!.last.close, pos);
        }
      } else {
        if (sc.targets[pos.index] > Config.SELLMSCORE) {
          //SELL 유지 점수보다 높은 경우
          buy(pos.index, M.targets[pos.index].kListShort!.last.close, pos);
        }
      }
    } else {
      if (sc.targets[0].abs() > sc.targets[1].abs()) {
        if (sc.targets[0] > Config.BUYSCORE) {
          buy(0, M.targets[0].kListShort!.last.close, pos);
        } else if (sc.targets[0] < Config.SELLSCORE) {
          sell(0, M.targets[0].kListShort!.last.close, pos);
        }
      } else {
        if (sc.targets[1] > Config.BUYSCORE) {
          buy(1, M.targets[1].kListShort!.last.close, pos);
        } else if (sc.targets[1] < Config.SELLSCORE) {
          sell(1, M.targets[1].kListShort!.last.close, pos);
        }
      }
    }
  }

  static sell(int index, double price, PositionInfo pos) {
    if (pos.p == 0) {
      pos.index = index;
      pos.p = price;
      pos.buy = false;
      pos.t = DateTime.now();
      print('SELL:${M.targets[index].symbol} $price ${DateTime.now()}');
    } else {
      print('END :${M.targets[index].symbol} $price ${DateTime.now()}');
      print(
          'RES :${(pos.p - price) * 100 / pos.p}%--------------------------------\n');
      pos.p = 0;
    }
  }

  static buy(int index, double price, PositionInfo pos) {
    if (pos.p == 0) {
      pos.index = index;
      pos.p = price;
      pos.buy = true;
      pos.t = DateTime.now();
      print('BUY :${M.targets[index].symbol} $price ${DateTime.now()}');
    } else {
      print('END :${M.targets[index].symbol} $price ${DateTime.now()}');
      print(
          'RES :${-(pos.p - price) * 100 / pos.p}%--------------------------------\n\n');
      pos.p = 0;
    }
  }

  static test() {
    PositionInfo pos1 =
        PositionInfo(symbol: 'bchusdt', buy: true, p: 0, t: DateTime.now());
    Score sc = Score();

    print('${M.targets}');

    sc.targets[0] = -70;
    print('TEST) $sc \t$pos1');
    trade(sc, pos1);
    sc.targets[0] = 94;
    sc.targets[1] = 93;
    print('TEST) $sc \t$pos1');
    trade(sc, pos1);
    sc.targets[0] = 9;
    sc.targets[1] = 99;
    print('TEST) $sc \t$pos1');
    trade(sc, pos1);
    sc.targets[0] = -10;
    sc.targets[1] = -20;
    print('TEST) $sc \t$pos1');
    trade(sc, pos1);
    sc.targets[0] = -30;
    sc.targets[1] = -30;
    print('TEST) $sc \t$pos1');
    trade(sc, pos1);
  }
}
