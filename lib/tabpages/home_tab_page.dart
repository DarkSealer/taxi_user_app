import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_user_app/assistants/assistant_methods.dart';

class HomeTabPage extends StatelessWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Completer<GoogleMapController> _controllerGoogleMap = Completer();
    late GoogleMapController newGoogleMapController;
    late Position currentPosition;
    var geoLocator = Geolocator();

    const CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962),
      zoom: 14.4746,
    );

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
      ],
    );
  }
}
