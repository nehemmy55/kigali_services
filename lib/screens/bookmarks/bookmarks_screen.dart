import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';
import '../../providers/interaction_provider.dart';
import '../../widgets/listing_card.dart';
import '../directory/listing_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
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
        title: const Text('Bookmarks'),
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Consumer2<ListingProvider, InteractionProvider>(
        builder: (context, listingProvider, interactionProvider, _) {
          final bookmarks = interactionProvider.userBookmarks;
          final allListings = listingProvider.allListings;

          if (bookmarks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bookmarked services',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Save services to access them quickly',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Get bookmarked listings
          final bookmarkedListings = <ListingModel>[];
          for (final bookmark in bookmarks) {
            try {
              final listing = allListings.firstWhere(
                (l) => l.id == bookmark.listingId,
              );
              bookmarkedListings.add(listing);
            } catch (e) {
              // Listing not found, skip
            }
          }

          if (bookmarkedListings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bookmarked services not found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'They may have been deleted',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookmarkedListings.length,
            itemBuilder: (context, index) {
              final listing = bookmarkedListings[index];
              final rating = interactionProvider.getAverageRating(listing.id);
              final reviewCount =
                  interactionProvider.getReviewCount(listing.id);

              return ListingCard(
                listing: listing,
                rating: rating,
                reviewCount: reviewCount,
                onTap: () => _showListingDetails(listing),
              );
            },
          );
        },
      ),
    );
  }
}
