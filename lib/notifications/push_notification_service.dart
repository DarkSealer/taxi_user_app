import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '/features/ride/data/mappers/ride_request_mapper.dart';
import '/features/ride/data/repositories/firebase_ride_requests_repository.dart';
import '/features/ride/domain/usecases/get_ride_request_use_case.dart';
import '/notifications/notification_dialog.dart';
import '../configmaps.dart';
import '../main.dart';

class PushNotificationService {
  late FirebaseMessaging firebaseMessaging;
  late final GetRideRequestUseCase _getRideRequestUseCase;

  PushNotificationService({
    DatabaseReference? requestsRef,
  }) {
    _getRideRequestUseCase = GetRideRequestUseCase(
      FirebaseRideRequestsRepository(requestsRef ?? newRequestRef),
    );
  }

  Future initialize(context) async {
    firebaseMessaging = FirebaseMessaging.instance;

    await firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) async {
      // retrieveUserRequestInfo(getUserRequestId(message), context);
      if (message.notification != null) {
        retrieveRideRequestInfo(getRideRequestId(message), context);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      // retrieveUserRequestInfo(getUserRequestId(message), context);
      if (message.notification != null) {
        retrieveRideRequestInfo(getRideRequestId(message), context);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<String?> getToken() async {
    String? token = await firebaseMessaging.getToken();
    driversRef.child(currentfirebaseUser!.uid).child("token").set(token);

    firebaseMessaging.subscribeToTopic("alldrivers");
    firebaseMessaging.subscribeToTopic("allusers");

    return token;
  }

  String getUserRequestId(RemoteMessage message) {
    String userRequestId = message.data['user_request_id'].toString();
    return userRequestId;
  }

  Future<void> retrieveUserRequestInfo(
      String userRequestId, BuildContext context) async {
    retrieveRideRequestInfo(userRequestId, context);
  }

  String getRideRequestId(RemoteMessage message) {
    String? rideRequestId = "";
    // if (Platform.isAndroid) {
    // retrieve if is Android
    log('This is Ride Request Id: ${message.data['ride_request_id']}');
    rideRequestId = message.data['ride_request_id'];
    // }
    // else if (Platform.isIOS) {
    //   // retrieve for iOS
    //   rideRequestId = message['ride_request_id'];
    // }

    return rideRequestId!;
  }

  void retrieveRideRequestInfo(String rideRequestId, BuildContext context) {
    _getRideRequestUseCase.call(rideRequestId).then((result) {
      if (!result.hasData) {
        return;
      }
      assetsAudioPlayer.play(AssetSource('sounds/alert.mp3'));
      final rideDetails = result.data!.toRideDetails();
      log('Information:: ${rideDetails.dropoff_address}');

      showDialog(
        context: context,
        builder: (BuildContext context) =>
            NotificationDialog(rideDetails: rideDetails),
        barrierDismissible: false,
      );
    });
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}
