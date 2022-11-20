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

    s.targets[0] = (Random().nextInt(200) - 100) * 0.81;
    s.targets[1] = (Random().nextInt(200) - 100) * 0.81;
    // print('Algo2:$name: score:${s}');

    return s;
  }
}
