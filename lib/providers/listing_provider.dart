import 'package:flutter/material.dart';
import '../services/listing_service.dart';
import '../models/listing_model.dart';

class ListingProvider extends ChangeNotifier {
  final ListingService _listingService = ListingService();

  List<ListingModel> _allListings = [];
  List<ListingModel> _userListings = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<ListingModel> get allListings => _filteredListings();
  List<ListingModel> get userListings => _userListings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  List<ListingModel> get allListingsRaw => _allListings;

  List<ListingModel> _filteredListings() {
    return _allListings.where((listing) {
      final matchesSearch = listing.name
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' ||
          listing.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void listenToAllListings() {
    _isLoading = true;
    notifyListeners();

    _listingService.getAllListings().listen((listings) {
      _allListings = listings;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  void listenToUserListings(String uid) {
    _listingService.getUserListings(uid).listen((listings) {
      _userListings = listings;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      notifyListeners();
    });
  }

  Future<bool> createListing(ListingModel listing) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _listingService.createListing(listing);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateListing(String id, ListingModel listing) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _listingService.updateListing(id, listing);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteListing(String id) async {
    try {
      await _listingService.deleteListing(id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    notifyListeners();
  }
}