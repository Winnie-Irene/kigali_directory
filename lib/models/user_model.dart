class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final bool notificationsEnabled;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.notificationsEnabled = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      notificationsEnabled: data['notificationsEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'notificationsEnabled': notificationsEnabled,
    };
  }
}