import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';
import '../models/interaction_models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _listingsCollection = 'listings';

  // ---------------------------------------------------------------------------
  // Real-time streams
  // ---------------------------------------------------------------------------

  /// Stream of ALL listings ordered by timestamp descending.
  Stream<List<ListingModel>> getAllListings() {
    return _db
        .collection(_listingsCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ListingModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Stream of listings created by a specific user.
  Stream<List<ListingModel>> getUserListings(String uid) {
    return _db
        .collection(_listingsCollection)
        .where('createdBy', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ListingModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // ---------------------------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------------------------

  /// Create a new listing and return its generated ID.
  Future<String> createListing(ListingModel listing) async {
    final docRef =
        await _db.collection(_listingsCollection).add(listing.toMap());
    return docRef.id;
  }

  /// Update an existing listing identified by [id].
  Future<void> updateListing(String id, ListingModel listing) async {
    await _db.collection(_listingsCollection).doc(id).update(listing.toMap());
  }

  /// Delete a listing by [id].
  Future<void> deleteListing(String id) async {
    await _db.collection(_listingsCollection).doc(id).delete();
  }

  /// Fetch a single listing snapshot by [id].
  Future<ListingModel?> getListing(String id) async {
    final doc = await _db.collection(_listingsCollection).doc(id).get();
    if (!doc.exists) return null;
    return ListingModel.fromMap(doc.data()!, doc.id);
  }

  // ---------------------------------------------------------------------------
  // Reviews
  // ---------------------------------------------------------------------------

  /// Stream of reviews for a specific listing.
  Stream<List<ReviewModel>> getListingReviews(String listingId) {
    return _db
        .collection('reviews')
        .where('listingId', isEqualTo: listingId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ReviewModel.fromMap(d.data())).toList());
  }

  Future<void> addReview(ReviewModel review) async {
    await _db.collection('reviews').doc(review.id).set(review.toMap());
  }

  // ---------------------------------------------------------------------------
  // Bookmarks
  // ---------------------------------------------------------------------------

  /// Stream of bookmarks for a specific user.
  Stream<List<BookmarkModel>> getUserBookmarks(String userId) {
    return _db
        .collection('bookmarks')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
            (s) => s.docs.map((d) => BookmarkModel.fromMap(d.data())).toList());
  }

  Future<void> addBookmark(BookmarkModel bookmark) async {
    await _db.collection('bookmarks').doc(bookmark.id).set(bookmark.toMap());
  }

  Future<void> removeBookmark(String bookmarkId) async {
    await _db.collection('bookmarks').doc(bookmarkId).delete();
  }

  Future<bool> isBookmarked(String userId, String listingId) async {
    final s = await _db
        .collection('bookmarks')
        .where('userId', isEqualTo: userId)
        .where('listingId', isEqualTo: listingId)
        .limit(1)
        .get();
    return s.docs.isNotEmpty;
  }

  /// Calculate average rating for a listing based on its reviews.
  Future<double> getAverageRating(String listingId) async {
    final reviews = await _db
        .collection('reviews')
        .where('listingId', isEqualTo: listingId)
        .get();

    if (reviews.docs.isEmpty) return 0.0;

    double totalRating = 0;
    for (final doc in reviews.docs) {
      final rating = (doc.data()['rating'] as num?)?.toDouble() ?? 0.0;
      totalRating += rating;
    }

    return totalRating / reviews.docs.length;
  }

  /// Get the count of reviews for a listing.
  Future<int> getReviewCount(String listingId) async {
    final reviews = await _db
        .collection('reviews')
        .where('listingId', isEqualTo: listingId)
        .get();
    return reviews.docs.length;
  }
}
