import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pocketbase/pocketbase.dart';

class CoffeeShopRegisterScreen extends StatefulWidget {
  final PocketBase pb;

  const CoffeeShopRegisterScreen({super.key, required this.pb});

  @override
  CoffeeShopRegisterScreenState createState() =>
      CoffeeShopRegisterScreenState();
}

class CoffeeShopRegisterScreenState extends State<CoffeeShopRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _coffeShopName = '';
  String _address = '';
  String _workSchedule = '';
  double? _latitude;
  double? _longitude;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Cafetería')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Nombre de la Cafetería'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre de la cafetería';
                  }
                  return null;
                },
                onSaved: (value) => _coffeShopName = value!,
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
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  helperText:
                      'Ingrese una dirección completa para ubicación en el mapa',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una dirección';
                  }
                  return null;
                },
                onSaved: (value) => _address = value!,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Horario de Trabajo'),
                onSaved: (value) => _workSchedule = value ?? '',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Registrar Cafetería'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _geocodeAddress() async {
    try {
      List<Location> locations = await locationFromAddress(_address);
      if (locations.isNotEmpty) {
        setState(() {
          _latitude = locations.first.latitude;
          _longitude = locations.first.longitude;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo encontrar la ubicación')),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_latitude == null || _longitude == null) {
        await _geocodeAddress();
      }

      try {
        await widget.pb.collection('coffeShop').create(body: {
          'name': _coffeShopName,
          'email': _email,
          'address': _address,
          'work_schedule': _workSchedule,
          'latitude': _latitude,
          'longitude': _longitude,
          'verified': false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cafetería registrada con éxito')),
        );

        Navigator.of(context).pushReplacementNamed('/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar cafetería: $e')),
        );
      }
    }
  }
}
