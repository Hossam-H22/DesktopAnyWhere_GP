import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:desktop_anywhere/modules/liveview/signaling.dart';
import 'package:desktop_anywhere/shared/component/LoadingPage.dart';
import 'package:desktop_anywhere/shared/component/keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class LiveView extends StatefulWidget {
  final String ip;
  var index;
  String roomId;
  Map<String, dynamic> configuration;
  IO.Socket socket;

  LiveView({
    super.key,
    required this.ip,
    required this.index,
    required this.roomId,
    required this.configuration,
    required this.socket,
  });

  @override
  State<LiveView> createState() => _LiveView5State();
}

class _LiveView5State extends State<LiveView> {
  AppCubit? cubit;
  GlobalKey _key = GlobalKey();
  bool rotate = false;
  double iconSize = 27;
  double sizeFactor = 1;
  Color iconColor = Colors.white;
  String click_type = "Left Click";
  double desktop_width = 1;
  double desktop_height = 1;

  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  Signaling signaling = Signaling();
  bool isKeyboardOpened = false;

  void socketFunction() {}

  Future<void> shareScreen() async {
    widget.roomId =
        await signaling.createRoom(_remoteRenderer, widget.configuration);

    widget.socket.emit("event", {
      "ip": widget.ip,
      "type": "mobile",
      "target_type": "web",
      "event": "roomId",
      "message": {
        "roomId": widget.roomId,
      },
      "eventError": "errorRoomId", // error event if target not found
      "messageError": "device not found",
    });
  }

  void setUp() {
    socketFunction();

    _localRenderer.initialize();
    _remoteRenderer.initialize();
    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    shareScreen();
  }

  @override
  void initState() {
    setUp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, States>(
      listener: (context, state) {},
      builder: (context, state) {
        cubit = AppCubit.get(context);

        rotate = cubit?.active_desktops[widget.index]["rotate"];
        sizeFactor =
            cubit?.active_desktops[widget.index]["sizeFactor"].toDouble();

        Map<String, double> coordinate = {
          "X": 0.0,
          "Y": 0.0,
          "width": 0.0,
          "height": 0.0,
          "touchpad": 1,
        };
        Offset previousOffset = Offset.zero;

        return Column(
          // mainAxisAlignment: MainAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              key: _key,
              child: _remoteRenderer.srcObject != null
                  ? GestureDetector(
                      onTapDown: (position) {
                        // print("\n\n\n\n ${position.globalPosition} \n\n\n\n");
                      },
                      onPanStart: (details) {
                        previousOffset = details.globalPosition;
                      },
                      onPanUpdate: (value) {
                        // print(value.globalPosition);

                        Size? size = _key.currentContext
                            ?.findRenderObject()
                            ?.paintBounds
                            .size;

                        // var factor = rotate? sizeFactor : 1;

                        // Calculate the difference between current and previous positions
                        double deltaX =
                            value.globalPosition.dx - previousOffset.dx;
                        double deltaY =
                            value.globalPosition.dy - previousOffset.dy;

                        // Update the previous position
                        previousOffset = value.globalPosition;

                        if (rotate) {
                          // coordinate["Y"] = -1*value.globalPosition.dx+ (size!.width) -45;
                          coordinate["Y"] = -1 * deltaX;
                          // coordinate["X"] = value.globalPosition.dy-90;
                          coordinate["X"] = deltaY;
                          // coordinate["height"] = size!.width-90;
                          coordinate["height"] = size!.width;
                          // coordinate["width"] = size!.height-90;
                          coordinate["width"] = size!.height;
                        } else {
                          // coordinate["X"] = value.globalPosition.dx-35;
                          coordinate["X"] = deltaX;
                          // coordinate["Y"] = value.globalPosition.dy-(size!.height*0.65);
                          coordinate["Y"] = deltaY;
                          // coordinate["width"] = size!.width-70;
                          coordinate["width"] = size!.width;
                          // coordinate["height"] = size!.height-(size!.height*0.5);
                          coordinate["height"] = size!.height;
                        }

                        // print("\n\n\n\n ${coordinate} \n\n\n\n\n\n");

                        cubit?.emitSocketEvent(
                          ip: widget.ip,
                          event: "mouse_move",
                          msg: coordinate,
                          event_error: "errorMouseMove",
                          msg_error: "device not found",
                          skipWaiting: true,
                        );
                      },
                      child: Transform.rotate(
                        angle: rotate ? 1.5708 : 0,
                        child: FractionallySizedBox(
                          heightFactor: rotate ? sizeFactor : 1.0,
                          widthFactor: rotate ? sizeFactor : 1.0,
                          child: RTCVideoView(
                            _remoteRenderer,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitContain,
                          ),
                        ),
                      ),
                    )
                  : LoadingPage(
                      backgroundColor: Colors.white,
                      circleColor: Colors.black,
                    ),
            ),
            isKeyboardOpened && !rotate
                ? Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.bottomCenter,
                    child: Keyboard(
                      ip: widget.ip,
                    ),
                  )
                : const SizedBox(),
            Container(
              padding: const EdgeInsets.only(bottom: 4, top: 2),
              alignment: Alignment.bottomCenter,
              color: Colors.black,
              child: Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                      onPressed: () {
                        signaling.hangUp(_localRenderer, widget.roomId);
                        setState(() {
                          _remoteRenderer = RTCVideoRenderer();
                        });
                        setUp();
                      },
                      icon: Icon(
                        Icons.restart_alt_outlined,
                        size: iconSize,
                        color: Colors.red[900],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        if(cubit?.active_desktops[widget.index]["recordLoading"]) return;

                        if(cubit?.active_desktops[widget.index]["isRecording"]==false){
                          cubit?.toggleRecordState(index: widget.index, state: true);
                          cubit?.recordVoice();
                        }
                        else {
                          await cubit?.stopRecording();
                          File audioFile = File(cubit!.filePath);
                          List<int> audioBytes = audioFile.readAsBytesSync();
                          print("Audio Finished \n\n\n\n\n\n\n");
                          cubit?.toggleRecordLoadingState(index: widget.index, state: true);
                          cubit?.toggleRecordState(index: widget.index, state: false);


                          cubit?.emitSocketEvent(
                            ip: widget.ip,
                            event: "voice",
                            msg: audioBytes,
                            event_error: "notFoundDevice",
                            msg_error: "Voice not sent",
                            skipWaiting: true,
                          );


                        }
                      },
                      icon: cubit?.active_desktops[widget.index]["recordLoading"]? LoadingAnimationWidget.threeRotatingDots(
                        color: Colors.white,
                        size: 25,
                      ):
                      Icon(
                        cubit?.active_desktops[widget.index]["isRecording"] ? Icons.stop_circle_outlined : Icons.mic,
                        color: Colors.white,
                      ),
                    ),
                    if (rotate) IconButton(
                        icon: Icon(
                          Icons.zoom_in,
                          size: iconSize,
                          color: rotate ? iconColor : Colors.grey[600],
                        ),
                        onPressed: () {
                          if (rotate)
                            cubit?.updateSizeFactor(widget.index, 0.1);
                        },
                      ),
                    if (rotate) IconButton(
                        icon: Icon(
                          Icons.zoom_out,
                          size: iconSize,
                          color: rotate ? iconColor : Colors.grey[600],
                        ),
                        onPressed: () {
                          if (rotate)
                            cubit?.updateSizeFactor(widget.index, -0.1);
                        },
                      ),
                    if (!rotate) IconButton(
                        icon: isKeyboardOpened
                            ? Icon(
                                Icons.keyboard_hide,
                                size: iconSize,
                                color: iconColor,
                              )
                            : Icon(
                                Icons.keyboard,
                                size: iconSize,
                                color: rotate ? Colors.grey[600] : iconColor,
                              ),
                        onPressed: () {
                          if (!rotate) {
                            setState(() {
                              isKeyboardOpened = !isKeyboardOpened;
                            });
                          }
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.rotate_90_degrees_ccw,
                        size: iconSize,
                        color: iconColor,
                      ),
                      onPressed: () {
                        cubit?.updateRotate(widget.index);
                      },
                    ),
                    InkWell(
                      onDoubleTap: () {
                        cubit?.emitSocketEvent(
                          ip: widget.ip,
                          event: "mouse_click",
                          msg: "Double Click",
                          skipWaiting: true,
                        );
                      },
                      onTap: () {
                        cubit?.emitSocketEvent(
                          ip: widget.ip,
                          event: "mouse_click",
                          msg: "Left Click",
                          skipWaiting: true,
                        );
                      },
                      child: Transform.rotate(
                        angle: rotate ? 1.5708 : 0,
                        child: const SizedBox(
                          height: 30,
                          width: 40,
                          child: Image(
                            image: AssetImage('assets/images/left-click.png'),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        cubit?.emitSocketEvent(
                          ip: widget.ip,
                          event: "mouse_click",
                          msg: "Right Click",
                          skipWaiting: true,
                        );
                      },
                      child: Transform.rotate(
                        angle: rotate ? 1.5708 : 0,
                        child: const SizedBox(
                          height: 30,
                          width: 40,
                          child: Image(
                            image: AssetImage('assets/images/right-click.png'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
