import 'package:coin/transactions.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

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
      body: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        height: 220,
        width: double.maxFinite,
        child: const Card(
          elevation: 5,
        ),
      ),
    ),
    Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.person),
              hintText: 'Enter your name',
              labelText: 'Name',
            ),
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.phone),
              hintText: 'Enter a phone number',
              labelText: 'Phone',
            ),
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.calendar_today),
              hintText: 'Enter your date of birth',
              labelText: 'Dob',
            ),
          ),
          Container(
              padding: const EdgeInsets.only(left: 150.0, top: 40.0),
              // ignore: deprecated_member_use
              child: const RaisedButton(
                child: Text('Submit'),
                onPressed: null,
              )),
        ],
      ),
    ),
    charts.LineChart(series,
        domainAxis: const charts.NumericAxisSpec(
          tickProviderSpec:
              charts.BasicNumericTickProviderSpec(zeroBound: false),
          viewport: charts.NumericExtents(1.0, 31.0),
        ),
        animate: true),
  ];

  static get series {
    final List<transactions> data = [
      transactions(
        date: 1,
        spent: 45,
        barColor: charts.ColorUtil.fromDartColor(Color.fromARGB(255, 0, 0, 0)),
      ),
      transactions(
        date: 2,
        spent: 3,
        barColor: charts.ColorUtil.fromDartColor(Color.fromARGB(255, 0, 0, 0)),
      ),
      transactions(
        date: 3,
        spent: 4,
        barColor: charts.ColorUtil.fromDartColor(Color.fromARGB(255, 0, 0, 0)),
      ),
      transactions(
        date: 4,
        spent: 3,
        barColor: charts.ColorUtil.fromDartColor(Color.fromARGB(255, 0, 0, 0)),
      ),
      transactions(
        date: 5,
        spent: 10,
        barColor: charts.ColorUtil.fromDartColor(Color.fromARGB(255, 0, 0, 0)),
      ),
      transactions(
        date: 6,
        spent: 3,
        barColor: charts.ColorUtil.fromDartColor(Color.fromARGB(255, 0, 0, 0)),
      ),
      transactions(
        date: 7,
        spent: 11,
        barColor: charts.ColorUtil.fromDartColor(Color.fromARGB(255, 0, 0, 0)),
      ),
      transactions(
        date: 8,
        spent: 3,
        barColor: charts.ColorUtil.fromDartColor(Color.fromARGB(255, 0, 0, 0)),
      ),
      transactions(
        date: 9,
        spent: 30,
        barColor: charts.ColorUtil.fromDartColor(Color.fromARGB(255, 0, 0, 0)),
      ),
      transactions(
        date: 10,
        spent: 1,
        barColor: charts.ColorUtil.fromDartColor(Color.fromARGB(255, 0, 0, 0)),
      ),
      transactions(
        date: 11,
        spent: 3,
        barColor: charts.ColorUtil.fromDartColor(Color.fromARGB(255, 0, 0, 0)),
      ),
      transactions(
        date: 12,
        spent: 0,
        barColor: charts.ColorUtil.fromDartColor(Color.fromARGB(255, 0, 0, 0)),
      ),
      transactions(
        date: 13,
        spent: 6,
        barColor: charts.ColorUtil.fromDartColor(Color.fromARGB(255, 0, 0, 0)),
      ),
      transactions(
        date: 14,
        spent: 2,
        barColor: charts.ColorUtil.fromDartColor(Color.fromARGB(255, 0, 0, 0)),
      ),
      transactions(
        date: 15,
        spent: 10,
        barColor: charts.ColorUtil.fromDartColor(Color.fromARGB(255, 0, 0, 0)),
      ),
      transactions(
        date: 16,
        spent: 0,
        barColor: charts.ColorUtil.fromDartColor(Color.fromARGB(255, 0, 0, 0)),
      ),
      transactions(
        date: 17,
        spent: 9,
        barColor: charts.ColorUtil.fromDartColor(Color.fromARGB(255, 0, 0, 0)),
      ),
      transactions(
        date: 18,
        spent: 4,
        barColor: charts.ColorUtil.fromDartColor(Color.fromARGB(255, 0, 0, 0)),
      ),
    ];

    List<charts.Series<transactions, num>> series = [
      charts.Series(
          id: "developers",
          data: data,
          domainFn: (transactions series, _) => series.date,
          measureFn: (transactions series, _) => series.spent,
          colorFn: (transactions series, _) => series.barColor)
    ];

    return series;
  }

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
        selectedItemColor: Color.fromARGB(255, 0, 0, 0),
        onTap: _onItemTapped,
      ),
    );
  }
}
