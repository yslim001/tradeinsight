import '../models/global.dart';
import 'algorithm.dart';

class Algo1 extends Algorithm {
  int count = 2;
  Algo1() {
    name = 'MACD $count';
  }

  @override
  Score calculate() {
    Score s = Score();

    for (int i = 0; i < M.targets.length; ++i) {
      if (isBuyCurve(M.targets[i].kListShort!, cnt: count)) {
        if (M.targets[i].kListShort!.last.j! < 20 &&
            jChange(M.targets[i].kListShort!) > 0) {
          s.targets[i] = 90;
          print('Algo:$name: BUY::: ${M.targets[i].symbol}');
        }
      } else if (isSellCurve(M.targets[i].kListShort!, cnt: count)) {
        if (M.targets[i].kListShort!.last.j! > 80 &&
            jChange(M.targets[i].kListShort!) < 0) {
          s.targets[i] = -90;
          print('Algo:$name: SELL::: ${M.targets[i].symbol}');
        }
      }
    }
    // print('Algo:$name: rsi:${M.targets[1].kListShort!.last.rsi!} score:${s}');

    return s;
  }
}
