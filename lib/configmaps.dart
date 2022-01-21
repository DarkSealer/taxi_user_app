import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '/models/all_users.dart';

String mapKey = "AIzaSyAALYM8a49G3M_WTZytgesrxNmMIQersaU";
String language = "ro";
User? firebaseUser;
Users? userCurrentInfo;
User? currentfirebaseUser;
StreamSubscription<Position>? homeTabPageStreamSubscription;
