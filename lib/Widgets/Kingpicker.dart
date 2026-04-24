import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class KingPicker extends StatefulWidget {
  State<KingPicker> createState() {
    return _KingPicker();
  }
}

class _KingPicker extends State<KingPicker> {
  XFile? king;
  Uint8List? kingBytes;

  void onClick() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      king = image;
      kingBytes = bytes;
    });
  }

  Widget build(context) {
    return Container(
      child:
          king == null
              ? IconButton(
                onPressed: onClick,
                icon: Icon(Icons.camera_alt_rounded),
              )
              : Image.memory(kingBytes!, fit: BoxFit.contain),
      height: 350,
    );
  }
}
