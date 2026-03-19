import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/document_validator_service.dart';

void main() {
  group('Philippine ID Validation', () {
    test('Should recognize and validate PhilSys (PSA) ID and PCN', () {
      final validator = DocumentValidatorService();
      
      // Test valid PhilSys (PSN) format (12-digit)
      expect(validator.validatePhilippineIdNumber('123456789012'), isTrue);
      
      // Test valid PhilSys Card Number (PCN) format (16-digit)
      expect(validator.validatePhilippineIdNumber('1234567890123456'), isTrue);
    });
    
    test('Should recognize and validate UMID', () {
      final validator = DocumentValidatorService();
      
      // Test UMID formats
      expect(validator.validatePhilippineIdNumber('012345678901'), isTrue); // starts with 0
      expect(validator.validatePhilippineIdNumber('112345678901'), isTrue); // starts with 1
    });
    
    test('Should recognize and validate Driver\'s License', () {
      final validator = DocumentValidatorService();
      
      // Test driver's license formats
      expect(validator.validatePhilippineIdNumber('N12-34-567890'), isTrue);
      expect(validator.validatePhilippineIdNumber('N123456789012'), isTrue);
      expect(validator.validatePhilippineIdNumber('123456789012345'), isTrue);
    });
    
    test('Should recognize and validate Passport', () {
      final validator = DocumentValidatorService();
      
      // Test passport formats
      expect(validator.validatePhilippineIdNumber('P1234567'), isTrue);
      expect(validator.validatePhilippineIdNumber('p1234567'), isTrue); // lowercase P
    });
    
    test('Should recognize and validate TIN', () {
      final validator = DocumentValidatorService();
      
      // Test TIN formats
      expect(validator.validatePhilippineIdNumber('123-456-789'), isTrue);
      expect(validator.validatePhilippineIdNumber('123456789'), isTrue);
    });
    
    test('Should recognize and validate Voter ID', () {
      final validator = DocumentValidatorService();
      
      expect(validator.validatePhilippineIdNumber('123456789'), isTrue);
    });
    
    test('Should recognize and validate Postal ID', () {
      final validator = DocumentValidatorService();
      
      expect(validator.validatePhilippineIdNumber('1234567890'), isTrue);
    });
    
    test('Should reject invalid ID formats', () {
      final validator = DocumentValidatorService();
      
      expect(validator.validatePhilippineIdNumber('123'), isFalse); // too short
      expect(validator.validatePhilippineIdNumber('1234567890123'), isFalse); // too long
      expect(validator.validatePhilippineIdNumber('abc123'), isFalse); // contains letters
      expect(validator.validatePhilippineIdNumber(''), isFalse); // empty
    });
  });
}
