import '../models/listing_model.dart';
import '../services/firestore_service.dart';

// mediates between the state layer and the service layer.

class ListingRepository {
  final FirestoreService _service;

  ListingRepository({FirestoreService? service})
      : _service = service ?? FirestoreService();

  Stream<List<ListingModel>> getAllListings() {
    return _service.getAllListings();
  }

  Stream<List<ListingModel>> getUserListings(String uid) {
    return _service.getUserListings(uid);
  }

  Future<String> createListing(ListingModel listing) async {
    try {
      return await _service.createListing(listing);
    } catch (e) {
      throw _mapError(e, 'creating the listing');
    }
  }

  Future<void> updateListing(ListingModel listing) async {
    try {
      await _service.updateListing(listing.id, listing);
    } catch (e) {
      throw _mapError(e, 'updating the listing');
    }
  }

  Future<void> deleteListing(String id) async {
    try {
      await _service.deleteListing(id);
    } catch (e) {
      throw _mapError(e, 'deleting the listing');
    }
  }

  String _mapError(Object e, String action) {
    return 'An error occurred while $action. Please try again. ($e)';
  }
}
