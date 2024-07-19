
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../shared/cubit/cubit.dart';

class partitionPage extends StatelessWidget {
  final String componentName;
  final String ip;
  final int index;
  BuildContext tabContext;

  partitionPage({
    super.key ,
    required this.componentName ,
    required this.ip,
    required this.index,
    required this.tabContext
  });


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 400;
    AppCubit cubit = AppCubit.get(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                    Icons.account_tree_outlined,
                    color: Colors.white54,
                    size: min(25*scaleFactor, 35)
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  componentName,
                  style: TextStyle(
                    fontSize: min(22*scaleFactor, 25),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_circle_right_outlined,
              size: min(25*scaleFactor, 35),
              color: Colors.white,
            ),
            onPressed: () async {
              cubit.setpath(
                  foldername: componentName,
                  flag: 1,
                  update: 0,
                  index: index
              );
              cubit.updateInputData(context: tabContext);
              cubit.updateActiveDeviceLoading(index: index);
              cubit.emitSocketEvent(
                ip: ip,
                event: "getPartition",
                msg: {
                  "ip": ip,
                  "target": componentName.replaceAll("\\", ""),
                  "dataType": "Folder",
                  "part": "secondary",
                  "componentName": componentName,
                  "index": index,
                  "path_flag": 1,
                },
              );

            },
          ),
        ],
      ),
    );
  }
}
