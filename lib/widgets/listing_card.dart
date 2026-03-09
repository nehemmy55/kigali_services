import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/listing_model.dart';

class ListingCard extends StatelessWidget {
  final ListingModel listing;
  final double rating;
  final int reviewCount;
  final VoidCallback onTap;
  final bool showDistance;

  const ListingCard({
    super.key,
    required this.listing,
    required this.rating,
    required this.reviewCount,
    required this.onTap,
    this.showDistance = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category icon with background
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: ListingCategory.getCategoryColor(listing.category)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  ListingCategory.getCategoryIcon(listing.category),
                  color: ListingCategory.getCategoryColor(listing.category),
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and category tag
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ListingCategory.getCategoryColor(
                                    listing.category)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: ListingCategory.getCategoryColor(
                                      listing.category)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            listing.category,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: ListingCategory.getCategoryColor(
                                      listing.category),
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Address
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.address,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Rating, distance, and contact
                    Row(
                      children: [
                        // Rating stars
                        RatingBar.builder(
                          initialRating: rating,
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 16,
                          itemBuilder: (_, __) => Icon(
                            Icons.star_rounded,
                            color: Colors.amber.shade400,
                          ),
                          onRatingUpdate: (_) {},
                          ignoreGestures: true,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${rating.toStringAsFixed(1)} ($reviewCount)',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),

                        // Distance
                        if (showDistance && listing.distanceKm != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.directions_walk,
                                  size: 12,
                                  color: Colors.green[700],
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  _formatDistance(listing.distanceKm!),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const Spacer(),
                        // Contact icon
                        if (listing.contactNumber.isNotEmpty)
                          Icon(
                            Icons.phone_outlined,
                            size: 16,
                            color: Colors.blue.shade600,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Trailing arrow
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).round()} m';
    } else if (km < 10) {
      return '${km.toStringAsFixed(1)} km';
    } else {
      return '${km.round()} km';
    }
  }
}
