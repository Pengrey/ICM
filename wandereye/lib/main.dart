import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:badges/badges.dart';
import 'package:geolocator/geolocator.dart';

// nearby sync
import 'package:image_picker/image_picker.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'dart:typed_data';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final camera = cameras.first;
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

  availableCameras().then((availableCameras) {
    cameras = availableCameras;
    camera = cameras.first;
  });
  String imagePath;

  return Scaffold(
      appBar: AppBar(
        title: Text("Create a challenge"),
      ),
      body: ListView(
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TakePictureScreen(
                      camera: camera,
                    ),
                  ),
                );
              },
              child: Text("Pic!"))
        ],
      ));
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

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                ),
              ),
            );
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
  int _bottomNavIndex = 0;
  List<IconData> bottom_navbarIcons = [
    Icons.home_rounded,
    Icons.sync_alt_rounded,
    //Icons.add_rounded,
    Icons.emoji_events_rounded,
    Icons.settings_rounded,
  ];

  static const String _kLocationServicesDisabledMessage =
      'Location services are disabled.';
  static const String _kPermissionDeniedMessage = 'Permission denied.';
  static const String _kPermissionDeniedForeverMessage =
      'Permission denied forever.';
  static const String _kPermissionGrantedMessage = 'Permission granted.';

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  final List<_PositionItem> _positionItems = <_PositionItem>[];
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;
  bool positionStreamStarted = false;

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
            onPressed: () => {},
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

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return;
    }

    final position = await _geolocatorPlatform.getCurrentPosition();
    _updatePositionList(
      _PositionItemType.position,
      position.toString(),
    );
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      _updatePositionList(
        _PositionItemType.log,
        _kLocationServicesDisabledMessage,
      );

      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        _updatePositionList(
          _PositionItemType.log,
          _kPermissionDeniedMessage,
        );

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      _updatePositionList(
        _PositionItemType.log,
        _kPermissionDeniedForeverMessage,
      );

      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    _updatePositionList(
      _PositionItemType.log,
      _kPermissionGrantedMessage,
    );
    return true;
  }

  void _updatePositionList(_PositionItemType type, String displayValue) {
    _positionItems.add(_PositionItem(type, displayValue));
    setState(() {});
    print(_PositionItem(type, displayValue));
  }

  void _toggleServiceStatusStream() {
    if (_serviceStatusStreamSubscription == null) {
      final serviceStatusStream = _geolocatorPlatform.getServiceStatusStream();
      _serviceStatusStreamSubscription =
          serviceStatusStream.handleError((error) {
        _serviceStatusStreamSubscription?.cancel();
        _serviceStatusStreamSubscription = null;
      }).listen((serviceStatus) {
        String serviceStatusValue;
        if (serviceStatus == ServiceStatus.enabled) {
          if (positionStreamStarted) {
            _toggleListening();
          }
          serviceStatusValue = 'enabled';
        } else {
          if (_positionStreamSubscription != null) {
            setState(() {
              _positionStreamSubscription?.cancel();
              _positionStreamSubscription = null;
              _updatePositionList(
                  _PositionItemType.log, 'Position Stream has been canceled');
            });
          }
          serviceStatusValue = 'disabled';
        }
        _updatePositionList(
          _PositionItemType.log,
          'Location service has been $serviceStatusValue',
        );
      });
    }
  }

  void _toggleListening() {
    if (_positionStreamSubscription == null) {
      final positionStream = _geolocatorPlatform.getPositionStream();
      _positionStreamSubscription = positionStream.handleError((error) {
        _positionStreamSubscription?.cancel();
        _positionStreamSubscription = null;
      }).listen((position) => _updatePositionList(
            _PositionItemType.position,
            position.toString(),
          ));
      _positionStreamSubscription?.pause();
    }

    setState(() {
      if (_positionStreamSubscription == null) {
        return;
      }

      String statusDisplayValue;
      if (_positionStreamSubscription!.isPaused) {
        _positionStreamSubscription!.resume();
        statusDisplayValue = 'resumed';
      } else {
        _positionStreamSubscription!.pause();
        statusDisplayValue = 'paused';
      }

      _updatePositionList(
        _PositionItemType.log,
        'Listening for position updates $statusDisplayValue',
      );
    });
  }

  @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription!.cancel();
      _positionStreamSubscription = null;
    }

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    positionStreamStarted = !positionStreamStarted;
    _toggleServiceStatusStream();
  }

  void _getLastKnownPosition() async {
    final position = await _geolocatorPlatform.getLastKnownPosition();
    if (position != null) {
      _updatePositionList(
        _PositionItemType.position,
        position.toString(),
      );
    } else {
      _updatePositionList(
        _PositionItemType.log,
        'No last known position available',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _mainBodyOptions = [
      Container(
        child: Column(children: [
          Expanded(
            child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(left: 50, right: 50),
                children: youGotMail +
                    List<Widget>.generate(localChallengeList.length,
                        (index) => pictureCard(context, index))),
          ),
        ]),
      ),
      const Body(),
      Container(),
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
      floatingActionButton: FloatingActionButton(
        //params
        child: const Icon(Icons.add_rounded),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateChallengeScreen(context)),
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

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  _MyBodyState createState() => _MyBodyState();
}

class _MyBodyState extends State<Body> {
  final String userName = Random().nextInt(10000).toString(); // TODO
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

enum _PositionItemType {
  log,
  position,
}

class _PositionItem {
  _PositionItem(this.type, this.displayValue);

  final _PositionItemType type;
  final String displayValue;
}

class Debug extends StatefulWidget {
  const Debug({Key? key}) : super(key: key);

  @override
  _MyDebugState createState() => _MyDebugState();
}

class _MyDebugState extends State<Debug> {
  final String userName = Random().nextInt(10000).toString();
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
