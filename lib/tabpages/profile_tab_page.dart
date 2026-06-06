import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:taxi_driver_app/main.dart';
import 'package:taxi_driver_app/screens/loginscreen.dart';

import '/configmaps.dart';

class ProfileTabPage extends StatelessWidget {
  const ProfileTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF171717),
              child: Text(
                driversInformation.name.isNotEmpty
                    ? driversInformation.name[0].toUpperCase()
                    : "D",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                driversInformation.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '$title driver',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 18),
            InfoCard(
              text: driversInformation.phone,
              icon: Icons.phone_outlined,
              onPressed: () {},
            ),
            InfoCard(
              text: driversInformation.email,
              icon: Icons.email_outlined,
              onPressed: () {},
            ),
            InfoCard(
              text:
                  '${driversInformation.car_color} ${driversInformation.car_model} ${driversInformation.car_number}',
              icon: Icons.directions_car_outlined,
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
              ),
              onPressed: () async {
                await Geofire.initialize('availableDrivers');
                await Geofire.removeLocation(currentfirebaseUser!.uid);
                rideRequestRef?.onDisconnect();
                rideRequestRef?.remove();
                rideRequestRef = null;

                FirebaseAuth.instance.signOut();
                if (!context.mounted) {
                  return;
                }
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  LoginScreen.idScreen,
                  (route) => false,
                );
              },
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  const InfoCard(
      {super.key,
      required this.text,
      required this.icon,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onPressed,
        leading: Icon(
          icon,
          color: const Color(0xFF171717),
        ),
        title: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF171717),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
