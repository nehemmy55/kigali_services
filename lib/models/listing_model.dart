import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class ListingModel {
  final String id;
  final String name;
  final String category;
  final String address;
  final String contactNumber;
  final String description;
  final double latitude;
  final double longitude;
  final String createdBy;
  final DateTime timestamp;

  // Distance from user (calculated locally, not stored in Firestore)
  double? distanceKm;

  ListingModel({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contactNumber,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.timestamp,
    this.distanceKm,
  });

  /// Get LatLng location
  LatLng get location => LatLng(latitude, longitude);

  /// Calculate distance from user location
  void calculateDistance(LatLng? userLocation) {
    if (userLocation == null) {
      distanceKm = null;
      return;
    }
    const Distance distance = Distance();
    distanceKm = distance.as(
      LengthUnit.Kilometer,
      userLocation,
      location,
    );
  }

  factory ListingModel.fromMap(Map<String, dynamic> map, String docId) {
    return ListingModel(
      id: docId,
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? '',
      address: map['address'] as String? ?? '',
      contactNumber: map['contactNumber'] as String? ?? '',
      description: map['description'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      createdBy: map['createdBy'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'contactNumber': contactNumber,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  ListingModel copyWith({
    String? id,
    String? name,
    String? category,
    String? address,
    String? contactNumber,
    String? description,
    double? latitude,
    double? longitude,
    String? createdBy,
    DateTime? timestamp,
    double? distanceKm,
  }) {
    return ListingModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdBy: createdBy ?? this.createdBy,
      timestamp: timestamp ?? this.timestamp,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}

/// Canonical category constants used across the whole app.
class ListingCategory {
  static const String hospital = 'Hospital';
  static const String policeStation = 'Police Station';
  static const String library = 'Library';
  static const String utilityOffice = 'Utility Office';
  static const String restaurant = 'Restaurant';
  static const String cafe = 'Café';
  static const String park = 'Park';
  static const String touristAttraction = 'Tourist Attraction';
  static const String governmentOffice = 'Government Office';
  static const String pharmacy = 'Pharmacy';
  static const String school = 'School';
  // Additional Kigali-specific services
  static const String bank = 'Bank';
  static const String atm = 'ATM';
  static const String supermarket = 'Supermarket';
  static const String market = 'Market';
  static const String gym = 'Gym/Fitness';
  static const String spa = 'Spa/Wellness';
  static const String carWash = 'Car Wash';
  static const String petrolStation = 'Petrol Station';
  static const String hospitalClinic = 'Clinic';
  static const String church = 'Church';
  static const String mosque = 'Mosque';

  static const List<String> all = [
    hospital,
    hospitalClinic,
    pharmacy,
    policeStation,
    bank,
    atm,
    library,
    utilityOffice,
    restaurant,
    cafe,
    supermarket,
    market,
    park,
    touristAttraction,
    governmentOffice,
    school,
    gym,
    spa,
    carWash,
    petrolStation,
    church,
    mosque,
  ];

  /// Same as [all] but exposed as a method for easy access
  static List<String> get categories => all;

  /// Get category icon
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case hospital:
      case hospitalClinic:
      case pharmacy:
        return Icons.local_hospital_outlined;
      case policeStation:
        return Icons.local_police_outlined;
      case bank:
      case atm:
        return Icons.account_balance_outlined;
      case library:
        return Icons.library_books_outlined;
      case utilityOffice:
        return Icons.precision_manufacturing_outlined;
      case restaurant:
        return Icons.restaurant_outlined;
      case cafe:
        return Icons.local_cafe_outlined;
      case supermarket:
      case market:
        return Icons.shopping_cart_outlined;
      case park:
        return Icons.park_outlined;
      case touristAttraction:
        return Icons.landscape_outlined;
      case governmentOffice:
        return Icons.domain_outlined;
      case school:
        return Icons.school_outlined;
      case gym:
        return Icons.fitness_center_outlined;
      case spa:
        return Icons.spa_outlined;
      case carWash:
        return Icons.local_car_wash_outlined;
      case petrolStation:
        return Icons.local_gas_station_outlined;
      case church:
      case mosque:
        return Icons.place_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  /// Get category color
  static Color getCategoryColor(String category) {
    switch (category) {
      case hospital:
      case hospitalClinic:
      case pharmacy:
        return Colors.red;
      case policeStation:
        return Colors.blue;
      case bank:
      case atm:
        return Colors.purple;
      case library:
        return Colors.indigo;
      case utilityOffice:
        return Colors.teal;
      case restaurant:
      case cafe:
        return Colors.orange;
      case supermarket:
      case market:
        return Colors.amber;
      case park:
      case touristAttraction:
        return Colors.green;
      case governmentOffice:
        return Colors.blueGrey;
      case school:
        return Colors.brown;
      case gym:
      case spa:
        return Colors.pink;
      case carWash:
        return Colors.cyan;
      case petrolStation:
        return Colors.redAccent;
      case church:
      case mosque:
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }
}
