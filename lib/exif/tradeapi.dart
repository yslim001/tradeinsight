import '../models/global.dart';
import '../src/algo.dart';

class Trade {
  static trade(Score sc) {
    if (G.btc1.position.p != 0) {
      if (G.btc1.position.buy) {
        if (sc.btc1 < Config.BUYMSCORE) {
          //BUY 유지 점수 보다 낮은경우
          _sell(G.btc1);
        }
      } else {
        if (sc.btc1 > Config.SELLMSCORE) {
          //SELL 유지 점수보다 높은 경우
          _buy(G.btc1);
        }
      }
    } else if (G.eth1.position.p != 0) {
      if (G.eth1.position.buy) {
        if (sc.eth1 < Config.BUYMSCORE) {
          //BUY 유지 점수 보다 낮은경우
          _sell(G.eth1);
        }
      } else {
        if (sc.eth1 > Config.SELLMSCORE) {
          //SELL 유지 점수보다 높은 경우
          _buy(G.eth1);
        }
      }
    } else {
      if (sc.btc1.abs() > sc.eth1.abs()) {
        if (sc.btc1 > Config.BUYSCORE) {
          _buy(G.btc1);
        } else if (sc.btc1 < Config.SELLSCORE) {
          _sell(G.btc1);
        }
      } else {
        if (sc.eth1 > Config.BUYSCORE) {
          _buy(G.eth1);
        } else if (sc.eth1 < Config.SELLSCORE) {
          _sell(G.eth1);
        }
      }
    }
  }

  static _sell(CoinInfo target) {
    if (target.position.p == 0) {
      target.position.p = target.m!.kListShort!.last.close;
      target.position.buy = false;
      target.position.t = DateTime.now();
      print(
          'SELL:${target.m!.symbol} ${target.m!.kListShort!.last.close} ${DateTime.now()}');
    } else {
      print(
          'END :${target.m!.symbol} ${target.m!.kListShort!.last.close} ${DateTime.now()}');
      print(
          'RES :${(target.position.p - target.m!.kListShort!.last.close) * 100 / target.position.p}%--------------------------------\n');
      target.position.p = 0;
    }
  }

  static _buy(CoinInfo target) {
    if (target.position.p == 0) {
      target.position.p = target.m!.kListShort!.last.close;
      target.position.buy = true;
      target.position.t = DateTime.now();
      print(
          'BUY :${target.m!.symbol} ${target.m!.kListShort!.last.close} ${DateTime.now()}');
    } else {
      print(
          'END :${target.m!.symbol} ${target.m!.kListShort!.last.close} ${DateTime.now()}');
      print(
          'RES :${-(target.position.p - target.m!.kListShort!.last.close) * 100 / target.position.p}%--------------------------------\n\n');
      target.position.p = 0;
    }
  }

  static test() {
    Score sc = Score();

    sc.btc1 = -70;
    print('TEST) $sc \t${G.btc1.position.p}');
    trade(sc);
    sc.btc1 = 92;
    sc.eth1 = 93;
    print('TEST) $sc \t${G.btc1.position.p}');
    trade(sc);
    sc.btc1 = 9;
    sc.eth1 = 99;
    print('TEST) $sc \t${G.btc1.position.p}');
    trade(sc);
    sc.btc1 = -10;
    sc.eth1 = -20;
    print('TEST) $sc \t${G.btc1.position.p}');
    trade(sc);
    sc.btc1 = -30;
    sc.eth1 = -30;
    print('TEST) $sc \t${G.btc1.position.p}');
    trade(sc);
  }
}
