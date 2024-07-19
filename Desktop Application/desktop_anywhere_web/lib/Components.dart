

import 'package:flutter/material.dart';

Widget listHeader({
  required text,
  fontSize = 18,
  color = Colors.white
}){
  return Expanded(
    child: Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    ),
  );
}


Widget deviceCard({data, fun, context}){
  return Padding(
    padding: const EdgeInsets.only(top: 5.0, right: 10, left: 10),
    child: Container(
      padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          listHeader(text: data["name"], fontSize: 16, color: Colors.black),
          listHeader(text: data["model"], fontSize: 16, color: Colors.black),
          Expanded(
            child: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                ),
                onPressed: (){
                  dialog(
                    title: 'Alert!',
                    message: 'Are you sure that you want to remove ${data["name"]}\'s Device?',
                    context: context,
                    actionButtons: [
                      MaterialButton(
                        onPressed: () async {
                          fun(data);
                          Navigator.pop(context); // Close the pop-up
                        },
                        child: const Text(
                          'Yes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the pop-up
                        },
                        child: const Text(
                          'No',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


Object dialog({
  required title,
  required message,
  required actionButtons,
  required context,
}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      titlePadding: const EdgeInsetsDirectional.only(top: 20),
      title: Center(
        child: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red
          ),
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 19
        ),
      ),
      actionsPadding: const EdgeInsetsDirectional.only(bottom: 20),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: actionButtons,
        ),
      ],
    ),
  );

}