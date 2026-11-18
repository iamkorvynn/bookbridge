// Pure helpers for turning a seller's phone number into contact links.
// Kept free of any Flutter dependency so they are trivially unit-testable.

/// Strips everything that is not a digit.
String digitsOnly(String phone) => phone.replaceAll(RegExp(r'\D'), '');

/// True when the number has at least 10 digits after stripping.
bool isValidPhone(String phone) => digitsOnly(phone).length >= 10;

/// Normalises a phone number for wa.me / tel links.
///
/// - 10 digits (Indian mobile) -> prefixed with 91
/// - 11 digits starting with 0 -> the 0 is dropped, then 91 is prefixed
/// - 12 digits starting with 91 -> used as-is
/// - anything else with 10+ digits -> used as-is
String normalizePhone(String phone) {
  final digits = digitsOnly(phone);
  if (digits.length == 10) return '91$digits';
  if (digits.length == 11 && digits.startsWith('0')) {
    return '91${digits.substring(1)}';
  }
  return digits;
}

/// The prefilled WhatsApp message sent to a seller about a listing.
String whatsappMessage(String title) =>
    'Hi! Is $title still available on BookBridge?';

/// Builds the wa.me deep link for a listing, with a prefilled message.
String whatsappUrl({required String phone, required String title}) {
  final normalized = normalizePhone(phone);
  final encoded = Uri.encodeComponent(whatsappMessage(title));
  return 'https://wa.me/$normalized?text=$encoded';
}

/// Builds the tel: link for calling a seller.
String callUrl(String phone) => 'tel:${digitsOnly(phone)}';
