import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import 'providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

bool _showPassword = false;

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset("assets/logoo.png", width: 150),
                const SizedBox(height: 20),

                Text(
                  "ADAdmin",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),
                Text(
                  "Gestión ministerial con propósito",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Correo electrónico...",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: passwordController,
                  obscureText: !_showPassword, // 👁️ se oculta cuando es false
                  decoration: InputDecoration(
                    labelText: "Contraseña...",
                    border: OutlineInputBorder(),

                    // 👁️ Icono para mostrar/ocultar contraseña
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.isLoading
                        ? null
                        : () {
                            ref
                                .read(authProvider.notifier)
                                .login(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                  context,
                                );
                          },
                    child: auth.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Iniciar sesión"),
                  ),
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/reset-password");
                  },
                  child: Text(
                    "¿Olvidaste tu contraseña?",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
