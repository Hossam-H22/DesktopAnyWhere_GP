import 'dart:math';

import 'package:flutter/material.dart';

enum ComponentType { Folder, File }

class GenericComponent extends StatefulWidget {
  final String componentName;
  final ComponentType componentType;

  const GenericComponent({
    Key? key,
    required this.componentName,
    required this.componentType,
  }) : super(key: key);

  @override
  State<GenericComponent> createState() => _GenericComponentState();
}

class _GenericComponentState extends State<GenericComponent> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 400;

    IconData iconData;
    Color iconColor;

    switch (widget.componentType) {

      case ComponentType.Folder:
        iconData = Icons.folder_outlined;
        iconColor = Colors.blue;
        break;
      case ComponentType.File:
        iconData = Icons.insert_drive_file_outlined;
        iconColor = Colors.green;
        break;
    }

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
                    iconData,
                    color: iconColor,
                    size: min(25*scaleFactor, 35)
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  widget.componentName,
                  style: TextStyle(
                    fontSize: min(22*scaleFactor, 25),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (widget.componentType == ComponentType.Folder ||
                  widget.componentType == ComponentType.File)
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    size: min(25*scaleFactor, 35),
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // Customize the behavior based on component type
                    if (widget.componentType == ComponentType.Folder) {
                      // Handle folder click
                    } else if (widget.componentType == ComponentType.File) {
                      // Handle file click
                    }
                  },
                ),

              if (widget.componentType == ComponentType.Folder)
                IconButton(
                  icon: Icon(
                    Icons.arrow_circle_right_outlined,
                    size: min(25*scaleFactor, 35),
                    color: Colors.white,
                  ),
                  onPressed: () {
                    print(widget.componentName);
                    // // Customize the behavior based on component type
                    // if (widget.componentType == ComponentType.Folder) {
                    //   // Handle folder click
                    // } else if (widget.componentType == ComponentType.File) {
                    //   // Handle file click
                    // }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
