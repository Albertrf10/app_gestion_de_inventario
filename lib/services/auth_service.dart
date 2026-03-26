import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // =========================
  // EMAIL & PASSWORD
  // =========================

  Future<UserCredential?> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Error login: ${e.message}');
      return null;
    } catch (e) {
      print('Error inesperado login: $e');
      return null;
    }
  }

  Future<UserCredential?> register(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Error register: ${e.message}');
      return null;
    } catch (e) {
      print('Error inesperado register: $e');
      return null;
    }
  }

  // =========================
  // LOGOUT
  // =========================

  Future<void> logout() async {
    await _auth.signOut();

    try {
      await GoogleSignIn().signOut();
    } catch (_) {}

    try {
      await FacebookAuth.instance.logOut();
    } catch (_) {}
  }

  // =========================
  // GOOGLE SIGN-IN
  // =========================

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print("Error: tokens de Google nulos");
        return null;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Error Google Sign-In: $e");
      return null;
    }
  }

  // =========================
  // FACEBOOK SIGN-IN
  // =========================

  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken!.tokenString;

        final credential =
        FacebookAuthProvider.credential(accessToken);

        return await _auth.signInWithCredential(credential);
      } else if (result.status == LoginStatus.cancelled) {
        print("Login cancelado por usuario");
        return null;
      } else {
        print("Error Facebook: ${result.message}");
        return null;
      }
    } catch (e) {
      print("Error Facebook: $e");
      return null;
    }
  }
}