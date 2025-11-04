import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isEmailVerified = false;
  bool _isLoadingVerification = false;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  void _checkEmailVerification() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _isEmailVerified = user?.emailVerified ?? false;
    });
  }

  Future<void> _reloadUser() async {
    await FirebaseAuth.instance.currentUser?.reload();
    _checkEmailVerification();
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isLoadingVerification = true);

    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correo de verificación enviado. Revisa tu bandeja de entrada.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Error al enviar correo de verificación';
      
      if (e.code == 'too-many-requests') {
        message = 'Demasiadas solicitudes. Espera unos minutos e intenta de nuevo.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingVerification = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Inicio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFF6B35)),
            onPressed: _reloadUser,
            tooltip: 'Actualizar estado',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFFF6B35)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isEmailVerified
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_rounded,
                size: 100,
                color: _isEmailVerified
                    ? const Color(0xFFFF6B35)
                    : Colors.orange,
              ),
              const SizedBox(height: 40),
              Text(
                _isEmailVerified ? '¡Bienvenido!' : '¡Casi listo!',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isEmailVerified
                    ? 'Sesión iniciada'
                    : 'Verifica tu correo electrónico',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFB0B0B0),
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 48,
                      color: Color(0xFFFF6B35),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Usuario',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFB0B0B0),
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? 'No disponible',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _isEmailVerified
                            ? Colors.green.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isEmailVerified
                                ? Icons.verified
                                : Icons.mail_outline,
                            size: 16,
                            color: _isEmailVerified
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isEmailVerified
                                ? 'Correo verificado'
                                : 'Correo no verificado',
                            style: TextStyle(
                              fontSize: 12,
                              color: _isEmailVerified
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isEmailVerified) ...[
                const SizedBox(height: 30),
                const Text(
                  'Revisa tu correo y haz clic en el enlace de verificación.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB0B0B0),
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _isLoadingVerification ? null : _resendVerificationEmail,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF6B35)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isLoadingVerification
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFFF6B35),
                            ),
                          )
                        : const Icon(
                            Icons.email,
                            color: Color(0xFFFF6B35),
                          ),
                    label: const Text(
                      'Reenviar correo',
                      style: TextStyle(
                        color: Color(0xFFFF6B35),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
