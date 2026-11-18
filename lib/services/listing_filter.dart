import '../models/listing.dart';

/// How the browse list can be ordered.
enum SortOption { newest, priceLowToHigh, priceHighToLow }

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.newest:
        return 'Newest first';
      case SortOption.priceLowToHigh:
        return 'Price: low to high';
      case SortOption.priceHighToLow:
        return 'Price: high to low';
    }
  }
}

/// Filters [listings] by free-text query (title / author / subject),
/// subject and condition. Empty / 'All' values mean "no filter".
/// When [hideSold] is true, sold listings are dropped.
List<Listing> filterListings(
  List<Listing> listings, {
  String query = '',
  String subject = 'All',
  String condition = 'All',
  bool hideSold = false,
}) {
  final q = query.trim().toLowerCase();
  return listings.where((listing) {
    if (hideSold && listing.isSold) return false;
    if (subject != 'All' && listing.subject != subject) return false;
    if (condition != 'All' && listing.condition != condition) return false;
    if (q.isEmpty) return true;
    final haystack =
        '${listing.title} ${listing.author ?? ''} ${listing.subject}'
            .toLowerCase();
    return haystack.contains(q);
  }).toList();
}

/// Returns a new list sorted per [option]. The input list is not mutated.
List<Listing> sortListings(List<Listing> listings, SortOption option) {
  final sorted = List<Listing>.from(listings);
  switch (option) {
    case SortOption.newest:
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    case SortOption.priceLowToHigh:
      sorted.sort((a, b) => a.price.compareTo(b.price));
    case SortOption.priceHighToLow:
      sorted.sort((a, b) => b.price.compareTo(a.price));
  }
  return sorted;
}
