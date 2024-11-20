import 'package:pocketbase/pocketbase.dart';

class AuthService {
  final PocketBase pb;
  AuthService({required this.pb});
  RecordModel? get currentUser => pb.authStore.model;

  bool get isAuthenticated => pb.authStore.isValid;

  Future<RecordModel?> registerCoffeeShop({
    required String email,
    required String password,
    required String coffeShopName,
    String? address,
    String? workSchedule,
  }) async {
    try {
      final record = await pb.collection('cafeterias').create(body: {
        'email': email,
        'name': coffeShopName,
        'address': address ?? '',
        'work_schedule': workSchedule ?? '',
        'verified': false,
      });

      await pb.collection('users').create(body: {
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'cafeteria': record.id,
      });

      await signIn(email: email, password: password);

      return record;
    } on ClientException catch (e) {
      _handleAuthError(e);
      return null;
    }
  }

  Future<RecordModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final authData = await pb.collection('users').authWithPassword(
            email,
            password,
          );

      return authData.record;
    } on ClientException catch (e) {
      _handleAuthError(e);
      return null;
    }
  }

  Future<void> signOut() async {
    pb.authStore.clear();
  }

  void _handleAuthError(ClientException e) {
    String errorMessage = '';

    switch (e.statusCode) {
      case 400:
        errorMessage = 'Datos inválidos';
        break;
      case 401:
        errorMessage = 'Credenciales incorrectas';
        break;
      case 403:
        errorMessage = 'Acceso denegado';
        break;
      default:
        errorMessage = 'Error de autenticación: $e';
    }

    // Mostrar este error en un SnackBar o Dialog
    print(errorMessage);
  }
}
