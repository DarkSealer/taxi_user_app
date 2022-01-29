import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:taxi_driver_app/models/drivers.dart';
import 'package:taxi_driver_app/notifications/push_notification_service.dart';

import '/configmaps.dart';
import '/main.dart';

class HomeTabPage extends StatefulWidget {
  HomeTabPage({Key? key}) : super(key: key);

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;
  var geoLocator = Geolocator();
  String driverStatusText = "Offline Now - Go Online  ";
  Color driverStatusColor = Colors.red;
  bool isDriverAvailable = false;

  final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCurrentDriverInfo();
  }

  // get the user current position
  void locatePosition() async {
    await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    currentPosition = position;
    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    // String address =
    //     await AssistantMethods.searchCoordinateAddress(position, context);
    // print("This is your Address: $address");
  }

  void getCurrentDriverInfo() async {
    currentfirebaseUser = await FirebaseAuth.instance.currentUser!;

    driversRef.child(currentfirebaseUser!.uid).get().then((dataSnapshot) {
      if (dataSnapshot.value != null) {
        driversInformation = Drivers.fromSnapshot(dataSnapshot);
      }
    });

    PushNotificationService pushNotificationService = PushNotificationService();

    pushNotificationService.initialize(context);
    String? token = await pushNotificationService.getToken();
    print("Token:: $token");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          initialCameraPosition: _kGooglePlex,
          myLocationEnabled: true,
          // zoomGesturesEnabled: true,
          // zoomControlsEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

            locatePosition();
          },
        ),
        //online / offline driver Container
        Container(
          height: 140,
          width: double.infinity,
          color: Colors.black54,
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RaisedButton(
                  onPressed: () {
                    // do something
                    if (!isDriverAvailable) {
                      makeDriverOnlineNow();
                      getLocationLiveUpdates();

                      setState(() {
                        driverStatusColor = Colors.green;
                        driverStatusText = "Online Now  ";
                        isDriverAvailable = true;
                      });

                      displayToastMessage("You are Online Now.", context);
                      return;
                    }

                    makeDriverOfflineNow();

                    setState(() {
                      driverStatusColor = Colors.red;
                      driverStatusText = "Offline Now - Go Online  ";
                      isDriverAvailable = false;
                    });
                  },
                  color: driverStatusColor,
                  child: Padding(
                    padding: const EdgeInsets.all(17),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          driverStatusText,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const Icon(
                          Icons.phone_android,
                          color: Colors.white,
                          size: 26,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void makeDriverOfflineNow() {
    Geofire.removeLocation(currentfirebaseUser!.uid);
    rideRequestRef!.onDisconnect();
    rideRequestRef!.remove();
    rideRequestRef = null;
    displayToastMessage("You are Offline Now.", context);
  }

  void makeDriverOnlineNow() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    currentPosition = position;

    Geofire.initialize("availableDrivers");
    Geofire.setLocation(currentfirebaseUser!.uid, currentPosition.latitude,
        currentPosition.longitude);

    rideRequestRef!.set("searching"); // make the driver "available" for a ride
    rideRequestRef!.onValue.listen((event) {
      //
    });
  }

  void getLocationLiveUpdates() {
    homeTabPageStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      if (isDriverAvailable) {
        Geofire.setLocation(
            currentfirebaseUser!.uid, position.latitude, position.longitude);
      }
      LatLng latlng = LatLng(position.latitude, position.longitude);
      newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latlng));
    });
  }
}
