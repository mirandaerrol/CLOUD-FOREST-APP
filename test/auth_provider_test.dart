import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_application_1/models/models.dart';
import 'package:flutter_application_1/repositories/auth_repository.dart';
import 'package:flutter_application_1/services/auth_provider.dart';
import 'package:flutter_application_1/core/result.dart';

@GenerateNiceMocks([MockSpec<AuthRepository>()])
import 'auth_provider_test.mocks.dart';

void main() {
  late AuthProvider authProvider;
  late MockAuthRepository mockAuthRepository;

  final testUser = User(id: '1', username: 'test', role: 'client', name: 'Test User');

  setUpAll(() {
    provideDummy<Result<User>>(Result.success(testUser));
    provideDummy<Result<void>>(Result.success(null));
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authProvider = AuthProvider(mockAuthRepository);
  });

  group('AuthProvider Tests', () {
    final testUser = User(id: '1', username: 'test', role: 'client', name: 'Test User');

    test('initial state is correct', () {
      expect(authProvider.isLoggedIn, false);
      expect(authProvider.isLoading, false);
      expect(authProvider.currentUser, null);
    });

    test('login success updates state', () async {
      when(mockAuthRepository.login('test', '123'))
          .thenAnswer((_) async => Result.success(testUser));

      final success = await authProvider.login('test', '123');

      expect(success, true);
      expect(authProvider.isLoggedIn, true);
      expect(authProvider.currentUser, testUser);
      expect(authProvider.error, null);
    });

    test('login failure updates error', () async {
      when(mockAuthRepository.login('test', 'wrong'))
          .thenAnswer((_) async => Result.failure(Exception('Unauthorized')));

      final success = await authProvider.login('test', 'wrong');

      expect(success, false);
      expect(authProvider.isLoggedIn, false);
      expect(authProvider.error, contains('Unauthorized'));
    });

    test('logout clears user', () async {
      when(mockAuthRepository.login('test', '123'))
          .thenAnswer((_) async => Result.success(testUser));
      await authProvider.login('test', '123');
      
      when(mockAuthRepository.logout())
          .thenAnswer((_) async => Result.success(null));
      
      await authProvider.logout();

      expect(authProvider.isLoggedIn, false);
      expect(authProvider.currentUser, null);
    });
  });
}
