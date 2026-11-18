import 'dart:io';

import 'package:material_ui/material_ui.dart';

import '../models/listing.dart';
import 'condition_badge.dart';

/// One row in the browse list: photo, title, subject, price, condition.
class ListingCard extends StatelessWidget {
  const ListingCard({super.key, required this.listing, required this.onTap});

  final Listing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photo = listing.photoPath;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 96,
              height: 110,
              child: photo != null && File(photo).existsSync()
                  ? Image.file(File(photo), fit: BoxFit.cover)
                  : Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      child: Icon(
                        Icons.menu_book,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (listing.author != null &&
                            listing.author!.isNotEmpty)
                          listing.author!,
                        listing.subject,
                      ].join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '₹${listing.price.toStringAsFixed(listing.price.truncateToDouble() == listing.price ? 0 : 2)}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            decoration: listing.isSold
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const Spacer(),
                        ConditionBadge(
                          condition: listing.condition,
                          isSold: listing.isSold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Seller: ${listing.sellerName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
