import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '/assistants/assistant_methods.dart';
import '/features/home/data/services/driver_availability_service.dart';
import '/models/drivers.dart';
import '/notifications/push_notification_service.dart';
import '/configmaps.dart';
import '/main.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

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
  late final DriverAvailabilityService _driverAvailabilityService;

  final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _driverAvailabilityService = DriverAvailabilityService(
      currentRequestRef: rideRequestRef,
    );

    getCurrentDriverInfo();
  }

  void getRideType() {
    driversRef
        .child(currentfirebaseUser!.uid)
        .child('car_details')
        .child('type')
        .get()
        .then((snapshot) {
      if (snapshot.value != null) {
        setState(() {
          rideType = snapshot.value.toString();
        });
      }
    });
  }

  void getRatings() {
    // update and display Ratings
    driversRef
        .child(currentfirebaseUser!.uid)
        .child('ratings')
        .get()
        .then((snap) {
      if (snap.value != null) {
        setState(() {
          starCounter = double.parse(snap.value.toString());
        });

        if (starCounter <= 1.5) {
          setState(() {
            title = 'Very Bad';
          });
          return;
        }
        if (starCounter <= 2.5) {
          setState(() {
            title = 'Bad';
          });

          return;
        }
        if (starCounter <= 3.5) {
          setState(() {
            title = 'Good';
          });
          return;
        }
        if (starCounter <= 4.5) {
          setState(() {
            title = 'Very Good';
          });
          return;
        }
        if (starCounter <= 5) {
          setState(() {
            title = 'Excellent';
          });
          return;
        }
      }
    });
  }

  // get the user current position
  void locatePosition() async {
    final bool hasPermission = await _ensureLocationPermission();
    if (!hasPermission) {
      return;
    }
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } on PermissionDeniedException {
      _showLocationPermissionDeniedMessage();
      return;
    }

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
    currentfirebaseUser = FirebaseAuth.instance.currentUser!;

    driversRef.child(currentfirebaseUser!.uid).get().then((dataSnapshot) {
      if (dataSnapshot.value != null) {
        driversInformation = Drivers.fromSnapshot(dataSnapshot);
      }
    });

    PushNotificationService pushNotificationService = PushNotificationService();

    pushNotificationService.initialize(context);
    await pushNotificationService.getToken();
    // String? token = await pushNotificationService.getToken();
    // print("Token:: $token");

    AssistantMethods.retrieveHistoryInfo(context);
    getRatings();
    getRideType();
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
        Positioned(
          top: 52,
          left: 16,
          right: 16,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isDriverAvailable ? "You are online" : "You are offline",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (isDriverAvailable
                                  ? Colors.green
                                  : const Color(0xFFEF4444))
                              .withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          isDriverAvailable ? "ONLINE" : "OFFLINE",
                          style: TextStyle(
                            color: isDriverAvailable
                                ? Colors.green
                                : const Color(0xFFEF4444),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Semantics(
                    label: isDriverAvailable
                        ? "Go offline button"
                        : "Go online button",
                    button: true,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDriverAvailable
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF171717),
                      ),
                      onPressed: () {
                        if (!isDriverAvailable) {
                          makeDriverOnlineNow();
                          getLocationLiveUpdates();

                          setState(() {
                            driverStatusColor = Colors.green;
                            driverStatusText = "Online Now";
                            isDriverAvailable = true;
                          });

                          displayToastMessage("You are online now.", context);
                          return;
                        }

                        makeDriverOfflineNow();

                        setState(() {
                          driverStatusColor = Colors.red;
                          driverStatusText = "Offline Now - Go Online";
                          isDriverAvailable = false;
                        });
                      },
                      child:
                          Text(isDriverAvailable ? "Go Offline" : "Go Online"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void makeDriverOfflineNow() {
    _driverAvailabilityService.makeDriverOffline(
      driverId: currentfirebaseUser!.uid,
    );
    rideRequestRef = null;
    displayToastMessage("You are offline now.", context);
  }

  void makeDriverOnlineNow() async {
    final bool hasPermission = await _ensureLocationPermission();
    if (!hasPermission) {
      return;
    }
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } on PermissionDeniedException {
      _showLocationPermissionDeniedMessage();
      return;
    }

    currentPosition = position;

    _driverAvailabilityService.makeDriverOnline(
      driverId: currentfirebaseUser!.uid,
      position: currentPosition,
    );
    rideRequestRef!.onValue.listen((event) {
      //
    });
  }

  void getLocationLiveUpdates() {
    Geolocator.checkPermission().then((permission) {
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showLocationPermissionDeniedMessage();
      }
    });
    homeTabPageStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      if (isDriverAvailable) {
        _driverAvailabilityService.updateLiveLocation(
          driverId: currentfirebaseUser!.uid,
          position: position,
        );
      }
      LatLng latlng = LatLng(position.latitude, position.longitude);
      newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latlng));
    }, onError: (Object error) {
      if (error is PermissionDeniedException) {
        _showLocationPermissionDeniedMessage();
        homeTabPageStreamSubscription?.cancel();
      }
    });
  }

  Future<bool> _ensureLocationPermission() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      displayToastMessage(
        "Please enable location service to continue.",
        context,
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showLocationPermissionDeniedMessage();
      return false;
    }
    return true;
  }

  void _showLocationPermissionDeniedMessage() {
    displayToastMessage(
      "Location permission denied. Please allow location access.",
      context,
    );
  }
}
