import 'package:firebase_auth/firebase_auth.dart';

class AuthGateway {
  const AuthGateway(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) =>
      _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  Future<UserCredential> register({
    required String email,
    required String password,
  }) =>
      _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

  Future<void> signOut() => _firebaseAuth.signOut();
}
