import 'package:flutter_application_1/services/document_validator_service.dart';


void main() {
  final validator = DocumentValidatorService();
  
  // Test the specific hyphenated PCN from the image: 6076-1832-7914-6713
  const testCases = [
    '6076-1832-7914-6713',      // Hyphenated 16-digit PCN (exact from image)
    '6076183279146713',         // Non-hyphenated 16-digit PCN
    '6076-1832-7914-671',       // Invalid length
    'abc123-4567-8901-2345',    // Contains letters
    '607-618-327-914-6713',     // Invalid hyphen positions
  ];
  
  print('Testing hyphenated PCN format extraction and validation:');
  print('=' * 50);
  
  for (final testCase in testCases) {
    final isValid = validator.validatePhilippineIdNumber(testCase);
    
    // Debug extraction
    print('\nTest: $testCase');
    print('Valid: $isValid');
    print('Normalized: ${testCase.replaceAll('-', '')}');
    
    // Check extraction with context (simulating OCR output)
    final extractedId = validator.extractPhilippineIdNumber(
        'PhilSys Card Number: $testCase');
    print('Extracted from text: $extractedId');
  }
  
  // Additional test with other common formats
  print('\n${'=' * 50}');
  print('Testing other ID formats for comparison:');
  print('=' * 50);
  
  const otherFormats = [
    '012345678901',       // UMID
    'N12-34-567890',      // Driver's License
    'P1234567',           // Passport
    '123-456-789',        // TIN
  ];
  
  for (final format in otherFormats) {
    final isValid = validator.validatePhilippineIdNumber(format);
    print('\n$format: ${isValid ? '✓ Valid' : '✗ Invalid'}');
  }
}
