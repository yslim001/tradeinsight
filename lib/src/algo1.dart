import '../models/global.dart';
import 'algorithm.dart';

class Algo1 extends Algorithm {
  Algo1() {
    name = 'RSI KDJ';
  }
  @override
  Score calculate() {
    Score s = Score();

    if (M.targets[0].kListShort!.last.k! > M.targets[0].kListShort!.last.d!) {
      s.targets[0] = 100 - M.targets[0].kListShort!.last.rsi!;
    } else {
      s.targets[0] = -100 + (100 - M.targets[0].kListShort!.last.rsi!);
    }

    if (M.targets[1].kListShort!.last.k! > M.targets[1].kListShort!.last.d!) {
      s.targets[1] = 100 - M.targets[1].kListShort!.last.rsi!;
    } else {
      s.targets[1] = -100 + (100 - M.targets[1].kListShort!.last.rsi!);
    }

    // print('Algo:$name: rsi:${M.targets[1].kListShort!.last.rsi!} score:${s}');

    return s;
  }
}
