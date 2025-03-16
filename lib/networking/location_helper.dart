import 'package:test/models/user_location.dart';
import 'package:test/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';

class LocationHelper {
  Location location = Location();

  Future<UserLocation?> getUserLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        Fluttertoast.showToast(
            textColor: Colors.white,
            backgroundColor: kOrangeColor,
            msg: getTranslatedText(
                "لوکیشن سروس کو فعال کریں۔", "enable location service."),
            gravity: ToastGravity.CENTER);
        return null;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        Fluttertoast.showToast(
            textColor: Colors.white,
            backgroundColor: kOrangeColor,
            msg: getTranslatedText("لوکیشن کی اجازت کی ضرورت ہے.",
                "location permission required."),
            gravity: ToastGravity.CENTER);
        return null;
      }
    }
    if (permissionGranted == PermissionStatus.granted) {
      LocationData locationData = await location.getLocation();
      if (locationData.latitude != null) {
        UserLocation location = UserLocation(
            longitude: locationData.longitude!,
            latitude: locationData.latitude!);
        return location;
      }
    }
    return null;
  }
}
