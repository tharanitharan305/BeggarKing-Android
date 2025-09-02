import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AlertBox extends StatelessWidget {
  AlertBox({
    required this.title,
    required this.b1,
    required this.b2,
    required this.content,
  });
  String title;
  String b1;
  String b2;
  String content;

  Widget build(context) {
    var isB2 = b2 == null ? false : true;
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        if (!isB2)
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(b1))
        else
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(b1)),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(b2))
      ],
    );
  }
}
