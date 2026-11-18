import 'package:bookbridge/services/contact_links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('digitsOnly', () {
    test('strips spaces, dashes and plus signs', () {
      expect(digitsOnly('+91 98765-43210'), '919876543210');
      expect(digitsOnly('(987) 654-3210'), '9876543210');
    });
  });

  group('isValidPhone', () {
    test('accepts a 10-digit Indian number', () {
      expect(isValidPhone('9876543210'), isTrue);
      expect(isValidPhone('+91 98765 43210'), isTrue);
    });

    test('rejects short or empty numbers', () {
      expect(isValidPhone('12345'), isFalse);
      expect(isValidPhone(''), isFalse);
      expect(isValidPhone('abcdefghij'), isFalse);
    });
  });

  group('normalizePhone', () {
    test('prefixes 91 for a plain 10-digit number', () {
      expect(normalizePhone('9876543210'), '919876543210');
    });

    test('keeps an already-prefixed 12-digit number as-is', () {
      expect(normalizePhone('919876543210'), '919876543210');
      expect(normalizePhone('+91 98765 43210'), '919876543210');
    });

    test('drops a leading 0 from an 11-digit number', () {
      expect(normalizePhone('09876543210'), '919876543210');
    });
  });

  group('whatsappUrl', () {
    test('10-digit number becomes wa.me/91... with encoded message', () {
      final url = whatsappUrl(
        phone: '9876543210',
        title: 'Engineering Mathematics',
      );
      expect(
        url,
        'https://wa.me/919876543210?text=Hi!%20Is%20Engineering%20Mathematics%20still%20available%20on%20BookBridge%3F',
      );
    });

    test('already-prefixed number is not double-prefixed', () {
      final url = whatsappUrl(
        phone: '+919876543210',
        title: 'Physics',
      );
      expect(url.startsWith('https://wa.me/919876543210?text='), isTrue);
      expect(url.contains('9191'), isFalse);
    });

    test('message is URL-encoded for special characters', () {
      final url = whatsappUrl(phone: '9876543210', title: 'C++ & Data');
      expect(url.contains('C%2B%2B%20%26%20Data'), isTrue);
    });

    test('whatsappMessage uses the exact template', () {
      expect(
        whatsappMessage('Let Us C'),
        'Hi! Is Let Us C still available on BookBridge?',
      );
    });
  });

  group('callUrl', () {
    test('produces a tel: link with digits only', () {
      expect(callUrl('+91 98765 43210'), 'tel:919876543210');
      expect(callUrl('9876543210'), 'tel:9876543210');
    });
  });
}
