import 'package:app/auth_service.dart';
import 'package:app/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class LoginScreen extends StatefulWidget {
  final PocketBase pb;

  const LoginScreen({super.key, required this.pb});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  late AuthService _authService;
  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Correo Electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Por favor ingrese un correo válido';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Iniciar Sesión'),
              ),
              TextButton(
                onPressed: () {
                  // Navegación a pantalla de registro
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => RegisterScreen(pb: widget.pb)));
                },
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _authService = AuthService(pb: widget.pb);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final result = await _authService.signIn(
          email: _email,
          password: _password,
        );

        if (result != null) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en el inicio de sesión: $e')),
        );
      }
    }
  }
}
