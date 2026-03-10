import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/listing_provider.dart';
import '../providers/interaction_provider.dart';
import '../models/listing_model.dart';
import 'listings/create_listing_screen.dart';
import 'directory/listing_detail_screen.dart';
import '../widgets/listing_card.dart';
import '../widgets/category_chip.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToDirectory;

  const HomeScreen({super.key, required this.onNavigateToDirectory});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        title: const Text('Kigali Services'),
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          Consumer<ListingProvider>(
            builder: (context, provider, _) {
              if (provider.isLoadingLocation) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: () {
                  // Refresh location
                },
                tooltip: 'Update my location',
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateListing,
        tooltip: 'Add New Service',
        child: const Icon(Icons.add),
      ),
      body: Consumer2<ListingProvider, InteractionProvider>(
        builder: (context, listingProvider, interactionProvider, _) {
          // Get nearest listings
          final listings = listingProvider.filteredNearestListings;

          return CustomScrollView(
            slivers: [
              // Location info banner
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          listingProvider.userLocation != null
                              ? 'Showing services near you (sorted by distance)'
                              : 'Location not available - showing all services',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: SearchBar(
                    controller: _searchController,
                    onChanged: (value) => listingProvider.setSearchQuery(value),
                    leading: const Icon(Icons.search),
                    hintText: 'Search services...',
                  ),
                ),
              ),

              // Category chips
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      CategoryChip(
                        label: 'All',
                        isSelected: listingProvider.selectedCategory == null,
                        onPressed: () => listingProvider.clearFilters(),
                      ),
                      ...ListingCategory.categories
                          .map((category) => CategoryChip(
                                label: category,
                                isSelected: listingProvider.selectedCategory ==
                                    category,
                                onPressed: () =>
                                    listingProvider.setCategory(category),
                              )),
                    ],
                  ),
                ),
              ),

              // Section headerNearest services
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.near_me, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Nearest to You',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const Spacer(),
                      Text(
                        '${listings.length} found',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              // Listings list
              if (listings.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No services found',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.tonal(
                          onPressed: () => listingProvider.clearFilters(),
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final listing = listings[index];
                        final rating =
                            interactionProvider.getAverageRating(listing.id);
                        final reviewCount =
                            interactionProvider.getReviewCount(listing.id);

                        return ListingCard(
                          listing: listing,
                          rating: rating,
                          reviewCount: reviewCount,
                          showDistance: true,
                          onTap: () => _showListingDetails(listing),
                        );
                      },
                      childCount: listings.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
