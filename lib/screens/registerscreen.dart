import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taxi_driver_app/features/auth/data/services/auth_gateway.dart';

import '/configmaps.dart';
import '/screens/carinfoscreen.dart';

import '/main.dart';
import '/widgets/progressdialog.dart';

import '/screens/loginscreen.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  static const String idScreen = "register";

  final TextEditingController nameTextEditingController =
      TextEditingController();
  final TextEditingController emailTextEditingController =
      TextEditingController();
  final TextEditingController phoneTextEditingController =
      TextEditingController();
  final TextEditingController passwordTextEditingController =
      TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late final AuthGateway _authGateway = AuthGateway(_firebaseAuth);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Image(
              image: AssetImage("images/logo.png"),
              width: 240,
              height: 170,
              alignment: Alignment.center,
            ),
            const SizedBox(height: 18),
            Text(
              "Create Driver Account",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              "Set up your profile to start accepting trips.",
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
                    keyboardType: TextInputType.name,
                    controller: nameTextEditingController,
                    decoration: const InputDecoration(
                      labelText: "Full name",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailTextEditingController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.phone,
                    controller: phoneTextEditingController,
                    decoration: const InputDecoration(
                      labelText: "Phone number",
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    obscureText: true,
                    controller: passwordTextEditingController,
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
                      if (nameTextEditingController.text.length < 4) {
                        displayToastMessage(
                          "Name must be at least 4 characters.",
                          context,
                        );
                        return;
                      } else if (!emailValid) {
                        displayToastMessage(
                          "Please enter a valid email address.",
                          context,
                        );
                        return;
                      } else if (phoneTextEditingController.text.length < 10 ||
                          phoneTextEditingController.text.length > 12) {
                        displayToastMessage(
                          "Please enter a valid phone number.",
                          context,
                        );
                        return;
                      } else if (passwordTextEditingController.text.length <
                          6) {
                        displayToastMessage(
                          "Password must be at least 6 characters.",
                          context,
                        );
                        return;
                      }

                      registerNewUser(context);
                    },
                    child: const Text("Create Account"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginScreen.idScreen, (route) => false);
              },
              child: const Text("Already have an account? Sign in."),
            ),
          ],
        ),
      ),
    );
  }

  void registerNewUser(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Creating account. Please wait...",
          );
        });
    User? firebaseUser;
    try {
      final credential = await _authGateway.register(
        email: emailTextEditingController.text,
        password: passwordTextEditingController.text,
      );
      firebaseUser = credential.user;
    } catch (errMesg) {
      if (!context.mounted) {
        return;
      }
      Navigator.pop(context);
      displayToastMessage(
        "Error: $errMesg",
        context,
      );
      return;
    }

    if (firebaseUser != null) // user created
    {
      if (!context.mounted) {
        return;
      }
      Map userDataMap = {
        "name": nameTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
      };

      driversRef.child(firebaseUser.uid).set(userDataMap);
      currentfirebaseUser = firebaseUser;

      displayToastMessage("Your account was created successfully.", context);

      Navigator.pushNamed(context, CarInfoScreen.idScreen);
      return;
    }

    Navigator.pop(context);
    displayToastMessage("User account could not be created.", context);
  }
}
