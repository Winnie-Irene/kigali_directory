import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUp(String email, String password, String displayName, String username) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user!.updateDisplayName(displayName);
    await Future.delayed(const Duration(seconds: 1));
    await credential.user!.sendEmailVerification();

    try {
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'displayName': displayName,
        'username': username,
        'bio': '',
        'notificationsEnabled': false,
        'totalListings': 0,
        'joinedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      
      debugPrint('Firestore profile save failed: $e');
    }

    return credential;
  }

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> deleteAccount(String password) async {
    final user = _auth.currentUser!;
    final credential = EmailAuthProvider.credential(email: user.email!, password: password);
    await user.reauthenticateWithCredential(credential);
    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
  }

  Future<void> updateProfile(String uid, String displayName, String username, String bio) async {
    await _firestore.collection('users').doc(uid).update({
      'displayName': displayName,
      'username': username,
      'bio': bio,
    });
    await _auth.currentUser!.updateDisplayName(displayName);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser!;
    final credential = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) return UserModel.fromMap(doc.data()!, uid);
    return null;
  }

  Future<void> updateNotificationPreference(String uid, bool value) async {
    await _firestore.collection('users').doc(uid).update({'notificationsEnabled': value});
  }
}