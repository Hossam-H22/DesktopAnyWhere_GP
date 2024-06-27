import 'dart:convert';
import 'package:desktop_anywhere_web/Components.dart';
import 'package:desktop_anywhere_web/signaling.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:flutter_webrtc/flutter_webrtc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: "AIzaSyAVjZjh4_Bn6pyRzLKTO23Pw5HT8FqTQOQ",
    authDomain: "desktopanywhere-7ea4c.firebaseapp.com",
    projectId: "desktopanywhere-7ea4c",
    storageBucket: "desktopanywhere-7ea4c.appspot.com",
    messagingSenderId: "1095289543550",
    appId: "1:1095289543550:android:12bca12be0ea8c4b25712f",
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Desktop Anywhere',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late IO.Socket socket;
  String? roomId;
  String? ipAddress;
  String? password;
  String? macAddress;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  Signaling signaling = Signaling();
  late Map<String, dynamic> configuration;
  String serverLink = "https://desktopanywhere.onrender.com";
  var connections = [];
  bool loading = true;

  void getPassword() {
    socket.emit("event", {
      "ip": ipAddress,
      "type": "web",
      "target_type": "desktop",
      "event": "getPassword",
      "message": "",
      "eventError": "errorPassword", // error event if target not found
      "messageError": "device not found",
    });
  }

  void refreshPassword() {
    socket.emit("event", {
      "ip": ipAddress,
      "type": "web",
      "target_type": "desktop",
      "event": "refreshPassword",
      "message": "",
      "eventError": "errorPassword", // error event if target not found
      "messageError": "device not found",
    });
  }

  void socketFunction() {
    socket = IO.io(
      serverLink,
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );

    socket.onConnect((_) async {
      print('connect');
      print(socket.id);
      socket.emit('addDevice', {
        // "id": socket.id,
        "ip": ipAddress,
        "type": "web"
      });

      if (password == null) {
        await Future.delayed(const Duration(seconds: 1));
        getPassword();
      }
    });

    socket.on("password", (data) {
      print("get password: $data");
      setState(() {
        password = data;
      });
    });

    socket.on("errorPassword", (data) async {
      print("$data \n\n\n");
      await Future.delayed(const Duration(seconds: 2));
      getPassword();
    });

    socket.on("roomId", (data) {
      print(data);
      signaling.hangUp(_localRenderer);
      signaling.joinRoom(data["roomId"], _remoteRenderer, configuration);
    });

    socket.on("refreshConnection", (data) async {
      print("refreshConnection event \n\n\n\n\n\n\n\n");
      await getConnections();
    });

    socket.onDisconnect((_) {
      print('disconnect');
    });
  }

  Future<bool> getPublicIP() async {
    try {
      var response =
          await http.get(Uri.parse('https://api.ipify.org/?format=json'));
      if (response.statusCode == 200) {
        // Parse the JSON response
        var data = jsonDecode(response.body);
        // Extract the IP address
        ipAddress = data['ip'];
        setState(() {});
        print(ipAddress);
        // socketFunction();
        return true;
      } else {
        // If the request was not successful, return an empty string or handle the error accordingly
        return false;
      }
    } catch (e) {
      // Handle any errors that might occur during the process
      print('Error getting public IP: $e');
      return false;
    }
  }

  Future<bool> getConfigurations() async {
    final response = await http.get(
      Uri.parse('$serverLink/confegration'),
    );

    if (response.statusCode == 200) {
      configuration = json.decode(response.body)["configuration"];
      print("\n\n\n ${configuration} \n\n\n\n");
      // socketFunction();
      await getMac();
      return true;
    } else {
      return false;
    }
  }

  Future<void> getMac() async {
    final response = await http.get(
      Uri.parse('$serverLink/desktop/$ipAddress'),
    );

    if (response.statusCode == 200) {
      macAddress = json.decode(response.body)["device"]["mac_address"];
      print("\n\n\n ${macAddress} \n\n\n\n");
      getConnections();
      socketFunction();
    }
  }

  Future<void> getConnections() async {
    setState(() {
      loading = true;
    });
    final response = await http.get(
      Uri.parse('$serverLink/connection/desktop/$macAddress'),
    );

    if (response.statusCode == 200) {
      connections = json.decode(response.body)["mobiles"];
      print("\n\n\n ${connections} \n\n\n\n");
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> deleteConnection(device) async {
    setState(() {
      loading = true;
    });

    print("Delete Index: ${device["name"]}");
    final response = await http.delete(
      Uri.parse('$serverLink/connection/${device["connectionId"]}'),
      // Uri.parse('http://localhost:5000/connection/${device["connectionId"]}'),
    );

    if (response.statusCode == 200) {
      var msg = json.decode(response.body);
      print("\n\n\n ${msg} \n\n\n\n");
      await getConnections();
    }
    else {
      setState(() {
        loading = false;
      });
    }


  }

  Future<void> setUp() async {
    bool check = await getPublicIP();
    if (!check) {
      print("Trying to get public IP ....");
      check = await getPublicIP();
    }

    check = await getConfigurations();
    if (!check) {
      print("Trying to get configurations ....");
      check = await getConfigurations();
    }

    _localRenderer.initialize();
    _remoteRenderer.initialize();
    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    int x = await signaling.openUserMedia(_localRenderer, _remoteRenderer);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    setUp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Desktop Anywhere",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(right: 5.0, left: 5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // const SizedBox(height: 20,),
              Container(
                padding: const EdgeInsets.all(35),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black,
                ),
                width: 450,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Credentials",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'IP:  $ipAddress',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.copy,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: "$ipAddress"));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Password:  ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            (password!=null)? Text(
                              password!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ) : const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(color: Colors.white,),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.copy,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: "$password"));
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            refreshPassword();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 450,
                    height: 350,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black,
                      ),
                      child: _localRenderer.srcObject != null
                          ? RTCVideoView(_localRenderer)
                          : const Center(
                              child: Text(
                                "Shared Area Of Screen",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 550,
                    height: 350,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black,
                      ),
                      child: !loading
                          ? connections.isNotEmpty
                              ? SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 10,),
                                      const Text(
                                        "Authorized Devices",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 15,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          listHeader(text: "Name"),
                                          listHeader(text: "Model"),
                                          listHeader(text: "Action"),
                                        ],
                                      ),
                                      const SizedBox(height: 7,),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: connections.length,
                                        itemBuilder: (context, index) {
                                          return deviceCard(
                                            data: connections[index],
                                            fun: deleteConnection,
                                            context: context,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              : const Center(
                                  child: Text(
                                  "No Authorized Devices",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ))
                          : const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          int x =
              await signaling.openUserMedia(_localRenderer, _remoteRenderer);
          setState(() {});
          await getConnections();
        },
        tooltip: 'Share Screen',
        backgroundColor: Colors.black,
        child: const Icon(Icons.screen_share_outlined),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
