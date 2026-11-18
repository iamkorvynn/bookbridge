import 'package:material_ui/material_ui.dart';

import '../models/listing.dart';
import '../services/database_helper.dart';
import '../services/listing_filter.dart';
import '../widgets/listing_card.dart';
import 'add_listing_screen.dart';
import 'listing_detail_screen.dart';
import 'my_listings_screen.dart';

/// Browse screen: search, subject + condition filters, sorting,
/// and the full list of textbooks. Starts empty — no sample data.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Listing> _all = [];
  bool _loading = true;
  String _query = '';
  String _subject = 'All';
  String _condition = 'All';
  SortOption _sort = SortOption.newest;
  bool _hideSold = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final listings = await DatabaseHelper.instance.getAllListings();
    if (!mounted) return;
    setState(() {
      _all = listings;
      _loading = false;
    });
  }

  List<Listing> get _visible {
    final filtered = filterListings(
      _all,
      query: _query,
      subject: _subject,
      condition: _condition,
      hideSold: _hideSold,
    );
    return sortListings(filtered, _sort);
  }

  Future<void> _openDetail(Listing listing) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(listing: listing),
      ),
    );
    await _load();
  }

  Future<void> _openAdd() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddListingScreen()),
    );
    if (added == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Scaffold(
      appBar: AppBar(
        title: const Text('BookBridge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'My listings',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MyListingsScreen(),
                ),
              );
              await _load();
            },
          ),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            initialValue: _sort,
            onSelected: (option) => setState(() => _sort = option),
            itemBuilder: (context) => SortOption.values
                .map(
                  (option) => PopupMenuItem(
                    value: option,
                    child: Text(option.label),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search title, author or subject',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Subject: $_subject',
                  onTap: () => _pickFilter(
                    title: 'Filter by subject',
                    options: ['All', ...listingSubjects],
                    current: _subject,
                    onPicked: (v) => setState(() => _subject = v),
                  ),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Condition: $_condition',
                  onTap: () => _pickFilter(
                    title: 'Filter by condition',
                    options: ['All', ...listingConditions],
                    current: _condition,
                    onPicked: (v) => setState(() => _condition = v),
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Hide sold'),
                  selected: _hideSold,
                  onSelected: (v) => setState(() => _hideSold = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : visible.isEmpty
                ? _EmptyState(
                    hasListings: _all.isNotEmpty,
                    onAdd: _openAdd,
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      itemCount: visible.length,
                      itemBuilder: (context, index) => ListingCard(
                        listing: visible[index],
                        onTap: () => _openDetail(visible[index]),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        icon: const Icon(Icons.add),
        label: const Text('Sell a book'),
      ),
    );
  }

  Future<void> _pickFilter({
    required String title,
    required List<String> options,
    required String current,
    required ValueChanged<String> onPicked,
  }) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: options
                    .map(
                      (option) => ListTile(
                        title: Text(option),
                        trailing: option == current
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () => Navigator.of(context).pop(option),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
    if (picked != null) onPicked(picked);
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasListings, required this.onAdd});

  final bool hasListings;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 72,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              hasListings
                  ? 'No books match your filters'
                  : 'No books listed yet',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasListings
                  ? 'Try a different search or clear the filters.'
                  : 'Be the first to list a textbook — '
                      'snap a photo and set your price.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            if (!hasListings)
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('List your first book'),
              ),
          ],
        ),
      ),
    );
  }
}
