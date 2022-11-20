import 'dart:math';

import '../models/global.dart';
import 'algorithm.dart';

class Algo2 extends Algorithm {
  Algo2() {
    name = 'Random2';
  }
  @override
  Score calculate() {
    Score s = Score();

    s.targets[0] = (Random().nextInt(200) - 100) * 0.81;
    s.targets[1] = (Random().nextInt(200) - 100) * 0.81;

    return s;
  }
}
