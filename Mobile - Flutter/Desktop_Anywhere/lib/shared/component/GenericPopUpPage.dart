import 'package:flutter/material.dart';

class ConfirmationPopup extends StatelessWidget {
  String? title;
  Color? titleColor;
  Widget? titleWidget;
  String? message;
  Widget? messageWidget;
  List<Widget>? actionButtons;
  Widget? content;
  String? textOfAcceptanceButton;
  String? textOfRejectionButton;
  var functionOfAcceptanceButton;


   ConfirmationPopup({
     Key? key,
     this.title,
     this.message,
     this.actionButtons,
     this.functionOfAcceptanceButton,
     this.textOfAcceptanceButton,
     this.textOfRejectionButton,
     this.content,
     this.messageWidget,
     this.titleWidget,
     this.titleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: titleWidget?? Text(
          title!,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: titleColor?? Colors.red
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          messageWidget ?? Text(
            message!,
            style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 19
            ),
          ),
          content ?? const SizedBox(),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: actionButtons ?? [
              MaterialButton(
                onPressed: functionOfAcceptanceButton,
                child: Text(
                  textOfAcceptanceButton?? 'Yes',
                  style: const TextStyle(
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
                child: Text(
                  textOfRejectionButton?? 'No',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
        ),
      ],
    );
  }
}

