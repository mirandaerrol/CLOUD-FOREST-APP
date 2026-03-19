import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../core/result.dart';
import '../core/exceptions.dart';

abstract class AuthRepository {
  Future<Result<User>> login(String username, String password);
  Future<Result<void>> logout();
  Future<User?> getPersistedUser();
  Future<void> persistUser(User user);
  Future<void> clearPersistedUser();
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  AuthRepositoryImpl(this._apiService, {FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<Result<User>> login(String username, String password) async {
    try {
      final user = await _apiService.login(username, password);
      if (user != null) {
        await persistUser(user);
        return Result.success(user);
      }
      return Result.failure(UnauthorizedException('Invalid credentials'));
    } catch (e) {
      return Result.failure(ServerException(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _apiService.logout();
      await clearPersistedUser();
      return Result.success(null);
    } catch (e) {
      return Result.failure(ServerException(e.toString()));
    }
  }

  @override
  Future<User?> getPersistedUser() async {
    final id = await _storage.read(key: 'user_id');
    final role = await _storage.read(key: 'user_role');
    final name = await _storage.read(key: 'user_name');

    if (id != null && role != null && name != null) {
      return User(id: id, role: role, name: name, username: '');
    }
    return null;
  }

  @override
  Future<void> persistUser(User user) async {
    await _storage.write(key: 'user_id', value: user.id);
    await _storage.write(key: 'user_role', value: user.role);
    await _storage.write(key: 'user_name', value: user.name);
  }

  @override
  Future<void> clearPersistedUser() async {
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'user_role');
    await _storage.delete(key: 'user_name');
  }
}
