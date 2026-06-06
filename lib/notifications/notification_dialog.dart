import 'package:flutter/material.dart';
import 'package:taxi_driver_app/assistants/assistant_methods.dart';
import 'package:taxi_driver_app/configmaps.dart';
import 'package:taxi_driver_app/main.dart';
import 'package:taxi_driver_app/models/ride_details.dart';
import 'package:taxi_driver_app/screens/new_ride_screen.dart';

class NotificationDialog extends StatelessWidget {
  final RideDetails rideDetails;
  const NotificationDialog({super.key, required this.rideDetails});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.transparent,
      elevation: 1,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 30),
            Image.asset(
              "images/taxi.png",
              width: 120,
              height: 120,
            ),
            const SizedBox(
              height: 18,
            ),
            const Text(
              "New Ride Request",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "images/pickicon.png",
                        height: 16,
                        width: 16,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Text(
                          rideDetails.pickup_address,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "images/desticon.png",
                        height: 16,
                        width: 16,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Text(
                          rideDetails.dropoff_address,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(
              height: 2.0,
              color: Colors.black,
              thickness: 2,
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(color: Colors.red),
                      ),
                      foregroundColor: Colors.red,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                    ),
                    onPressed: () {
                      assetsAudioPlayer.stop();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Decline',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(color: Color(0xFF171717)),
                      ),
                      backgroundColor: const Color(0xFF171717),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      assetsAudioPlayer.stop();
                      checkAvailabilityOfRide(context);
                    },
                    child: const Text(
                      "Accept",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  void checkAvailabilityOfRide(BuildContext context) async {
    final snapShot = await rideRequestRef?.get();
    if (!context.mounted) {
      return;
    }

    Navigator.pop(context);
    String theRideId = '';
    if (snapShot?.value != null) {
      theRideId = snapShot!.value.toString();
    } else {
      displayToastMessage("Ride does not exist.", context);
    }

    if (theRideId == rideDetails.ride_request_id) {
      rideRequestRef?.set("accepted");
      await AssistantMethods.disableHomeTabLiveLocationUpdates();
      if (!context.mounted) {
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewRideScreen(rideDetails: rideDetails),
        ),
      );
    } else if (theRideId == "cancelled") {
      displayToastMessage("Ride has been cancelled.", context);
    } else if (theRideId == "timeout") {
      displayToastMessage("Ride has timed out.", context);
    } else {
      displayToastMessage("Ride does not exist.", context);
    }
  }
}
