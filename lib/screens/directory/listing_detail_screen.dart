import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/listing_model.dart';
import '../../providers/interaction_provider.dart';
import '../../providers/auth_provider.dart' as ap;
import 'review_screen.dart';
import '../map/map_view_screen.dart';
import '../listings/edit_listing_screen.dart';

class ListingDetailScreen extends StatelessWidget {
  final ListingModel listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interaction = context.watch<InteractionProvider>();
    final auth = context.watch<ap.AuthProvider>();
    final isOwner = auth.currentUid == listing.createdBy;

    // Get rating from cache
    final rating = interaction.getAverageRating(listing.id);
    final reviewCount = interaction.getReviewCount(listing.id);

    // Check if bookmarked
    final isBookmarked =
        auth.currentUid != null ? interaction.isBookmarked(listing.id) : false;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(listing.name,
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Bookmark button only show if logged in
          if (auth.currentUid != null)
            IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                color: isBookmarked ? Colors.amber : null,
              ),
              onPressed: () async {
                await interaction.toggleBookmark(auth.currentUid!, listing.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isBookmarked
                            ? 'Removed from bookmarks'
                            : 'Added to bookmarks!',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
            ),
          // Edit/Delete for owner
          if (isOwner)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditListingScreen(listing: listing),
                    ),
                  );
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete Listing'),
                      content: const Text('Are you sure?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  ListingCategory.getCategoryIcon(listing.category),
                  size: 64,
                  color: ListingCategory.getCategoryColor(listing.category),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    listing.name,
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),

                  // Rating & Category
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text('${rating.toStringAsFixed(1)} stars',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 4),
                      Text('($reviewCount reviews)',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14)),
                      const SizedBox(width: 8),
                      Text('•', style: TextStyle(color: Colors.grey[400])),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              ListingCategory.getCategoryColor(listing.category)
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(listing.category,
                            style: TextStyle(
                                color: ListingCategory.getCategoryColor(
                                    listing.category),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Address
                  if (listing.address.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.address,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Contact
                  if (listing.contactNumber.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.phone, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          listing.contactNumber,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 16),
                  const Text('Description',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    listing.description.isNotEmpty
                        ? listing.description
                        : "Popular neighborhood place offering high quality services.",
                    style: TextStyle(
                        color: Colors.grey[800], height: 1.4, fontSize: 15),
                  ),

                  // Map Section
                  if (listing.latitude != 0 && listing.longitude != 0) ...[
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        const Text('Location',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 18)),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target:
                                  LatLng(listing.latitude, listing.longitude),
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId(listing.id),
                                position:
                                    LatLng(listing.latitude, listing.longitude),
                                infoWindow: InfoWindow(
                                  title: listing.name,
                                  snippet: listing.address,
                                ),
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueRed,
                                ),
                              ),
                            },
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                            myLocationButtonEnabled: false,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Rate this service button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        interaction.subscribeToReviews(listing.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewScreen(
                              listingId: listing.id,
                              listingName: listing.name,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.rate_review),
                      label: const Text('Rate this service'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // View on Map button
                  if (listing.latitude != 0 && listing.longitude != 0)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MapViewScreen(
                                initialListing: listing,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('View on Map'),
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
