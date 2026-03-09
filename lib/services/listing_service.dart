import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';
import '../models/review_model.dart';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ListingModel>> getAllListings() {
    return _firestore
        .collection('listings')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ListingModel.fromFirestore(d)).toList());
  }

  Stream<List<ListingModel>> getUserListings(String uid) {
    return _firestore
        .collection('listings')
        .where('createdBy', isEqualTo: uid)
        .snapshots()
        .map((s) {
          final listings = s.docs.map((d) => ListingModel.fromFirestore(d)).toList();
          
          listings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return listings;
        });
  }

  Future<void> createListing(ListingModel listing) async {
    await _firestore.collection('listings').add(listing.toMap());
  }

  Future<void> updateListing(String id, ListingModel listing) async {
    await _firestore.collection('listings').doc(id).update(listing.toMap());
  }

  Future<void> deleteListing(String id) async {
    await _firestore.collection('listings').doc(id).delete();
  }

  Stream<List<ReviewModel>> getReviews(String listingId) {
    return _firestore
        .collection('reviews')
        .where('listingId', isEqualTo: listingId)
        .snapshots()
        .map((s) {
          final reviews = s.docs.map((d) => ReviewModel.fromFirestore(d)).toList();
          
          reviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return reviews;
        });
  }

  Future<void> addReview(ReviewModel review) async {
    final batch = _firestore.batch();
    final reviewRef = _firestore.collection('reviews').doc();
    batch.set(reviewRef, review.toMap());

    final listingRef = _firestore.collection('listings').doc(review.listingId);
    final listingSnap = await listingRef.get();
    final data = listingSnap.data()!;
    final currentCount = (data['reviewCount'] ?? 0) as int;
    final currentAvg = (data['avgRating'] ?? 0.0) as double;
    final newCount = currentCount + 1;
    final newAvg = ((currentAvg * currentCount) + review.rating) / newCount;

    batch.update(listingRef, {'avgRating': newAvg, 'reviewCount': newCount});
    await batch.commit();
  }

  Future<bool> isFavourited(String userId, String listingId) async {
    final doc = await _firestore
        .collection('favourites')
        .doc('${userId}_$listingId')
        .get();
    return doc.exists;
  }

  Future<void> toggleFavourite(String userId, String listingId) async {
    final docRef = _firestore.collection('favourites').doc('${userId}_$listingId');
    final listingRef = _firestore.collection('listings').doc(listingId);
    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.delete();
      await listingRef.update({'favouriteCount': FieldValue.increment(-1)});
    } else {
      await docRef.set({
        'userId': userId,
        'listingId': listingId,
        'timestamp': Timestamp.now(),
      });
      await listingRef.update({'favouriteCount': FieldValue.increment(1)});
    }
  }

  Stream<List<ListingModel>> getFavouriteListings(String userId) {
    return _firestore
        .collection('favourites')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final ids = snapshot.docs.map((d) => d.data()['listingId'] as String).toList();
      if (ids.isEmpty) return [];
      final listings = await Future.wait(
        ids.map((id) => _firestore.collection('listings').doc(id).get()),
      );
      return listings
          .where((d) => d.exists)
          .map((d) => ListingModel.fromFirestore(d))
          .toList();
    });
  }
}