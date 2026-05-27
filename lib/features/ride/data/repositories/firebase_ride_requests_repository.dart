import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/app_result.dart';
import '../../domain/entities/ride_request_entity.dart';
import '../../domain/repositories/ride_requests_repository.dart';

class FirebaseRideRequestsRepository implements RideRequestsRepository {
  const FirebaseRideRequestsRepository(this._requestRef);

  final DatabaseReference _requestRef;

  @override
  Future<AppResult<RideRequestEntity>> fetchById(String requestId) async {
    try {
      final databaseEvent = await _requestRef.child(requestId).once();
      final rawValue = databaseEvent.snapshot.value;
      if (rawValue == null || rawValue is! Map) {
        return AppResult.failure(
          const AppFailure(message: 'Ride does not exist.'),
        );
      }

      final values = rawValue.cast<dynamic, dynamic>();
      final pickup = values['pickup'] as Map<dynamic, dynamic>;
      final dropoff = values['dropoff'] as Map<dynamic, dynamic>;

      return AppResult.success(
        RideRequestEntity(
          id: requestId,
          pickupAddress: values['pickup_address'].toString(),
          dropoffAddress: values['dropoff_address'].toString(),
          pickup: LatLng(
            double.parse(pickup['latitude'].toString()),
            double.parse(pickup['longitude'].toString()),
          ),
          dropoff: LatLng(
            double.parse(dropoff['latitude'].toString()),
            double.parse(dropoff['longitude'].toString()),
          ),
          paymentMethod: values['payment_method'].toString(),
          riderName: values['rider_name'].toString(),
          riderPhone: values['rider_phone'].toString(),
        ),
      );
    } catch (_) {
      return AppResult.failure(
        const AppFailure(message: 'Could not load ride request.'),
      );
    }
  }
}
