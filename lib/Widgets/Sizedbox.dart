import 'package:flutter/cupertino.dart';

class getSizedBox extends StatelessWidget {
  getSizedBox({required this.height, required this.widht});
  double height;
  double widht;
  Widget build(context) {
    return SizedBox(
      height: height,
      width: widht,
    );
  }
}
