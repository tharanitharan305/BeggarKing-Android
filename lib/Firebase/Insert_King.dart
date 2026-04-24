//import 'package:beggarking/Widgets/Command.dart';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  Future<void> putFile({
    required Uint8List picData,
    required String fileName,
    required String location,
    required String country,
    required String localPin,
    required String area,
    required String district,
    required String state,
    required String latitude,
    required String logitude,
    required int like,
    required int dislike,
  }) async {
    if (picData.isEmpty || fileName.trim().isEmpty) {
      throw Exception('Invalid file data provided for upload.');
    }

    final uuid = Uuid().v4();
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final storagePath =
        'public/${DateTime.now().millisecondsSinceEpoch}_${uuid}_$safeName';

    try {
      await Supabase.instance.client.storage
          .from('beggarPicks')
          .uploadBinary(storagePath, picData);
    } on StorageException catch (e) {
      throw Exception('Supabase upload failed: ${e.message}');
    } catch (e) {
      throw Exception('Supabase upload failed: $e');
    }

    final imageUrl = Supabase.instance.client.storage
        .from('beggarPicks')
        .getPublicUrl(storagePath);
    final cloudRef = FirebaseFirestore.instance.collection('King details');
    await cloudRef.doc(uuid).set({
      'UserName': FirebaseAuth.instance.currentUser!.displayName,
      'User_email': FirebaseAuth.instance.currentUser!.email,
      'King_url': imageUrl,
      'Address': location,
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

  Future<void> updateLike(dynamic users, String uuid) async {
    await FirebaseFirestore.instance
        .collection('King details')
        .doc(uuid)
        .update({"likedUsers": users.toSet().toList(), 'like': users.length});
  }

  Future<void> updatedisLike(dynamic users, String uuid) async {
    await FirebaseFirestore.instance
        .collection('King details')
        .doc(uuid)
        .update({
          "dislikedUsers": users.toSet().toList(),
          'dislike': users.length,
        });
  }

  Future<void> updatecomments(dynamic comment, String uuid) async {
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
