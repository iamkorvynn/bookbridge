import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/listing.dart';
import '../services/contact_links.dart';
import '../services/database_helper.dart';
import '../services/photo_service.dart';
import '../widgets/condition_badge.dart';

/// Full detail view for one listing: big photo, all info, WhatsApp / Call
/// actions, mark-as-sold and delete.
class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key, required this.listing});

  final Listing listing;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  late Listing _listing;

  @override
  void initState() {
    super.initState();
    _listing = widget.listing;
  }

  Future<void> _openUrl(String url, String errorLabel) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $errorLabel')),
      );
    }
  }

  Future<void> _toggleSold() async {
    final sold = !_listing.isSold;
    await DatabaseHelper.instance.markSold(_listing.id!, sold);
    setState(() => _listing = _listing.copyWith(isSold: sold));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sold ? 'Marked as sold' : 'Marked as available again',
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this listing?'),
        content: const Text(
          'This removes the listing and its photo permanently.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await PhotoService().deletePhoto(_listing.photoPath);
    await DatabaseHelper.instance.deleteListing(_listing.id!);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final photo = _listing.photoPath;
    final priceText =
        '₹${_listing.price.toStringAsFixed(_listing.price.truncateToDouble() == _listing.price ? 0 : 2)}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete listing',
            onPressed: _delete,
          ),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 280,
            width: double.infinity,
            child: photo != null && File(photo).existsSync()
                ? Image.file(File(photo), fit: BoxFit.cover)
                : Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.12),
                    child: Icon(
                      Icons.menu_book,
                      size: 96,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _listing.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ConditionBadge(
                      condition: _listing.condition,
                      isSold: _listing.isSold,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (_listing.author != null && _listing.author!.isNotEmpty)
                  Text(
                    'by ${_listing.author}',
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  priceText,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                _InfoRow(label: 'Subject', value: _listing.subject),
                _InfoRow(label: 'Condition', value: _listing.condition),
                _InfoRow(label: 'Seller', value: _listing.sellerName),
                _InfoRow(label: 'Phone', value: _listing.sellerPhone),
                const SizedBox(height: 24),
                if (!_listing.isSold) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openUrl(
                        whatsappUrl(
                          phone: _listing.sellerPhone,
                          title: _listing.title,
                        ),
                        'WhatsApp',
                      ),
                      icon: const Icon(Icons.chat),
                      label: const Text('WhatsApp seller'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openUrl(
                        callUrl(_listing.sellerPhone),
                        'the dialler',
                      ),
                      icon: const Icon(Icons.call),
                      label: const Text('Call seller'),
                    ),
                  ),
                  const SizedBox(height: 10),
                ] else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'This book has been sold.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: _toggleSold,
                  icon: Icon(
                    _listing.isSold ? Icons.undo : Icons.check_circle,
                  ),
                  label: Text(
                    _listing.isSold
                        ? 'Mark as available again'
                        : 'Mark as sold',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
