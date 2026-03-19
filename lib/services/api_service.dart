import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/models.dart';
import '../core/exceptions.dart';

// ============================================================
// ENVIRONMENT CONFIGURATION
// ============================================================
enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment current = Environment.development;

  static String get baseUrl {
    switch (current) {
      case Environment.development:
        return 'http://localhost:3000/api/v1';
      case Environment.staging:
        return 'https://staging-api.cloudforest.com/api/v1';
      case Environment.production:
        return 'https://api.cloudforest.com/api/v1';
    }
  }

  static Duration get timeout {
    return const Duration(seconds: 30);
  }
}

// ============================================================
// API SERVICE INTERFACE
// ============================================================
abstract class ApiService {
  Future<User?> login(String username, String password);
  Future<void> logout();

  // Client
  Future<BillingRecord?> getClientBilling(String customerId);
  Future<List<PaymentHistory>> getPaymentHistory(String customerId);
  Future<List<RepairTicket>> getClientTickets(String customerId);
  Future<RepairTicket> createRepairTicket(String customerId, String issue, String description);

  // Staff
  Future<List<Applicant>> getApplicants();
  Future<void> approveApplicant(String applicantId);
  Future<void> declineApplicant(String applicantId);
  Future<List<RepairTicket>> getAllTickets();
  Future<void> updateTicket(TicketUpdateRequest request);
  Future<List<BillingRecord>> getAllBillingRecords();
  Future<void> processPayment(PaymentRequest request);
  Future<CustomerLookupResult?> lookupCustomer(String name);
  Future<void> submitRegistration(RegistrationFormData data);
}

// ============================================================
// PRODUCTION API SERVICE IMPLEMENTATION (Dio)
// ============================================================
class DioApiService implements ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  final Connectivity _connectivity;

  DioApiService({
    Dio? dio,
    FlutterSecureStorage? storage,
    Connectivity? connectivity,
  })  : _dio = dio ?? Dio(BaseOptions(
          baseUrl: EnvironmentConfig.baseUrl,
          connectTimeout: EnvironmentConfig.timeout,
          receiveTimeout: EnvironmentConfig.timeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )),
        _storage = storage ?? const FlutterSecureStorage(),
        _connectivity = connectivity ?? Connectivity() {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Check network connectivity
        final connectivityResult = await _connectivity.checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          handler.reject(DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: NetworkException(),
          ));
          return;
        }

        // Add authentication token if available
        final token = await _getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (DioException error, handler) async {
        // Handle token refresh for 401 errors
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry original request with new token
            final originalRequest = error.requestOptions;
            final token = await _getToken();
            originalRequest.headers['Authorization'] = 'Bearer $token';
            try {
              final response = await _dio.fetch(originalRequest);
              handler.resolve(response);
              return;
            } catch (e) {
              // Token refresh failed, logout user
              await _handleLogoutOnTokenFailure();
            }
          }
        }

        // Map Dio errors to custom exceptions
        final exception = _mapDioErrorToException(error);
        handler.reject(DioException(
          requestOptions: error.requestOptions,
          type: error.type,
          error: exception,
          response: error.response,
        ));
      },
    ));
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<String?> _getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> _saveTokens(String token, String refreshToken) async {
    await _storage.write(key: 'auth_token', value: token);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        '/auth/refresh-token',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'];
        final newRefreshToken = response.data['refresh_token'];
        await _saveTokens(newToken, newRefreshToken);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _handleLogoutOnTokenFailure() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'refresh_token');
    // This will trigger auth state change in UI
  }

  AppException _mapDioErrorToException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Request timeout');
      case DioExceptionType.connectionError:
        return NetworkException('No internet connection');
      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case 400:
            return ValidationException(
                error.response?.data['message'] ?? 'Invalid request');
          case 401:
            return UnauthorizedException('Session expired');
          case 403:
            return UnauthorizedException('Forbidden');
          case 404:
            return ServerException('Resource not found');
          case 500:
            return ServerException('Server error');
          default:
            return ServerException('Server error occurred');
        }
      default:
        return ServerException('An error occurred');
    }
  }

  @override
  Future<User?> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final refreshToken = response.data['refresh_token'];
        await _saveTokens(token, refreshToken);
        return User.fromJson(response.data['user']);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      // Ignore errors during logout
    } finally {
      await _handleLogoutOnTokenFailure();
    }
  }

  @override
  Future<BillingRecord?> getClientBilling(String customerId) async {
    try {
      final response = await _dio.get('/client/billing/$customerId');
      if (response.statusCode == 200) {
        return BillingRecord.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PaymentHistory>> getPaymentHistory(String customerId) async {
    try {
      final response = await _dio.get('/client/payments/$customerId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => PaymentHistory.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<RepairTicket>> getClientTickets(String customerId) async {
    try {
      final response = await _dio.get('/client/tickets/$customerId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => RepairTicket.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<RepairTicket> createRepairTicket(
      String customerId, String issue, String description) async {
    try {
      final response = await _dio.post('/client/tickets', data: {
        'customer_id': customerId,
        'issue': issue,
        'description': description,
      });

      if (response.statusCode == 201) {
        return RepairTicket.fromJson(response.data['data']);
      }

      throw ServerException('Failed to create ticket');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Applicant>> getApplicants() async {
    try {
      final response = await _dio.get('/staff/applicants');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Applicant.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> approveApplicant(String applicantId) async {
    try {
      await _dio.post('/staff/applicants/$applicantId/approve');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> declineApplicant(String applicantId) async {
    try {
      await _dio.post('/staff/applicants/$applicantId/decline');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<RepairTicket>> getAllTickets() async {
    try {
      final response = await _dio.get('/staff/tickets');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => RepairTicket.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateTicket(TicketUpdateRequest request) async {
    try {
      await _dio.put('/staff/tickets/${request.ticketId}', data: request.toJson());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BillingRecord>> getAllBillingRecords() async {
    try {
      final response = await _dio.get('/staff/billing');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => BillingRecord.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> processPayment(PaymentRequest request) async {
    try {
      await _dio.post('/staff/payments', data: request.toJson());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CustomerLookupResult?> lookupCustomer(String name) async {
    try {
      final response = await _dio.get('/staff/customers/lookup',
          queryParameters: {'name': name});

      if (response.statusCode == 200 && response.data['data'] != null) {
        return CustomerLookupResult.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> submitRegistration(RegistrationFormData data) async {
    try {
      await _dio.post('/auth/register', data: data.toJson());
    } catch (e) {
      rethrow;
    }
  }
}

// ============================================================
// MOCK IMPLEMENTATION (for testing purposes)
// ============================================================
class MockApiService implements ApiService {
  // Simulates network delay
  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 500));

  @override
  Future<User?> login(String username, String password) async {
    await _delay();
    if (username == 'client' && password == '123') {
      return User(
        id: 'c1',
        username: 'client',
        role: 'client',
        name: 'Errol',
        contactNumber: '09123456789',
        address: 'Bito, Abuyog',
        planName: 'Fiber 1500',
        monthlyBill: 1500,
        dueDateDay: '10th',
      );
    }
    if (username == 'staff' && password == '123') {
      return User(
        id: 's1',
        username: 'staff',
        role: 'staff',
        name: 'Staff Member',
      );
    }
    return null;
  }

  @override
  Future<void> logout() async => await _delay();

  @override
  Future<BillingRecord?> getClientBilling(String customerId) async {
    await _delay();
    return BillingRecord(
      id: '1',
      customerId: 'c1',
      customerName: 'Juan Dela Cruz',
      address: 'Bito, Abuyog',
      planName: 'Fiber 799',
      previousBalance: 799,
      currentCharges: 799,
      totalBalance: 1598,
      status: BillingStatus.unpaid,
      installationTotal: 3000,
      installationPaid: 1000,
    );
  }

  @override
  Future<List<PaymentHistory>> getPaymentHistory(String customerId) async {
    await _delay();
    return [
      PaymentHistory(
        id: '1',
        month: 'December',
        date: 'Dec 23',
        year: '2023',
        amount: 1000,
        method: 'GCash',
        referenceNumber: '020926081615-2503',
      ),
      PaymentHistory(
        id: '2',
        month: 'November',
        date: 'Nov 23',
        year: '2023',
        amount: 1000,
        method: 'GCash',
        referenceNumber: '020926081615-2501',
      ),
    ];
  }

  @override
  Future<List<RepairTicket>> getClientTickets(String customerId) async {
    await _delay();
    return [
      RepairTicket(
        id: '101',
        issue: 'No Internet Connection',
        date: 'Feb 23, 2026',
        status: TicketStatus.pending,
        customerName: 'Juan Dela Cruz',
        description:
            'Customer reported red LOS. Found cut fiber cable near the post. Spliced and restored connection.',
        technicianNotes: null,
      ),
      RepairTicket(
        id: '102',
        issue: 'Slow Connection',
        date: 'Feb 20, 2026',
        status: TicketStatus.resolved,
        customerName: 'Maria Santos',
        description: 'Reconfigured router settings.',
        technicianNotes: null,
      ),
    ];
  }

  @override
  Future<RepairTicket> createRepairTicket(
      String customerId, String issue, String description) async {
    await _delay();
    return RepairTicket(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      issue: issue,
      date: 'Today',
      status: TicketStatus.pending,
      customerName: 'Current User',
      description: description,
    );
  }

  @override
  Future<List<Applicant>> getApplicants() async {
    await _delay();
    return [
      Applicant(
        id: '1',
        name: 'Juan Dela Cruz',
        plan: 'Fiber 799',
        address: 'Bito, Abuyog',
        contactNumber: '09123456789',
        connectionType: ConnectionType.residential,
        date: 'Feb 10, 2026',
        status: ApplicantStatus.pending,
        facebookLink: 'juandelacruz',
        amortizationFee: 3000,
        paymentTerms: 3,
      ),
      Applicant(
        id: '2',
        name: 'Sarah Geronimo',
        plan: 'Fiber 1500',
        address: 'Poblacion, Abuyog',
        contactNumber: '09987654321',
        connectionType: ConnectionType.business,
        date: 'Feb 12, 2026',
        status: ApplicantStatus.pending,
        facebookLink: 'sargeronimo',
        amortizationFee: 5000,
        paymentTerms: 5,
      ),
    ];
  }

  @override
  Future<void> approveApplicant(String applicantId) async => await _delay();

  @override
  Future<void> declineApplicant(String applicantId) async => await _delay();

  @override
  Future<List<RepairTicket>> getAllTickets() async {
    await _delay();
    return [
      RepairTicket(
        id: '101',
        issue: 'No Internet Connection',
        date: 'Feb 23, 2026',
        status: TicketStatus.pending,
        customerName: 'Juan Dela Cruz',
        description:
            'Customer reported red LOS. Found cut fiber cable near the post. Spliced and restored connection.',
        technicianNotes: null,
      ),
      RepairTicket(
        id: '102',
        issue: 'Slow Connection',
        date: 'Feb 20, 2026',
        status: TicketStatus.resolved,
        customerName: 'Maria Santos',
        description: 'Reconfigured router settings.',
        technicianNotes: null,
      ),
    ];
  }

  @override
  Future<void> updateTicket(TicketUpdateRequest request) async => await _delay();

  @override
  Future<List<BillingRecord>> getAllBillingRecords() async {
    await _delay();
    return [
      BillingRecord(
        id: '1',
        customerId: 'c1',
        customerName: 'Juan Dela Cruz',
        address: 'Bito, Abuyog',
        planName: 'Fiber 799',
        previousBalance: 799,
        currentCharges: 799,
        totalBalance: 1598,
        status: BillingStatus.unpaid,
        installationTotal: 3000,
        installationPaid: 1000,
      ),
      BillingRecord(
        id: '2',
        customerId: 'c2',
        customerName: 'Errol Miranda',
        address: 'Bito, Abuyog',
        planName: 'Fiber 1500',
        previousBalance: 0,
        currentCharges: 1500,
        totalBalance: 0,
        status: BillingStatus.remitted,
        installationTotal: 3000,
        installationPaid: 3000,
      ),
    ];
  }

  @override
  Future<void> processPayment(PaymentRequest request) async => await _delay();

  @override
  Future<CustomerLookupResult?> lookupCustomer(String name) async {
    await _delay();
    if (name.toLowerCase().contains('juan')) {
      return CustomerLookupResult(
        name: name,
        address: 'Bito, Abuyog',
        status: CustomerLookupStatus.notUpdated,
      );
    }
    return CustomerLookupResult(
      name: name,
      address: 'MacArthur',
      status: CustomerLookupStatus.active,
      customerId: 'c-lookup-1',
    );
  }

  @override
  Future<void> submitRegistration(RegistrationFormData data) async => await _delay();
}
