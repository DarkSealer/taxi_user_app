import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:taxi_driver_app/main.dart';
import 'package:taxi_driver_app/models/history.dart';

import '/datahandler/appdata.dart';
import '/models/direction_details.dart';

import '/assistants/requestassistant.dart';
import '/configmaps.dart';

class AssistantMethods {
  static const String _availableDriversPath = 'availableDrivers';
  static bool _isGeoFireInitialized = false;

  static Future<void> _ensureGeoFireInitialized() async {
    if (_isGeoFireInitialized) {
      return;
    }
    await Geofire.initialize(_availableDriversPath);
    _isGeoFireInitialized = true;
  }

  // decode the coordinate into a readable address
  // static Future<String> searchCoordinateAddress(
  //     Position position, context) async {
  //   String placeAddress = "";
  //   String st1, st2, st3, placeId;
  //   String url =
  //       "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
  //   var response = await RequestAssistant.getRequest(url);
  //   if (response != "failed") {
  //     // placeAddress = response["results"][0]["formatted_address"];
  //     st1 = response["results"][0]["address_components"][3]
  //         ["long_name"]; // localitate
  //     st2 = response["results"][0]["address_components"][1]
  //         ["long_name"]; // strada
  //     st3 = response["results"][0]["address_components"][5]
  //         ["long_name"]; // cod postal
  //     placeId = response["results"][0]["place_id"];
  //     placeAddress = st1 + ", " + st2 + ", " + st3;
  //     Address userPickUpAddress = new Address(
  //         placeFormattedAddress: placeAddress,
  //         placeName: placeAddress,
  //         placeId: placeId,
  //         latitude: position.latitude,
  //         longitude: position.longitude);
  //     Provider.of<AppData>(context, listen: false)
  //         .updatePickUpLocationAddress(userPickUpAddress);
  //   }
  //   return placeAddress;
  // }

  static Future<DirectionDetails?> obtainDirectionsDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";

    var res = await RequestAssistant.getRequest(directionUrl);

    if (res == "failed") {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails(
      distanceValue: res["routes"][0]["legs"][0]["distance"]["value"],
      durationValue: res["routes"][0]["legs"][0]["duration"]["value"],
      distanceText: res["routes"][0]["legs"][0]["distance"]["text"],
      durationText: res["routes"][0]["legs"][0]["duration"]["text"],
      encodedPoints: res["routes"][0]["overview_polyline"]["points"],
    );

    return directionDetails;
  }

  // TODO - de modificat valoarea initiala (0.20) pentru modificarea pretului
  static int calculateFares(DirectionDetails directionDetails) {
    // in terms of USD
    double timeTraveledFare =
        (directionDetails.durationValue / 60) * 0.20; // 0.20$ / minute
    double distanceTraveledFare =
        (directionDetails.distanceValue / 1000) * 0.20; // 0.20$ / km
    // directionDetails.durationValue * 0.20;

    double totalPriceAmount = timeTraveledFare + distanceTraveledFare;

    // 1$ = 160RS
    //double totalLocalAmount = totalPriceAmount * 160

    if (rideType == 'uber-x') {
      totalPriceAmount *= 2.0;
    } else if (rideType == 'bike') {
      totalPriceAmount = totalPriceAmount / 2.0;
    }

    return totalPriceAmount.truncate();
  }

  // stop notification from and to db for driver after accepted a ride
  static Future<void> disableHomeTabLiveLocationUpdates() async {
    homeTabPageStreamSubscription?.pause();
    await _ensureGeoFireInitialized();
    await Geofire.removeLocation(currentfirebaseUser!.uid);
  }

  static Future<void> enabelHomeTabLiveLocationUpdates() async {
    homeTabPageStreamSubscription?.resume();
    await _ensureGeoFireInitialized();
    await Geofire.setLocation(
      currentfirebaseUser!.uid,
      currentPosition.latitude,
      currentPosition.longitude,
    );
  }

  static void retrieveHistoryInfo(context) {
    // retrieve and display Earnings
    driversRef
        .child(currentfirebaseUser!.uid)
        .child('earnings')
        .get()
        .then((snap) {
      if (snap.value != null) {
        String earnings = snap.value.toString();
        Provider.of<AppData>(context, listen: false).updateEarnings(earnings);
      }
    });

    // retrieve and display Trip History
    driversRef
        .child(currentfirebaseUser!.uid)
        .child('history')
        .get()
        .then((snap) {
      // update total number of trip counts to provider
      if (snap.value != null) {
        Map<dynamic, dynamic> keys = snap.value as Map<dynamic, dynamic>;
        int tripCounter = keys.length;
        Provider.of<AppData>(context, listen: false)
            .updateTripsCounter(tripCounter);

        // update trip keys to provider
        List<String> tripHistoryKeys = [];
        keys.forEach((key, value) {
          tripHistoryKeys.add(key);
        });
        Provider.of<AppData>(context, listen: false)
            .updateTripKeys(tripHistoryKeys);
        obtainTripRequestHistoryData(context);
      }
    });
  }

  static void obtainTripRequestHistoryData(context) {
    var keys = Provider.of<AppData>(context, listen: false).tripHistoryKeys;

    for (String key in keys) {
      newRequestRef.child(key).get().then((snap) {
        if (snap.value != null) {
          var history = History.fromSnapshot(snap);
          Provider.of<AppData>(context, listen: false).updateTripData(history);
        }
      });
    }
  }

  static String formatTripDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate =
        '${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}';
    return formattedDate;
  }

  // static void getCurrentOnlineUserInfo() async {
  //   firebaseUser = await FirebaseAuth.instance.currentUser;
  //   String userId = firebaseUser!.uid;
  //   DatabaseReference reference =
  //       FirebaseDatabase.instance.ref().child("users").child(userId);
  //   reference.once().then((value) {
  //     if (value.snapshot != null) {
  //       userCurrentInfo = Users.fromSnapshot(value.snapshot);
  //     }
  //   });
  // }
}
