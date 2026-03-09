import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String username;
  final String bio;
  final bool notificationsEnabled;
  final int totalListings;
  final DateTime? joinedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.username = '',
    this.bio = '',
    this.notificationsEnabled = false,
    this.totalListings = 0,
    this.joinedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      username: data['username'] ?? '',
      bio: data['bio'] ?? '',
      notificationsEnabled: data['notificationsEnabled'] ?? false,
      totalListings: data['totalListings'] ?? 0,
      joinedAt: data['joinedAt'] != null
          ? (data['joinedAt'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'username': username,
      'bio': bio,
      'notificationsEnabled': notificationsEnabled,
      'totalListings': totalListings,
      'joinedAt': joinedAt != null ? Timestamp.fromDate(joinedAt!) : FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? displayName,
    String? username,
    String? bio,
    bool? notificationsEnabled,
    int? totalListings,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      totalListings: totalListings ?? this.totalListings,
      joinedAt: joinedAt,
    );
  }
}