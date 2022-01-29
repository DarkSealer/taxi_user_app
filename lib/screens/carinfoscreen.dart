import 'package:flutter/material.dart';

import '/configmaps.dart';
import '/main.dart';
import '/screens/mainscreen.dart';

class CarInfoScreen extends StatelessWidget {
  CarInfoScreen({Key? key}) : super(key: key);
  static const String idScreen = "carinfo";

  TextEditingController carModelTextEditingController = TextEditingController();
  TextEditingController carNumberTextEditingController =
      TextEditingController();
  TextEditingController carColorTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 22,
              ),
              Image.asset(
                "images/logo.png",
                width: 390,
                height: 250,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Enter Car Details",
                      style: TextStyle(
                        fontFamily: "Brand",
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(
                      height: 26,
                    ),
                    TextField(
                      controller: carModelTextEditingController,
                      decoration: const InputDecoration(
                        labelText: "Car Model",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: carNumberTextEditingController,
                      decoration: const InputDecoration(
                        labelText: "Car Number",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: carColorTextEditingController,
                      decoration: const InputDecoration(
                        labelText: "Car Color",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(
                      height: 42,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: RaisedButton(
                        onPressed: () {
                          if (carModelTextEditingController.text.isEmpty) {
                            displayToastMessage(
                                "Please enter your car Model", context);
                            return;
                          }
                          if (carNumberTextEditingController.text.isEmpty) {
                            displayToastMessage(
                                "Please enter your car registration Number",
                                context);
                            return;
                          }
                          if (carColorTextEditingController.text.isEmpty) {
                            displayToastMessage(
                                "Please enter your car Color", context);
                            return;
                          }

                          saveDriverCarInfo(context);
                        },
                        color: Theme.of(context).accentColor,
                        child: Padding(
                          padding: const EdgeInsets.all(17),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Next",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 26,
                              ),
                            ],
                          ),
                        ),
                      ),
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
    };

    driversRef.child(userId).child("car_details").set(carInfoMap);

    Navigator.pushNamedAndRemoveUntil(
        context, MainScreen.idScreen, (route) => false);
  }
}
