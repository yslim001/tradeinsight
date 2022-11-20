import 'dart:math';

import '../models/global.dart';
import 'algorithm.dart';

class Algo3 extends Algorithm {
  Algo3() {
    name = 'Random3';
  }
  @override
  Score calculate() {
    Score s = Score();

    for (int i = 0; i < s.targets.length; ++i) {
      s.targets[i] = (Random().nextInt(200) - 100) * 0.805;
    }
    return s;
  }
}
