import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideRequestEntity {
  const RideRequestEntity({
    required this.id,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickup,
    required this.dropoff,
    required this.paymentMethod,
    required this.riderName,
    required this.riderPhone,
  });

  final String id;
  final String pickupAddress;
  final String dropoffAddress;
  final LatLng pickup;
  final LatLng dropoff;
  final String paymentMethod;
  final String riderName;
  final String riderPhone;
}
