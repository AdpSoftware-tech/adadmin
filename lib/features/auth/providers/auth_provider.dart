import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

@immutable
class AuthState {
  final bool isLoading;

  const AuthState({this.isLoading = false});

  AuthState copyWith({bool? isLoading}) {
    return AuthState(isLoading: isLoading ?? this.isLoading);
  }
}

class AuthNotifier extends Notifier<AuthState> {
  final AuthService _service = AuthService();

  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> login(String email, String pass, BuildContext context) async {
    try {
      state = state.copyWith(isLoading: true);

      final result = await _service.login(email, pass);

      final role = result["rol"] as String?;

      if (role == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se recibió el rol del usuario.")),
        );
        return;
      }

      // 🔁 Redirección por rol
      if (role == "SuperADMIN") {
        Navigator.pushReplacementNamed(context, "/super/dashboard");
      } else if (role == "SECRETARIAAsociacion") {
        // De momento solo avisamos que no está implementado
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Dashboard de Secretaría aún no implementado"),
          ),
        );
      } else if (role == "PASTOR") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Dashboard de Pastor aún no implementado"),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Rol no reconocido: $role")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al iniciar sesión: $e")));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);
