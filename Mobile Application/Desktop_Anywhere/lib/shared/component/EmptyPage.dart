



import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Image(
              image: AssetImage('assets/images/Empty.png'),
            ),
            Text(
              "No devices added yet, please add one ..",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16
              ),
            ),
          ],
        ),
      ),
    );
  }
}


