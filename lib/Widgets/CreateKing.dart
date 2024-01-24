import 'package:beggarking/Widgets/PreviewKing.dart';
import 'package:beggarking/Widgets/newtest.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateKing extends StatefulWidget {
  const CreateKing({super.key});

  @override
  State<CreateKing> createState() {
    return _CreateKing();
  }
}

class _CreateKing extends State<CreateKing> {
  void onClick() {
    showModalBottomSheet(
        context: context,
        builder: (ctx) => PreviewKing(),
        enableDrag: true,
        isScrollControlled: true,
        showDragHandle: true);
  }

  Widget build(context) {
    return Padding(
      padding: EdgeInsets.only(top: 2, left: 15, bottom: 15, right: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextButton(
              onPressed: onClick,
              child: Text('I Found A King...'),
            ),
          ),
        ],
      ),
    );
  }
}
