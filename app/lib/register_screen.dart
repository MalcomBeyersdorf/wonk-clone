import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class RegisterScreen extends StatefulWidget {
  final PocketBase pb;

  const RegisterScreen({super.key, required this.pb});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  String _username = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Nombre de Usuario (opcional)',
                    hintText: 'Se generará uno si lo dejas en blanco'),
                onSaved: (value) => _username = value?.trim() ?? '',
              ),
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
                onSaved: (value) => _email = value!.trim(),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'La contraseña debe tener al menos 8 caracteres';
                  }
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Registrar'),
              ),
              TextButton(
                onPressed: () {
                  // Navegar a pantalla de login
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: const Text('¿Ya tienes cuenta? Inicia sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await widget.pb.collection('users').create(body: {
          'email': _email,
          'password': _password,
          'passwordConfirm': _password,
          'username': _username,
        });

        await widget.pb.collection('users').authWithPassword(_email, _password);

        Navigator.of(context).pushReplacementNamed('/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en el registro: $e')),
        );
      }
    }
  }
}
