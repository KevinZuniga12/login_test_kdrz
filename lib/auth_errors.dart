import 'package:firebase_auth/firebase_auth.dart';

class AuthErrors {
  // Obtener mensaje de error para login
  static String getLoginErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Contraseña incorrecta o usuario no encontrado';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'operation-not-allowed':
        return 'Login con email/password no está habilitado.\nHabilítalo en Firebase Console > Authentication > Sign-in method';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta más tarde';
      default:
        return 'Error: ${e.code}\n${e.message ?? ""}';
    }
  }

  // Obtener mensaje de error para registro
  static String getRegisterErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres)';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'operation-not-allowed':
        return 'Registro con email/password no está habilitado.\nHabilítalo en Firebase Console > Authentication > Sign-in method';
      default:
        return 'Error: ${e.code}\n${e.message ?? ""}';
    }
  }

  // Mensaje genérico de error
  static String genericError(dynamic e) {
    return 'Error inesperado: $e';
  }
}
