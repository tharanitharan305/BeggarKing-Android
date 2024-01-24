import 'dart:ffi';
import 'dart:io';
import 'package:beggarking/Firebase/Insert_King.dart';
import 'package:beggarking/Widgets/locations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class PreviewKing extends StatefulWidget {
  State<PreviewKing> createState() {
    return _PreviewKing();
  }
}

class _PreviewKing extends State<PreviewKing> {
  final form_key = GlobalKey<FormState>();
  var geolocator;
  String street = "";
  String area = "";
  String village = "";
  String distric = "";
  String state = "";
  String pin = "";
  String country = "";
  File? King;
  String Address =
      "Where is the King...[Streetname,post or taluk,district,state]";
  void onClick() async {
    final image =
        await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 50);
    if (image == null) return;
    setState(() {
      King = File(image.path);
    });
  }

  void onLaunch() {
    if (form_key.currentState!.validate()) {
      form_key.currentState!.save();
      Insert_King(pic: King, Location: Address).putFile();
      Navigator.pop(context);
    }
  }

  Widget build(context) {
    return SingleChildScrollView(
      child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(shape: BoxShape.circle),
                height: 350,
                child: King == null
                    ? IconButton(
                        onPressed: onClick,
                        icon: Icon(Icons.camera_alt_rounded))
                    : Image(image: FileImage(King!), fit: BoxFit.contain),
              ),
              Form(
                key: form_key,
                child: Column(
                  children: [
                    TextFormField(
                      onTap: () async {
                        var add = await Locations().getcurrentLocation();
                        setState(() {
                          geolocator = add.split(",");
                          street = geolocator[0] + "," + geolocator[1];
                          area = geolocator[2];
                          distric = geolocator[3];
                          pin = geolocator[5];
                          state = geolocator[4];
                          country = geolocator[6];
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Street",
                        hintText: street,
                      ),
                      validator: (value) {
                        value = Address;
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 15 ||
                            !value.contains(","))
                          return "Enter a valid Address ";
                        return null;
                      },
                      onSaved: (value) {
                        setState(() {
                          Address = value!;
                        });
                      },
                    ),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: "area", hintText: area),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: "district", hintText: distric),
                    ),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: "Pin", hintText: pin),
                    ),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: "State", hintText: state),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: "Country", hintText: country),
                    )
                  ],
                ),
              ),
              if (King != null)
                TextButton.icon(
                  onPressed: onLaunch,
                  icon: Icon(Icons.rocket_rounded),
                  label: Text('Launch King...'),
                ),
              TextButton(
                onPressed: () {
                  setState(() {
                    King = null;
                  });
                },
                child: Text('Reset King...'),
              ),
            ],
          )),
    );
  }
}
