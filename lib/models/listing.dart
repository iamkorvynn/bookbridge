/// A single textbook listing on BookBridge.
class Listing {
  final int? id;
  final String title;
  final String? author;
  final String subject;
  final double price;
  final String condition;
  final String? photoPath;
  final String sellerName;
  final String sellerPhone;
  final bool isSold;
  final DateTime createdAt;

  const Listing({
    this.id,
    required this.title,
    this.author,
    required this.subject,
    required this.price,
    required this.condition,
    this.photoPath,
    required this.sellerName,
    required this.sellerPhone,
    this.isSold = false,
    required this.createdAt,
  });

  Listing copyWith({
    int? id,
    String? title,
    String? author,
    String? subject,
    double? price,
    String? condition,
    String? photoPath,
    String? sellerName,
    String? sellerPhone,
    bool? isSold,
    DateTime? createdAt,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      subject: subject ?? this.subject,
      price: price ?? this.price,
      condition: condition ?? this.condition,
      photoPath: photoPath ?? this.photoPath,
      sellerName: sellerName ?? this.sellerName,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      isSold: isSold ?? this.isSold,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'subject': subject,
      'price': price,
      'condition': condition,
      'photo_path': photoPath,
      'seller_name': sellerName,
      'seller_phone': sellerPhone,
      'is_sold': isSold ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Listing.fromMap(Map<String, Object?> map) {
    return Listing(
      id: map['id'] as int?,
      title: map['title'] as String,
      author: map['author'] as String?,
      subject: map['subject'] as String,
      price: (map['price'] as num).toDouble(),
      condition: map['condition'] as String,
      photoPath: map['photo_path'] as String?,
      sellerName: map['seller_name'] as String,
      sellerPhone: map['seller_phone'] as String,
      isSold: (map['is_sold'] as int? ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at'] as int,
      ),
    );
  }
}

/// The four condition grades a seller can pick.
const List<String> listingConditions = [
  'Like New',
  'Good',
  'Fair',
  'Heavily Used',
];

/// Subject / stream choices for the filter and the listing form.
const List<String> listingSubjects = [
  'Computer Science',
  'AIML',
  'Information Technology',
  'Mechanical',
  'Civil',
  'Electrical',
  'Electronics',
  'Mathematics',
  'Physics',
  'Chemistry',
  'Management',
  'Commerce',
  'Other',
];
