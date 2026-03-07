import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/listing_model.dart';
import '../../utils/constants.dart';

class ListingDetailScreen extends StatefulWidget {
  final ListingModel listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  GoogleMapController? _mapController;

  Set<Marker> get _markers => {
        Marker(
          markerId: MarkerId(widget.listing.id),
          position: LatLng(widget.listing.latitude, widget.listing.longitude),
          infoWindow: InfoWindow(title: widget.listing.name),
        ),
      };

  Future<void> _launchNavigation() async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${widget.listing.latitude},${widget.listing.longitude}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPhone() async {
    final uri = Uri.parse('tel:${widget.listing.contactNumber}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryData = kCategoryIcons[widget.listing.category] ?? kCategoryIcons['Other']!;
    final color = Color(categoryData['color'] as int);
    final iconData = IconData(categoryData['icon'] as int, fontFamily: 'MaterialIcons');

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF0F3460),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.listing.latitude, widget.listing.longitude),
                  zoom: 15,
                ),
                markers: _markers,
                onMapCreated: (controller) => _mapController = controller,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(iconData, color: color, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              widget.listing.category,
                              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.listing.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow(Icons.location_on_outlined, widget.listing.address, const Color(0xFF4ECDC4)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _launchPhone,
                    child: _buildInfoRow(Icons.phone_outlined, widget.listing.contactNumber, const Color(0xFF4ECDC4)),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'About',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.listing.description,
                    style: const TextStyle(color: Color(0xFF8892B0), fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow(
                    Icons.my_location,
                    '${widget.listing.latitude.toStringAsFixed(5)}, ${widget.listing.longitude.toStringAsFixed(5)}',
                    const Color(0xFF8892B0),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _launchNavigation,
                      icon: const Icon(Icons.navigation_outlined),
                      label: const Text(
                        'Get Directions',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ECDC4),
                        foregroundColor: const Color(0xFF1A1A2E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF8892B0), fontSize: 14),
          ),
        ),
      ],
    );
  }
}