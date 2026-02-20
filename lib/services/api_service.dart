import '../models/models.dart';

// ============================================================
// DUMMY DATA - Replace method bodies with real API calls
// ============================================================

final mockTickets = [
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

final mockApplicants = [
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
  ),
];

final mockBillingRecords = [
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
  ),
  BillingRecord(
    id: '3',
    customerId: 'c3',
    customerName: 'Sarah Geronimo',
    address: 'Poblacion, Abuyog',
    planName: 'Fiber 1500',
    previousBalance: 0,
    currentCharges: 1500,
    totalBalance: 500,
    status: BillingStatus.partial,
  ),
  BillingRecord(
    id: '4',
    customerId: 'c4',
    customerName: 'Bamboo Mañalac',
    address: 'Bito, Abuyog',
    planName: 'Fiber 2000',
    previousBalance: 0,
    currentCharges: 2000,
    totalBalance: 0,
    status: BillingStatus.remitted,
  ),
];

final mockPaymentHistory = [
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

final mockClientUser = User(
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

final mockStaffUser = User(
  id: 's1',
  username: 'staff',
  role: 'staff',
  name: 'Staff Member',
);

// ============================================================
// API SERVICE - Swap mock implementations for real HTTP calls
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
// MOCK IMPLEMENTATION - replace with DioApiService for prod
// ============================================================

class MockApiService implements ApiService {
  // Simulates network delay
  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 500));

  @override
  Future<User?> login(String username, String password) async {
    await _delay();
    if (username == 'client' && password == '123') return mockClientUser;
    if (username == 'staff' && password == '123') return mockStaffUser;
    return null;
  }

  @override
  Future<void> logout() async => await _delay();

  @override
  Future<BillingRecord?> getClientBilling(String customerId) async {
    await _delay();
    try {
      return mockBillingRecords.firstWhere((b) => b.customerId == customerId);
    } catch (_) {
      return mockBillingRecords.first;
    }
  }

  @override
  Future<List<PaymentHistory>> getPaymentHistory(String customerId) async {
    await _delay();
    return mockPaymentHistory;
  }

  @override
  Future<List<RepairTicket>> getClientTickets(String customerId) async {
    await _delay();
    return mockTickets;
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
    return mockApplicants;
  }

  @override
  Future<void> approveApplicant(String applicantId) async => await _delay();

  @override
  Future<void> declineApplicant(String applicantId) async => await _delay();

  @override
  Future<List<RepairTicket>> getAllTickets() async {
    await _delay();
    return mockTickets;
  }

  @override
  Future<void> updateTicket(TicketUpdateRequest request) async => await _delay();

  @override
  Future<List<BillingRecord>> getAllBillingRecords() async {
    await _delay();
    return mockBillingRecords;
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

// ============================================================
// PRODUCTION IMPLEMENTATION STUB (Dio/HTTP)
// Uncomment and implement when connecting to real API
// ============================================================

/*
import 'package:dio/dio.dart';

class DioApiService implements ApiService {
  final Dio _dio;
  static const _baseUrl = 'https://your-api.cloudforest.com/api/v1';

  DioApiService() : _dio = Dio(BaseOptions(baseUrl: _baseUrl)) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Handle 401, 403, network errors
        handler.next(error);
      },
    ));
  }

  Future<String?> _getToken() async {
    final storage = const FlutterSecureStorage();
    return await storage.read(key: 'auth_token');
  }

  @override
  Future<User?> login(String username, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
    if (response.statusCode == 200) {
      final token = response.data['token'];
      await const FlutterSecureStorage().write(key: 'auth_token', value: token);
      return User.fromJson(response.data['user']);
    }
    return null;
  }

  // ... implement other methods similarly
}
*/
