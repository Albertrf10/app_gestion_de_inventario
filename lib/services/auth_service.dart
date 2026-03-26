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
      print('🔐 Intentando login con: $email');
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('❌ Error Firebase login: ${e.code} - ${e.message}');
      _handleAuthError(e);
      return null;
    } catch (e) {
      print('❌ Error inesperado login: $e');
      return null;
    }
  }

  // Método helper para diagnosticar errores
  void _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        print('📧 Email inválido');
        break;
      case 'user-disabled':
        print('⛔ Usuario deshabilitado');
        break;
      case 'user-not-found':
        print('👤 Usuario no encontrado');
        break;
      case 'wrong-password':
        print('🔑 Contraseña incorrecta');
        break;
      case 'network-request-failed':
        print('🌐 Error de red - Verifica tu conexión a Internet');
        break;
      default:
        print('⚠️ Error desconocido: ${e.code}');
    }
  }

  Future<UserCredential?> register(String email, String password) async {
    try {
      print('📝 Intentando registrar: $email');
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('❌ Error Firebase registro: ${e.code} - ${e.message}');
      _handleAuthError(e);
      return null;
    } catch (e) {
      print('❌ Error inesperado registro: $e');
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
      print('🔵 Iniciando Google Sign-In...');
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print('ℹ️ Google Sign-In cancelado por usuario');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print("❌ Error: tokens de Google nulos");
        return null;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔐 Autenticando con Firebase...');
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print("❌ Error Firebase Google Sign-In: ${e.code} - ${e.message}");
      _handleAuthError(e);
      return null;
    } catch (e) {
      print("❌ Error Google Sign-In: $e");
      return null;
    }
  }

  // =========================
  // FACEBOOK SIGN-IN
  // =========================

  Future<UserCredential?> signInWithFacebook() async {
    try {
      print('👥 Iniciando Facebook Login...');
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken!.tokenString;
        print('🔐 Token Facebook obtenido, autenticando con Firebase...');

        final credential = FacebookAuthProvider.credential(accessToken);

        return await _auth.signInWithCredential(credential);
      } else if (result.status == LoginStatus.cancelled) {
        print("ℹ️ Facebook Login cancelado por usuario");
        return null;
      } else {
        print("❌ Error Facebook: ${result.message}");
        return null;
      }
    } on FirebaseAuthException catch (e) {
      print("❌ Error Firebase Facebook Sign-In: ${e.code} - ${e.message}");
      _handleAuthError(e);
      return null;
    } catch (e) {
      print("❌ Error Facebook: $e");
      return null;
    }
  }
}
