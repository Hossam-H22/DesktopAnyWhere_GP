import 'package:desktop_anywhere/modules/desktopdata/Partitions.dart';
import 'package:desktop_anywhere/modules/liveview/LiveView.dart';
import 'package:desktop_anywhere/modules/virtualtouchpadandkeyboard/VirtualTouchPadAndKeyboard.dart';
import 'package:desktop_anywhere/shared/component/DataComponent.dart';
import 'package:desktop_anywhere/shared/component/LoadingPage.dart';
import 'package:desktop_anywhere/shared/cubit/cubit.dart';
import 'package:desktop_anywhere/shared/cubit/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';

import 'package:loading_animation_widget/loading_animation_widget.dart';






class ComponentData{
  late String componentName;
  late ComponentType componentType;
  ComponentData(this.componentName, this.componentType);
}
class DesktopData extends StatelessWidget {

  BuildContext contextTabs;
  final String ip ;
  final int index;
  List<dynamic> listofpartitions;

   DesktopData({
     super.key,
     required this.index,
     required this.ip ,
     required this.listofpartitions,
     required this.contextTabs,
   });


  @override
  Widget build(BuildContext context) {

    Widget barListItem(text, icon){
      return Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          Icon(icon),
        ],
      );
    }

    return BlocConsumer<AppCubit,States>(
        listener: (context,state){},
        builder: (context,state){
          AppCubit cubit = AppCubit.get(context);

          cubit.getStoragePermissions();
          cubit.socket.emit('addDevice', {
            "ip": ip,
            "type": "mobile"
          });

          return Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                settings: settings,
                builder: (context) {
                  return Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.black,
                      centerTitle: true,
                      leading: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: (){
                          // Navigator.pop(context);
                          cubit.updateRoomId(index, "");
                          cubit.deleteActiveDevice(ip);
                        },
                      ),
                      title: DropdownButton(
                        isExpanded: true,
                        value: cubit.active_desktops[index]['view'].toString(),
                        style: const TextStyle(color: Colors.white,),
                        dropdownColor: Colors.black,
                        underline: Container(),
                        onChanged: (String? newValue){
                          cubit.changeViewMode(
                            index,
                            newValue,
                          );
                          // print("$newValue \n\n\n\n\n");
                        },
                        items: [
                          DropdownMenuItem(value: "Partitions", child: barListItem("Partitions", Icons.folder_copy),),
                          DropdownMenuItem(value: "Share Screen", child: barListItem("Share Screen" , Icons.live_tv),),
                          DropdownMenuItem(value: "Virtual Control", child: barListItem("Virtual Control", Icons.mouse_outlined),),
                        ],
                      ),
                    ),
                    body: cubit.active_desktops[index]['view']=="Partitions"?
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView.builder(
                              itemCount: listofpartitions.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: partitionPage(componentName: listofpartitions[index],ip: ip, index: this.index, tabContext: context),
                                );
                              },
                            ),
                          ),
                          cubit.active_desktops[index]["loading"]? LoadingPage(): const SizedBox(),
                        ],
                      ):
                    cubit.active_desktops[index]['view']=="Share Screen"?
                    LiveView(
                        ip: ip,
                        index: index,
                        roomId: cubit.active_desktops[index]['roomId'],
                        configuration: cubit.configuration,
                        socket: cubit.socket,
                      ): VirtualTouchpadAndKeyboard(ip: ip,),
                    floatingActionButton: cubit.active_desktops[index]['view']=="Partitions"?
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if(cubit.active_desktops[index]["isRecording"]) Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: FloatingActionButton(
                              onPressed: () async {
                                await cubit.stopRecording();
                                print("Audio Canceled \n\n\n");
                                cubit.toggleRecordState(index: index, state: false);
                              },
                              backgroundColor: Colors.black,
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          FloatingActionButton(
                          onPressed: () async {
                            if(cubit.active_desktops[index]["recordLoading"]) return;

                            if(cubit.active_desktops[index]["isRecording"]==false){
                              cubit.toggleRecordState(index: index, state: true);
                              cubit.recordVoice();
                            }
                            else {
                              await cubit.stopRecording();
                              File audioFile = File(cubit.filePath);
                              List<int> audioBytes = audioFile.readAsBytesSync();
                              // print("Audio Finished \n\n\n");
                              cubit.toggleRecordLoadingState(index: index, state: true);
                              cubit.toggleRecordState(index: index, state: false);

                              cubit.emitSocketEvent(
                                ip: ip,
                                event: "voice",
                                msg: audioBytes,
                                event_error: "notFoundDevice",
                                msg_error: "Voice not sent",
                                skipWaiting: true,
                              );
                            }
                          },
                          backgroundColor: Colors.black,
                          child: cubit.active_desktops[index]["recordLoading"]? LoadingAnimationWidget.threeRotatingDots(
                            color: Colors.white,
                            size: 25,
                          ):
                          Icon(
                            cubit.active_desktops[index]["isRecording"] ? Icons.stop_circle_outlined : Icons.mic,
                            color: Colors.white,
                          ),
                    ),
                        ],
                      ): const SizedBox(),
                    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
                  );
                },
              );
            },
          );
        },
    );
  }
}

