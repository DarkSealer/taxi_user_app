// import 'dart:io' show Platform;

import 'package:assets_audio_player/assets_audio_player.dart' as AudioPlayer;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '/models/ride_details.dart';
import '/notifications/notification_dialog.dart';
import '../configmaps.dart';
import '../main.dart';

class PushNotificationService {
  late FirebaseMessaging firebaseMessaging;

  Future initialize(context) async {
    firebaseMessaging = FirebaseMessaging.instance;

    NotificationSettings settings = await firebaseMessaging.requestPermission(
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

    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) =>
        retrieveUserRequestInfo(getUserRequestId(message), context));
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
    print('This is Ride Request Id: ${message.data['ride_request_id']}');
    rideRequestId = message.data['ride_request_id'];
    // }
    // else if (Platform.isIOS) {
    //   // retrieve for iOS
    //   rideRequestId = message['ride_request_id'];
    // }

    return rideRequestId!;
  }

  void retrieveRideRequestInfo(String rideRequestId, BuildContext context) {
    newRequestRef
        .child(rideRequestId)
        .once()
        .then((DatabaseEvent databaseEvent) {
      if (databaseEvent.snapshot.value != null) {
        // play sound
        assetsAudioPlayer.open(AudioPlayer.Audio("sounds/alert.mp3"));
        assetsAudioPlayer.play();

        var values = databaseEvent.snapshot.value as Map<dynamic, dynamic>;
        double pickUpLocationLat =
            double.parse(values['pickup']['latitude'].toString());
        double pickUpLocationLng =
            double.parse(values['pickup']['longitude'].toString());
        String pickUpAddress = values['pickup_address'].toString();

        double dropOffLocationLat =
            double.parse(values['dropoff']['latitude'].toString());
        double dropOffLocationLng =
            double.parse(values['dropoff']['longitude'].toString());
        String dropOffAddress = values['dropoff_address'].toString();

        String paymentMethod = values['payment_method'].toString();

        String rider_name = values['rider_name'].toString();
        String rider_phone = values['rider_phone'].toString();

        RideDetails rideDetails = RideDetails(
            pickup_address: pickUpAddress,
            dropoff_address: dropOffAddress,
            ride_request_id: rideRequestId,
            payment_method: paymentMethod,
            rider_name: rider_name,
            rider_phone: rider_phone);
        rideDetails.pickup = LatLng(pickUpLocationLat, pickUpLocationLng);
        rideDetails.dropoff = LatLng(dropOffLocationLat, dropOffLocationLng);

        print('Information:: ');
        print(dropOffAddress);
        print(pickUpAddress);

        showDialog(
          context: context,
          builder: (BuildContext context) =>
              NotificationDialog(rideDetails: rideDetails),
          barrierDismissible: false,
        );
      }
    });
  }
}
