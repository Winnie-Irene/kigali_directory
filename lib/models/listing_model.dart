import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String createdByUsername;
  final DateTime timestamp;
  final double avgRating;
  final int reviewCount;
  final int favouriteCount;

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
    this.createdByUsername = '',
    required this.timestamp,
    this.avgRating = 0.0,
    this.reviewCount = 0,
    this.favouriteCount = 0,
  });

  factory ListingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ListingModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      address: data['address'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      createdBy: data['createdBy'] ?? '',
      createdByUsername: data['createdByUsername'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      avgRating: (data['avgRating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      favouriteCount: data['favouriteCount'] ?? 0,
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
      'createdByUsername': createdByUsername,
      'timestamp': Timestamp.fromDate(timestamp),
      'avgRating': avgRating,
      'reviewCount': reviewCount,
      'favouriteCount': favouriteCount,
    };
  }
}