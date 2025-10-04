import 'package:flutter_test/flutter_test.dart';
import 'package:gestcom/core/utils/validation_utils.dart';

void main() {
  group('ValidationUtils', () {
    group('validateMatriculeFiscal', () {
      test('should return null for valid 8-digit matricule', () {
        expect(ValidationUtils.validateMatriculeFiscal('12345678'), isNull);
      });

      test('should return null for valid 8-digit matricule with letter suffix', () {
        expect(ValidationUtils.validateMatriculeFiscal('12345678A'), isNull);
        expect(ValidationUtils.validateMatriculeFiscal('12345678ABC'), isNull);
      });

      test('should return error for empty string', () {
        expect(ValidationUtils.validateMatriculeFiscal(''), isNotNull);
      });

      test('should return error for less than 8 digits', () {
        expect(ValidationUtils.validateMatriculeFiscal('1234567'), isNotNull);
        expect(ValidationUtils.validateMatriculeFiscal('123'), isNotNull);
      });

      test('should return error for non-numeric first 8 characters', () {
        expect(ValidationUtils.validateMatriculeFiscal('1234567A'), isNotNull);
        expect(ValidationUtils.validateMatriculeFiscal('ABCD1234'), isNotNull);
      });

      test('should return error for invalid suffix characters', () {
        expect(ValidationUtils.validateMatriculeFiscal('12345678@'), isNotNull);
        expect(ValidationUtils.validateMatriculeFiscal('123456781'), isNotNull);
        expect(ValidationUtils.validateMatriculeFiscal('12345678A1'), isNotNull);
      });

      test('should handle whitespace correctly', () {
        expect(ValidationUtils.validateMatriculeFiscal(' 12345678 '), isNull);
        expect(ValidationUtils.validateMatriculeFiscal(' 12345678A '), isNull);
      });
    });

    group('validateEmail', () {
      test('should return null for valid email', () {
        expect(ValidationUtils.validateEmail('test@example.com'), isNull);
        expect(ValidationUtils.validateEmail('user.name@domain.co.tn'), isNull);
      });

      test('should return error for invalid email', () {
        expect(ValidationUtils.validateEmail('invalid-email'), isNotNull);
        expect(ValidationUtils.validateEmail('test@'), isNotNull);
        expect(ValidationUtils.validateEmail('@domain.com'), isNotNull);
      });

      test('should return error for empty email', () {
        expect(ValidationUtils.validateEmail(''), isNotNull);
      });
    });

    group('validatePhone', () {
      test('should return null for valid phone numbers', () {
        expect(ValidationUtils.validatePhone('12345678'), isNull);
        expect(ValidationUtils.validatePhone('+216 71 123 456'), isNull);
        expect(ValidationUtils.validatePhone('(216) 71-123-456'), isNull);
      });

      test('should return error for invalid phone', () {
        expect(ValidationUtils.validatePhone('abc123'), isNotNull);
        expect(ValidationUtils.validatePhone('123@456'), isNotNull);
      });

      test('should return error for empty phone', () {
        expect(ValidationUtils.validatePhone(''), isNotNull);
      });
    });

    group('validateRequired', () {
      test('should return null for non-empty string', () {
        expect(ValidationUtils.validateRequired('test', 'Field'), isNull);
      });

      test('should return error for empty string', () {
        expect(ValidationUtils.validateRequired('', 'Field'), isNotNull);
        expect(ValidationUtils.validateRequired('   ', 'Field'), isNotNull);
      });
    });
  });
}