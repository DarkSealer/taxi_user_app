import 'package:flutter/material.dart';

import '/configmaps.dart';
import '/main.dart';
import '/screens/mainscreen.dart';

class CarInfoScreen extends StatefulWidget {
  CarInfoScreen({super.key});
  static const String idScreen = "carinfo";

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  final TextEditingController carModelTextEditingController =
      TextEditingController();
  final TextEditingController carNumberTextEditingController =
      TextEditingController();
  final TextEditingController carColorTextEditingController =
      TextEditingController();
  String selectedCarType = 'uber-go';
  final List<String> carTypesList = ['uber-x', 'uber-go', 'bike'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Image.asset(
                "images/logo.png",
                width: 240,
                height: 170,
              ),
              const SizedBox(height: 18),
              Text(
                "Vehicle Details",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                "Add your vehicle information to start driving.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF0F0F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: carModelTextEditingController,
                      decoration: const InputDecoration(
                        labelText: "Car Model",
                        prefixIcon: Icon(Icons.directions_car_outlined),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: carNumberTextEditingController,
                      decoration: const InputDecoration(
                        labelText: "Plate Number",
                        prefixIcon: Icon(Icons.confirmation_number_outlined),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: carColorTextEditingController,
                      decoration: const InputDecoration(
                        labelText: "Car Color",
                        prefixIcon: Icon(Icons.palette_outlined),
                      ),
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Ride Type",
                        prefixIcon: Icon(Icons.local_taxi_outlined),
                      ),
                      initialValue: selectedCarType,
                      items: carTypesList
                          .map((car) => DropdownMenuItem(
                                value: car,
                                child: Text(car.toUpperCase()),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedCarType = newValue ?? selectedCarType;
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () {
                        if (carModelTextEditingController.text.isEmpty) {
                          displayToastMessage("Please enter your car model.", context);
                          return;
                        }
                        if (carNumberTextEditingController.text.isEmpty) {
                          displayToastMessage(
                              "Please enter your car plate number.", context);
                          return;
                        }
                        if (carColorTextEditingController.text.isEmpty) {
                          displayToastMessage("Please enter your car color.", context);
                          return;
                        }
                        if (selectedCarType.isEmpty) {
                          displayToastMessage("Please select a ride type.", context);
                          return;
                        }

                        saveDriverCarInfo(context);
                      },
                      child: const Text("Continue"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveDriverCarInfo(context) {
    String userId = currentfirebaseUser!.uid;
    Map carInfoMap = {
      "car_color": carColorTextEditingController.text,
      "car_number": carNumberTextEditingController.text,
      "car_model": carModelTextEditingController.text,
      "type": selectedCarType,
    };

    driversRef.child(userId).child("car_details").set(carInfoMap);

    Navigator.pushNamedAndRemoveUntil(
        context, MainScreen.idScreen, (route) => false);
  }
}
