import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  AuthProvider(this._authRepository);

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isClient => _currentUser?.role == 'client';
  bool get isStaff => _currentUser?.role == 'staff';
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    _currentUser = await _authRepository.getPersistedUser();
    
    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authRepository.login(username, password);
    
    _isLoading = false;
    if (result.isSuccess) {
      _currentUser = result.dataOrNull;
      notifyListeners();
      return true;
    } else {
      _error = result.exceptionOrNull?.toString() ?? 'Login failed';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
