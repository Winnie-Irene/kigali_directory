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

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kigali Directory',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Find services and places in Kigali',
                    style: TextStyle(color: Color(0xFF8892B0), fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) => listingProvider.setSearchQuery(value),
                    decoration: InputDecoration(
                      hintText: 'Search by name...',
                      hintStyle: const TextStyle(color: Color(0xFF8892B0)),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF8892B0)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Color(0xFF8892B0)),
                              onPressed: () {
                                _searchController.clear();
                                listingProvider.setSearchQuery('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFF0F3460),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: kCategories.length,
                itemBuilder: (context, index) {
                  final category = kCategories[index];
                  final isSelected = listingProvider.selectedCategory == category;
                  return GestureDetector(
                    onTap: () => listingProvider.setCategory(category),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4ECDC4) : const Color(0xFF0F3460),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF1A1A2E) : const Color(0xFF8892B0),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: listingProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF4ECDC4)))
                  : listingProvider.allListings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, color: Color(0xFF8892B0), size: 60),
                              const SizedBox(height: 16),
                              const Text(
                                'No listings found',
                                style: TextStyle(color: Color(0xFF8892B0), fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: listingProvider.allListings.length,
                          itemBuilder: (context, index) {
                            final listing = listingProvider.allListings[index];
                            return ListingCard(
                              listing: listing,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ListingDetailScreen(listing: listing),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}