import 'package:get/get.dart';

import '../entity/k_line_entity.dart';
import '../exif/tradeapi.dart';
import '../models/global.dart';
import 'algo1.dart';
import 'algo2.dart';
import 'algo3.dart';

class Score {
  late List<double> targets;

  Score() {
    targets = <double>[];
    for (var coin in Targets.coins) {
      targets.add(0);
    }
  }

  @override
  String toString() {
    return 'Score coin1:${targets[0]}\tcoin2:${targets[1]}';
  }
}

class Overview {
  String name = '';
  int win = 0;
  int lose = 0;
  double per = 0;
}

abstract class Algorithm {
  var name = 'algo';
  var position = PositionInfo();
  var summary = <TradeSummary>[];
  Score calculate();
  trade() {
    Score sc = calculate();
    if (position.p != 0) {
      if (position.buy) {
        if (sc.targets[position.index] < Config.BuyCloseScore) {
          TradeSummary ts = TradeSummary();
          ts.index = position.index;
          ts.buy = position.buy;
          ts.startt = position.t;
          ts.startp = position.p;
          ts.endt = DateTime.now();
          ts.endp = M.targets[position.index].kListShort!.last.close;
          ts.per = (ts.endp - ts.startp) * 100 / ts.startp;
          summary.insert(0, ts);
          position.p = 0;
        }
      } else {
        if (sc.targets[position.index] > Config.SellCloseScore) {
          TradeSummary ts = TradeSummary();
          ts.index = position.index;
          ts.buy = position.buy;
          ts.startt = position.t;
          ts.startp = position.p;
          ts.endt = DateTime.now();
          ts.endp = M.targets[position.index].kListShort!.last.close;
          ts.per = -(ts.endp - ts.startp) * 100 / ts.startp;
          summary.insert(0, ts);
          position.p = 0;
        }
      }
    } else {
      double targetScore = -1;
      int targetIndex = -1;
      for (int i = 0; i < sc.targets.length; ++i) {
        if (sc.targets[i].abs() > targetScore) {
          targetScore = sc.targets[i].abs();
          targetIndex = i;
        }
      }
      if (sc.targets[targetIndex] > Config.BUYSCORE) {
        position.index = targetIndex;
        position.p = M.targets[targetIndex].kListShort!.last.close;
        position.buy = true;
        position.t = DateTime.now();
      } else if (sc.targets[targetIndex] < Config.SELLSCORE) {
        position.index = targetIndex;
        position.p = M.targets[targetIndex].kListShort!.last.close;
        position.buy = false;
        position.t = DateTime.now();
      }
    }
  }

  bool isBuyCurve(List<KLineEntity> kList, {int cnt = 3, allowDelay = true}) {
    int len = kList.length;
    int peakIndex = len - 2;
    double gap = 0;
    bool dirok = true;

    //check decreasing
    for (int i = peakIndex - cnt; i < peakIndex; ++i) {
      if (kList[i].macd < kList[i + 1].macd) {
        dirok = false;
        break;
      }
    }

    if (dirok) {
      gap = (kList[peakIndex - cnt].macd - kList[peakIndex].macd).abs() /
          (cnt * 2);
      if (kList[peakIndex].macd < kList[len - 1].macd) {
        if ((kList[peakIndex].macd - kList[len - 1].macd).abs() > gap) {
          return true;
        }
      }
    }

    if (!allowDelay) return false;

    peakIndex = len - 3;
    //check decreasing
    for (int i = peakIndex - cnt; i < peakIndex; ++i) {
      if (kList[i].macd < kList[i + 1].macd) {
        dirok = false;
        break;
      }
    }

    if (dirok) {
      gap = (kList[peakIndex - cnt].macd - kList[peakIndex].macd).abs() /
          (cnt * 2);
      if (kList[peakIndex].macd < kList[len - 1].macd) {
        if ((kList[peakIndex].macd - kList[len - 1].macd).abs() > gap) {
          return true;
        }
      }
    }

    return false;
  }

  bool isSellCurve(List<KLineEntity> kList, {int cnt = 3, allowDelay = true}) {
    int len = kList.length;
    int peakIndex = len - 2;
    double gap = 0;
    bool dirok = true;

    //check increasing
    for (int i = peakIndex - cnt; i < peakIndex; ++i) {
      if (kList[i].macd > kList[i + 1].macd) {
        dirok = false;
        break;
      }
    }

    if (dirok) {
      gap = (kList[peakIndex - cnt].macd - kList[peakIndex].macd).abs() /
          (cnt * 2);
      if (kList[peakIndex].macd > kList[len - 1].macd) {
        if ((kList[peakIndex].macd - kList[len - 1].macd).abs() > gap) {
          return true;
        }
      }
    }

    if (!allowDelay) return false;

    peakIndex = len - 3;
    //check decreasing
    for (int i = peakIndex - cnt; i < peakIndex; ++i) {
      if (kList[i].macd > kList[i + 1].macd) {
        dirok = false;
        break;
      }
    }

    if (dirok) {
      gap = (kList[peakIndex - cnt].macd - kList[peakIndex].macd).abs() /
          (cnt * 2);
      if (kList[peakIndex].macd > kList[len - 1].macd) {
        if ((kList[peakIndex].macd - kList[len - 1].macd).abs() > gap) {
          return true;
        }
      }
    }

    return false;
  }

  double jChange(List<KLineEntity> kList) {
    int len = kList.length;
    return kList[len - 2].j! - kList[len - 1].j!;
  }
}

class AlgoMngr {
  static var algos = <Algorithm>[];
  static var monitor = ''.obs;
  static bool bReady = false;
  // static var summaries = <TradeSummary>[];
  static var overviews = <Overview>[];

  AlgoMngr() {
    algos.add(Algo1());
    algos.add(Algo2());
    algos.add(Algo3());
  }

  static reset() {
    for (var a in algos) {
      a.summary = <TradeSummary>[];
      a.position.p = 0;
    }
  }

  static List<Overview> refresh() {
    if (!bReady) {
      if (M.btc == null || M.eth == null) return <Overview>[];
      for (var t in M.targets) {
        if (t.kListShort == null || t.kListMed == null || t.kListLong == null) {
          return <Overview>[];
        }
      }
    }

    bReady = true;
    String m = '';

    for (Algorithm a in algos) {
      a.trade();
      if (a.position.p != 0) {
        double per = (a.position.buy ? 1 : -1) *
            (M.targets[a.position.index].kListShort!.last.close -
                a.position.p) *
            100 /
            a.position.p;

        m +=
            '${a.name} \t${a.position.toString()} ${per.toStringAsFixed(2)}%\n';
      }
    }
    monitor.value = m;

    overviews = <Overview>[];
    for (Algorithm a in algos) {
      // s += a.name + '\n';
      Overview to = Overview();
      to.name = a.name;
      for (TradeSummary ts in a.summary) {
        if (ts.per >= 0) {
          to.win++;
        } else {
          to.lose++;
        }

        to.per += ts.per;
      }
      overviews.add(to);
    }
    return overviews;
  }
}
