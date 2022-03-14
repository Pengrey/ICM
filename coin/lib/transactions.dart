import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/foundation.dart';

class transactions {
  final int date;
  final int spent;
  final charts.Color barColor;

  transactions(
      {required this.date, required this.spent, required this.barColor});
}
