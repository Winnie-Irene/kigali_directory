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

  Future<bool> signUp(String email, String password, String displayName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signUp(email, password, displayName);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
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
      _errorMessage = e.message;
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