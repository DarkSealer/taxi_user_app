import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

import '/configmaps.dart';
import 'screens/carinfoscreen.dart';
import '/screens/mainscreen.dart';
import '/screens/loginscreen.dart';
import '/screens/registerscreen.dart';
import 'datahandler/appdata.dart';

DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("drivers");
DatabaseReference newRequestRef =
    FirebaseDatabase.instance.ref().child("rideRequests");
DatabaseReference? rideRequestRef = FirebaseDatabase.instance
    .ref()
    .child("drivers")
    .child(currentfirebaseUser!.uid)
    .child("newRide");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  currentfirebaseUser = FirebaseAuth.instance.currentUser;

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return provider.ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Taxi Driver App',
        theme: ThemeData(
          fontFamily: "Bolt",
          primarySwatch: Colors.blue,
        ),
        initialRoute: FirebaseAuth.instance.currentUser == null
            ? LoginScreen.idScreen
            : MainScreen.idScreen,
        routes: {
          MainScreen.idScreen: (context) => const MainScreen(),
          RegisterScreen.idScreen: (context) => RegisterScreen(),
          LoginScreen.idScreen: (context) => LoginScreen(),
          CarInfoScreen.idScreen: (context) => CarInfoScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
