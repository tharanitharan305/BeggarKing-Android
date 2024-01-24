import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Locations {
  Future<bool> getPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return false;
    }
    return true;
  }

  Future<String> getcurrentLocation() async {
    String Address;
    if (await getPermission()) {
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> place =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      return "${place[0].street!},${place[0].thoroughfare},${place[0].subLocality},${place[0].locality},${place[0].administrativeArea!},${place[0].postalCode},${place[0].country}";
    }
    return "Enter address manual";
  }
}
