import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../models/listing_model.dart';
import '../../utils/constants.dart';
import '../directory/listing_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  ListingModel? _selectedListing;

  static const LatLng _kigaliCenter = LatLng(-1.9441, 30.0619);

  List<Marker> _buildMarkers(List<ListingModel> listings) {
    return listings.map((listing) {
      final categoryData = kCategoryIcons[listing.category] ?? kCategoryIcons['Other']!;
      final color = Color(categoryData['color'] as int);

      return Marker(
        point: LatLng(listing.latitude, listing.longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => setState(() => _selectedListing = listing),
          child: Icon(
            Icons.location_pin,
            color: color,
            size: 40,
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final listingProvider = context.watch<ListingProvider>();
    final listings = listingProvider.allListingsRaw;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Map View',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'All listings in Kigali',
                        style: TextStyle(color: Color(0xFF8892B0), fontSize: 14),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3460),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF4ECDC4), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${listings.length} places',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: _kigaliCenter,
                        initialZoom: 13,
                        onTap: (_, __) => setState(() => _selectedListing = null),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.kigali_directory',
                        ),
                        MarkerLayer(
                          markers: _buildMarkers(listings),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedListing != null)
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ListingDetailScreen(listing: _selectedListing!),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F3460),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.location_on, color: Color(0xFF4ECDC4), size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedListing!.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _selectedListing!.category,
                                      style: const TextStyle(color: Color(0xFF4ECDC4), fontSize: 12),
                                    ),
                                    Text(
                                      _selectedListing!.address,
                                      style: const TextStyle(color: Color(0xFF8892B0), fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Color(0xFF8892B0)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}