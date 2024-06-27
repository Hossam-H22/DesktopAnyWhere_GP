import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


class LoadingPage extends StatelessWidget {
  Color? backgroundColor;
  Color? circleColor;

  LoadingPage({
    super.key,
    this.backgroundColor,
    this.circleColor
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      color: backgroundColor ?? Colors.black.withOpacity(0.5),
      child: Center(
        child: LoadingAnimationWidget.dotsTriangle(
          color: circleColor ?? Colors.white,
          size: 75,
        ),
      ),
    );
  }
}
