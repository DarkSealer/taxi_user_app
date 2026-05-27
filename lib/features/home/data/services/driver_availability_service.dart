import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';

class DriverAvailabilityService {
  const DriverAvailabilityService({
    required this.currentRequestRef,
  });

  final DatabaseReference? currentRequestRef;

  Future<void> makeDriverOnline({
    required String driverId,
    required Position position,
  }) async {
    Geofire.initialize('availableDrivers');
    Geofire.setLocation(driverId, position.latitude, position.longitude);
    await currentRequestRef?.set('searching');
  }

  Future<void> makeDriverOffline({
    required String driverId,
  }) async {
    Geofire.removeLocation(driverId);
    currentRequestRef?.onDisconnect();
    await currentRequestRef?.remove();
  }

  void updateLiveLocation({
    required String driverId,
    required Position position,
  }) {
    Geofire.setLocation(driverId, position.latitude, position.longitude);
  }
}
