//import 'package:beggarking/Widgets/Command.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

class Insert_King {
  // Insert_King({
  //   required this.pic,
  //   required this.Location,
  //   required this.country,
  //   required this.area,
  //   required this.localPin,
  //   required this.district,
  //   required this.state,
  //   required this.latitude,
  //   required this.logitude,
  //   required this.like,
  //   required this.dislike,
  // });
  // var pic;
  // String Location;
  // String country;
  // String localPin;
  // String area;
  // String district;
  // String state;
  // String latitude;
  // String logitude;
  // int like;
  // int dislike;
  putFile(
    var pic,
    String Location,
    String country,
    String localPin,
    String area,
    String district,
    String state,
    String latitude,
    String logitude,
    int like,
    int dislike,
  ) async {
    var uuid = Uuid().v4();
    final storage_ref = await FirebaseStorage.instance
        .ref()
        .child('King Pics')
        .child('${FirebaseAuth.instance.currentUser!.email}')
        .child(uuid);
    await storage_ref.putFile(pic);
    final Image_url = await storage_ref.getDownloadURL();
    final cloud_ref = await FirebaseFirestore.instance.collection(
      'King details',
    );
    await cloud_ref.doc(uuid).set({
      'UserName': FirebaseAuth.instance.currentUser!.displayName,
      'User_email': FirebaseAuth.instance.currentUser!.email,
      'King_url': Image_url,
      'Address': Location,
      'country': country,
      "localPin": localPin,
      "district": district,
      "state": state,
      "Area": area,
      "latitude": latitude,
      "longitude": logitude,
      "like": like,
      "dislike": dislike,
      "uuid": uuid,
      "likedUsers": {"test"},
      "dislikedUsers": {"test"},
      "comments": {""},
      'Launched_at': Timestamp.now(),
    });
  }

  Future<void> updateLike(var Users, String uuid) async {
    await FirebaseFirestore.instance
        .collection('King details')
        .doc(uuid)
        .update({"likedUsers": Users.toSet().toList(), 'like': Users.length});
  }

  Future<void> updatedisLike(var Users, String uuid) async {
    await FirebaseFirestore.instance
        .collection('King details')
        .doc(uuid)
        .update({
          "dislikedUsers": Users.toSet().toList(),
          'dislike': Users.length,
        });
  }

  Future<void> updatecomments(var comment, String uuid) async {
    await FirebaseFirestore.instance
        .collection('King details')
        .doc(uuid)
        .update({"comments": comment.toList()});
  }

  void live() {
    Geolocator.requestPermission();
    Geolocator.getPositionStream().listen((event) async {
      final currlat = event.latitude;
      final currlong = event.longitude;
      await FirebaseFirestore.instance.collection("Live").doc("Live").set({
        "lat": currlat,
        "long": currlong,
      });
    });
  }
}
