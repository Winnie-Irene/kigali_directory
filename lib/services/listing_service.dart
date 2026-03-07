import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'listings';

  Stream<List<ListingModel>> getAllListings() {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ListingModel.fromFirestore(doc)).toList());
  }

  Stream<List<ListingModel>> getUserListings(String uid) {
    return _firestore
        .collection(_collection)
        .where('createdBy', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ListingModel.fromFirestore(doc)).toList());
  }

  Future<void> createListing(ListingModel listing) async {
    await _firestore.collection(_collection).add(listing.toMap());
  }

  Future<void> updateListing(String id, ListingModel listing) async {
    await _firestore.collection(_collection).doc(id).update(listing.toMap());
  }

  Future<void> deleteListing(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}