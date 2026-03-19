import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/document_validator_service.dart';

void main() {
  group('Isolate Test Case', () {
    late DocumentValidatorService validator;

    setUp(() {
      validator = DocumentValidatorService();
    });

    test('Test case: Number: 6076-1832-7914-6713', () {
      const testCase = 'Number: 6076-1832-7914-6713';
      print('Testing: $testCase');
      final extracted = validator.extractPhilippineIdNumber(testCase);
      print('Extracted: $extracted');
      expect(extracted, '6076183279146713');
    });
  });
}
