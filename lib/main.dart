import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_options.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'home/dashboard_screen.dart';

// Services
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // ⚠️ SOLO ejecutar una vez si lo necesitas
  // await FirestoreService().importarDesdeJson();

  // Asignar imágenes (puedes dejarlo o quitarlo según tu lógica)
  await FirestoreService().asignarImagenes();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Inventario',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

/// 🔐 Decide qué pantalla mostrar según el login
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {

        // ⏳ Cargando estado de Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ Usuario logueado
        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen();
        }

        // ❌ No logueado
        return const LoginScreen();
      },
    );
  }
}