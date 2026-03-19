import 'package:flutter_application_1/services/document_validator_service.dart';

void main() {
  final validator = DocumentValidatorService();
  
  // Debug the 1234567890123 case
  const testCase = '1234567890123';
  print('Debugging: $testCase');
  
  final cleanIdNumber = testCase.replaceAll('-', '').toUpperCase();
  print('Clean: $cleanIdNumber');
  
  // Test each validation condition
  if (RegExp(r'^\d{12}$').hasMatch(cleanIdNumber)) {
    print('PhilSys');
  }
  if (RegExp(r'^[01]\d{11}$').hasMatch(cleanIdNumber)) {
    print('UMID');
  }
  if (RegExp(r'^[A-Z]{1,2}\d{6,13}$|^\d{12,15}$').hasMatch(cleanIdNumber) && cleanIdNumber.length <= 15) {
    print('Driver License');
  }
  if (RegExp(r'^[Pp]\d{7}$').hasMatch(cleanIdNumber)) {
    print('Passport');
  }
  if (RegExp(r'^\d{9}$').hasMatch(cleanIdNumber)) {
    print('TIN');
  }
  if (RegExp(r'^\d{9}$').hasMatch(cleanIdNumber)) {
    print('Voter ID');
  }
  if (RegExp(r'^\d{10}$').hasMatch(cleanIdNumber)) {
    print('Postal ID');
  }
  final cleanDigits = cleanIdNumber;
  if (RegExp(r'^\d{9,12}$').hasMatch(cleanDigits) && cleanDigits.length != 13) {
    print('Other');
  }
  
  print('Final result: ${validator.validatePhilippineIdNumber(testCase)}');
}
