import 'package:flutter/material.dart';
import 'package:homework/money_data.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:homework/transactions.dart';
import 'package:homework/transactions_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TransActions',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const HomePage(title: 'homepage'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _addTransaction() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddTransactionPage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TransActions'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'History'),
              Tab(text: 'Graph'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HistoryPage(),
            GraphsPage(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'uniqueTag',
          onPressed: _addTransaction,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), //
      ),
    );
  }
}

class AddTransactionPage extends StatelessWidget {
  const AddTransactionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'uniqueTag',
        label: Row(
          children: const [Icon(Icons.save), Text('Save')],
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  HistoryPage({Key? key}) : super(key: key);

  List<Map<String, Object>> data = MoneyData.getData;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  child: ListView.builder(
                      itemCount: data.length,
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
                                      color: getChangeColor(data[index])),
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
                                            padding: const EdgeInsets.only(
                                                left: 10, top: 5),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    expenseTypeIcon(
                                                        data[index]),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    expenseName(data[index]),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    const Spacer(),
                                                    changeIcon(data[index]),
                                                    const SizedBox(
                                                      width: 20,
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    transactionAmount(
                                                        data[index])
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
                      }))
            ],
          ),
        ));
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

class GraphsPage extends StatelessWidget {
  GraphsPage({Key? key}) : super(key: key);

  List<charts.Series<transactions, num>> series = [
    charts.Series(
        id: "developers",
        data: TransactionsData.getData,
        domainFn: (transactions series, _) => series.date,
        measureFn: (transactions series, _) => series.money,
        colorFn: (transactions series, _) => series.barColor)
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
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
    );
  }
}
