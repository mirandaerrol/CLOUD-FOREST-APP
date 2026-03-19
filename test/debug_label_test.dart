import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/document_validator_service.dart';

void main() {
  group('Debug Label Extraction', () {
    late DocumentValidatorService validator;

    setUp(() {
      validator = DocumentValidatorService();
    });

    test('Debug extraction with "Number: " label', () {
      const text = 'Number: 6076-1832-7914-6713';
      print('Input text: $text');

      // Test all patterns
      const patterns = [
        r'(?:\b(?:PCN|PhilSys\s*Card\s*Number|PhilSys\s*Number|Id\s*Number|ID\s*Number)\b\s*:?\s*|#\s*)(\d{13}|\d{12}|\d{4}-\d{4}-\d{4}-\d{4}|\d{16})',
        r'(?:PCN|PhilSys\s*Card\s*Number|PhilSys\s*Number|Id\s*Number|ID\s*Number|Number)\s*:?\s*(\d{13}|\d{12}|\d{4}-\d{4}-\d{4}-\d{4}|\d{16})',
        r'(\d{4}-\d{4}-\d{4}-\d{4})',
        r'(\d{16})',
        r'(\d{13})',
        r'(\d{12})',
      ];

      for (int i = 0; i < patterns.length; i++) {
        final pattern = RegExp(patterns[i], caseSensitive: false);
        final match = pattern.firstMatch(text);
        print('Pattern $i: ${patterns[i]}');
        print('Match: $match');
        if (match != null) {
          for (int j = 0; j <= match.groupCount; j++) {
            print('  Group $j: ${match.group(j)}');
          }
        }
        print('');
      }

      // Try actual extraction
      final extracted = validator.extractPhilippineIdNumber(text);
      print('Actual extracted: $extracted');
      
      expect(extracted, isNotNull);
    });
  });
}
