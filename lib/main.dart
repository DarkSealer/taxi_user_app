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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const appPrimaryColor = Color(0xFF171717);
    const appSecondaryTextColor = Color(0xFF404040);
    const appAccentColor = Color(0xFFD4AF37);
    final baseTheme = ThemeData.light();

    return provider.ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Taxi Driver App',
        theme: baseTheme.copyWith(
          scaffoldBackgroundColor: Colors.white,
          colorScheme: const ColorScheme.light(
            primary: appPrimaryColor,
            secondary: appAccentColor,
            surface: Colors.white,
            onPrimary: Colors.white,
            onSecondary: appPrimaryColor,
            onSurface: appPrimaryColor,
          ),
          textTheme: baseTheme.textTheme.copyWith(
            headlineLarge: const TextStyle(
              color: appPrimaryColor,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
            headlineSmall: const TextStyle(
              color: appPrimaryColor,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            titleLarge: const TextStyle(
              color: appPrimaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: const TextStyle(
              color: appPrimaryColor,
              fontSize: 16,
            ),
            bodyMedium: const TextStyle(
              color: appSecondaryTextColor,
              fontSize: 14,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: appPrimaryColor, width: 1.2),
            ),
            labelStyle: const TextStyle(color: appSecondaryTextColor),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: appPrimaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: appPrimaryColor,
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFF1F2F4)),
            ),
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: appPrimaryColor,
            contentTextStyle: const TextStyle(color: Colors.white),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: appPrimaryColor,
            unselectedItemColor: appSecondaryTextColor,
            selectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            elevation: 8,
            type: BottomNavigationBarType.fixed,
          ),
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
