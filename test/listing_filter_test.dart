import 'package:bookbridge/models/listing.dart';
import 'package:bookbridge/services/listing_filter.dart';
import 'package:flutter_test/flutter_test.dart';

Listing makeListing({
  int? id,
  String title = 'Engineering Mathematics',
  String? author = 'B. S. Grewal',
  String subject = 'Mathematics',
  double price = 250,
  String condition = 'Good',
  bool isSold = false,
  DateTime? createdAt,
}) {
  return Listing(
    id: id,
    title: title,
    author: author,
    subject: subject,
    price: price,
    condition: condition,
    sellerName: 'Asha',
    sellerPhone: '9876543210',
    isSold: isSold,
    createdAt: createdAt ?? DateTime(2026, 11, 18, 10),
  );
}

void main() {
  final listings = [
    makeListing(id: 1, price: 250, createdAt: DateTime(2026, 11, 18, 10)),
    makeListing(
      id: 2,
      title: 'Let Us C',
      author: 'Yashavant Kanetkar',
      subject: 'Computer Science',
      price: 150,
      condition: 'Like New',
      createdAt: DateTime(2026, 11, 17, 9),
    ),
    makeListing(
      id: 3,
      title: 'Thermodynamics',
      author: 'Cengel',
      subject: 'Mechanical',
      price: 400,
      condition: 'Fair',
      isSold: true,
      createdAt: DateTime(2026, 11, 16, 8),
    ),
    makeListing(
      id: 4,
      title: 'Data Structures',
      author: 'Narasimha Karumanchi',
      subject: 'Computer Science',
      price: 300,
      condition: 'Good',
      createdAt: DateTime(2026, 11, 18, 12),
    ),
  ];

  group('filterListings', () {
    test('no filters returns everything', () {
      expect(filterListings(listings).length, 4);
    });

    test('query matches title case-insensitively', () {
      final result = filterListings(listings, query: 'let us c');
      expect(result.map((l) => l.id), [2]);
    });

    test('query matches author', () {
      final result = filterListings(listings, query: 'cengel');
      expect(result.map((l) => l.id), [3]);
    });

    test('query matches subject', () {
      final result = filterListings(listings, query: 'mechanical');
      expect(result.map((l) => l.id), [3]);
    });

    test('subject filter narrows to that stream', () {
      final result = filterListings(
        listings,
        subject: 'Computer Science',
      );
      expect(result.map((l) => l.id).toSet(), {2, 4});
    });

    test('condition filter narrows to that grade', () {
      final result = filterListings(listings, condition: 'Good');
      expect(result.map((l) => l.id).toSet(), {1, 4});
    });

    test('combined query + subject filter', () {
      final result = filterListings(
        listings,
        query: 'data',
        subject: 'Computer Science',
      );
      expect(result.map((l) => l.id), [4]);
    });

    test('hideSold drops sold listings', () {
      final result = filterListings(listings, hideSold: true);
      expect(result.map((l) => l.id).toSet(), {1, 2, 4});
    });
  });

  group('sortListings', () {
    test('newest first orders by createdAt descending', () {
      final result = sortListings(listings, SortOption.newest);
      expect(result.map((l) => l.id).toList(), [4, 1, 2, 3]);
    });

    test('price low to high', () {
      final result = sortListings(listings, SortOption.priceLowToHigh);
      expect(result.map((l) => l.id).toList(), [2, 1, 4, 3]);
    });

    test('price high to low', () {
      final result = sortListings(listings, SortOption.priceHighToLow);
      expect(result.map((l) => l.id).toList(), [3, 4, 1, 2]);
    });

    test('does not mutate the input list', () {
      final input = List<Listing>.from(listings);
      sortListings(input, SortOption.priceLowToHigh);
      expect(input.map((l) => l.id).toList(), [1, 2, 3, 4]);
    });
  });

  group('Listing model', () {
    test('toMap/fromMap round-trip preserves fields', () {
      final original = makeListing(id: 7, isSold: true);
      final restored = Listing.fromMap(original.toMap());
      expect(restored.id, 7);
      expect(restored.title, original.title);
      expect(restored.author, original.author);
      expect(restored.price, 250);
      expect(restored.isSold, isTrue);
      expect(restored.createdAt, original.createdAt);
    });
  });
}
