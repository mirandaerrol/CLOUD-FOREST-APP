import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:io';
import 'package:intl/intl.dart';

// ============================================================
// DOCUMENT VALIDATION SERVICE
// ============================================================

class DocumentValidatorService {
  // Text Recognizer for OCR
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  
  // Face Detector
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  Future<void> initialize() async {
    try {
      // For prototype, we're using mock face recognition
      // In production, we would load a TFLite face embedding model
    } catch (e) {
      print('Error initializing document validator: $e');
    }
  }

  // ============================================================
  // GOVERNMENT ID VALIDATION (OCR + MRZ Detection)
  // ============================================================

  Future<GovernmentIdValidationResult> validateGovernmentId(File imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Extract information from ID
      final idInfo = _extractIdInformation(recognizedText);
      
      // Validate ID
      final isValid = _validateIdInformation(idInfo);
      
      return GovernmentIdValidationResult(
        isValid: isValid,
        idNumber: idInfo['idNumber'],
        name: idInfo['name'],
        birthDate: idInfo['birthDate'],
        expiryDate: idInfo['expiryDate'],
        errors: isValid ? [] : _getValidationErrors(idInfo),
      );
    } catch (e) {
      return GovernmentIdValidationResult(
        isValid: false,
        errors: ['Error validating ID: ${e.toString()}'],
      );
    }
  }

  Map<String, dynamic> _extractIdInformation(RecognizedText text) {
    final result = <String, dynamic>{};
    
    // Extract name (looking for patterns like "Name:", "Full Name:", or similar)
    final namePattern = RegExp(r'(?:Name|Full Name|Given Name|Last Name|Pangalan)\s*[:.]?\s*([A-Z\s]+)', caseSensitive: false);
    final nameMatch = namePattern.firstMatch(text.text);
    if (nameMatch != null) {
      result['name'] = nameMatch.group(1)?.trim();
    }

    // Extract ID number (supporting various Philippine ID formats)
    final idNumber = extractPhilippineIdNumber(text.text);
    if (idNumber != null) {
      result['idNumber'] = idNumber;
    }

    // Extract birth date (looking for date patterns)
    final birthDatePattern = RegExp(r'(?:Birth|DOB|Date of Birth|Tanggal ng Kapanganakan)\s*[:.]?\s*(\d{1,2}[/.-]\d{1,2}[/.-]\d{4})');
    final birthMatch = birthDatePattern.firstMatch(text.text);
    if (birthMatch != null) {
      result['birthDate'] = birthMatch.group(1);
    }

    // Extract expiry date (looking for date patterns)
    final expiryPattern = RegExp(r'(?:Expiry|Expiration|Valid Until|Hanggang sa petsa)\s*[:.]?\s*(\d{1,2}[/.-]\d{1,2}[/.-]\d{4})');
    final expiryMatch = expiryPattern.firstMatch(text.text);
    if (expiryMatch != null) {
      result['expiryDate'] = expiryMatch.group(1);
    }

    // Try MRZ detection (Machine Readable Zone) - common on passports/IDs
    final mrzPattern = RegExp(r'[A-Z]{1,2}\d{7}[A-Z]{1,3}\d{7}');
    final mrzMatch = mrzPattern.firstMatch(text.text);
    if (mrzMatch != null) {
      result['mrz'] = mrzMatch.group(0);
    }

    return result;
  }

  String? extractPhilippineIdNumber(String text) {
    // PhilSys (PSA) ID: 12-digit PSN or 16-digit PhilSys Card Number (PCN) with optional hyphen separators
    final philsysPattern = RegExp(r'\b(?:PhilSys|PSA|ID Number|ID No|Number|PCN|PhilSys Card Number)\s*[:.]?\s*(\d{4}[-]?\d{4}[-]?\d{4}[-]?\d{4}|\d{12}|\d{16})\b', caseSensitive: false);
    final philsysMatch = philsysPattern.firstMatch(text);
    if (philsysMatch != null) {
      return philsysMatch.group(1)?.replaceAll('-', '');
    }

    // UMID (SSS/GSIS): 12-digit number starting with 0 or 1 (e.g., 012345678901)
    final umidPattern = RegExp(r'\b(?:UMID|SSS|GSIS)\s*[:.]?\s*(\d{12})\b', caseSensitive: false);
    final umidMatch = umidPattern.firstMatch(text);
    if (umidMatch != null) {
      return umidMatch.group(1);
    }

    // Driver's License: 15-digit number (e.g., N12-34-567890) or pure digits
    final driverLicensePattern = RegExp(r'\b(?:Driver|License|DL No|Lic No)\s*[:.]?\s*([A-Z]{1,2}\d{2}[-]?\d{2}[-]?\d{6}|\d{15})\b', caseSensitive: false);
    final driverLicenseMatch = driverLicensePattern.firstMatch(text);
    if (driverLicenseMatch != null) {
      return driverLicenseMatch.group(1)?.replaceAll('-', '');
    }

    // Passport: Starts with P followed by 7 digits (e.g., P1234567)
    final passportPattern = RegExp(r'\b(?:Passport|PASSPORT)\s*[:.]?\s*([Pp]\d{7})\b', caseSensitive: false);
    final passportMatch = passportPattern.firstMatch(text);
    if (passportMatch != null) {
      return passportMatch.group(1)?.toUpperCase();
    }

    // TIN (Tax Identification Number): 9-digit number (e.g., 123-456-789)
    final tinPattern = RegExp(r'\b(?:TIN|Tax ID|Tax Number)\s*[:.]?\s*(\d{3}[-]?\d{3}[-]?\d{3}|\d{9})\b', caseSensitive: false);
    final tinMatch = tinPattern.firstMatch(text);
    if (tinMatch != null) {
      return tinMatch.group(1)?.replaceAll('-', '');
    }

    // Voter's ID: 9-digit number (e.g., 123456789)
    final voterIdPattern = RegExp(r'\b(?:Voter|Voter ID|VIN)\s*[:.]?\s*(\d{9})\b', caseSensitive: false);
    final voterIdMatch = voterIdPattern.firstMatch(text);
    if (voterIdMatch != null) {
      return voterIdMatch.group(1);
    }

    // Postal ID: 10-digit number (e.g., 1234567890)
    final postalIdPattern = RegExp(r'\b(?:Postal|Postal ID)\s*[:.]?\s*(\d{10})\b', caseSensitive: false);
    final postalIdMatch = postalIdPattern.firstMatch(text);
    if (postalIdMatch != null) {
      return postalIdMatch.group(1);
    }

    // Other common formats: 6-12 digit numbers
    final generalIdPattern = RegExp(r'\b(?:ID|Identification|Number|No)\s*[:.]?\s*(\d{6,12})\b', caseSensitive: false);
    final generalIdMatch = generalIdPattern.firstMatch(text);
    if (generalIdMatch != null) {
      return generalIdMatch.group(1);
    }

    // Fallback: Match any standalone valid Philippine ID format without label
    final standalonePattern = RegExp(r'\b(\d{4}[-]?\d{4}[-]?\d{4}[-]?\d{4}|\d{12}|\d{16}|\d{15}|\d{10}|\d{9}|\d{6,12})\b');
    final standaloneMatch = standalonePattern.firstMatch(text);
    if (standaloneMatch != null) {
      final matched = standaloneMatch.group(1)!;
      // Only return if it's a valid Philippine ID number format
      if (validatePhilippineIdNumber(matched)) {
        return matched.replaceAll('-', '');
      }
    }

    return null;
  }

  bool _validateIdInformation(Map<String, dynamic> idInfo) {
    // Check if we have minimum required fields
    if (idInfo['idNumber'] == null || idInfo['name'] == null) {
      return false;
    }

    // Validate Philippine ID number format
    if (!validatePhilippineIdNumber(idInfo['idNumber'])) {
      return false;
    }

    // Validate expiry date
    if (idInfo['expiryDate'] != null) {
      final expiryDate = _parseDate(idInfo['expiryDate']);
      if (expiryDate != null && expiryDate.isBefore(DateTime.now())) {
        return false;
      }
    }

    return true;
  }

  bool validatePhilippineIdNumber(String idNumber) {
    // Normalize by removing hyphens
    final normalizedId = idNumber.replaceAll('-', '');
    
    // PhilSys (PSA) ID: 12-digit number or 16-digit PhilSys Card Number (PCN)
    if (RegExp(r'^\d{12}$|^\d{16}$').hasMatch(normalizedId)) {
      return true;
    }

    // UMID (SSS/GSIS): 12-digit number starting with 0 or 1
    if (RegExp(r'^[01]\d{11}$').hasMatch(idNumber)) {
      return true;
    }

    // Driver's License: Various formats (including N12-34-567890)
    final cleanIdNumber = idNumber.replaceAll('-', '').toUpperCase();
    if (RegExp(r'^[A-Z]{1,2}\d{6,13}$|^\d{12}$|^\d{14,15}$').hasMatch(cleanIdNumber)) {
      return true;
    }

    // Passport: Starts with P followed by 7 digits
    if (RegExp(r'^[Pp]\d{7}$').hasMatch(idNumber)) {
      return true;
    }

    // TIN (Tax Identification Number): 9-digit number
    if (RegExp(r'^\d{9}$').hasMatch(idNumber.replaceAll('-', ''))) {
      return true;
    }

    // Voter's ID: 9-digit number
    if (RegExp(r'^\d{9}$').hasMatch(idNumber)) {
      return true;
    }

    // Postal ID: 10-digit number
    if (RegExp(r'^\d{10}$').hasMatch(idNumber)) {
      return true;
    }

    // Other acceptable formats: 9-12 digit numbers (more strict for Philippine IDs)
    final cleanDigits = normalizedId;
    if (RegExp(r'^\d{9,12}$').hasMatch(cleanDigits) && cleanDigits.length != 13) {
      return true;
    }

    return false;
  }

  List<String> _getValidationErrors(Map<String, dynamic> idInfo) {
    final errors = <String>[];
    
    if (idInfo['idNumber'] == null) {
      errors.add('ID number not found');
    } else if (!validatePhilippineIdNumber(idInfo['idNumber'])) {
      errors.add('Invalid Philippine ID format');
    }
    
    if (idInfo['name'] == null) {
      errors.add('Name not found');
    }
    
    if (idInfo['expiryDate'] != null) {
      final expiryDate = _parseDate(idInfo['expiryDate']);
      if (expiryDate != null && expiryDate.isBefore(DateTime.now())) {
        errors.add('ID has expired');
      }
    }
    
    return errors;
  }

  DateTime? _parseDate(String dateString) {
    try {
      final formats = [
        DateFormat('dd/MM/yyyy'),
        DateFormat('MM/dd/yyyy'),
        DateFormat('yyyy/MM/dd'),
        DateFormat('dd-MM-yyyy'),
        DateFormat('MM-dd-yyyy'),
        DateFormat('yyyy-MM-dd'),
      ];
      
      for (final format in formats) {
        try {
          return format.parseStrict(dateString);
        } catch (e) {
          continue;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // SELFIE VALIDATION (SIMPLE FACE DETECTION)
  // ============================================================

  Future<SelfieValidationResult> validateSelfie(File selfieImage) async {
    try {
      final selfieFaces = await _detectFaces(selfieImage);

      if (selfieFaces.isEmpty) {
        return SelfieValidationResult(
          isValid: false,
          confidence: 0.0,
          errors: ['Face not detected in selfie'],
        );
      }

      // For selfie validation, we just need to detect a face (no comparison needed)
      return SelfieValidationResult(
        isValid: true,
        confidence: 1.0, // High confidence since we just need to detect a face
        errors: [],
      );
    } catch (e) {
      return SelfieValidationResult(
        isValid: false,
        confidence: 0.0,
        errors: ['Error validating selfie: ${e.toString()}'],
      );
    }
  }

  Future<List<Face>> _detectFaces(File imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    return await _faceDetector.processImage(inputImage);
  }



  // ============================================================
  // DISPOSE
  // ============================================================

  void dispose() {
    _textRecognizer.close();
    _faceDetector.close();
  }
}

// ============================================================
// VALIDATION RESULT CLASSES
// ============================================================

class GovernmentIdValidationResult {
  final bool isValid;
  final String? idNumber;
  final String? name;
  final String? birthDate;
  final String? expiryDate;
  final List<String> errors;

  GovernmentIdValidationResult({
    required this.isValid,
    this.idNumber,
    this.name,
    this.birthDate,
    this.expiryDate,
    this.errors = const [],
  });

  @override
  String toString() {
    return 'GovernmentIdValidationResult{isValid: $isValid, idNumber: $idNumber, name: $name, birthDate: $birthDate, expiryDate: $expiryDate, errors: $errors}';
  }
}

class SelfieValidationResult {
  final bool isValid;
  final double confidence;
  final List<String> errors;

  SelfieValidationResult({
    required this.isValid,
    required this.confidence,
    this.errors = const [],
  });

  @override
  String toString() {
    return 'SelfieValidationResult{isValid: $isValid, confidence: ${(confidence * 100).toStringAsFixed(1)}%, errors: $errors}';
  }
}

class ElectricBillValidationResult {
  final bool isValid;
  final String? accountNumber;
  final String? serviceAddress;
  final String? billingDate;
  final double? amount;
  final List<String> errors;

  ElectricBillValidationResult({
    required this.isValid,
    this.accountNumber,
    this.serviceAddress,
    this.billingDate,
    this.amount,
    this.errors = const [],
  });

  @override
  String toString() {
    return 'ElectricBillValidationResult{isValid: $isValid, accountNumber: $accountNumber, serviceAddress: $serviceAddress, billingDate: $billingDate, amount: $amount, errors: $errors}';
  }
}
