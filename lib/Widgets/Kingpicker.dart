import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class KingPicker extends StatefulWidget {
  State<KingPicker> createState() {
    return _KingPicker();
  }
}

class _KingPicker extends State<KingPicker> {
  File? King;
  void onClick() async {
    final image =
        await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 50);
    if (image == null) return;
    setState(() {
      King = File(image.path);
    });
  }

  Widget build(context) {
    return Container(
      child: King == null
          ? IconButton(onPressed: onClick, icon: Icon(Icons.camera_alt_rounded))
          : Image(image: FileImage(King!), fit: BoxFit.contain),
      height: 350,
    );
  }
}
