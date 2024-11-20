import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

void main() {
  runApp(const CoffeeShopApp());
}

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
}

class CoffeeShopApp extends StatefulWidget {
  const CoffeeShopApp({super.key});

  @override
  CoffeeShopAppState createState() => CoffeeShopAppState();
}

class CoffeeShopAppState extends State<CoffeeShopApp> {
  late PocketBase pb;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wonk clone',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: pb.authStore.isValid ? AppRoutes.home : AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => LoginScreen(pb: pb),
        AppRoutes.register: (context) => RegisterScreen(pb: pb),
        AppRoutes.home: (context) => HomeScreen(pb: pb),
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // Para desarrollo local, 'http://localhost:8090'
    // Para producción, dominio/URL del server
    pb = PocketBase('http://localhost:8090');

    // Opcional: Manejar cambios de autenticación
    pb.authStore.onChange.listen((token) {
      print('Auth state changed: ${pb.authStore.isValid}');
    });
  }
}

extension PocketBaseHelpers on PocketBase {
  Future<void> openAdminInterface() async {
    final url = Uri.parse('$baseUrl/_/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print('No se pudo abrir la URL de PocketBase');
    }
  }
}
