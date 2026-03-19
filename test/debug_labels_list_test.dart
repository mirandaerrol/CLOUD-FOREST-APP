import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/document_validator_service.dart';

void main() {
  group('Debug Label List Extraction', () {
    late DocumentValidatorService validator;

    setUp(() {
      validator = DocumentValidatorService();
    });

    test('Debug each label in the list', () {
      const labels = [
        'PCN: 6076-1832-7914-6713',
        'PhilSys Card Number: 6076-1832-7914-6713',
        'PhilSys Number: 6076-1832-7914-6713',
        'ID Number: 6076-1832-7914-6713',
        'Number: 6076-1832-7914-6713',
        '6076-1832-7914-6713', // No label
      ];

      for (int i = 0; i < labels.length; i++) {
        final label = labels[i];
        print('');
        print('=== Label $i: $label ===');
        final extracted = validator.extractPhilippineIdNumber(label);
        print('Extracted: $extracted');
        print('');
        expect(extracted, '6076183279146713');
      }
    });
  });
}
