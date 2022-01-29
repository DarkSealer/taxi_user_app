import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_driver_app/widgets/collect_fare_dialog.dart';

import '/assistants/assistant_methods.dart';
import '/assistants/map_kit_assistant.dart';
import '/configmaps.dart';
import '/main.dart';
import '/models/direction_details.dart';
import '/models/ride_details.dart';
import '/widgets/progressdialog.dart';

class NewRideScreen extends StatefulWidget {
  RideDetails rideDetails;
  NewRideScreen({Key? key, required this.rideDetails}) : super(key: key);

  static final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _NewRideScreenState createState() => _NewRideScreenState();
}

class _NewRideScreenState extends State<NewRideScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newRideGoogleMapController;
  Set<Marker> markersSet = Set<Marker>();
  Set<Circle> circleSet = Set<Circle>();
  Set<Polyline> polylineSet = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  double mapPaddingFromBottom = 0;
  var geoLocator = Geolocator();
  var locationOptions =
      const LocationSettings(accuracy: LocationAccuracy.bestForNavigation);
  BitmapDescriptor? animatingMarkerIcon;
  late Position myPosition;
  String status = 'accepted';
  String durationRide = "1 min";
  bool isRequestingDirection = false;
  String btnTitle = "Arrived";
  Color btnColor = Colors.blueAccent;
  late Timer timer;
  int durationCounter = 0;

  @override
  void initState() {
    super.initState();

    acceptRideRequest();
  }

  void createIconMarker() {
    if (animatingMarkerIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
        context,
        size: const Size(2, 2),
      );
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "images/car_android.png")
          .then((value) {
        animatingMarkerIcon = value;
      });
    }
  }

  void getRideLiveLocationUpdates() {
    LatLng oldPos = LatLng(0, 0);

    rideStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      myPosition = position;
      LatLng mPosition = LatLng(position.latitude, position.longitude);

      // update the rotation of the car icon on map
      var rot = MapKitAssistant.getMarkerRotation(
        oldPos.latitude,
        oldPos.longitude,
        myPosition.latitude,
        myPosition.longitude,
      );

      Marker animatingMarker = Marker(
        markerId: const MarkerId("animating"),
        position: mPosition,
        icon: animatingMarkerIcon!,
        rotation: rot,
        infoWindow: const InfoWindow(title: "Current Location"),
      );

      setState(() {
        CameraPosition cameraPosition = CameraPosition(
          target: mPosition,
          zoom: 17,
        );
        newRideGoogleMapController
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        markersSet
            .removeWhere((element) => element.markerId.value == "animating");
        markersSet.add(animatingMarker);
      });

      oldPos = mPosition;
      updateRideDetails();

      // update the position in db
      String rideRequestId = widget.rideDetails.ride_request_id;
      updateLocationInDb(rideRequestId);
    });
  }

  @override
  Widget build(BuildContext context) {
    createIconMarker();

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPaddingFromBottom),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: NewRideScreen._kGooglePlex,
            myLocationEnabled: true,
            markers: markersSet,
            circles: circleSet,
            polylines: polylineSet,
            // zoomGesturesEnabled: true,
            // zoomControlsEnabled: true,
            onMapCreated: (GoogleMapController controller) async {
              _controllerGoogleMap.complete(controller);
              newRideGoogleMapController = controller;

              setState(() {
                mapPaddingFromBottom = 265;
              });

              var currentLatLng =
                  LatLng(currentPosition.latitude, currentPosition.longitude);
              var pickupLatLng = widget.rideDetails.pickup;

              await getPlaceDirection(currentLatLng, pickupLatLng!);
              getRideLiveLocationUpdates();
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 16,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              height: 270,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  children: [
                    Text(
                      durationRide,
                      style: const TextStyle(
                          fontSize: 14,
                          fontFamily: "Brand",
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.rideDetails.rider_name,
                          style: const TextStyle(
                            fontFamily: "Brand",
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.phone_android),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 26.0,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "images/pickicon.png",
                          height: 16,
                          width: 16,
                        ),
                        const SizedBox(
                          width: 18,
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.rideDetails.pickup_address,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Image.asset(
                          "images/desticon.png",
                          height: 16,
                          width: 16,
                        ),
                        const SizedBox(
                          width: 18,
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.rideDetails.dropoff_address,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 26,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: RaisedButton(
                        onPressed: () async {
                          // update the Arrived button
                          if (status == "accepted") {
                            // cand soferul accepta comanda si pleaca spre client
                            status = "arrived";
                            newRequestRef
                                .child(widget.rideDetails.ride_request_id)
                                .child("status")
                                .set(status);

                            setState(() {
                              btnTitle = "Start Trip";
                              btnColor = Colors.green;
                            });

                            // display a message to let the user know that is loading
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) =>
                                    ProgressDialog(
                                      message: "Please wait...",
                                    ));

                            // load the data
                            await getPlaceDirection(
                              widget.rideDetails.pickup!,
                              widget.rideDetails.dropoff!,
                            );

                            // close the message
                            Navigator.pop(context);
                          }
                          // cand soferul a preluat clientul si pleaca spre destinatie
                          else if (status == "arrived") {
                            status = "onride";
                            newRequestRef
                                .child(widget.rideDetails.ride_request_id)
                                .child("status")
                                .set(status);

                            setState(() {
                              btnTitle = "End Trip";
                              btnColor = Colors.redAccent;
                            });

                            // start the timer
                            initTimer();
                          }
                          // cand se incheie calatoria
                          else if (status == "onride") {
                            endTheTrip();
                          }
                        },
                        color: btnColor,
                        child: Padding(
                          padding: const EdgeInsets.all(17),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                btnTitle,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Icon(
                                Icons.directions_car,
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
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getPlaceDirection(
      LatLng pickUpLatLng, LatLng dropOffLatLng) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Please wait...",
            ));

    var details = await AssistantMethods.obtainDirectionsDetails(
        pickUpLatLng, dropOffLatLng);

    Navigator.pop(context);

    print("This is Encoded Points: ${details!.encodedPoints}");

    PolylinePoints polylinePoints = PolylinePoints();
    // decode the encoded polyline points
    List<PointLatLng> decodePolylinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints);

    polylineCoordinates.clear();

    if (decodePolylinePointsResult.isNotEmpty) {
      for (var pointLatLng in decodePolylinePointsResult) {
        polylineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: Colors.blue,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polylineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });

    // make the polyline stick to the map
    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newRideGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    // marker for pick up location
    Marker pickUpLocMarker = Marker(
      markerId: const MarkerId("pickUpId"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      position: pickUpLatLng,
    );

    // marker for drop off location
    Marker dropOffLocMarker = Marker(
      markerId: const MarkerId("dropOffId"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: dropOffLatLng,
    );

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
      circleId: const CircleId("pickUpId"),
      fillColor: Colors.green,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.greenAccent,
    );

    Circle dropOffLocCircle = Circle(
      circleId: const CircleId("dropOffId"),
      fillColor: Colors.red,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.redAccent,
    );

    setState(() {
      circleSet.add(pickUpLocCircle);
      circleSet.add(dropOffLocCircle);
    });
  }

  void acceptRideRequest() {
    String rideRequestId = widget.rideDetails.ride_request_id;
    newRequestRef.child(rideRequestId).child("status").set("accepted");
    newRequestRef
        .child(rideRequestId)
        .child("driver_name")
        .set(driversInformation.name);
    newRequestRef
        .child(rideRequestId)
        .child("driver_phone")
        .set(driversInformation.phone);
    newRequestRef
        .child(rideRequestId)
        .child("driver_id")
        .set(driversInformation.id);
    newRequestRef.child(rideRequestId).child("car_details").set(
        '${driversInformation.car_color} - ${driversInformation.car_model}');

    updateLocationInDb(rideRequestId);

    // add the trip to the history of this driver
    driversRef
        .child(currentfirebaseUser!.uid)
        .child("history")
        .child(rideRequestId)
        .set(true);
  }

  void updateLocationInDb(String rideRequestId) {
    Map locMap = {
      "latitude": currentPosition.latitude.toString(),
      "longitude": currentPosition.longitude.toString(),
    };

    newRequestRef.child(rideRequestId).child("driver_location").set(locMap);
  }

  // actualizeaza starea comenzii
  void updateRideDetails() async {
    if (!isRequestingDirection) {
      isRequestingDirection = true;
      if (myPosition == null) return;

      var posLatLng = LatLng(myPosition.latitude, myPosition.longitude);
      LatLng destinationLatLng;

      // comanda a fost acceptata - destinatia = punctul de preluare a clientului
      if (status == "accepted") {
        destinationLatLng = widget.rideDetails.pickup!;
      }
      // clientul a fost preluat, destinatia = punctul de coborare al clientului
      else {
        destinationLatLng = widget.rideDetails.dropoff!;
      }

      // set the destination
      var directionDetails = await AssistantMethods.obtainDirectionsDetails(
        posLatLng,
        destinationLatLng,
      );

      if (directionDetails != null) {
        // print("DURATION IS UPDATING");
        setState(() {
          durationRide = directionDetails.durationText;
        });
      }

      isRequestingDirection = false;
    }
  }

  void initTimer() {
    const interval = Duration(seconds: 1);

    timer = Timer.periodic(interval, (timer) {
      durationCounter += 1;
    });
  }

  void endTheTrip() async {
    // stop the timer
    timer.cancel();

    // display a dialog
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
      ),
      barrierDismissible: false,
    );

    var currentLatLng = LatLng(
      myPosition.latitude,
      myPosition.longitude,
    );

    var directionalDetails = await AssistantMethods.obtainDirectionsDetails(
      widget.rideDetails.pickup!,
      currentLatLng,
    );

    // close the dialog
    Navigator.pop(context);

    // get the price
    int fareAmount = AssistantMethods.calculateFares(directionalDetails!);
    // update the status in db
    newRequestRef
        .child(widget.rideDetails.ride_request_id)
        .child("status")
        .set("ended");
    // update the price in db
    newRequestRef
        .child(widget.rideDetails.ride_request_id)
        .child("fares")
        .set(fareAmount.toString());

    rideStreamSubscription!.cancel();

    showDialog(
      context: context,
      builder: (BuildContext context) => CollectFareDialog(
        paymentMethod: widget.rideDetails.payment_method,
        fareAmount: fareAmount,
      ),
      barrierDismissible: false,
    );

    saveEarnings(fareAmount);
  }

  void saveEarnings(int fareAmount) {
    double totalEarnings = 0;
    // preia din db castigurile pentru sofer
    driversRef
        .child(currentfirebaseUser!.uid)
        .child("earnings")
        .get()
        .then((dataSnapshot) {
      // daca exista date
      if (dataSnapshot.value != null) {
        // converteste datele in valoare double
        double oldEarnings = double.parse(dataSnapshot.value.toString());
        // adauga castigurile anterioare + pretul cursei incheiate
        totalEarnings = fareAmount + oldEarnings;
      }
      // daca este un sofer nou fara castiguri anterioare
      else {
        totalEarnings = fareAmount.toDouble();
      }

      // actualizeaza informatia in db
      driversRef
          .child(currentfirebaseUser!.uid)
          .child("earnings")
          .set(totalEarnings.toStringAsFixed(2));
    });
  }
}
