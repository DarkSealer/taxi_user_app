import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '/models/all_users.dart';
import 'models/drivers.dart';

String mapKey = "AIzaSyAALYM8a49G3M_WTZytgesrxNmMIQersaU";
String language = "ro";
User? firebaseUser;
Users? userCurrentInfo;
User? currentfirebaseUser;
StreamSubscription<Position>? homeTabPageStreamSubscription;
StreamSubscription<Position>? rideStreamSubscription;
final assetsAudioPlayer = AssetsAudioPlayer();
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
