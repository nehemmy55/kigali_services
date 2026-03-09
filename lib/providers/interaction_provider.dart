import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/interaction_models.dart';
import '../services/firestore_service.dart';

class InteractionProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();

  List<ReviewModel> _currentReviews = [];
  List<BookmarkModel> _userBookmarks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Rating cache
  final Map<String, double> _ratingCache = {};
  final Map<String, int> _reviewCountCache = {};

  List<ReviewModel> get currentReviews => _currentReviews;
  List<BookmarkModel> get userBookmarks => _userBookmarks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get average ratings map for all listings
  Map<String, double> get ratings => _ratingCache;

  /// Get review counts map for all listings
  Map<String, int> get reviewCounts => _reviewCountCache;

  /// Get average rating for a listing from cache
  double getAverageRating(String listingId) {
    return _ratingCache[listingId] ?? 0.0;
  }

  /// Get review count for a listing from cache
  int getReviewCount(String listingId) {
    return _reviewCountCache[listingId] ?? 0;
  }

  /// Check if a listing is bookmarked
  bool isBookmarked(String listingId) {
    return _userBookmarks.any((b) => b.listingId == listingId);
  }

  StreamSubscription? _reviewSub;
  StreamSubscription? _bookmarkSub;

  void subscribeToReviews(String listingId) {
    _reviewSub?.cancel();
    _reviewSub = _db.getListingReviews(listingId).listen((reviews) {
      _currentReviews = reviews;
      notifyListeners();
    });
  }

  void subscribeToBookmarks(String userId) {
    _bookmarkSub?.cancel();
    _bookmarkSub = _db.getUserBookmarks(userId).listen((bookmarks) {
      _userBookmarks = bookmarks;
      notifyListeners();
    });
  }

  /// Refresh bookmarks from Firestore
  Future<void> refreshBookmarks(String userId) async {
    try {
      final bookmarks = await _db.getUserBookmarks(userId).first;
      _userBookmarks = bookmarks;
      notifyListeners();
    } catch (e) {
      // Ignore errors
    }
  }

  Future<bool> addReview(ReviewModel review) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _db.addReview(review);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleBookmark(String userId, String listingId) async {
    try {
      final existing =
          _userBookmarks.where((b) => b.listingId == listingId).toList();
      if (existing.isNotEmpty) {
        await _db.removeBookmark(existing.first.id);
        // Remove from local list immediately
        _userBookmarks.removeWhere((b) => b.id == existing.first.id);
      } else {
        final bookmark = BookmarkModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          listingId: listingId,
          timestamp: DateTime.now(),
        );
        await _db.addBookmark(bookmark);
        // Add to local list immediately
        _userBookmarks.add(bookmark);
      }
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Load ratings for a list of listing IDs (called on app start)
  Future<void> loadRatingsForListings(List<String> listingIds) async {
    for (final listingId in listingIds) {
      if (!_ratingCache.containsKey(listingId)) {
        final rating = await _db.getAverageRating(listingId);
        final count = await _db.getReviewCount(listingId);
        _ratingCache[listingId] = rating;
        _reviewCountCache[listingId] = count;
      }
    }
    notifyListeners();
  }

  /// Refresh rating for a specific listing (called after adding a review)
  Future<void> refreshRating(String listingId) async {
    final rating = await _db.getAverageRating(listingId);
    final count = await _db.getReviewCount(listingId);
    _ratingCache[listingId] = rating;
    _reviewCountCache[listingId] = count;
    notifyListeners();
  }

  @override
  void dispose() {
    _reviewSub?.cancel();
    _bookmarkSub?.cancel();
    super.dispose();
  }
}
