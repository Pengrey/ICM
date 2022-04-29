import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:badges/badges.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// nearby sync
import 'package:image_picker/image_picker.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'dart:typed_data';

// Found chall popup
import 'package:rflutter_alert/rflutter_alert.dart';

// Name generator
import 'package:english_words/english_words.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:wandereye/users_scores.dart';

late SharedPreferences localData;
List? lastPosition;
List? challPosition;
final String userName = generateWordPairs().first.asString;

String gameServer = "https://wandereye.azurewebsites.net/";
// ========= For testing purposes only ==========
late List<Map<String, dynamic>> localChallengeList;
List<Map<String, dynamic>> test_localChallengeList = [
  {
    "token": "12345",
    "image_url":
        "https://s2.glbimg.com/6VyBKVon5j6Ofdc70Yt9c1FTlvk=/0x0:695x521/984x0/smart/filters:strip_icc()/i.s3.glbimg.com/v1/AUTH_08fbf48bc0524877943fe86e43087e7a/internal_photos/bs/2021/9/Q/4z9FL4T1G7MKHrl1AYpg/2014-04-11-bliss.jpg",
    "hint": "Try Jumping.",
    "ts": DateTime.now().toUtc().millisecondsSinceEpoch / 1000,
  },
  {
    "token": "45678",
    "image_url":
        "https://staticg.sportskeeda.com/editor/2022/02/45fd5-16457369574775-1920.jpg",
    "hint": "Behold, dog!",
    "ts": DateTime.now().toUtc().millisecondsSinceEpoch / 1000,
  },
  {
    "token": "90000",
    "image_url":
        "https://curatedmint.com/wp-content/uploads/2021/07/warframe-fortuna-720x720.jpg",
    "hint": "Secret wall ahead.",
    "ts": DateTime.now().toUtc().millisecondsSinceEpoch / 1000,
  }
];

//=======================================

List<String> listMapToJsonList(List<Map<String, dynamic>> input) {
  List<String> tmp = [];
  for (Map<String, dynamic> it in input) {
    tmp.add(json.encode(it));
  }

  return tmp;
}

List<Map<String, dynamic>> jsonListToListMap(List<String> input) {
  List<Map<String, dynamic>> tmp = [];
  for (String it in input) {
    tmp.add(json.decode(it));
  }

  return tmp;
}

void sendLocalChallToServer() {
  List<String>? dataLocal = localData.containsKey('localChal')
      ? localData.getStringList('localChal')
      : [""];

  if (dataLocal!.isEmpty) {
    return;
  }

  List<String> data = [
    userName, //duh
    // b64img, // image in b64 format :)
    dataLocal[1], //timestamp
    dataLocal[2], //location
    dataLocal[3], //hint
  ];

  var postUri = Uri.parse(gameServer + "submit");
  var request = http.MultipartRequest("POST", postUri);

  request.fields['user'] = userName;
  request.fields['timestamp'] = dataLocal[1];
  request.fields['location'] = dataLocal[2];
  request.fields['hint'] = dataLocal[3];

  Uint8List img = File(dataLocal[0]).readAsBytesSync();
  String img64 = base64Encode(img);

  request.fields['image'] = img64;
  //request.files.add(http.MultipartFile.fromBytes('image', img,
  //    contentType: MediaType('image', 'jpeg')));
  //print("sent a request to " + gameServer);
  request.send().then((response) {
    if (response.statusCode == 200) print("Uploaded!");
  });
}

void fetchChallengeFromServer(userID) {
  var uri = Uri.parse(gameServer + "challenge/" + userID.toString());
  //var request = http.MultipartRequest("GET", postUri);
  http.get(uri).then((response) {
    if (response.statusCode == 200) {
      print(response);
      Map<String, dynamic> resp = jsonDecode(response.body);
      print(resp['user']);

      Map<String, dynamic> newChallenge = {
        "token": resp['user'],
        "image_url": gameServer + resp['user'] + '.jpg',
        "hint": resp['hint'],
        "ts": DateTime.now().toUtc().millisecondsSinceEpoch / 1000,
      };
      localChallengeList.add(newChallenge);
      localData.setStringList(
          'challenges', listMapToJsonList(localChallengeList));
      print("New challenge!");
      reloadChallengeList();
    }
  });
}

//TODO Apply this where needed. maybe when loadnig main page?
void verifyExpiredChallenges() {
  if (localData.containsKey('localChal')) {
    List<String>? localCh = localData.getStringList('localChal');
    if ((DateTime.now().toUtc().millisecondsSinceEpoch / 1000) -
            double.parse(localCh![1]) >
        10000) {
      localData.remove('localChal');
    }
  }

  if (localData.containsKey('challenges')) {
    List<String>? tmp = localData.getStringList('challenges');
    if (tmp != null) {
      List<Map<String, dynamic>> challs = jsonListToListMap(tmp);
      List<Map<String, dynamic>> to_save = jsonListToListMap(tmp);

      for (Map<String, dynamic> chall in challs) {
        if (DateTime.now().toUtc().millisecondsSinceEpoch / 1000 - chall['ts'] >
            86400) {
          to_save.remove(chall);
        }
      }
      localData.setStringList('challenges', listMapToJsonList(to_save));
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  localData = await SharedPreferences.getInstance();

  //for testing only
  //List<String> encodedList = listMapToJsonList(test_localChallengeList);
  await localData.clear();

  //await localData.setStringList('challenges', encodedList);

  //actual things
  verifyExpiredChallenges();
  final cameras = await availableCameras();
  final camera = cameras.first;

  if (localData.containsKey('challenges')) {
    List<String>? tmp = localData.getStringList('challenges');
    localChallengeList = jsonListToListMap(tmp!);
  } else {
    localChallengeList = [];
  }
  print("LOADED");
  runApp(const MyApp());
}

/*

List<List<String>> localChallengeList = [
  [
    "12345", //id
    "https://s2.glbimg.com/6VyBKVon5j6Ofdc70Yt9c1FTlvk=/0x0:695x521/984x0/smart/filters:strip_icc()/i.s3.glbimg.com/v1/AUTH_08fbf48bc0524877943fe86e43087e7a/internal_photos/bs/2021/9/Q/4z9FL4T1G7MKHrl1AYpg/2014-04-11-bliss.jpg",
    "Try Jumping.", // hint
    "12345", // timestamp
    "123455", // latitude,
    "12345" //longitude
  ],
  [
    "45678",
    "https://staticg.sportskeeda.com/editor/2022/02/45fd5-16457369574775-1920.jpg",
    "Behold, dog!",
    "1234",
    "1234",
    "1234"
  ],
  [
    "90000",
    "https://curatedmint.com/wp-content/uploads/2021/07/warframe-fortuna-720x720.jpg",
    "Secret wall ahead.",
    "1234",
    "1234",
    "1234"
  ]
];

*/
int _notifications = 1;

void reloadChallengeList() async {
  print("REloaded!");
  verifyExpiredChallenges();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WanderEye',
      theme: ThemeData(
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
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Widget CreateChallengeScreen(context) {
  late CameraDescription camera;
  List<CameraDescription> cameras;
  late TextEditingController _controller;

  availableCameras().then((availableCameras) {
    cameras = availableCameras;
    camera = cameras.first;
  });
  _controller = TextEditingController();
  late String hint;
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Scaffold(
          appBar: AppBar(
            title: Text("Create a challenge"),
          ),
          body: Column(
            children: [
              localData.getStringList('localChal') != null
                  ? Image.file(File(localData.getStringList('localChal')![0]))
                  : Image.network(
                      'https://images.assetsdelivery.com/compings_v2/yehorlisnyi/yehorlisnyi2104/yehorlisnyi210400016.jpg'),
              Center(
                child: TextField(
                    controller: _controller,
                    onSubmitted: (String value) async {
                      hint = value;
                    }),
              ),
              localData.getStringList('localChal') == null
                  ? ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TakePictureScreen(
                              camera: camera,
                            ),
                          ),
                        ).then((value) => setState(() {}));
                      },
                      child: Text("Take Pic!"))
                  : ElevatedButton(
                      onPressed: () {
                        List<String>? tmp =
                            localData.getStringList('localChal');

                        tmp!.add(hint);
                        localData.setStringList('localChal', tmp);
                        sendLocalChallToServer();
                        Navigator.pop(context);
                      },
                      child: Text("Create Challenge!"))
            ],
          ));
    },
  );
}

class SeeLocalChallenge extends StatefulWidget {
  const SeeLocalChallenge({Key? key}) : super(key: key);

  @override
  State<SeeLocalChallenge> createState() => _LocalChallengeState();
}

class _LocalChallengeState extends State<SeeLocalChallenge> {
  List<String>? localChal = localData.getStringList('localChal');
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Your Challenge!"),
      content: Column(
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
                child: Image.file(File(localChal![0]), fit: BoxFit.cover),
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
                            localChal![3],
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

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);
  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();
            Position position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high);
            final loc = await Geolocator.getCurrentPosition();
            if (position == null || image == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Couldn't obtain location/picture :(")));
            } else {
              List<String> myChallData = [
                image.path,
                (DateTime.now().toUtc().millisecondsSinceEpoch / 1000)
                    .toString(),
                loc.toString()
              ];

              await localData.setStringList('localChal', myChallData);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(myChallData.toString()),
                ),
              );
            }

            // If the picture was taken, display it on a new screen.
            Navigator.pop(context);
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
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

  // Location stuff
  final StreamController<Position> _locStream = StreamController();
  late StreamSubscription<Position> locationSubscription;

  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }

  startLocation() {
    final positionStream =
        Geolocator.getPositionStream().handleError((error) {});
    locationSubscription = positionStream.listen((Position position) {
      _locStream.sink.add(position);

      // DEBUG STUFF
      //showSnackbar("LastP: $lastPosition"); // show last position
      //challPosition = ["40.9596", "-8.6340"]; // mocked challenge position TODO: make coord assignments

      // We get lasposition initiated
      lastPosition ??= [
        position.latitude.toStringAsFixed(4),
        position.longitude.toStringAsFixed(4)
      ];

      // If position changes, we change last position
      if (lastPosition![0] != position.latitude.toStringAsFixed(4) ||
          lastPosition![1] != position.longitude.toStringAsFixed(4)) {
        lastPosition = [
          position.latitude.toStringAsFixed(4),
          position.longitude.toStringAsFixed(4)
        ];
        showSnackbar(
            "Changed to Lat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}");
      }

      // Check if coords equal to chall
      if (challPosition != null &&
          lastPosition != null &&
          lastPosition![0] == challPosition![0] &&
          lastPosition![1] == challPosition![1]) showChallFouPopup(context);
    });
  }

  showChallFouPopup(context) {
    // Reusable alert style
    var alertStyle = AlertStyle(
        animationType: AnimationType.fromTop,
        isCloseButton: false,
        isOverlayTapDismiss: false,
        descStyle: const TextStyle(fontWeight: FontWeight.bold),
        animationDuration: const Duration(milliseconds: 400),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
          side: const BorderSide(
            color: Colors.grey,
          ),
        ),
        titleStyle: const TextStyle(
          color: Colors.green,
        ),
        constraints: const BoxConstraints.expand(width: 300),
        //First to chars "55" represents transparency of color
        overlayColor: const Color(0x55000000),
        alertElevation: 0,
        alertAlignment: Alignment.topCenter);

    // Alert dialog using custom alert style
    Alert(
      context: context,
      style: alertStyle,
      type: AlertType.success,
      title: "Congratulations!",
      desc: "You found me :D",
      buttons: [
        DialogButton(
          child: const Text(
            "Yay",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: const Color.fromRGBO(0, 179, 134, 1.0),
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }

  @override
  void initState() {
    super.initState();
    GeolocatorPlatform.instance.requestPermission();
    startLocation();
  }

  @override
  void dispose() {
    _locStream.close();
    locationSubscription.cancel();
    super.dispose();
  }

  int _bottomNavIndex = 0;
  List<IconData> bottom_navbarIcons = [
    Icons.home_rounded,
    Icons.sync_alt_rounded,
    //Icons.add_rounded,
    Icons.emoji_events_rounded,
    Icons.settings_rounded,
  ];
  int chalSize = localChallengeList != [{}] ? localChallengeList.length : 0;
  List<Widget> youGotMail = <Widget>[
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
          child: FloatingActionButton(
            heroTag: "notifBut",
            onPressed: () => {fetchChallengeFromServer(1234)},
            child: const Icon(Icons.message_outlined),
            mini: true,
            shape: const ContinuousRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(18))),
          ),
        ),
        const Spacer()
      ]),
    )
  ];

  @override
  Widget build(BuildContext context) {
    List<Widget> _mainBodyOptions = [
      Container(
        child: Column(children: [
          Expanded(
            child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(left: 50, right: 50),
                children: chalSize > 0
                    ? (youGotMail +
                        List<Widget>.generate(
                            chalSize, (index) => pictureCard(context, index)))
                    : [Spacer()]),
          ),
        ]),
      ),
      const NearbyPage(),
      LeaderboardPage(),
      Container(),
      Container(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container();
          },
        ),
      ),
    ];

    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: _mainBodyOptions.elementAt(_bottomNavIndex),
      ),
      floatingActionButton: localData.getStringList('localChal') == null
          ? FloatingActionButton(
              heroTag: "noChalBut",
              //params
              child: const Icon(Icons.add_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateChallengeScreen(context)),
                ).then((value) => setState(() {}));
              },
            )
          : FloatingActionButton(
              heroTag: "yesChalBut",
              //params
              child: const Icon(Icons.picture_in_picture),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SeeLocalChallenge()),
                );
              },
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

class NearbyPage extends StatefulWidget {
  const NearbyPage({Key? key}) : super(key: key);

  @override
  _NearbyPageState createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  final Strategy strategy = Strategy.P2P_STAR;
  Map<String, ConnectionInfo> endpointMap = {};

  String? tempFileUri; //reference to the file currently being transferred
  Map<int, String> map = {}; //store filename mapped to corresponding payloadId

  void _debugPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Debug(),
        ));
  }

  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }

  prePermitions() async {
    // If there isnt permition for location then we ask for it
    if (!await Nearby().checkLocationPermission()) {
      if (!await Nearby().askLocationPermission()) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location Permission not granted")));
      }
    }

    if (!await Nearby().checkLocationEnabled()) {
      if (!await Nearby().enableLocationServices()) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Enabling Location Service Failed")));
      }
    }

    // If there isnt permition for External Storage then we ask for it
    if (!await Nearby().checkExternalStoragePermission()) {
      Nearby().askExternalStoragePermission();

      if (!await Nearby().checkExternalStoragePermission()) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("External Storage Permission not granted")));
      }
    }

    // If there isnt permition for bluetooth (Android 12+) then we ask for it
    if (!await Nearby().checkBluetoothPermission()) {
      Nearby().askBluetoothPermission();
    }
  }

  void onConnectionInit(String id, ConnectionInfo info) {
    endpointMap[id] = info;
    Nearby().acceptConnection(id, onPayLoadRecieved: (endid, payload) async {
      if (payload.type == PayloadType.BYTES) {
        String str = String.fromCharCodes(payload.bytes!);
        showSnackbar("New challenge: " + str);
        fetchChallengeFromServer(str);
      } else {
        showSnackbar("Format ERROR");
      }
    });
  }

  sendChallenge() async {
    // Start Advertising
    try {
      bool a = await Nearby().startAdvertising(
        userName,
        strategy,
        onConnectionInitiated: onConnectionInit,
        onConnectionResult: (id, status) {
          showSnackbar(status);

          // Send challenge
          endpointMap.forEach((key, value) {
            showSnackbar(
                "Sending $userName to ${value.endpointName}, id: $key");
            Nearby()
                .sendBytesPayload(key, Uint8List.fromList(userName.codeUnits));

            // Stop Advertising
            Nearby().stopAdvertising();
            showSnackbar("ADVERTISING: false");

            // Clear connections
            Nearby().stopAllEndpoints();
          });
        },
        onDisconnected: (id) {
          showSnackbar(
              "Disconnected: ${endpointMap[id]!.endpointName}, id $id");
          setState(() {
            endpointMap.remove(id);
          });
        },
      );
      showSnackbar("ADVERTISING: " + a.toString());
    } catch (exception) {
      showSnackbar(exception);
    }
  }

  receiveChallenge() async {
    try {
      bool a = await Nearby().startDiscovery(
        userName,
        strategy,

        // On connection found
        onEndpointFound: (id, name, serviceId) {
          // Automatically accept the request connection
          Nearby().requestConnection(
            userName,
            id,
            onConnectionInitiated: (id, info) {
              onConnectionInit(id, info);
            },
            onConnectionResult: (id, status) {
              showSnackbar(status);

              // Stop Discovery
              Nearby().stopDiscovery();
              showSnackbar("DISCOVERY: false");

              // Clear connections
              Nearby().stopAllEndpoints();
            },
            onDisconnected: (id) {
              setState(() {
                endpointMap.remove(id);
              });
              showSnackbar(
                  "Disconnected from: ${endpointMap[id]!.endpointName}, id $id");
            },
          );
        },
        onEndpointLost: (id) {
          showSnackbar(
              "Lost discovered Endpoint: ${endpointMap[id]!.endpointName}, id $id");
        },
      );
      showSnackbar("DISCOVERING: " + a.toString());
    } catch (e) {
      showSnackbar(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _debugPage,
        label: const Text('Debug'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Text(
            "Nearby share",
          ),
          const Image(image: AssetImage('assets/nearbySharing.png')),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton.icon(
                  icon: const Icon(
                    Icons.upload,
                  ),
                  label: const Text("Send"),
                  onPressed: () {
                    prePermitions();
                    sendChallenge();
                  }),
              ElevatedButton.icon(
                  icon: const Icon(
                    Icons.download,
                  ),
                  label: const Text("Receive"),
                  onPressed: () {
                    prePermitions();
                    receiveChallenge();
                  }),
            ],
          ),
        ],
      ),
    );
  }
}

class LeaderboardPage extends StatelessWidget {
  LeaderboardPage({Key? key}) : super(key: key);

  List<Map<String, Object>> data = UsersScore.getScores;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 40),
              const Image(image: AssetImage('assets/podium.png')),
              Expanded(
                  child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                          height: 70,
                          width: double.maxFinite,
                          child: Card(
                            elevation: 5,
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
                                                  userPosition(data[index]),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  userName(data[index]),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  const Spacer(),
                                                  userScore(data[index]),
                                                  const SizedBox(
                                                    width: 20,
                                                  )
                                                ],
                                              ),
                                            ],
                                          ))
                                    ],
                                  ),
                                )
                              ]),
                            ),
                          ),
                        );
                      }))
            ],
          ),
        ));
  }

  static Widget userName(data) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: '   ${data['name']}',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
      ),
    );
  }

  static Widget userScore(data) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: '${data['points']}',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
      ),
    );
  }

  static Widget userPosition(data) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: '${data['position']}',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
      ),
    );
  }
}

// DEBUG stuff to clean later

class Debug extends StatefulWidget {
  const Debug({Key? key}) : super(key: key);

  @override
  _MyDebugState createState() => _MyDebugState();
}

class _MyDebugState extends State<Debug> {
  final Strategy strategy = Strategy.P2P_STAR;
  Map<String, ConnectionInfo> endpointMap = {};

  String? tempFileUri; //reference to the file currently being transferred
  Map<int, String> map = {}; //store filename mapped to corresponding payloadId

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Debug Menu'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: <Widget>[
                Wrap(
                  children: <Widget>[
                    const Text(
                      "Nearby share",
                    ),
                    const Text(
                      "Permissions",
                    ),
                    ElevatedButton(
                      child: const Text("checkLocationPermission"),
                      onPressed: () async {
                        if (await Nearby().checkLocationPermission()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Location permissions granted :)")));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Location permissions not granted :(")));
                        }
                      },
                    ),
                    ElevatedButton(
                      child: const Text("askLocationPermission"),
                      onPressed: () async {
                        if (await Nearby().askLocationPermission()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Location Permission granted :)")));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Location permissions not granted :(")));
                        }
                      },
                    ),
                    ElevatedButton(
                      child: const Text("checkExternalStoragePermission"),
                      onPressed: () async {
                        if (await Nearby().checkExternalStoragePermission()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "External Storage permissions granted :)")));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  "External Storage permissions not granted :(")));
                        }
                      },
                    ),
                    ElevatedButton(
                      child: const Text("askExternalStoragePermission"),
                      onPressed: () {
                        Nearby().askExternalStoragePermission();
                      },
                    ),
                    ElevatedButton(
                      child:
                          const Text("checkBluetoothPermission (Android 12+)"),
                      onPressed: () async {
                        if (await Nearby().checkBluetoothPermission()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Bluethooth permissions granted :)")));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Bluetooth permissions not granted :(")));
                        }
                      },
                    ),
                    ElevatedButton(
                      child: const Text("askBluetoothPermission (Android 12+)"),
                      onPressed: () {
                        Nearby().askBluetoothPermission();
                      },
                    ),
                  ],
                ),
                const Divider(),
                const Text("Location Enabled"),
                Wrap(
                  children: <Widget>[
                    ElevatedButton(
                      child: const Text("checkLocationEnabled"),
                      onPressed: () async {
                        if (await Nearby().checkLocationEnabled()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Location is ON :)")));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Location is OFF :(")));
                        }
                      },
                    ),
                    ElevatedButton(
                      child: const Text("enableLocationServices"),
                      onPressed: () async {
                        if (await Nearby().enableLocationServices()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Location Service Enabled :)")));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Enabling Location Service Failed :(")));
                        }
                      },
                    ),
                  ],
                ),
                const Divider(),
                Text("User Name: " + userName),
                Wrap(
                  children: <Widget>[
                    ElevatedButton(
                      child: const Text("Start Advertising"),
                      onPressed: () async {
                        try {
                          bool a = await Nearby().startAdvertising(
                            userName,
                            strategy,
                            onConnectionInitiated: onConnectionInit,
                            onConnectionResult: (id, status) {
                              showSnackbar(status);
                            },
                            onDisconnected: (id) {
                              showSnackbar(
                                  "Disconnected: ${endpointMap[id]!.endpointName}, id $id");
                              setState(() {
                                endpointMap.remove(id);
                              });
                            },
                          );
                          showSnackbar("ADVERTISING: " + a.toString());
                        } catch (exception) {
                          showSnackbar(exception);
                        }
                      },
                    ),
                    ElevatedButton(
                      child: const Text("Stop Advertising"),
                      onPressed: () async {
                        await Nearby().stopAdvertising();
                      },
                    ),
                  ],
                ),
                Wrap(
                  children: <Widget>[
                    ElevatedButton(
                      child: const Text("Start Discovery"),
                      onPressed: () async {
                        try {
                          bool a = await Nearby().startDiscovery(
                            userName,
                            strategy,
                            onEndpointFound: (id, name, serviceId) {
                              // show sheet automatically to request connection
                              showModalBottomSheet(
                                context: context,
                                builder: (builder) {
                                  return Center(
                                    child: Column(
                                      children: <Widget>[
                                        Text("id: " + id),
                                        Text("Name: " + name),
                                        Text("ServiceId: " + serviceId),
                                        ElevatedButton(
                                          child:
                                              const Text("Request Connection"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Nearby().requestConnection(
                                              userName,
                                              id,
                                              onConnectionInitiated:
                                                  (id, info) {
                                                onConnectionInit(id, info);
                                              },
                                              onConnectionResult: (id, status) {
                                                showSnackbar(status);
                                              },
                                              onDisconnected: (id) {
                                                setState(() {
                                                  endpointMap.remove(id);
                                                });
                                                showSnackbar(
                                                    "Disconnected from: ${endpointMap[id]!.endpointName}, id $id");
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            onEndpointLost: (id) {
                              showSnackbar(
                                  "Lost discovered Endpoint: ${endpointMap[id]!.endpointName}, id $id");
                            },
                          );
                          showSnackbar("DISCOVERING: " + a.toString());
                        } catch (e) {
                          showSnackbar(e);
                        }
                      },
                    ),
                    ElevatedButton(
                      child: const Text("Stop Discovery"),
                      onPressed: () async {
                        await Nearby().stopDiscovery();
                      },
                    ),
                  ],
                ),
                Text("Number of connected devices: ${endpointMap.length}"),
                ElevatedButton(
                  child: const Text("Stop All Endpoints"),
                  onPressed: () async {
                    await Nearby().stopAllEndpoints();
                    setState(() {
                      endpointMap.clear();
                    });
                  },
                ),
                const Divider(),
                const Text(
                  "Sending Data",
                ),
                ElevatedButton(
                  child: const Text("Send Random Bytes Payload"),
                  onPressed: () async {
                    endpointMap.forEach((key, value) {
                      String a = Random().nextInt(100).toString();

                      showSnackbar(
                          "Sending $a to ${value.endpointName}, id: $key");
                      Nearby().sendBytesPayload(
                          key, Uint8List.fromList(a.codeUnits));
                    });
                  },
                ),
                ElevatedButton(
                  child: const Text("Send File Payload"),
                  onPressed: () async {
                    PickedFile? file = await ImagePicker()
                        .getImage(source: ImageSource.gallery);

                    if (file == null) return;

                    for (MapEntry<String, ConnectionInfo> m
                        in endpointMap.entries) {
                      int payloadId =
                          await Nearby().sendFilePayload(m.key, file.path);
                      showSnackbar("Sending file to ${m.key}");
                      Nearby().sendBytesPayload(
                          m.key,
                          Uint8List.fromList(
                              "$payloadId:${file.path.split('/').last}"
                                  .codeUnits));
                    }
                  },
                ),
                ElevatedButton(
                  child: const Text("Print file names."),
                  onPressed: () async {
                    final dir = (await getExternalStorageDirectory())!;
                    final files = (await dir.list(recursive: true).toList())
                        .map((f) => f.path)
                        .toList()
                        .join('\n');
                    showSnackbar(files);
                  },
                ),
                const Divider(),
                const Text("Server stuff"),
                ElevatedButton(
                  child: const Text("Send local challenge to server"),
                  onPressed: () {
                    sendLocalChallToServer();
                  },
                ),
              ],
            ),
          ),
        ));
  }

  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }

  Future<bool> moveFile(String uri, String fileName) async {
    String parentDir = (await getExternalStorageDirectory())!.absolute.path;
    final b =
        await Nearby().copyFileAndDeleteOriginal(uri, '$parentDir/$fileName');

    showSnackbar("Moved file:" + b.toString());
    return b;
  }

  /// Called upon Connection request (on both devices)
  /// Both need to accept connection to start sending/receiving
  void onConnectionInit(String id, ConnectionInfo info) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Center(
          child: Column(
            children: <Widget>[
              Text("id: " + id),
              Text("Token: " + info.authenticationToken),
              Text("Name" + info.endpointName),
              Text("Incoming: " + info.isIncomingConnection.toString()),
              ElevatedButton(
                child: const Text("Accept Connection"),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    endpointMap[id] = info;
                  });
                  Nearby().acceptConnection(
                    id,
                    onPayLoadRecieved: (endid, payload) async {
                      if (payload.type == PayloadType.BYTES) {
                        String str = String.fromCharCodes(payload.bytes!);
                        showSnackbar(endid + ": " + str);

                        if (str.contains(':')) {
                          // used for file payload as file payload is mapped as
                          // payloadId:filename
                          int payloadId = int.parse(str.split(':')[0]);
                          String fileName = (str.split(':')[1]);

                          if (map.containsKey(payloadId)) {
                            if (tempFileUri != null) {
                              moveFile(tempFileUri!, fileName);
                            } else {
                              showSnackbar("File doesn't exist");
                            }
                          } else {
                            //add to map if not already
                            map[payloadId] = fileName;
                          }
                        }
                      } else if (payload.type == PayloadType.FILE) {
                        showSnackbar(endid + ": File transfer started");
                        tempFileUri = payload.uri;
                      }
                    },
                    onPayloadTransferUpdate: (endid, payloadTransferUpdate) {
                      if (payloadTransferUpdate.status ==
                          PayloadStatus.IN_PROGRESS) {
                        print(payloadTransferUpdate.bytesTransferred);
                      } else if (payloadTransferUpdate.status ==
                          PayloadStatus.FAILURE) {
                        print("failed");
                        showSnackbar(endid + ": FAILED to transfer file");
                      } else if (payloadTransferUpdate.status ==
                          PayloadStatus.SUCCESS) {
                        showSnackbar(
                            "$endid success, total bytes = ${payloadTransferUpdate.totalBytes}");

                        if (map.containsKey(payloadTransferUpdate.id)) {
                          //rename the file now
                          String name = map[payloadTransferUpdate.id]!;
                          moveFile(tempFileUri!, name);
                        } else {
                          //bytes not received till yet
                          map[payloadTransferUpdate.id] = "";
                        }
                      }
                    },
                  );
                },
              ),
              ElevatedButton(
                child: const Text("Reject Connection"),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await Nearby().rejectConnection(id);
                  } catch (e) {
                    showSnackbar(e);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
