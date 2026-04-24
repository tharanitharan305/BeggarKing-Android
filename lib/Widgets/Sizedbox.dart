import 'package:flutter/cupertino.dart';

class getSizedBox extends StatelessWidget {
  const getSizedBox({super.key, required this.height, required this.widht});
  final double height;
  final double widht;

  Widget build(context) {
    return SizedBox(height: height, width: widht);
  }
}
