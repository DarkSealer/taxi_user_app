import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:taxi_driver_app/configmaps.dart';
import 'package:taxi_driver_app/features/auth/data/services/auth_gateway.dart';

import '/widgets/progressDialog.dart';
import '/main.dart';
import 'registerscreen.dart';
import 'mainscreen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  static const String idScreen = "login";

  final TextEditingController emailTextEditingController =
      TextEditingController();
  final TextEditingController passwordTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            const SizedBox(height: 28),
            const Image(
              image: AssetImage("images/logo.png"),
              width: 240,
              height: 170,
              alignment: Alignment.center,
            ),
            const SizedBox(height: 18),
            Text(
              "Driver Sign In",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              "Welcome back. Continue to your driver dashboard.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
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
                    controller: emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordTextEditingController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () {
                      bool emailValid = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(emailTextEditingController.text);
                      if (!emailValid) {
                        displayToastMessage(
                          "Please enter a valid email address.",
                          context,
                        );
                        return;
                      } else if (passwordTextEditingController.text.isEmpty) {
                        displayToastMessage(
                          "Please enter a valid password.",
                          context,
                        );
                        return;
                      }

                      loginAndAuthentificateUser(context);
                    },
                    child: const Text("Sign In"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, RegisterScreen.idScreen, (route) => false);
              },
              child: const Text("No account yet? Create one."),
            ),
          ],
        ),
      ),
    );
  }

  final _firebaseAuth = FirebaseAuth.instance;
  late final AuthGateway _authGateway = AuthGateway(_firebaseAuth);

  void loginAndAuthentificateUser(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ProgressDialog(message: "Signing in. Please wait...");
        },
        barrierDismissible: false);

    User? firebaseUser;
    try {
      final credential = await _authGateway.signIn(
        email: emailTextEditingController.text,
        password: passwordTextEditingController.text,
      );
      firebaseUser = credential.user;
    } catch (errMsg) {
      if (!context.mounted) {
        return;
      }
      Navigator.pop(context);
      displayToastMessage("Error: $errMsg", context);
      return;
    }

    if (firebaseUser != null) // user logged in
    {
      if (!context.mounted) {
        return;
      }
      await driversRef.child(firebaseUser.uid).get().then((DataSnapshot snap) {
        if (snap.value != null) {
          currentfirebaseUser = firebaseUser;

          Navigator.pushNamedAndRemoveUntil(
              context, MainScreen.idScreen, (route) => false);

          displayToastMessage("You are now signed in.", context);
          return;
        }

        Navigator.pop(context);
        _authGateway.signOut();
        displayToastMessage("This user was not found in the database.", context);
      });
      return;
    }

    Navigator.pop(context);
    displayToastMessage(
        "Please check your credentials and try again.",
        context);
  }
}
