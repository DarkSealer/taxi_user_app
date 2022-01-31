import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:taxi_driver_app/main.dart';
import 'package:taxi_driver_app/screens/loginscreen.dart';

import '/configmaps.dart';

class ProfileTabPage extends StatelessWidget {
  const ProfileTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black87,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                driversInformation.name,
                style: const TextStyle(
                  fontSize: 65,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Signatra',
                ),
              ),
              Text(
                title + ' driver',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.blueGrey[200],
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Brand'),
              ),
              const SizedBox(
                height: 20,
                width: 200,
                child: Divider(
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              InfoCard(
                text: driversInformation.phone,
                icon: Icons.phone,
                onPressed: () {
                  print('this is phone');
                },
              ),
              InfoCard(
                text: driversInformation.email,
                icon: Icons.email,
                onPressed: () {
                  print('this is email');
                },
              ),
              InfoCard(
                text: driversInformation.car_color +
                    ' ' +
                    driversInformation.car_model +
                    ' ' +
                    driversInformation.car_number,
                icon: Icons.car_repair,
                onPressed: () {
                  print('this is your car');
                },
              ),
              GestureDetector(
                onTap: () {
                  // Log out
                  Geofire.removeLocation(currentfirebaseUser!.uid);
                  rideRequestRef!.onDisconnect();
                  rideRequestRef!.remove();
                  rideRequestRef = null;

                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginScreen.idScreen, (route) => false);
                },
                child: const Card(
                  color: Colors.red,
                  margin: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 115,
                  ),
                  child: ListTile(
                    trailing: Icon(
                      Icons.follow_the_signs_outlined,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Sign out',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Brand',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class InfoCard extends StatelessWidget {
  final String text;
  final IconData icon;
  Function onPressed;
  InfoCard(
      {Key? key,
      required this.text,
      required this.icon,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed(),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 10,
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.black87,
          ),
          title: Text(
            text,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontFamily: 'Brand',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
