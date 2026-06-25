import 'package:flutter/foundation.dart';

class LocalSessionService extends ChangeNotifier {
  LocalSessionService._();

  static final LocalSessionService instance = LocalSessionService._();

  String? _email;
  String? _username;
  String? _role;

  String? get email => _email;
  String? get username => _username;
  String? get role => _role;
  bool get hasUser => _email != null && _email!.isNotEmpty;

  void setUser(Map<String, dynamic> data) {
    _email = data['email']?.toString().trim().toLowerCase();
    _username = data['username']?.toString();
    _role = data['role']?.toString();
    notifyListeners();
  }

  void clear() {
    _email = null;
    _username = null;
    _role = null;
    notifyListeners();
  }
}
