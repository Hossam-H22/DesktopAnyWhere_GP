import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:desktop_anywhere/modules/desktopdata/folderandfile.dart';
import 'package:desktop_anywhere/shared/cubit/states.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import the library for encoding/decoding
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';


class AppCubit extends Cubit<States> {

  AppCubit() : super(InitialState()) {
    init();
  }

  void init() async {
    await initSharedPreferences();
    await activateServer();
    await getConfigurations();
    connectOnSocketServer();
    socketListener();
    createDatabase();

    startApp = true;
    emit(ToggleStartAppState());
  }


  static AppCubit get(context) => BlocProvider.of(context);
  late IO.Socket socket;


  late Database database;
  List<Map> desktops = [];

  final record = AudioRecorder();
  final justAudio = AudioPlayer();
  CrossFadeState recordFadeState = CrossFadeState.showFirst;
  late String filePath;

  bool isUppercase = false;
  bool isArabic = true;
  bool isNum = false;
  bool isNum2 = false;
  bool isRecording = false;
  bool isPassword = true;
  String path = '';
  String serverUrl = "https://desktopanywhere.onrender.com";
  bool pairLoading = false;
  bool isCopy = false;

  String deviceName="";
  String deviceId="";
  String version_number="";
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  String deviceModel="";
  Future<void> initPlatformState() async {
    try {
      if (kIsWeb) {
        WebBrowserInfo data = await deviceInfoPlugin.webBrowserInfo;
        deviceModel = data.browserName.name.toString();
        version_number = data.appVersion.toString();
      } else {
        if(defaultTargetPlatform == TargetPlatform.android){
          AndroidDeviceInfo build = await deviceInfoPlugin.androidInfo;
          String brand =
              build.brand.toString()[0].toUpperCase()
                  + build.brand.toString().substring(1);
          deviceModel = "$brand ${build.model}";
          version_number = build.version.incremental.toString();
        }
        else if(defaultTargetPlatform == TargetPlatform.iOS){
          IosDeviceInfo data = await deviceInfoPlugin.iosInfo;
          deviceModel = data.model.toString();
          version_number = data.utsname.version.toString();
        }
        else {
          deviceModel = "Unknown Device";
        }
      }
    } on PlatformException {
      deviceModel = "Unknown Device";
    }

    print("mobile Name: $deviceModel \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
  }
  bool startApp = false;


  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late final SharedPreferences savedValues;
  Future<void> initSharedPreferences() async {
    print("initSharedPreferences  \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    savedValues = await _prefs;

    String? model = savedValues.getString("deviceModel");
    if(model==null){
      await initPlatformState();
      savedValues.setString("deviceModel", deviceModel);
    }
    else {
      print("model: $model  \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
      deviceModel = model;
    }


    String? name = savedValues.getString("deviceName");
    if(name!=null){
      print("name: $name  \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
      deviceName = name;

      String? device_Id = savedValues.getString("deviceId");
      if(device_Id == null){

        // call request
        savedValues.setString("deviceId", deviceId);
      }
      else {
        deviceId = device_Id;
      }
    }

    emit(SharedPreferencesState());
  }

  Future<void> updateDeviceName(name) async {
    deviceName = name;
    savedValues.setString("deviceName", deviceName);
    await addDeviceToServer();
    emit(UpdateDeviceNameState());
  }

  void toggleUppercase() {
    isUppercase = !isUppercase;
    emit(ToggleUppercaseState());
  }

  void toggleArabic() {
    isArabic = !isArabic;
    emit(ToggleArabicState());
  }

  void toggleNum() {
    isNum = !isNum;
    emit(ToggleNumState());
  }

  void toggleNum2() {
    isNum2 = !isNum2;
    emit(ToggleNum2State());
  }

  void togglePairLoading({state}) {
    pairLoading = state ?? !pairLoading;
    emit(TogglePairLoadingState());
  }

  void toggleConnectDeviceLoading({index, state}) {
    desktops[index]["loading"] = state ;
    emit(ToggleConnectDeviceLoadingState());
  }

  List<Choice> listOfChoiceFolders = <Choice>[
    const Choice(title: "Delete", icon: Icons.delete_sweep_outlined),
    // Choice(title: "Paste", icon: Icons.paste),
  ];
  void toggleCopyBool({forMobile = false}) {
    if(!forMobile){
      isCopy = !isCopy;
    }

    if(isCopy){
      listOfChoiceFolders.add(const Choice(title: "Paste", icon: Icons.paste));
    }
    else{
      if(listOfChoiceFolders.last.title=="Paste"){
        listOfChoiceFolders.removeLast();
      }

    }
    emit(ToggleCopyBoolState());
  }



  // Voise Region
  void toggleRecordState({required index, required state}) {
    active_desktops[index]["isRecording"] = state;
    emit(ToggleRecordingState());
  }

  void toggleRecordLoadingState({index, state}) {
    active_desktops[index]["recordLoading"] = state;
    emit(ToggleRecordLoadingState());
  }

  Future<bool> getStoragePermissions() async {
    final status = await Permission.storage.request();
    final status2 = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<String> makeDirectory({required String dirName}) async {
    final directory = await getExternalStorageDirectory();
    final formattedDirectory = '/$dirName/';
    final Directory newDir =
        await Directory(directory!.path + formattedDirectory).create();
    return newDir.path;
  }

  get getAudioDir async => await makeDirectory(dirName: 'recordings');
  Future<String> createRecordAudioPath({
    required String dirPath,
    required String fileName,
  }) async {
    return """$dirPath${fileName.substring(0, min(fileName.length, 100))}.wav""";
  }

  recordVoice() async {
    final voiceDirPath = await getAudioDir;
    final voiceFilePath = await createRecordAudioPath(
        dirPath: voiceDirPath, fileName: "audio_message");
    await record.start(const RecordConfig(encoder: AudioEncoder.wav),
        path: voiceFilePath);
    emit(StartRecordState());
  }

  stopRecording() async {
    String? audioFilePath;
    audioFilePath = await record.stop();
    print('file path : $audioFilePath');
    filePath = audioFilePath ?? "";
    emit(EndRecordState());
  }
  // End Voice Region

  String getCurrentTime() {
    DateTime currentTime = DateTime.now();

    // Format and display the current time as a string
    String formattedTime =
        '${currentTime.year}/${currentTime.month}/${currentTime.day} ${currentTime.hour}:${currentTime.minute}';

    return formattedTime;
  }


  void togglePassword() {
    isPassword = !isPassword;
    emit(TogglePasswordState());
  }


  void createDatabase() async {
    openDatabase(
      'Desktop.db',
      version: 1,
      onCreate: (database, version) {
        print('database created');
        database
            .execute(
                'CREATE TABLE Desktop (id INTEGER PRIMARY KEY, name TEXT, mac TEXT, ip TEXT, password TEXT, connectionId TEXT, accessTime TEXT, online INTEGER)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('Error When Creating Table ${error.toString()}');
        });
      },
      onOpen: (database) {
        print(getDatabasesPath());
        getDataFromDatabase(database);
        // dropTable(database);
        print('database opened');
      },
    ).then((value) {
      database = value;
      emit(CreateDatabaseState());
    });
  }

  Future<void> printTableData(database) async {
    String tableName = 'Desktop'; // Replace with your actual table name

    // Query to retrieve all rows from the table
    List<Map<String, dynamic>> result = await database.query(tableName);

    // Print the data
    print('All data from $tableName:');
    result.forEach((row) {
      print(row);
    });
  }

  void insertToDatabase({
    required String name,
    required String password,
    required String ip,
    required String mac,
    required String connectionId,
    String accessTime = "Not accessed yet.",
    int online = 1,
  }) async {
    bool found = false;
    desktops.forEach((element) {
      if (element["ip"] == ip) {
        found = true;
      }
    });

    if (found == false) {
      await database.transaction((txn) => txn
              .rawInsert(
            'INSERT INTO Desktop(name, mac, ip, password, connectionId, accessTime, online) VALUES("$name", "$mac", "$ip", "$password", "$connectionId", "$accessTime", "$online")',
          )
              .then((value) {
            print('$value inserted successfully');
            emit(InsertDatabaseState());
            getDataFromDatabase(database);
          }).catchError((error) => print(
                  'Error When Inserting New Record ${error.toString()}')));
    }
  }

  void getDataFromDatabase(database) async {
    List<Map> newDesktops = [];
    emit(GetDatabaseLoadingState());
    database.rawQuery('SELECT * FROM Desktop').then((value) {
      value.forEach((element) {
        newDesktops.add({
          ...element,
          "loading": false,
        });
      });
      desktops = newDesktops;
      emit(GetDatabaseState());
    });
    printTableData(database);
  }

  void updateIpData({
    required String ip,
    required String mac,
    required int online,
    bool getDataFlag = true,
    // required bool flag,
  }) async {
    database.rawUpdate(
      'UPDATE Desktop SET ip = ?, online = ? WHERE mac = ?',
      [ip, online, mac],
    ).then((value) {

      if(getDataFlag){
        getDataFromDatabase(database);
        emit(UpdateDatabaseState());
      }

    });
  }

  void updateAccessTimeData({
    required String accessTime,
    required String ip,
  }) async {
    database.rawUpdate(
      'UPDATE Desktop SET accessTime = ? WHERE ip = ?',
      [accessTime, ip],
    ).then((value) {
      getDataFromDatabase(database);
      emit(UpdateDatabaseState());
    });
  }

  void deleteData({
    int? id,
    String? mac,
  }) async {
    // Perform the delete operation
    if(id!=null){
      await database.rawDelete('DELETE FROM Desktop WHERE id = ?', [id]);
    }
    else {
      await database.rawDelete('DELETE FROM Desktop WHERE mac = ?', [mac]);
    }


    // Retrieve all records after deletion
    List<Map<String, dynamic>> records = await database.query('Desktop');

    // Update the IDs to make them contiguous
    for (int i = 0; i < records.length; i++) {
      int currentId = records[i]['id'];
      if (currentId != i + 1) {
        // If the current ID is not equal to the expected ID, update it
        await database.rawUpdate(
            'UPDATE Desktop SET id = ? WHERE id = ?', [i + 1, currentId]);
      }
    }

    // Notify the listeners or emit a state indicating the deletion
    getDataFromDatabase(database);
    emit(DeleteDatabaseState());
  }

  void dropTable(database) async {
    try {
      await database.execute('DROP TABLE IF EXISTS Desktop');
      print('Table dropped successfully');
      emit(DropTableState());
    } catch (error) {
      print('Error when dropping table: $error');
    }
  }

  Future<bool> doesMacExists({
    required String macAddress,
  }) async {
    // Execute query to check if MAC address exists
    List<Map<String, dynamic>> result = await database.query(
      'Desktop',
      columns: ['mac'],
      where: 'mac = ?',
      whereArgs: [macAddress],
    );

    return result.isNotEmpty;
  }


  //Future<List<Map<String, dynamic>>>
  Future<void> autoConnection() async {
    if(desktops.length==0){
      laoding=false;
      return;
    }

    var macList = [];
    desktops.forEach((device) => macList.add(device["mac"]));
    final ready_devices = await getNewIps(macList);
    for(int i=0; i<ready_devices.length; i++){
      if(ready_devices[i]["authorized"]==false){
        deleteActiveDevice(ready_devices[i]["public_ip"]);
        deleteData(mac: ready_devices[i]["mac_address"]);
        continue;
      }

      if(desktops[i]["ip"]!=ready_devices[i]["public_ip"] || desktops[i]["online"]!=ready_devices[i]["availabile"]){
        updateIpData(
          ip: ready_devices[i]["public_ip"],
          mac: ready_devices[i]["mac_address"],
          online: ready_devices[i]["available"],
          getDataFlag: false,
        );
      }

      if(ready_devices[i]["available"]==0) {
        deleteActiveDevice(ready_devices[i]["public_ip"]);
      }
    }
    getDataFromDatabase(database);
    laoding = false;
  }


  Future<void> delay({var sec = 2}) async {
    print('Start Delay, $sec sec');
    await Future.delayed(Duration(seconds: sec)); // Delay for 2 seconds
    print('End Delay');
  }



  List<Map> active_desktops = [
    {
      "name": "Desktop Anywhere",
      "ip": "0.0.0.0",
      "listofpartitions": [],
      "path": "",
      "view": "Partitions",
      "roomId": "",
      "rotate": false,
      "sizeFactor": 1,
      "loading": false,
      "recordLoading": false,
      "isRecording": false,
    },
  ];

  late Map<String, dynamic> configuration;

  int addActiveDevice(ip, name, listofpartitions) {
    var index;
    bool found = false;
    for (var i = 1; i < active_desktops.length; i++) {
      if (active_desktops[i]['ip'] == ip) {
        found = true;
        index = i;
        break;
      }
    }
    if (!found) {
      active_desktops.add({
        "name": name,
        "ip": ip,
        "listofpartitions": listofpartitions,
        "path": "",
        "view": "Partitions",
        "roomId": "",
        "rotate": false,
        "sizeFactor": 1,
        "loading": false,
        "recordLoading": false,
        "isRecording": false,
      });
      index = active_desktops.length - 1;
      // print(active_desktops);

      updateAccessTimeData(
        ip: ip,
        accessTime: getCurrentTime(),
      );

      emit(AddActiveDesktopList());
    }

    return index;
  }

  void deleteActiveDevice(ip) {
    List<Map> newList = [];
    for (var i = 0; i < active_desktops.length; i++) {
      if (active_desktops[i]['ip'] != ip) {
        newList.add(active_desktops[i]);
      }
    }
    active_desktops = newList;

    emit(DeleteActiveDesktopList());
  }

  void updateActiveDeviceLoading({index, status=null}){
    if(status==null){
      active_desktops[index]["loading"] = !active_desktops[index]["loading"];
    }
    else {
      active_desktops[index]["loading"] = status;
    }

    print("${active_desktops[index]["loading"]} \n\n\n\n\n\n\n\n\n");
    emit(updateActiveDeviceLoadingStatus());
  }

  //send index
  String setpath({foldername, flag, index, update = 1}) {
    // var index=0;
    // for(var i=1; i<active_desktops.length; i++){
    //   if(active_desktops[i]["ip"]==ip) {
    //     index=i;
    //     break;
    //   }
    // }

    if (active_desktops.length <= index) {
      return "";
    }

    String new_path = active_desktops[index]["path"];

    if (flag == 1) {
      new_path = foldername;
    } else {
      String path = active_desktops[index]["path"];
      if (path[path.length - 1] != '\\') {
        new_path = path + '\\' + foldername;
      } else {
        new_path = path + foldername;
      }
    }

    if (update == 1) {
      active_desktops[index]["path"] = new_path;
      emit(PushPageState());
    }
    return new_path;
  }

  //send index
  void updatepath(index) {
    String path = active_desktops[index]["path"];
    int lastSlashIndex = path.lastIndexOf('\\');
    if (lastSlashIndex != -1) {
      String result = path.substring(0, lastSlashIndex);

      // check if reach to partion name like => C: then and \ to be like => C:\
      if (result.lastIndexOf(':') == result.length - 1) {
        result += '\\';
      }

      active_desktops[index]["path"] = result;
    }
    emit(PopPageState());
  }

  void changeViewMode(index, mode) {
    // mode => "Partitions" or "Share Screen" or "Virtual Control"
    active_desktops[index]["view"] = mode;
    emit(changeDesktopViewMode());
  }

  void updateRoomId(index, roomId) {
    active_desktops[index]["roomId"] = roomId;
    emit(updateRoomID());
  }

  void updateRotate(index) {
    active_desktops[index]["rotate"] = !active_desktops[index]["rotate"];
    emit(updateRotateStatues());
  }

  void updateSizeFactor(index, sizeFactor) {
    active_desktops[index]["sizeFactor"] += sizeFactor;
    if (active_desktops[index]["sizeFactor"] < 0.2) {
      active_desktops[index]["sizeFactor"] = 0.2;
    }
    print("sizeFactor \n\n\n\n\n");
    emit(updateSizeFactorView());
  }

  Map get_active_desktop_data(ip) {
    var desktop;
    for (var i = 1; i < active_desktops.length; i++) {
      if (active_desktops[i]["ip"] == ip) {
        desktop = active_desktops[i];
      }
    }
    return desktop;
  }

  int get_active_desktop_index(ip) {
    var index = -1;
    for (var i = 1; i < active_desktops.length; i++) {
      if (active_desktops[i]["ip"] == ip) {
        index = i;
      }
    }
    return index;
  }

  void updateImageShared(ip, image) {
    var index = 0;
    for (var i = 1; i < active_desktops.length; i++) {
      if (active_desktops[i]["ip"] == ip) {
        index = i;
        break;
      }
    }

    active_desktops[index]['image'] = image;
    emit(updateImageShareScreen());
  }

  void connectOnSocketServer() {
    socket = IO.io(
      serverUrl,
      // "http://localhost:5000",
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );
    socket.onConnect((_) {
      print("\n\n");
      print('connect');
      print(socket.id);
      print("\n\n\n\n\n\n\n\n\n\n\n");

      // socket.emit('addDevice', {
      //   // "id": socket.id,
      //   "ip": "192.168.1.9",
      //   "type": "mobile"
      // });
    });

    socket.onDisconnect((_) {
      print("\n\n disconnect \n\n");
      activateServer();
    });
  }

  void showToast({flag = true, message = "test", waitingMsg = false}) {
    print("showToast \n\n\n\n\n");
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      // toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.grey,
      textColor: waitingMsg? Colors.black54: flag ? Colors.green[800] : Colors.red[900],
      gravity: ToastGravity.BOTTOM,
      fontSize: 18,
    );
  }

  String new_ip = "", new_name = "", new_password = "";
  late BuildContext context;
  void updateInputData({ip = "", name = "", password = "", context = null, emitCubit=true}) {
    this.new_ip = ip;
    this.new_name = name;
    this.new_password = password;
    if (context != null) {
      this.context = context;
    }

    if(emitCubit){
      emit(updateTemporaryData());
    }

  }

  bool sendR = true;
  void socketListener() {
    // socket.emit('addDevice', {
    //   "ip": ip,
    //   "type": "mobile"
    // });

    socket.on('partition', (data) async {
      print("${data} \n\n\n");
      if (data["part"] == "main") {
        toggleConnectDeviceLoading(index: data["index"], state: false);
        addActiveDevice(data["ip"], data["deviceName"], data["partitions"]);
      }
      else {




        if(data["update"] == null) {
          data["update"] = 1;
        }

        setpath(
            foldername: data["componentName"],
            flag: data["path_flag"],
            update: data["update"],
            index: data["index"]
        );

        if(data["popScreen"] != null){
          print("\n\n\n\n\n\n  pop Screen is Done \n\n\n\n\n");
          Navigator.pop(context);
          await delay(sec: 2);
        }


        if(data["update"]==1) updateActiveDeviceLoading(index: data["index"]);



        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FilesAndFolder(
              dataList: data["partitions"],
              dataType: data["dataType"],
              ip: data["ip"],
              parName: data["componentName"],
              index: data["index"],
            ),
          ),
        );
      }

      sendR = true;
      emit(updateSocketEmitState());
    });

    socket.on("checkIPResult", (data) {
      sendR = true;
      emit(updateSocketEmitState());

      if (data["found"] == true) {
        if (data["note"] == "add device") {
          socket.emit('addDevice', {"ip": new_ip, "type": "mobile"});
        }

        emitSocketEvent(ip: new_ip, event: "checkPassword", msg: {
          "password": new_password,
        });
      } else {
        // Navigator.of(context).pop();
        showToast(flag: data["found"], message: data["message"]);
      }
    });

    socket.on("password", (data) async {


      if (data["valid"]) {
        String connectionId = await createConnectionOnServer(data["mac"]);
        insertToDatabase(
          name: new_name,
          password: new_password,
          ip: new_ip,
          mac: data["mac"],
          connectionId: connectionId,
        );


        togglePairLoading(state: false);
        Navigator.of(context).pop();
      }


      // Navigator.of(context).pop();
      showToast(flag: data["valid"], message: data["message"]);
      togglePairLoading(state: false);


      sendR = true;
      emit(updateSocketEmitState());
    });

    socket.on("refreshConnection", (data) async {
      print("refreshConnection event \n\n\n\n\n\n\n\n");
      await autoConnection();
    });

    socket.on("voiceArrived", (data){
      int index = get_active_desktop_index(data["ip"]);
      if(index>=0){
        toggleRecordLoadingState(index: index, state: false);
      }
      showToast(flag: data["flag"], message: data["message"]);
    });

    socket.on("downloadResults", (data){
      print("\n\n\n\n\n\n $data  \n\n\n\n\n\n\n");
      showToast(flag: data["isDownloaded"], message: data["message"]);

      if(data["isDownloaded"]){
        toggleCopyBool();
      }
    });

    socket.on("uploadResults", (data) async {
      print("\n\n\n\n\n\n Data: $data  \n\n\n\n\n\n\n");
      // showToast(flag: data["isUploaded"], message: data["message"]);

      if(data["forMobile"] == null){
        data["forMobile"] = false;
      }
      if(data["isUploaded"]){
        toggleCopyBool(forMobile: data["forMobile"]);
      }


      if(data["forMobile"]){
        await downloadFile(data["directoryPathInMobile"]);
      }
      else {
        showToast(flag: data["isUploaded"], message: data["message"]);
      }
    });

    socket.on("deleteResults", (data){
      print("\n\n\n\n\n\n $data  \n\n\n\n\n\n\n");
      showToast(flag: data["isDeleted"], message: data["message"]);
      // if(data["isDeleted"]){
      //   updatepath(data["index"]);
      //   Navigator.pop(context);
      // }
      // Navigator.pop(context);
    });

    socket.on("createFolderResults", (data){
      print("\n\n\n\n\n\n $data  \n\n\n\n\n\n\n");
      showToast(flag: data["isCreated"], message: data["message"]);
      // Navigator.pop(context);
    });

    socket.on("notFoundDevice", (data) {
      print("Not Found Device \n\n\n\n\n\n");
      String ms = data["messageError"].toString().isNotEmpty ? data["messageError"] : "Not Found Device";
      sendR = true;
      int index = get_active_desktop_index(data["ip"]);
      if(index >= 0){
        updateActiveDeviceLoading(
          index: index,
          status: false,
        );
        toggleRecordLoadingState(index: index, state: false);
      }

      togglePairLoading(state: false);

      if(data["lostData"].containsKey('index') && data["lostData"].containsKey("part") && data["lostData"]["part"] == "main"){
        toggleConnectDeviceLoading(index: data["lostData"]["index"], state: false);
      }

      emit(updateSocketEmitState());
      showToast(flag: false, message: ms);
    });
  }

  void pasteFile({ip, index, path=""}){
    showToast(
        waitingMsg: true,
        message: "Waiting for paste"
    );

    emitSocketEvent(
      ip: ip,
      event: "downloadFile",
      msg: {
        "ip": ip,
        "path": path.isNotEmpty? path : active_desktops[index]['path'].toString(),
        "deviceId": deviceId,
        "index": index,
      },
      skipWaiting: true,
    );
  }

  void emitSocketEvent({
    ip,
    event,
    msg,
    event_error = "notFoundDevice",
    msg_error = "",
    skipWaiting = false
  }) {
    if (skipWaiting || sendR) {
      socket.emit("event", {
        "ip": ip,
        "type": "mobile",
        "target_type": "desktop",
        "mobile_Id": deviceId,
        "event": event,
        "message": msg,
        "eventError": event_error,
        "messageError": msg_error,
      });
      if (skipWaiting == false && sendR) {
        sendR = false;
        emit(updateSocketEmitState());
      }
    }
  }

  void updateSocketWaitingState() {
    sendR = true;
    emit(updateSocketEmitState());
  }

  Future<void> getConfigurations() async {
    final response = await http.get(
      Uri.parse('$serverUrl/confegration'),
    );

    if (response.statusCode == 200) {
      configuration = json.decode(response.body)["configuration"];
      print("\n\n\n ${configuration} \n\n\n\n");
    } else {
      delay(sec: 1);
      getConfigurations();
    }
  }

  Future<void> activateServer() async {
    final response = await http.get(
      Uri.parse('$serverUrl/welcome'),
      // Uri.parse('http://localhost:5000/welcome'),
    );

    if (response.statusCode == 200) {
      var ms = json.decode(response.body);
      print("\n\n\n ${ms} \n\n\n\n");
    } else {
      print("Trying to activate server ....");
      delay(sec: 2);
      activateServer();
    }
  }




  Future<String> pickDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    selectedDirectory ??= "";
    return selectedDirectory;
  }

  Future<void> downloadFile(String directoryPath) async {
    // String directoryPath = "storage/emulated/0/Download/TestDesktop";
    // String directoryPath = await pickDirectory();
    // if(directoryPath.startsWith("/")){
    //   directoryPath = directoryPath.replaceFirst(RegExp("/"), "");
    //   print("\n\n\n Path: $directoryPath \n\n\n\n");
    // }
    print("\n\n\n Path: $directoryPath \n\n\n\n");
    var time = DateTime.now().microsecondsSinceEpoch;

    final response = await http.get(
      Uri.parse('$serverUrl/media/view/$deviceId'),
    );

    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      print("\n\n\n ${res} \n\n\n\n");
      res = res["file"];
      directoryPath = "$directoryPath/${res["file_name"]}__$time";
      // directoryPath = "$directoryPath/${res["file_name"]}";
      var file = File(directoryPath);


      var fileResponse = await http.get(
        Uri.parse('$serverUrl/${res["secure_url"]}'),
      );

      if(fileResponse.statusCode == 200){
        await file.writeAsBytes(fileResponse.bodyBytes);
        showToast(flag: true, message: "File downloaded successfully");
        // OpenFile.open(directoryPath);
      } else{
        showToast(flag: false, message: "Failed download file");
      }

    } else {
      showToast(flag: false, message: "Failed download file");
    }
  }





  Future<List<dynamic>> getNewIps(macList) async {
    final headers = {'Content-Type': 'application/json'};
    String jsonData = jsonEncode({
      "mac": macList,
    });
    final response = await http.post(
      Uri.parse('$serverUrl/desktop/information/$deviceId'),
      headers: headers,
      body: jsonData
    );

    if (response.statusCode == 200) {
      var ready_devices = json.decode(response.body)["ready_devices"];
      print("${ready_devices} \n\n\n\n");

      return ready_devices;
    } else {
      delay(sec: 1);
      return getNewIps(macList);
      // return throw Error();
    }
  }


  Future<void> addDeviceToServer() async {
    final headers = {'Content-Type': 'application/json'};
    String jsonData = jsonEncode({
      "name": deviceName,
      "model": deviceModel,
      "version_number": version_number,
    });
    final response = await http.post(
      Uri.parse('$serverUrl/mobile'),
      headers: headers,
      body: jsonData
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      deviceId = json.decode(response.body)["mobile"]["_id"];
      savedValues.setString("deviceId", deviceId);
      print("device Id: ${deviceId} \n\n\n\n");

    } else {
      delay(sec: 1);
      addDeviceToServer();
    }
  }

  Future<String> createConnectionOnServer(desktop_mac) async {
    final headers = {'Content-Type': 'application/json'};
    String jsonData = jsonEncode({
      "desktop_mac": desktop_mac,
      "mobile_id": deviceId,
    });
    final response = await http.post(
        Uri.parse('$serverUrl/connection'),
        headers: headers,
        body: jsonData
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      var res = json.decode(response.body);
      print("Connection Respose: ${res} \n\n\n\n");
      return res["connection"]["_id"];

    } else {
      delay(sec: 1);
      return createConnectionOnServer(desktop_mac);
    }
  }

  Future<void> deleteConnection(connectionId) async {
    final response = await http.delete(
      Uri.parse('$serverUrl/connection/$connectionId'),
    );

    if (response.statusCode == 200) {
      var msg = json.decode(response.body);
      print("\n\n\n ${msg} \n\n\n\n");
    }else {
      var msg = json.decode(response.body);
      print("\n\n\n ${msg} \n\n\n\n");
    }

  }

  bool laoding = true;
  void stopLoading(){
    laoding=false;
    emit(stopLoadingState());
  }


}
