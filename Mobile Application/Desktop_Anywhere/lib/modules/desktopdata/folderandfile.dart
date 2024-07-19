import 'dart:math';

import 'package:desktop_anywhere/shared/component/GenericPopUpPage.dart';
import 'package:desktop_anywhere/shared/component/LoadingPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../shared/component/DataComponent.dart';
import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';

class Choice {
  const Choice({required this.title, required this.icon});
  final String title;
  final IconData icon;
}

const List<Choice> listOfChoiceFiles = <Choice>[
  Choice(title: "Save", icon: Icons.download),
  Choice(title: "Delete", icon: Icons.delete_sweep_outlined),
  Choice(title: "Copy", icon: Icons.copy),
];
// List<Choice> listOfChoiceFolders = <Choice>[
//   const Choice(title: "Delete", icon: Icons.delete_sweep_outlined),
//   // Choice(title: "Paste", icon: Icons.paste),
// ];

class FilesAndFolder extends StatelessWidget {
  final Map<dynamic, dynamic> dataList;
  final String dataType;
  final String ip;
  final String parName;
  final int index;
  final TextEditingController _textFieldController = TextEditingController();

   FilesAndFolder({
     super.key,
     required this.dataList,
     required this.dataType,
     required this.ip,
     required this.index,
     required this.parName
   });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 400;
    AppCubit cubit = AppCubit.get(context);

    return BlocConsumer<AppCubit, States>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.keyboard_backspace,
                color: Colors.white,
              ),
              onPressed: () {
                cubit.updatepath(index);
                Navigator.pop(context);
              },
            ),
            title: Text(
              cubit.active_desktops[index]['path'].toString(),
              maxLines: 1,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            actions: [
              cubit.isCopy? IconButton(
                      icon: const Icon(Icons.paste),
                      onPressed: () {
                        cubit.pasteFile(
                            ip: ip,
                            index: index
                        );
                      },
                    ) : const SizedBox(),
              IconButton(
                padding: const EdgeInsetsDirectional.only(end: 12),
                icon: const Icon(
                  Icons.create_new_folder_outlined,
                  size: 28,
                ),
                onPressed: () {
                  _textFieldController.text = "";
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => ConfirmationPopup(
                      title: "Create Folder",
                      titleColor: Colors.black,
                      messageWidget: const SizedBox(),
                      textOfAcceptanceButton: "Ok",
                      textOfRejectionButton: "Cancel",
                      content: TextField(
                        controller: _textFieldController,
                        decoration: const InputDecoration(
                          hintText: "Enter folder name ..",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.normal,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      functionOfAcceptanceButton: (){
                        if(_textFieldController.text.isEmpty)
                        {
                          return;
                        }
                        Navigator.pop(context);
                        // print("Folder name: ${_textFieldController.text} \n\n\n");

                        cubit.showToast(
                            waitingMsg: true,
                            message: "Waiting for creating"
                        );
                        cubit.emitSocketEvent(
                          ip: ip,
                          event: "createFolder",
                          msg: {
                            "ip": ip,
                            "path": cubit.active_desktops[index]['path'].toString(),
                            "deviceId": cubit.deviceId,
                            "index": index,
                            "folder_name": _textFieldController.text,
                          },
                          skipWaiting: true,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    ListView.builder(
                      itemCount: dataList["dir"].length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    width: 10.0,
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Icon(Icons.folder_copy_outlined,
                                            color: Colors.white,
                                            size: min(25 * scaleFactor, 35)),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Text(
                                            dataList["dir"][index].toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize:
                                                  min(22 * scaleFactor, 20),
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    PopupMenuButton<Choice>(
                                      //padding: const EdgeInsets.symmetric(vertical: 10),
                                      icon: const Icon(
                                        Icons.more_horiz_rounded,
                                        color: Colors.white,
                                      ),
                                      color: Colors.white70,
                                      shadowColor: Colors.brown,
                                      itemBuilder: (BuildContext context) {
                                        return cubit.listOfChoiceFolders.map((Choice val) {
                                          return PopupMenuItem<Choice>(
                                              padding: const EdgeInsets.symmetric(
                                                      vertical: 15,
                                                      horizontal: 15),
                                              value: val,
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(val.icon),
                                                    onPressed: () {
                                                      // print("${val.title} \n\n\n");

                                                      String path = cubit.setpath(
                                                          foldername: dataList["dir"][index],
                                                          flag: 0,
                                                          update: 0,
                                                          index: this.index
                                                      );
                                                      // print("path: ${path} \n\n\n");

                                                      if (val.title == "Delete") {
                                                        showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) => ConfirmationPopup(
                                                              title: "Alert",
                                                              message: "Are you sure that you want to remove this Folder (${dataList["dir"][index].toString()})?",
                                                              functionOfAcceptanceButton: (){
                                                                cubit.emitSocketEvent(
                                                                  ip: ip,
                                                                  event: "deleteFileOrFolder",
                                                                  msg: {
                                                                    "ip": ip,
                                                                    "path": cubit.active_desktops[this.index]['path'].toString(),
                                                                    "deleted_name": dataList["dir"][index],
                                                                    "index": this.index,
                                                                  },
                                                                  skipWaiting: true,
                                                                );
                                                                cubit.showToast(
                                                                    waitingMsg: true,
                                                                    message: "Waiting for deleting"
                                                                );
                                                                Navigator.pop(context);
                                                              },
                                                            ),
                                                        );
                                                      }
                                                      else if(val.title == "Paste"){
                                                        cubit.pasteFile(
                                                          ip: ip,
                                                          index: this.index,
                                                          path: path,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                  const SizedBox(width: 15),
                                                  Text(val.title),
                                                ],
                                              ),
                                          );
                                        }).toList();
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.arrow_circle_right_outlined,
                                        size: min(25 * scaleFactor, 35),
                                        color: Colors.white,
                                      ),
                                      onPressed: () async {
                                        // print('folder pressed : ${dataList["dir"][index]}');

                                        String target = cubit.setpath(
                                            foldername: dataList["dir"][index],
                                            flag: 0,
                                            update: 0,
                                            index: this.index);
                                        cubit.updateActiveDeviceLoading(
                                            index: this.index);

                                        cubit.emitSocketEvent(
                                          ip: ip,
                                          event: "getPartition",
                                          msg: {
                                            "ip": ip,
                                            // "target": cubit.active_desktops[this.index]['path'].toString(),
                                            "target": target,
                                            "dataType": "Folder",
                                            "part": "secondary",
                                            "componentName": dataList["dir"]
                                                [index],
                                            "index": this.index,
                                            "path_flag": 0,
                                          },
                                        );

                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    ListView.builder(
                      itemCount: dataList["files"].length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    width: 10.0,
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Icon(Icons.file_copy_outlined,
                                            color: Colors.white,
                                            size: min(25 * scaleFactor, 35)),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Text(
                                            dataList["files"][index].toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize:
                                                  min(22 * scaleFactor, 20),
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    PopupMenuButton<Choice>(
                                      //padding: const EdgeInsets.symmetric(vertical: 10),
                                      icon: const Icon(
                                        Icons.more_horiz_rounded,
                                        color: Colors.white,
                                      ),
                                      color: Colors.white70,
                                      shadowColor: Colors.brown,
                                      itemBuilder: (BuildContext context) {
                                        return listOfChoiceFiles.map((Choice val) {
                                          return PopupMenuItem<Choice>(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 15,
                                                  horizontal: 15
                                              ),
                                              value: val,
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(val.icon),
                                                    onPressed: () async {
                                                      // print("${val.title} \n\n\n");

                                                      String path = cubit.setpath(
                                                          foldername:dataList["files"][index],
                                                          flag: 0,
                                                          update: 0,
                                                          index: this.index
                                                      );
                                                      // print("path: ${path} \n\n\n");

                                                      if (val.title == "Copy") {
                                                        cubit.showToast(
                                                            waitingMsg: true,
                                                            message: "Waiting for ${val.title}"
                                                        );
                                                        cubit.emitSocketEvent(
                                                          ip: ip,
                                                          event: "uploadFile",
                                                          msg: {
                                                            "ip": ip,
                                                            "path": path,
                                                            "deviceId": cubit.deviceId,
                                                          },
                                                          skipWaiting: true,
                                                        );
                                                      }
                                                      else if (val.title == "Delete") {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) => ConfirmationPopup(
                                                            title: "Alert",
                                                            message: "Are you sure that you want to remove this file (${dataList["files"][index].toString()})?",
                                                            functionOfAcceptanceButton: (){
                                                              // print("\n\n\nPath : ${cubit.active_desktops[this.index]["path"]} \n\n\n");
                                                              cubit.emitSocketEvent(
                                                                ip: ip,
                                                                event: "deleteFileOrFolder",
                                                                msg: {
                                                                  "ip": ip,
                                                                  // "path": path,
                                                                  "path": cubit.active_desktops[this.index]['path'].toString(),
                                                                  "deleted_name": dataList["files"][index],
                                                                  "index": this.index,
                                                                },
                                                                skipWaiting: true,
                                                              );
                                                              cubit.showToast(
                                                                  waitingMsg: true,
                                                                  message: "Waiting for deleting"
                                                              );
                                                              Navigator.pop(context);
                                                            },
                                                          ),
                                                        );
                                                      }
                                                      else if (val.title == "Save") {
                                                        cubit.showToast(
                                                            waitingMsg: true,
                                                            message: "Choose location for saving ..."
                                                        );
                                                        String directoryPath = await cubit.pickDirectory();
                                                        cubit.showToast(
                                                            waitingMsg: true,
                                                            message: "Waiting for downloading file"
                                                        );
                                                        cubit.emitSocketEvent(
                                                          ip: ip,
                                                          event: "uploadFile",
                                                          msg: {
                                                            "ip": ip,
                                                            "path": path,
                                                            "deviceId": cubit.deviceId,
                                                            "forMobile": true,
                                                            "directoryPathInMobile": directoryPath,
                                                          },
                                                          skipWaiting: true,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                  const SizedBox(width: 15),
                                                  Text(val.title),
                                                ],
                                              ));
                                        }).toList();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              cubit.active_desktops[index]["loading"]
                  ? LoadingPage()
                  : const SizedBox(),
            ],
          ),
        );
      },
    );
  }
}
