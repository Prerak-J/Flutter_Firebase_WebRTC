import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_rtc_flutter_firebase/firebase_options.dart';
import 'package:web_rtc_flutter_firebase/signaling.dart';
import 'package:web_rtc_flutter_firebase/utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Web RTC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');
  bool onCall = false;
  bool _isLoading = false;

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to Flutter WebRTC"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        signaling.openUserMedia(_localRenderer, _remoteRenderer);
                      });
                    },
                    style: const ButtonStyle(
                      side: WidgetStatePropertyAll(
                        BorderSide(
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    child: const Text("Open camera & microphone"),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      roomId = await signaling.createRoom(_remoteRenderer);
                      textEditingController.text = roomId!;
                      setState(() {
                        onCall = true;
                        _isLoading = false;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.blue[900]),
                    ),
                    child: const Text(
                      "Create room",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      bool result = await signaling.joinRoom(
                        textEditingController.text.trim(),
                        _remoteRenderer,
                      );
                      if (!result && context.mounted) {
                        showSnackBar('Invalid Room ID', context);
                      }
                      setState(() {
                        onCall = result;
                        _isLoading = false;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.green[900]),
                    ),
                    child: const Text(
                      "Join room",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      signaling.hangUp(_localRenderer);
                      setState(() {
                        onCall = false;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.red[900]),
                    ),
                    child: const Text(
                      "Hangup",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),
            _isLoading
                ? Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    ),
                  )
                : onCall
                    ? Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.46,
                                child: RTCVideoView(_localRenderer, mirror: true)),
                            const SizedBox(
                              width: 4,
                            ),
                            SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.46, child: RTCVideoView(_remoteRenderer)),
                          ],
                        ),
                      )
                    : Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                              "Tap on 'Open camera and microphone' to give access to camera and microphone.\n\nTap 'Create Room' to start a call.\n\nTap 'Join Room' to join a room with the id given below.\n\nTap 'Hang up' to end the call.\n\nHappy Calling!"),
                        ),
                      ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Join the following Room: "),
                  Flexible(
                    child: TextFormField(
                      controller: textEditingController,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}
