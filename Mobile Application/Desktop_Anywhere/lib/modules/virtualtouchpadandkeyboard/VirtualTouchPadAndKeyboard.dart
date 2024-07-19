import 'package:desktop_anywhere/shared/component/keyboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';


class VirtualTouchpadAndKeyboard extends StatelessWidget {

  final String ip;
  VirtualTouchpadAndKeyboard({
    super.key,
    required this.ip
  });

  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    AppCubit cubit = AppCubit.get(context);

    Map<String, double> coordinate = {
      "X": 0.0,
      "Y": 0.0,
      "width": 0.0,
      "height": 0.0,
      "touchpad": 1,
    };

    Offset previousOffset = Offset.zero;

    return BlocConsumer<AppCubit, States>(
      listener: (BuildContext context, Object? state) {},
      builder: (BuildContext context, state) {
        return Column(
          children: [
            // Touchpad Section
            Expanded(
              child: Padding(
                key: _key,
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onPanStart: (details) {
                    previousOffset = details.globalPosition;
                  },
                  onPanUpdate: (x) {
                    Size? size = _key.currentContext
                        ?.findRenderObject()
                        ?.paintBounds
                        .size;

                    // Calculate the difference between current and previous positions
                    double deltaX = x.globalPosition.dx - previousOffset.dx;
                    double deltaY = x.globalPosition.dy - previousOffset.dy;

                    // Update the previous position
                    previousOffset = x.globalPosition;
                    coordinate["X"] = deltaX;
                    coordinate["Y"] = deltaY;
                    coordinate["height"] = size!.width;
                    coordinate["width"] = size!.height;

                    // cubit.sendMessageTouchpad(coordinate, ip, 8888);
                    cubit.emitSocketEvent(
                      ip: ip,
                      event: "mouse_move",
                      msg: coordinate,
                      event_error: "errorMouseMove",
                      msg_error: "device not found",
                      skipWaiting: true,
                    );

                    // cubit.delay();
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2,
                    // color: Colors.blue,
                    color: Colors.grey[800],
                    child: const Center(
                      child: Text(
                        'Virtual Touchpad',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onDoubleTap: (){
                        cubit.emitSocketEvent(
                          ip: ip,
                          event: "mouse_click",
                          msg: "Double Click",
                          skipWaiting: true,
                        );
                      },
                      onTap: (){
                        cubit.emitSocketEvent(
                          ip: ip,
                          event: "mouse_click",
                          msg: "Left Click",
                          skipWaiting: true,
                        );
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: const Center(child: Text("Right Click")),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        cubit.emitSocketEvent(
                          ip: ip,
                          event: "mouse_click",
                          msg: "Right Click",
                          skipWaiting: true,
                        );
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(20.0)
                        ),
                        child: const Center(child: Text("Left Click")),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            // Keyboard Section
            Keyboard(ip: ip),
            const SizedBox(
              height: 5,
            ),
          ],
        );
      },
    );
  }
}