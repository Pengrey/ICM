// ignore_for_file: unnecessary_const

import 'package:coin/transactions.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import 'money_data.dart';
import 'transactions_data.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Coin';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    Scaffold(
        body: Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: ListView.builder(
// scrollDirection: Axis.horizontal,
              itemCount: MoneyData.getData.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  height: 220,
                  width: double.maxFinite,
                  child: Card(
                    elevation: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              width: 2.0,
                              color: getChangeColor(MoneyData.getData[index])),
                        ),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(7),
                        child: Stack(children: <Widget>[
                          Align(
                            alignment: Alignment.centerRight,
                            child: Stack(
                              children: <Widget>[
                                Padding(
                                    padding:
                                        const EdgeInsets.only(left: 10, top: 5),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            expenseTypeIcon(
                                                MoneyData.getData[index]),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            expenseName(
                                                MoneyData.getData[index]),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            const Spacer(),
                                            changeIcon(
                                                MoneyData.getData[index]),
                                            const SizedBox(
                                              width: 20,
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            transactionAmount(
                                                MoneyData.getData[index])
                                          ],
                                        )
                                      ],
                                    ))
                              ],
                            ),
                          )
                        ]),
                      ),
                    ),
                  ),
                );
              }),
        ),
      ],
    )),
    Form(
      child: Scrollbar(
        child: Align(
          alignment: Alignment.topCenter,
          child: Card(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ...[
                      TextFormField(
                        decoration: const InputDecoration(
                          filled: true,
                          hintText: 'Enter a title...',
                          labelText: 'Title',
                        ),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          hintText: 'Enter a description...',
                          labelText: 'Description',
                        ),
                        onChanged: (value) {
                          var description = value;
                        },
                        maxLines: 5,
                      ),
                      _FormDatePicker(
                        date: date,
                        onChanged: (DateTime value) {},
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Estimated value',
                              ),
                            ],
                          ),
                          Text(
                            intl.NumberFormat.currency(
                                    symbol: "\$", decimalDigits: 0)
                                .format(maxValue),
                          ),
                          Slider(
                            min: 0,
                            max: 500,
                            divisions: 500,
                            value: maxValue,
                            onChanged: (double value) {},
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Enable feature'),
                          Switch(
                            value: enableFeature,
                            onChanged: (bool value) {},
                          ),
                        ],
                      ),
                    ].expand(
                      (widget) => [
                        widget,
                        const SizedBox(
                          height: 24,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    Container(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 40.0),
      height: 500,
      width: double.maxFinite,
      child: Card(
        elevation: 5,
        child: charts.LineChart(series,
            domainAxis: const charts.NumericAxisSpec(
              tickProviderSpec:
                  charts.BasicNumericTickProviderSpec(zeroBound: false),
              viewport: charts.NumericExtents(1.0, 31.0),
            ),
            animate: true),
      ),
    ),
  ];

  static var maxValue = 0.0;

  static var enableFeature = false;

  static get series {
    final List<transactions> data = TransactionsData.getData;

    List<charts.Series<transactions, num>> series = [
      charts.Series(
          id: "developers",
          data: data,
          domainFn: (transactions series, _) => series.date,
          measureFn: (transactions series, _) => series.money,
          colorFn: (transactions series, _) => series.barColor)
    ];

    return series;
  }

  static get date => DateTime.now();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Graph',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        onTap: _onItemTapped,
      ),
    );
  }

  static Widget expenseTypeIcon(data) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(
            data['icon'],
            color: data['iconColor'],
            size: 40,
          )),
    );
  }

  static Widget expenseName(data) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: '${data['name']}',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
          children: <TextSpan>[
            TextSpan(
                text: '\n${data['time']}',
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  static Widget changeIcon(data) {
    return Align(
        alignment: Alignment.topRight,
        child: data['changeColor'] == Colors.red
            ? Icon(
                Icons.arrow_downward,
                color: data['changeColor'],
                size: 30,
              )
            : Icon(
                Icons.arrow_upward,
                color: data['changeColor'],
                size: 30,
              ));
  }

  static Color getChangeColor(data) {
    return data['changeColor'];
  }

  static Widget transactionAmount(data) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Row(
          children: <Widget>[
            RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                text: '\n${data['value']}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormDatePicker extends StatefulWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _FormDatePicker({
    required this.date,
    required this.onChanged,
  });

  @override
  _FormDatePickerState createState() => _FormDatePickerState();
}

class _FormDatePickerState extends State<_FormDatePicker> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Date',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Text(
              intl.DateFormat.yMd().format(widget.date),
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
        TextButton(
          child: const Text('Edit'),
          onPressed: () async {
            var newDate = await showDatePicker(
              context: context,
              initialDate: widget.date,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );

            // Don't change the date if the date picker returns null.
            if (newDate == null) {
              return;
            }

            widget.onChanged(newDate);
          },
        )
      ],
    );
  }
}
