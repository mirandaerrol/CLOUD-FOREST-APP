import 'dart:io';

// ============================================================
// MODELS - Ready for API integration (fromJson / toJson)
// ============================================================

class User {
  final String id;
  final String username;
  final String role;
  final String name;
  final String? email;
  final String? contactNumber;
  final String? address;
  final String? planName;
  final double? monthlyBill;
  final String? dueDateDay;

  User({
    required this.id,
    required this.username,
    required this.role,
    required this.name,
    this.email,
    this.contactNumber,
    this.address,
    this.planName,
    this.monthlyBill,
    this.dueDateDay,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? 'client',
      name: json['name'] ?? '',
      email: json['email'],
      contactNumber: json['contact_number'],
      address: json['address'],
      planName: json['plan_name'],
      monthlyBill: json['monthly_bill'] != null
          ? double.tryParse(json['monthly_bill'].toString())
          : null,
      dueDateDay: json['due_date_day'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'role': role,
        'name': name,
        'email': email,
        'contact_number': contactNumber,
        'address': address,
        'plan_name': planName,
        'monthly_bill': monthlyBill,
        'due_date_day': dueDateDay,
      };
}

// ---- Billing / Payment ----

enum BillingStatus { unpaid, partial, remitted }

class BillingRecord {
  final String id;
  final String customerId;
  final String customerName;
  final String address;
  final String planName;
  final double previousBalance;
  final double currentCharges;
  final double totalBalance;
  final BillingStatus status;
  final String dueDateDay;
  // Installation fee tracking
  final double installationTotal;
  final double installationPaid;

  BillingRecord({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.address = '',
    required this.planName,
    required this.previousBalance,
    required this.currentCharges,
    required this.totalBalance,
    required this.status,
    this.dueDateDay = '10th',
    this.installationTotal = 0,
    this.installationPaid = 0,
  });

  double get installationBalance => installationTotal - installationPaid;

  factory BillingRecord.fromJson(Map<String, dynamic> json) {
    return BillingRecord(
      id: json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customerName: json['customer_name'] ?? '',
      address: json['address'] ?? '',
      planName: json['plan_name'] ?? '',
      previousBalance: double.tryParse(json['previous_balance'].toString()) ?? 0,
      currentCharges: double.tryParse(json['current_charges'].toString()) ?? 0,
      totalBalance: double.tryParse(json['total_balance'].toString()) ?? 0,
      status: _parseStatus(json['status']),
      dueDateDay: json['due_date_day'] ?? '10th',
      installationTotal: double.tryParse(json['installation_total']?.toString() ?? '0') ?? 0,
      installationPaid: double.tryParse(json['installation_paid']?.toString() ?? '0') ?? 0,
    );
  }

  static BillingStatus _parseStatus(dynamic raw) {
    switch (raw?.toString().toLowerCase()) {
      case 'partial': return BillingStatus.partial;
      case 'remitted': return BillingStatus.remitted;
      default: return BillingStatus.unpaid;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'customer_name': customerName,
        'address': address,
        'plan_name': planName,
        'previous_balance': previousBalance,
        'current_charges': currentCharges,
        'total_balance': totalBalance,
        'status': status.name,
        'due_date_day': dueDateDay,
        'installation_total': installationTotal,
        'installation_paid': installationPaid,
      };
}

class PaymentHistory {
  final String id;
  final String month;
  final String date;
  final String year;
  final double amount;
  final String method;
  final String referenceNumber;

  PaymentHistory({
    required this.id,
    required this.month,
    required this.date,
    required this.year,
    required this.amount,
    required this.method,
    required this.referenceNumber,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['id']?.toString() ?? '',
      month: json['month'] ?? '',
      date: json['date'] ?? '',
      year: json['year'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      method: json['method'] ?? '',
      referenceNumber: json['reference_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'month': month,
        'date': date,
        'year': year,
        'amount': amount,
        'method': method,
        'reference_number': referenceNumber,
      };
}

class PaymentRequest {
  final String customerId;
  final String settlementType;
  final double amount;
  final double discount;
  final String coveragePeriod;
  final String method;
  final String referenceNumber;
  final String? remarks;
  final DateTime paymentDate;

  PaymentRequest({
    required this.customerId,
    required this.settlementType,
    required this.amount,
    required this.discount,
    required this.coveragePeriod,
    required this.method,
    required this.referenceNumber,
    this.remarks,
    required this.paymentDate,
  });

  Map<String, dynamic> toJson() => {
        'customer_id': customerId,
        'settlement_type': settlementType,
        'amount': amount,
        'discount': discount,
        'coverage_period': coveragePeriod,
        'method': method,
        'reference_number': referenceNumber,
        'remarks': remarks,
        'payment_date': paymentDate.toIso8601String(),
      };
}

// ---- Repair Tickets ----

enum TicketStatus { pending, resolved, onHold }

class RepairTicket {
  final String id;
  final String issue;
  final String date;
  final TicketStatus status;
  final String customerName;
  final String description;
  final String? technicianNotes;

  RepairTicket({
    required this.id,
    required this.issue,
    required this.date,
    required this.status,
    required this.customerName,
    required this.description,
    this.technicianNotes,
  });

  factory RepairTicket.fromJson(Map<String, dynamic> json) {
    return RepairTicket(
      id: json['id']?.toString() ?? '',
      issue: json['issue'] ?? '',
      date: json['date'] ?? '',
      status: _parseStatus(json['status']),
      customerName: json['customer_name'] ?? '',
      description: json['description'] ?? '',
      technicianNotes: json['technician_notes'],
    );
  }

  static TicketStatus _parseStatus(dynamic raw) {
    switch (raw?.toString().toLowerCase()) {
      case 'resolved': return TicketStatus.resolved;
      case 'on_hold':
      case 'onhold': return TicketStatus.onHold;
      default: return TicketStatus.pending;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'issue': issue,
        'date': date,
        'status': status.name,
        'customer_name': customerName,
        'description': description,
        'technician_notes': technicianNotes,
      };
}

class TicketUpdateRequest {
  final String ticketId;
  final TicketStatus status;
  final String? technicianNotes;

  TicketUpdateRequest({
    required this.ticketId,
    required this.status,
    this.technicianNotes,
  });

  Map<String, dynamic> toJson() => {
        'ticket_id': ticketId,
        'status': status.name,
        'technician_notes': technicianNotes,
      };
}

// ---- Applicants / Installments ----

enum ApplicantStatus { pending, approved, declined }

enum ConnectionType { residential, business, government }

class Applicant {
  final String id;
  final String name;
  final String plan;
  final String address;
  final String contactNumber;
  final ConnectionType connectionType;
  final String date;
  final ApplicantStatus status;
  final String? facebookLink;
  final String? googleMapPin;
  // Installation fee details
  final double amortizationFee;
  final int paymentTerms;

  Applicant({
    required this.id,
    required this.name,
    required this.plan,
    required this.address,
    required this.contactNumber,
    required this.connectionType,
    required this.date,
    required this.status,
    this.facebookLink,
    this.googleMapPin,
    this.amortizationFee = 0,
    this.paymentTerms = 1,
  });

  factory Applicant.fromJson(Map<String, dynamic> json) {
    return Applicant(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      plan: json['plan'] ?? '',
      address: json['address'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      connectionType: _parseType(json['connection_type']),
      date: json['date'] ?? '',
      status: _parseStatus(json['status']),
      facebookLink: json['facebook_link'],
      googleMapPin: json['google_map_pin'],
      amortizationFee: double.tryParse(json['amortization_fee']?.toString() ?? '0') ?? 0,
      paymentTerms: int.tryParse(json['payment_terms']?.toString() ?? '1') ?? 1,
    );
  }

  static ConnectionType _parseType(dynamic raw) {
    switch (raw?.toString().toLowerCase()) {
      case 'business': return ConnectionType.business;
      case 'government': return ConnectionType.government;
      default: return ConnectionType.residential;
    }
  }

  static ApplicantStatus _parseStatus(dynamic raw) {
    switch (raw?.toString().toLowerCase()) {
      case 'approved': return ApplicantStatus.approved;
      case 'declined': return ApplicantStatus.declined;
      default: return ApplicantStatus.pending;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'plan': plan,
        'address': address,
        'contact_number': contactNumber,
        'connection_type': connectionType.name,
        'date': date,
        'status': status.name,
        'facebook_link': facebookLink,
        'google_map_pin': googleMapPin,
        'amortization_fee': amortizationFee,
        'payment_terms': paymentTerms,
      };
}

class RegistrationFormData {
  // Step 1 - Customer Profile
  String purpose = '';
  String customerName = '';
  String contactNumber = '';
  String facebookLink = '';
  String area = '';
  String landmark = '';

  // Step 2 - Service & Installation Details
  ConnectionType connectionType = ConnectionType.residential;
  String serviceStatus = '';
  String installationPayment = '';
  String amortizationFee = '1500';   // Fixed installation fee (₱1,500)
  String paymentTerms = '';      // Number of monthly amortization terms (e.g. 3)
  String dueDate = '';

  // Step 3 - Documents
  File? validIdFile;
  File? selfieFile;
  File? electricBillFile;

  Map<String, dynamic> toJson() => {
        'purpose': purpose,
        'customer_name': customerName,
        'contact_number': contactNumber,
        'facebook_link': facebookLink,
        'area': area,
        'landmark': landmark,
        'connection_type': connectionType.name,
        'status': serviceStatus,
        'installation_payment': installationPayment,
        'amortization_fee': amortizationFee,
        'payment_terms': paymentTerms,
        'due_date': dueDate,
      };
}

// ---- On-Site Customer Lookup ----

enum CustomerLookupStatus { active, notUpdated, notFound }

class CustomerLookupResult {
  final String name;
  final String address;
  final CustomerLookupStatus status;
  final String? customerId;

  CustomerLookupResult({
    required this.name,
    required this.address,
    required this.status,
    this.customerId,
  });

  factory CustomerLookupResult.fromJson(Map<String, dynamic> json) {
    return CustomerLookupResult(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      status: _parseStatus(json['status']),
      customerId: json['customer_id']?.toString(),
    );
  }

  static CustomerLookupStatus _parseStatus(dynamic raw) {
    switch (raw?.toString().toLowerCase()) {
      case 'active': return CustomerLookupStatus.active;
      case 'not_updated': return CustomerLookupStatus.notUpdated;
      default: return CustomerLookupStatus.notFound;
    }
  }
}
