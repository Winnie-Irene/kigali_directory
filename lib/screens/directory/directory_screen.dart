import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/listing_card.dart';
import '../../utils/constants.dart';
import '../directory/listing_detail_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().firebaseUser?.uid ?? '';
      context.read<ListingProvider>().listenToAllListings();
      context.read<ListingProvider>().listenToUserListings(uid);
      context.read<ListingProvider>().listenToFavourites(uid);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingProvider = context.watch<ListingProvider>();
    final authProvider = context.watch<AuthProvider>();
    final profile = authProvider.userProfile;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${profile?.displayName.split(' ').first ?? 'there'} 👋',
                            style: const TextStyle(color: Color(0xFF8892B0), fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Kigali Directory',
                            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4ECDC4), Color(0xFF0F3460)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            (profile?.displayName.isNotEmpty == true) ? profile!.displayName[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF1F2937)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) => listingProvider.setSearchQuery(value),
                      decoration: InputDecoration(
                        hintText: 'Search listings, places...',
                        hintStyle: const TextStyle(color: Color(0xFF4A5568)),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF8892B0), size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Color(0xFF8892B0), size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  listingProvider.setSearchQuery('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: kCategories.length,
                itemBuilder: (context, index) {
                  final category = kCategories[index];
                  final isSelected = listingProvider.selectedCategory == category;
                  return GestureDetector(
                    onTap: () => listingProvider.setCategory(category),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4ECDC4) : const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF4ECDC4) : const Color(0xFF1F2937),
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF0D0D1A) : const Color(0xFF8892B0),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${listingProvider.allListings.length} result${listingProvider.allListings.length == 1 ? '' : 's'}',
                    style: const TextStyle(color: Color(0xFF8892B0), fontSize: 13),
                  ),
                  if (listingProvider.searchQuery.isNotEmpty || listingProvider.selectedCategory != 'All')
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        listingProvider.clearFilters();
                      },
                      child: const Text('Clear filters', style: TextStyle(color: Color(0xFF4ECDC4), fontSize: 13)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: listingProvider.isLoading
                  ? _buildShimmer()
                  : listingProvider.allListings.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: const Color(0xFF4ECDC4),
                          backgroundColor: const Color(0xFF111827),
                          onRefresh: () async {
                            await Future.delayed(const Duration(seconds: 1));
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: listingProvider.allListings.length,
                            itemBuilder: (context, index) {
                              final listing = listingProvider.allListings[index];
                              return ListingCard(
                                listing: listing,
                                onTap: () => Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => ListingDetailScreen(listing: listing),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
                                    transitionDuration: const Duration(milliseconds: 300),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 88,
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(14))),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 160, decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(7))),
                  const SizedBox(height: 8),
                  Container(height: 10, width: 100, decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(5))),
                  const SizedBox(height: 6),
                  Container(height: 10, width: 130, decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(5))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: const Icon(Icons.search_off, color: Color(0xFF8892B0), size: 36),
          ),
          const SizedBox(height: 16),
          const Text('No listings found', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Try a different search or category', style: TextStyle(color: Color(0xFF8892B0), fontSize: 14)),
        ],
      ),
    );
  }
}