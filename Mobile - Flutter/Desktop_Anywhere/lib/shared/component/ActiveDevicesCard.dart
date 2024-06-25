// ActiveDevicesCard

import 'dart:math';
import 'package:desktop_anywhere/modules/desktopdata/DesktopData.dart';
import 'package:desktop_anywhere/shared/component/GenericPopUpPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cubit.dart';
import '../cubit/states.dart';

class ActiveDevicesCard extends StatelessWidget {
  // final String deviceName;
  // final int deviceid;
  // final String ip;
  final Map desktopData;
  final int index;

  ActiveDevicesCard({
    Key? key,
    required this.index,
    required this.desktopData,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, States>(
      listener: (context,state) {
        print(state);
      },
      builder: (context, state) {
        AppCubit cubit = AppCubit.get(context);

        return LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = MediaQuery.of(context).size.width;
            double scaleFactor = screenWidth / 400;

            return Container(
              padding: const EdgeInsets.only(left: 10, right: 3, top: 12, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  desktopData["online"]==1? Container(
                    padding: const EdgeInsets.only(right: 10),
                    child: CircleAvatar(
                      radius: min(5.0*scaleFactor, 5),
                      backgroundColor: Colors.green,
                    ),
                  ) : const SizedBox(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${desktopData["name"]}\'s Desktop',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: min(20*scaleFactor, 22),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          // 'Last accessed at: ${cubit.accessTime}',
                          'Last accessed at: ${desktopData["accessTime"]}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: min(15*scaleFactor, 16),
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      desktopData["online"]==1?desktopData["loading"]? const Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child:  SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ):
                      IconButton(
                        icon: Icon(
                          Icons.arrow_circle_right_outlined,
                          size: min(25*scaleFactor, 35),
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          cubit.toggleConnectDeviceLoading(index: index ,state: true);

                          cubit.socket.emit('addDevice', {
                            "ip": desktopData["ip"],
                            "type": "mobile"
                          });
                          cubit.emitSocketEvent(
                            ip: desktopData["ip"],
                            event: "getPartition",
                            msg: {
                              "ip": desktopData["ip"],
                              "target": "all",
                              "deviceName": desktopData["name"],
                              "part": "main",
                              "index": index,
                            },
                            event_error: "notFoundDevice",
                            msg_error: "This device not active now",
                          );
                        },
                      ) : const SizedBox(),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          size: min(25*scaleFactor, 35),
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => ConfirmationPopup(
                              title: 'Alert!',
                              message: 'Are you sure that you want to remove this device?',
                              actionButtons: [
                                MaterialButton(
                                  onPressed: () async {
                                    await cubit.deleteConnection(desktopData["connectionId"]);
                                    cubit.deleteActiveDevice(desktopData["ip"]);
                                    cubit.deleteData(id: desktopData["id"]);
                                    Navigator.pop(context); // Close the pop-up
                                  },
                                  child: Text(
                                    'Yes',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: min(18*scaleFactor, 18),
                                    ),
                                  ),
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close the pop-up
                                  },
                                  child: Text(
                                    'No',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      fontSize: min(18*scaleFactor, 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

