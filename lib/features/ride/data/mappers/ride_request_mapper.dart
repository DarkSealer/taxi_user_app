import 'package:taxi_driver_app/features/ride/domain/entities/ride_request_entity.dart';
import 'package:taxi_driver_app/models/ride_details.dart';

extension RideRequestMapper on RideRequestEntity {
  RideDetails toRideDetails() => RideDetails(
        pickup_address: pickupAddress,
        dropoff_address: dropoffAddress,
        ride_request_id: id,
        payment_method: paymentMethod,
        rider_name: riderName,
        rider_phone: riderPhone,
      )
        ..pickup = pickup
        ..dropoff = dropoff;
}
