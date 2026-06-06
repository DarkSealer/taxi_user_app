import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';

class DriverAvailabilityService {
  const DriverAvailabilityService({
    required this.currentRequestRef,
  });

  final DatabaseReference? currentRequestRef;
  static const String _availableDriversPath = 'availableDrivers';
  static bool _isGeoFireInitialized = false;

  Future<void> _ensureGeoFireInitialized() async {
    if (_isGeoFireInitialized) {
      return;
    }
    await Geofire.initialize(_availableDriversPath);
    _isGeoFireInitialized = true;
  }

  Future<void> makeDriverOnline({
    required String driverId,
    required Position position,
  }) async {
    await _ensureGeoFireInitialized();
    await Geofire.setLocation(driverId, position.latitude, position.longitude);
    await currentRequestRef?.set('searching');
  }

  Future<void> makeDriverOffline({
    required String driverId,
  }) async {
    await _ensureGeoFireInitialized();
    await Geofire.removeLocation(driverId);
    currentRequestRef?.onDisconnect();
    await currentRequestRef?.remove();
  }

  Future<void> updateLiveLocation({
    required String driverId,
    required Position position,
  }) async {
    await _ensureGeoFireInitialized();
    await Geofire.setLocation(driverId, position.latitude, position.longitude);
  }
}
