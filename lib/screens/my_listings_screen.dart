import 'package:material_ui/material_ui.dart';

import '../models/listing.dart';
import '../services/database_helper.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_screen.dart';

/// "My listings": everything the user has listed, available first,
/// then sold, with counts.
class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  List<Listing> _listings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final listings = await DatabaseHelper.instance.getAllListings();
    if (!mounted) return;
    setState(() {
      _listings = listings;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final available = _listings.where((l) => !l.isSold).toList();
    final sold = _listings.where((l) => l.isSold).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('My listings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _listings.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 72),
                    SizedBox(height: 16),
                    Text(
                      'You have not listed any books yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Use "Sell a book" on the home screen to list one.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                children: [
                  _SectionHeader(
                    title: 'Available (${available.length})',
                  ),
                  if (available.isEmpty)
                    const ListTile(
                      title: Text('No books currently on sale.'),
                    ),
                  ...available.map(
                    (listing) => ListingCard(
                      listing: listing,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ListingDetailScreen(listing: listing),
                          ),
                        );
                        await _load();
                      },
                    ),
                  ),
                  if (sold.isNotEmpty) ...[
                    _SectionHeader(title: 'Sold (${sold.length})'),
                    ...sold.map(
                      (listing) => ListingCard(
                        listing: listing,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ListingDetailScreen(listing: listing),
                            ),
                          );
                          await _load();
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
