// ignore_for_file: unnecessary_const

import 'package:coin/transactions.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

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
