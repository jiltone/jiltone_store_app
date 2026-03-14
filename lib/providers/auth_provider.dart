import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _email;
  String? _name;

  bool get isLoggedIn => _isLoggedIn;
  String? get email => _email;
  String? get name => _name;
  String get displayName => _name ?? _email?.split('@').first ?? 'Guest';

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (email.isNotEmpty && password.length >= 6) {
      _isLoggedIn = true;
      _email = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      _isLoggedIn = true;
      _email = email;
      _name = name;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    _email = null;
    _name = null;
    notifyListeners();
  }
}
