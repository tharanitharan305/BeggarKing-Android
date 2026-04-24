import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AlertBox extends StatelessWidget {
  const AlertBox({
    super.key,
    required this.title,
    required this.b1,
    this.b2,
    required this.content,
  });
  final String title;
  final String b1;
  final String? b2;
  final String content;

  Widget build(context) {
    final isB2 = b2 != null;
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        if (!isB2)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(b1),
          )
        else
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(b1),
          ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(b2!),
        ),
      ],
    );
  }
}
