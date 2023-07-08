import '../exif/exapi.dart';

class U {
  static String pr(double p) {
    return '${p.toStringAsFixed(BNCF.precision(p))} ';
  }

  static String pr1(String m, double p) {
    return '$m ${p.toStringAsFixed(BNCF.precision(p))} ';
  }

  static String pr2(String m, double p, double p1) {
    return '$m ${p.toStringAsFixed(BNCF.precision(p))} ${p1.toStringAsFixed(BNCF.precision(p1))} ';
  }

  static String pra(double p) {
    if (p > 1000) {
      return p.toStringAsFixed(1);
    } else if (p > 100) {
      return p.toStringAsFixed(2);
    } else if (p > 10) {
      return p.toStringAsFixed(3);
    } else if (p > 1) {
      return p.toStringAsFixed(4);
    } else {
      return p.toStringAsFixed(5);
    }
  }
}
