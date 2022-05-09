import 'package:charts_flutter/flutter.dart' as charts;

class transactions {
  final int date;
  final int money;
  final charts.Color barColor;

  transactions(
      {required this.date, required this.money, required this.barColor});
}
