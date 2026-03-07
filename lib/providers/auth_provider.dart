import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _firebaseUser;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _firebaseUser != null;
  bool get isEmailVerified => _firebaseUser?.emailVerified ?? false;

  AuthProvider() {
    _authService.authStateChanges.listen((user) async {
      _firebaseUser = user;
      if (user != null) {
        _userProfile = await _authService.getUserProfile(user.uid);
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
        return 'Incorrect email or password. Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  Future<bool> signUp(String email, String password, String displayName, String username) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.signUp(email, password, displayName, username);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.signIn(email, password);
      await _firebaseUser?.reload();
      _firebaseUser = _authService.currentUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _firebaseUser = null;
    _userProfile = null;
    notifyListeners();
  }

  Future<bool> updateProfile(String displayName, String username, String bio) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.updateProfile(_firebaseUser!.uid, displayName, username, bio);
      _userProfile = await _authService.getUserProfile(_firebaseUser!.uid);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.changePassword(currentPassword, newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount(String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.deleteAccount(password);
      _firebaseUser = null;
      _userProfile = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> reloadUser() async {
    await _firebaseUser?.reload();
    _firebaseUser = _authService.currentUser;
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    if (_firebaseUser == null) return;
    await _authService.updateNotificationPreference(_firebaseUser!.uid, value);
    _userProfile = await _authService.getUserProfile(_firebaseUser!.uid);
    notifyListeners();
  }
}