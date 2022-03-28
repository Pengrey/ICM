import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:badges/badges.dart';

void main() {
  runApp(const MyApp());
}

int _notifications = 1;
List<Map<String, dynamic>> localChallengeList = [
  {
    "token": "12345",
    "image_url":
        "https://s2.glbimg.com/6VyBKVon5j6Ofdc70Yt9c1FTlvk=/0x0:695x521/984x0/smart/filters:strip_icc()/i.s3.glbimg.com/v1/AUTH_08fbf48bc0524877943fe86e43087e7a/internal_photos/bs/2021/9/Q/4z9FL4T1G7MKHrl1AYpg/2014-04-11-bliss.jpg",
    "hint": "Try Jumping.",
  },
  {
    "token": "45678",
    "image_url":
        "https://staticg.sportskeeda.com/editor/2022/02/45fd5-16457369574775-1920.jpg",
    "hint": "Behold, dog!",
  },
  {
    "token": "90000",
    "image_url":
        "https://curatedmint.com/wp-content/uploads/2021/07/warframe-fortuna-720x720.jpg",
    "hint": "Secret wall ahead.",
  }
];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

bool _clicked = false;

class OpenChallenge extends StatefulWidget {
  const OpenChallenge({Key? key, required this.idx}) : super(key: key);

  final int idx;

  @override
  State<OpenChallenge> createState() => _OpenChallengeState();
}

TextStyle hintTextStyle = const TextStyle();

class _OpenChallengeState extends State<OpenChallenge> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(localChallengeList[widget.idx]['token'])),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.9),
                spreadRadius: 0.5,
                blurRadius: 5,
                offset: const Offset(0, 6),
              ),
            ], borderRadius: BorderRadius.circular(30)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                height: 400,
                width: 400,
                child: Image(
                  fit: BoxFit.cover,
                  image:
                      NetworkImage(localChallengeList[widget.idx]['image_url']),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.only(left: 10),
              child: const Text(
                "Hint:",
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              width: double.infinity,
              child: Container(
                color: const Color.fromARGB(76, 0, 0, 0),
                child: InkWell(
                  onTap: (() {
                    setState(() {
                      _clicked = !_clicked;
                    });
                  }),
                  child: Center(
                    child: _clicked
                        ? Text(
                            localChallengeList[widget.idx]['hint'],
                          )
                        : const Text("Click to show hint"),
                  ),
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Widget pictureCard(context, idx) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OpenChallenge(idx: idx)),
      );
    },
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.9),
              spreadRadius: 0.5,
              blurRadius: 5,
              offset: const Offset(0, 6),
            ),
          ], borderRadius: BorderRadius.circular(30)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              height: 400,
              width: 400,
              child: Image(
                fit: BoxFit.cover,
                image: NetworkImage(localChallengeList[idx]['image_url']),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10)
      ],
    ),
  );
}

class _MyHomePageState extends State<MyHomePage> {
  int _bottomNavIndex = 0;
  List<IconData> bottom_navbarIcons = [
    Icons.home_rounded,
    Icons.sync_alt_rounded,
    //Icons.add_rounded,
    Icons.emoji_events_rounded,
    Icons.settings_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    List<Widget> _mainBodyOptions = [
      Container(
        child: Column(children: [
          const SizedBox(height: 70),
          SizedBox(
            child: Row(children: [
              const Spacer(),
              const Spacer(),
              const Spacer(),
              const Spacer(),
              const Spacer(),
              const Spacer(),
              const Spacer(),
              const Spacer(),
              const Spacer(),
              const Spacer(),
              const Spacer(),
              const Spacer(),
              const Spacer(),
              const Spacer(),
              Badge(
                badgeContent: Text(_notifications.toString()),
                position: BadgePosition.topEnd(top: -1, end: -1),
                child: OutlinedButton(
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)))),
                    onPressed: () => {},
                    child: const Icon(Icons.message_outlined)),
              ),
              const Spacer()
            ]),
          ),
          Expanded(
            child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(left: 50, right: 50),
                children: List<Widget>.generate(localChallengeList.length,
                    (index) => pictureCard(context, index))),
          ),
        ]),
      ),
      Container(),
      Container(),
      Container(),
      Container()
    ];

    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: _mainBodyOptions.elementAt(_bottomNavIndex),
      ),
      floatingActionButton: FloatingActionButton(
        //params
        child: const Icon(Icons.add_rounded),
        onPressed: (() => {_bottomNavIndex = 5}),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: bottom_navbarIcons,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        //other params
      ),
    );
  }
}
