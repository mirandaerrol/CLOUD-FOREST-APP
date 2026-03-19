import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class RegistrationProvider extends ChangeNotifier {
  final ApiService _apiService;

  RegistrationProvider(this._apiService);

  int _step = 1;
  final RegistrationFormData _formData = RegistrationFormData();
  bool _isSubmitting = false;
  final int _totalSteps = 4;
  String? _validationError;

  int get step => _step;
  RegistrationFormData get formData => _formData;
  bool get isSubmitting => _isSubmitting;
  int get totalSteps => _totalSteps;
  String? get validationError => _validationError;

  bool canProceedToNextStep() {
    _validationError = null;
    
    switch (_step) {
      case 1:
        if (formData.purpose.isEmpty) {
          _validationError = 'Please select purpose of installment';
          return false;
        }
        if (formData.customerName.isEmpty) {
          _validationError = 'Please enter customer name';
          return false;
        }
        if (formData.contactNumber.isEmpty) {
          _validationError = 'Please enter contact number';
          return false;
        }
        if (formData.area.isEmpty) {
          _validationError = 'Please select area/barangay';
          return false;
        }
        if (formData.landmark.isEmpty) {
          _validationError = 'Please enter landmark/directions';
          return false;
        }
        break;
        
      case 2:
        if (formData.installationPayment.isEmpty) {
          _validationError = 'Please select installation payment type';
          return false;
        }
        if (formData.installationPayment == 'Partially Paid' && formData.paymentTerms.isEmpty) {
          _validationError = 'Please enter payment terms';
          return false;
        }
        if (formData.dueDate.isEmpty) {
          _validationError = 'Please select due date';
          return false;
        }
        break;
        
      case 3:
        if (formData.validIdFile == null) {
          _validationError = 'Please upload a valid ID';
          return false;
        }
        if (formData.selfieFile == null) {
          _validationError = 'Please upload a selfie';
          return false;
        }
        if (formData.electricBillFile == null) {
          _validationError = 'Please upload an electric bill';
          return false;
        }
        break;
    }
    
    return true;
  }

  void nextStep() {
    if (_step < _totalSteps && canProceedToNextStep()) {
      _step++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_step > 1) {
      _step--;
      notifyListeners();
    }
  }

  Future<void> submit() async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await _apiService.submitRegistration(_formData);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void updateFormData(void Function(RegistrationFormData) update) {
    update(_formData);
    notifyListeners();
  }
}
