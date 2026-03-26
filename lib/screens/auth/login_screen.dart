import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';
import '../dashboard_screen.dart';
import 'forgot_password_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // _formKey: identifica y valida el formulario
  final _formKey = GlobalKey<FormState>();
  // Controladores para leer el texto de cada campo
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    // Liberamos memoria al salir de la pantalla
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _authService.login(
        _emailController.text,
        _passwordController.text,
      );
      // AuthWrapper en main.dart detecta la sesión y redirige solo
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _getErrorMessage(e.code));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese email.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-email':
        return 'El email no es válido.';
      case 'invalid-credential':
        return 'Email o contraseña incorrectos.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos.';
      default:
        return 'Error al iniciar sesión. Inténtalo de nuevo.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Stack permite superponer el fondo y la card
      body: Stack(
        children: [
          // ── Fondo oscuro con blobs de color ──
          _buildBackground(),
          // ── Contenido centrado ──
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: _buildGlassCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Construye el fondo degradado con círculos de luz
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1a0a2e), Color(0xFF0d0520), Color(0xFF1a0a2e)],
        ),
      ),
      child: Stack(
        children: [
          // Blob superior derecha
          Positioned(
            top: -80,
            right: -80,
            child: _blob(300, const Color(0xFF7c3aed), 0.6),
          ),
          // Blob inferior izquierda
          Positioned(
            bottom: -60,
            left: -60,
            child: _blob(250, const Color(0xFF6d28d9), 0.5),
          ),
          // Blob centro derecha
          Positioned(
            bottom: 120,
            right: 30,
            child: _blob(160, const Color(0xFFa855f7), 0.3),
          ),
        ],
      ),
    );
  }

  // Genera un círculo con degradado radial (efecto blob)
  Widget _blob(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: opacity), Colors.transparent],
        ),
      ),
    );
  }

  // Card principal con efecto cristal (glassmorphism)
  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        // BackdropFilter + blur dan el efecto de cristal esmerilado
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLogo(),
                const SizedBox(height: 28),
                _buildTitle(),
                const SizedBox(height: 32),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 8),
                _buildForgotPassword(),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  _buildErrorMessage(),
                  const SizedBox(height: 16),
                ],
                _buildLoginButton(),
                const SizedBox(height: 16),   // un pequeño espacio
                _buildGoogleButton(),         // tu botón de Google
                const SizedBox(height: 20),
                _buildFacebookButton(),
                const SizedBox(height: 20),
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFa855f7), Color(0xFF7c3aed)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.inventory_2_rounded,
              color: Colors.white, size: 30),
        ),
        const SizedBox(height: 12),
        Text(
          'INVENTMOBILE',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
            letterSpacing: 3,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'Bienvenido',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          'Inicia sesión para continuar',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
        ),
      ],
    );
  }

  // Campo de texto con estilo glassmorphism
  Widget _buildEmailField() {
    return _glassField(
      controller: _emailController,
      label: 'Correo electrónico',
      hint: 'tu@email.com',
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Introduce tu email';
        if (!value.contains('@')) return 'Email no válido';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return _glassField(
      controller: _passwordController,
      label: 'Contraseña',
      hint: '••••••••',
      obscureText: _obscurePassword,
      onFieldSubmitted: (_) => _login(),
      prefixIcon: Icons.lock_outline,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: Colors.white38,
          size: 20,
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Introduce tu contraseña';
        if (value.length < 6) return 'Mínimo 6 caracteres';
        return null;
      },
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
          );
        },
        child: const Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(color: Color(0xFFa855f7), fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_errorMessage!,
                style:
                    const TextStyle(color: Colors.redAccent, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFa855f7), Color(0xFF7c3aed)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Iniciar sesión',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
        ),
      ),
    );
  }
  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isLoading
            ? null
            : () async {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });

          try {
            final user = await _authService.signInWithGoogle();
            if (user != null) {
              // Redirige a tu Dashboard si login exitoso
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const DashboardScreen()),
              );
            }
          } on FirebaseAuthException catch (e) {
            setState(() {
              _errorMessage = e.message ?? "Error con Google";
            });
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        },
        icon: const Icon(Icons.g_mobiledata, color: Colors.white),
        label: const Text(
          'Continuar con Google',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
  Widget _buildFacebookButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isLoading
            ? null
            : () async {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });

          try {
            final user = await _authService.signInWithFacebook();

            if (user == null) {
              setState(() {
                _errorMessage = "Login con Facebook cancelado o fallido";
              });
              return;
            }

            // ❗ NO navigation aquí (AuthWrapper lo hace)

          } catch (e) {
            setState(() {
              _errorMessage = "Error con Facebook";
            });
          } finally {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          }
        },
        icon: const Icon(Icons.facebook, color: Colors.white),
        label: const Text(
          'Continuar con Facebook',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('¿No tienes cuenta? ',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RegisterScreen())),
          child: const Text('Regístrate',
              style: TextStyle(
                  color: Color(0xFFa855f7),
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  // Widget reutilizable para campos de texto con estilo glass
  Widget _glassField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    void Function(String)? onFieldSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onFieldSubmitted: onFieldSubmitted,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 14),
            prefixIcon:
                Icon(prefixIcon, color: Colors.white38, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFa855f7)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
            ),
            errorStyle: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}