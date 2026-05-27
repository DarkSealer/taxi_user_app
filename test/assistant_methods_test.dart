import 'package:flutter_test/flutter_test.dart';
import 'package:taxi_driver_app/assistants/assistant_methods.dart';
import 'package:taxi_driver_app/configmaps.dart';
import 'package:taxi_driver_app/models/direction_details.dart';

void main() {
  group('AssistantMethods', () {
    test('calculateFares returns expected fare for uber-go', () {
      rideType = 'uber-go';
      final details = DirectionDetails(
        distanceValue: 10000,
        durationValue: 1800,
        distanceText: '10 km',
        durationText: '30 mins',
        encodedPoints: '',
      );

      final fare = AssistantMethods.calculateFares(details);

      expect(fare, 8);
    });

    test('formatTripDate returns formatted date string', () {
      final formatted =
          AssistantMethods.formatTripDate('2026-05-27T12:00:00.000Z');

      expect(formatted, contains('2026'));
    });
  });
}
