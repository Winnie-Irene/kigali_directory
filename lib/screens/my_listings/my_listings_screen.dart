import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/listing_card.dart';
import '../directory/listing_detail_screen.dart';
import 'listing_form_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listingProvider = context.watch<ListingProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Listings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${listingProvider.userListings.length} listing${listingProvider.userListings.length == 1 ? '' : 's'}',
                        style: const TextStyle(color: Color(0xFF8892B0), fontSize: 14),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ListingFormScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, color: Color(0xFF1A1A2E), size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Add New',
                            style: TextStyle(
                              color: Color(0xFF1A1A2E),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: listingProvider.userListings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F3460),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
                              Icons.add_location_alt_outlined,
                              color: Color(0xFF4ECDC4),
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No listings yet',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap "Add New" to create your first listing',
                            style: TextStyle(color: Color(0xFF8892B0), fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: listingProvider.userListings.length,
                      itemBuilder: (context, index) {
                        final listing = listingProvider.userListings[index];
                        return Stack(
                          children: [
                            ListingCard(
                              listing: listing,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ListingDetailScreen(listing: listing),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ListingFormScreen(listing: listing),
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1A1A2E),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.edit_outlined,
                                        color: Color(0xFF4ECDC4),
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () => _confirmDelete(context, listingProvider, listing.id),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1A1A2E),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline,
                                        color: Color(0xFFFF6B6B),
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ListingProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F3460),
        title: const Text('Delete Listing', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this listing? This cannot be undone.',
          style: TextStyle(color: Color(0xFF8892B0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8892B0))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteListing(id);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }
}