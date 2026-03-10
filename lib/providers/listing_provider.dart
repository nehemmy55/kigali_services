import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/listing_model.dart';
import '../repositories/listing_repository.dart';

class ListingProvider extends ChangeNotifier {
  final ListingRepository _repository;

  // All listings from Firestore
  List<ListingModel> _allListings = [];
  List<ListingModel> _myListings = [];

  // User location
  LatLng? _userLocation;
  bool _isLoadingLocation = false;

  bool _isLoading = false;
  String? _errorMessage;

  // Search & filter state
  String _searchQuery = '';
  String? _selectedCategory;

  StreamSubscription<List<ListingModel>>? _allListingsSubscription;
  StreamSubscription<List<ListingModel>>? _myListingsSubscription;

  ListingProvider({ListingRepository? repository})
      : _repository = repository ?? ListingRepository();

  // Getters

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  LatLng? get userLocation => _userLocation;
  bool get isLoadingLocation => _isLoadingLocation;

  List<ListingModel> get allListings => _allListings;
  List<ListingModel> get myListings => _myListings;

  //Get listings sorted by distance
  List<ListingModel> get nearestListings {
    _updateDistances();

    // Sort by distance
    final sorted = List<ListingModel>.from(_allListings);
    sorted.sort((a, b) {
      if (a.distanceKm == null && b.distanceKm == null) return 0;
      if (a.distanceKm == null) return 1;
      if (b.distanceKm == null) return -1;
      return a.distanceKm!.compareTo(b.distanceKm!);
    });
    return sorted;
  }

  /// Filtered listings for the Directory screen.
  List<ListingModel> get filteredListings {
    _updateDistances();

    return _allListings.where((l) {
      final matchesSearch = _searchQuery.isEmpty ||
          l.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.address.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == null || l.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Get nearest listings (sorted by distance)
  List<ListingModel> get filteredNearestListings {
    final filtered = filteredListings;
    filtered.sort((a, b) {
      if (a.distanceKm == null && b.distanceKm == null) return 0;
      if (a.distanceKm == null) return 1;
      if (b.distanceKm == null) return -1;
      return a.distanceKm!.compareTo(b.distanceKm!);
    });
    return filtered;
  }

  void _updateDistances() {
    for (var listing in _allListings) {
      listing.calculateDistance(_userLocation);
    }
  }

  // Set user location and recalculate distances
  void setUserLocation(LatLng? location) {
    _userLocation = location;
    _updateDistances();
    notifyListeners();
  }

  // Set loading state for location
  void setLoadingLocation(bool loading) {
    _isLoadingLocation = loading;
    notifyListeners();
  }

  // Start listening to all listings. Call once on app startup.
  void subscribeAllListings() {
    _allListingsSubscription?.cancel();
    _allListingsSubscription = _repository.getAllListings().listen(
      (listings) {
        _allListings = listings;

        _updateDistances();
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  // Start listening to a specific user's listings.
  void subscribeMyListings(String uid) {
    _myListingsSubscription?.cancel();
    _myListingsSubscription = _repository.getUserListings(uid).listen(
      (listings) {
        _myListings = listings;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  void unsubscribeMyListings() {
    _myListingsSubscription?.cancel();
    _myListings = [];
  }

  // Search & Filter

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category == _selectedCategory ? null : category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  // CRUD

  Future<bool> addListing(ListingModel listing) async {
    _setLoading(true);
    try {
      await _repository.createListing(listing);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateListing(ListingModel listing) async {
    _setLoading(true);
    try {
      await _repository.updateListing(listing);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> removeListing(String id) async {
    _setLoading(true);
    try {
      await _repository.deleteListing(id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _allListingsSubscription?.cancel();
    _myListingsSubscription?.cancel();
    super.dispose();
  }
}
