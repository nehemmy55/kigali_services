import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';
import '../../providers/interaction_provider.dart';
import '../../widgets/listing_card.dart';
import '../directory/listing_detail_screen.dart';
import 'create_listing_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  void _showListingDetails(ListingModel listing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(listing: listing),
      ),
    );
  }

  Future<void> _navigateToCreateListing() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const CreateListingScreen(),
      ),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Services'),
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateListing,
        tooltip: 'Add New Service',
        child: const Icon(Icons.add),
      ),
      body: Consumer2<ListingProvider, InteractionProvider>(
        builder: (context, listingProvider, interactionProvider, _) {
          final myListings = listingProvider.myListings;

          if (myListings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No services yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _navigateToCreateListing,
                    child: const Text('Add First Service'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myListings.length,
            itemBuilder: (context, index) {
              final listing = myListings[index];
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
