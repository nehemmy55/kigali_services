import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:uuid/uuid.dart';
import '../../providers/interaction_provider.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../models/interaction_models.dart';

class ReviewScreen extends StatelessWidget {
  final String listingId;
  final String listingName;

  const ReviewScreen({
    super.key,
    required this.listingId,
    required this.listingName,
  });

  void _showAddReviewDialog(BuildContext context) {
    final auth = context.read<ap.AuthProvider>();
    final interaction = context.read<InteractionProvider>();
    final commentCtrl = TextEditingController();
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Rate $listingName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (r) => rating = r,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentCtrl,
              decoration: const InputDecoration(
                hintText: 'Share your experience...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final review = ReviewModel(
                id: const Uuid().v4(),
                listingId: listingId,
                userId: auth.firebaseUser?.uid ?? 'unknown',
                userName: auth.userProfile?.displayName ?? 'Anonymous',
                rating: rating,
                comment: commentCtrl.text.trim(),
                timestamp: DateTime.now(),
              );

              // Use the dialog context for navigation
              final success = await interaction.addReview(review);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                if (success) {
                  // Refresh the rating after adding a review
                  await interaction.refreshRating(listingId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Review added successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            interaction.errorMessage ?? 'Failed to add review'),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final interaction = context.watch<InteractionProvider>();
    final reviews = interaction.currentReviews;
    final averageRating = interaction.getAverageRating(listingId);
    final reviewCount = interaction.getReviewCount(listingId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(listingName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReviewDialog(context),
        label: const Text('Write a Review'),
        icon: const Icon(Icons.edit_note),
      ),
      body: Column(
        children: [
          // Average Rating Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text('Average Rating',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      5,
                      (i) => Icon(Icons.star,
                          color: i < averageRating.round()
                              ? Colors.amber
                              : Colors.grey[300])),
                ),
                const SizedBox(height: 4),
                Text(
                    reviewCount > 0
                        ? '${averageRating.toStringAsFixed(1)} / $reviewCount reviews'
                        : 'No reviews yet',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          const Divider(height: 1),

          // Reviews List
          Expanded(
            child: reviews.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rate_review_outlined,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text('No reviews yet',
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        const Text('Be the first to review!',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: reviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(review.userName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(
                                '${review.timestamp.day}/${review.timestamp.month}/${review.timestamp.year}',
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(
                                5,
                                (i) => Icon(Icons.star,
                                    size: 14,
                                    color: i < review.rating
                                        ? Colors.amber
                                        : Colors.grey[300])),
                          ),
                          const SizedBox(height: 8),
                          Text(
                              review.comment.isNotEmpty
                                  ? review.comment
                                  : 'No comment',
                              style: TextStyle(
                                  color: Colors.grey[800], height: 1.4)),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
