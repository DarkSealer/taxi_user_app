import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '/models/all_users.dart';
import 'models/drivers.dart';

const String mapKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
String language = "ro";
User? firebaseUser;
Users? userCurrentInfo;
User? currentfirebaseUser;
StreamSubscription<Position>? homeTabPageStreamSubscription;
StreamSubscription<Position>? rideStreamSubscription;
final assetsAudioPlayer = AudioPlayer();
late Position currentPosition;
late Drivers driversInformation;
String title = '';
double starCounter = 0;
String rideType = '';

void displayToastMessage(String msg, BuildContext context) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: Text(msg),
      action:
          SnackBarAction(label: 'OK', onPressed: scaffold.hideCurrentSnackBar),
    ),
  );
}
