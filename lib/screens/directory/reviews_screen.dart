import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';
import '../../providers/interaction_provider.dart';
import 'listing_detail_screen.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  // Track expanded category (used for UI state)
  String? _expandedCategory;

  void _showListingDetails(ListingModel listing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(listing: listing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services Directory'),
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Consumer2<ListingProvider, InteractionProvider>(
        builder: (context, listingProvider, interactionProvider, _) {
          final listings = listingProvider.allListings;

          if (listings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.list_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No services in directory',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          // Group listings by category
          final groupedListings = <String, List<ListingModel>>{};
          for (final listing in listings) {
            groupedListings.putIfAbsent(listing.category, () => []);
            groupedListings[listing.category]!.add(listing);
          }

          final categories = groupedListings.keys.toList()
            ..sort((a, b) => a.compareTo(b));

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryListings = groupedListings[category]!;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      Icon(ListingCategory.getCategoryIcon(category)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${categoryListings.length} service${categoryListings.length != 1 ? 's' : ''}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onExpansionChanged: (value) {
                    setState(() {
                      _expandedCategory = value ? category : null;
                    });
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: List.generate(
                          categoryListings.length,
                          (idx) {
                            final listing = categoryListings[idx];
                            final rating = interactionProvider
                                .getAverageRating(listing.id);
                            final reviewCount =
                                interactionProvider.getReviewCount(listing.id);

                            return _buildListingTile(
                              context,
                              listing,
                              rating,
                              reviewCount,
                              onTap: () => _showListingDetails(listing),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildListingTile(
    BuildContext context,
    ListingModel listing,
    double rating,
    int reviewCount, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.name,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List<Widget>.generate(
                            5,
                            (i) {
                              final isFilled = i < rating;
                              return Icon(
                                Icons.star_rounded,
                                color: isFilled
                                    ? Colors.amber.shade400
                                    : Colors.grey[300],
                                size: 14,
                              );
                            },
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${rating.toStringAsFixed(1)} ($reviewCount)',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
            if (listing.address.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        listing.address,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            if (listing.contactNumber.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        listing.contactNumber,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 16),
          ],
        ),
      ),
    );
  }
}
