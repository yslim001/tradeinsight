import 'cci_entity.dart';
import 'kdj_entity.dart';
import 'rsi_entity.dart';
import 'rw_entity.dart';

mixin MACDEntity on KDJEntity, RSIEntity, WREntity, CCIEntity {
  double dea = 0;
  double dif = 0;
  double macd = 0;
}
