

import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {

  const ErrorPage({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Image(
          image: AssetImage('assets/images/Oops! 404 Error.png'),
        ),
      ),
    );
  }
}


