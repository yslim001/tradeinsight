import '../models/global.dart';

class Score {
  int btc1 = 0;
  int eth1 = 0;

  @override
  String toString() {
    return 'Score btc1:$btc1\teth1:$eth1';
  }
}

class Algo {
  // reutnr -100~100
  static Score calculate() {
    return _algo1();
  }

  static Score _algo1() {
    Score s = Score();
    // int len = G.btc.m!.kListShort!.length;

    // s.btc1 = 0;
    // s.eth1 = 0;

    // if (G.btc1.m!.kListShort![len - 2].macd >
    //     G.btc1.m!.kListShort![len - 1].macd) {}

    return s;
  }
}
