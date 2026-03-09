import 'package:cloud_firestore/cloud_firestore.dart';

/// Mock data service to populate initial listings for Kigali
class MockDataService {
  /// Get mock listings for Kigali
  static List<Map<String, dynamic>> getMockListings() {
    return [
      {
        'name': 'King Faisal Hospital',
        'category': 'Hospital',
        'address': 'KG 544 St, Kigali',
        'contactNumber': '+250 788 123 456',
        'description':
            'King Faisal Hospital is a leading referral hospital in Rwanda offering comprehensive medical services.',
        'latitude': -1.9536,
        'longitude': 29.8739,
        'createdBy': 'system',
        'timestamp': Timestamp.now(),
      },
      {
        'name': 'Kigali Police Station',
        'category': 'Police Station',
        'address': 'KN 5 Rd, Kigali',
        'contactNumber': '+250 788 999 111',
        'description':
            'Central police station providing security services and emergency response.',
        'latitude': -1.9439,
        'longitude': 30.0591,
        'createdBy': 'system',
        'timestamp': Timestamp.now(),
      },
      {
        'name': 'Kigali Public Library',
        'category': 'Library',
        'address': 'KN 3 Ave, Kigali',
        'contactNumber': '+250 788 222 333',
        'description':
            'Public library offering books, digital resources, and study spaces.',
        'latitude': -1.9537,
        'longitude': 30.0576,
        'createdBy': 'system',
        'timestamp': Timestamp.now(),
      },
      {
        'name': 'Heaven Restaurant',
        'category': 'Restaurant',
        'address': 'KG 7 Ave, Kigali',
        'contactNumber': '+250 788 444 555',
        'description':
            'Popular fine dining restaurant serving Rwandan and international cuisine.',
        'latitude': -1.9465,
        'longitude': 30.0526,
        'createdBy': 'system',
        'timestamp': Timestamp.now(),
      },
      {
        'name': 'Kigali Memorial Centre',
        'category': 'Tourist Attraction',
        'address': 'Gisozi Sector, Kigali',
        'contactNumber': '+250 788 666 777',
        'description':
            'A memorial and museum honoring the victims of the Rwandan genocide.',
        'latitude': -1.9697,
        'longitude': 30.0934,
        'createdBy': 'system',
        'timestamp': Timestamp.now(),
      },
    ];
  }

  /// Populate Firestore with mock data
  static Future<void> populateMockData(FirebaseFirestore db) async {
    final listingsRef = db.collection('listings');

    // Check if data already exists
    final existing = await listingsRef.limit(1).get();
    if (existing.docs.isNotEmpty) {
      return; // Data already exists
    }

    // Add mock listings
    final batch = db.batch();
    for (final data in getMockListings()) {
      final docRef = listingsRef.doc();
      batch.set(docRef, data);
    }

    await batch.commit();
  }
}
