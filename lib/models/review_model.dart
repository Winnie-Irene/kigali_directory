import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String listingId;
  final String userId;
  final String username;
  final double rating;
  final String comment;
  final DateTime timestamp;

  ReviewModel({
    required this.id,
    required this.listingId,
    required this.userId,
    required this.username,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      listingId: data['listingId'] ?? '',
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'listingId': listingId,
      'userId': userId,
      'username': username,
      'rating': rating,
      'comment': comment,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}