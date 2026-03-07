import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../models/review_model.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class ListingDetailScreen extends StatefulWidget {
  final ListingModel listing;
  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  bool _isFavourited = false;
  double _userRating = 0;

  @override
  void initState() {
    super.initState();
    _checkFavourite();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingProvider>().addToRecentlyViewed(widget.listing);
    });
  }

  Future<void> _checkFavourite() async {
    final uid = context.read<AuthProvider>().firebaseUser?.uid ?? '';
    final result = await context.read<ListingProvider>().isFavourited(uid, widget.listing.id);
    if (mounted) setState(() => _isFavourited = result);
  }

  Future<void> _toggleFavourite() async {
    final uid = context.read<AuthProvider>().firebaseUser?.uid ?? '';
    await context.read<ListingProvider>().toggleFavourite(uid, widget.listing.id);
    setState(() => _isFavourited = !_isFavourited);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavourited ? 'Added to saved places' : 'Removed from saved places'),
          backgroundColor: _isFavourited ? const Color(0xFF4ECDC4) : const Color(0xFF8892B0),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareListing() {
    Share.share(
      '📍 ${widget.listing.name}\n'
      '📂 ${widget.listing.category}\n'
      '📍 ${widget.listing.address}\n'
      '📞 ${widget.listing.contactNumber}\n\n'
      '${widget.listing.description}\n\n'
      'Get directions: https://www.google.com/maps?q=${widget.listing.latitude},${widget.listing.longitude}',
      subject: widget.listing.name,
    );
  }

  Future<void> _launchNavigation() async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${widget.listing.latitude},${widget.listing.longitude}');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchPhone() async {
    final uri = Uri.parse('tel:${widget.listing.contactNumber}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _showReviewSheet() {
    final commentController = TextEditingController();
    double selectedRating = _userRating;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Write a Review', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setSheetState(() => selectedRating = i + 1.0),
                  child: Icon(
                    i < selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: const Color(0xFFFFE66D),
                    size: 40,
                  ),
                )),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  hintStyle: const TextStyle(color: Color(0xFF4A5568)),
                  filled: true,
                  fillColor: const Color(0xFF0D0D1A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1F2937))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1F2937))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4ECDC4))),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedRating == 0) return;
                    final authProvider = context.read<AuthProvider>();
                    final review = ReviewModel(
                      id: '',
                      listingId: widget.listing.id,
                      userId: authProvider.firebaseUser!.uid,
                      username: authProvider.userProfile?.username.isNotEmpty == true
                          ? '@${authProvider.userProfile!.username}'
                          : authProvider.userProfile?.displayName ?? 'Anonymous',
                      rating: selectedRating,
                      comment: commentController.text.trim(),
                      timestamp: DateTime.now(),
                    );
                    await context.read<ListingProvider>().addReview(review);
                    setState(() => _userRating = selectedRating);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryData = kCategoryIcons[widget.listing.category] ?? kCategoryIcons['Other']!;
    final color = Color(categoryData['color'] as int);
    final iconData = IconData(categoryData['icon'] as int, fontFamily: 'MaterialIcons');
    final listingProvider = context.watch<ListingProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF0F3460),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D1A).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: _toggleFavourite,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D1A).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isFavourited ? Icons.bookmark : Icons.bookmark_outline,
                    color: _isFavourited ? const Color(0xFF4ECDC4) : Colors.white,
                    size: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _shareListing,
                child: Container(
                  margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D1A).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(widget.listing.latitude, widget.listing.longitude),
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.kigali_directory',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point: LatLng(widget.listing.latitude, widget.listing.longitude),
                      width: 40, height: 40,
                      child: const Icon(Icons.location_pin, color: Color(0xFFFF6B6B), size: 40),
                    ),
                  ]),
                ],
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(iconData, color: color, size: 13),
                            const SizedBox(width: 5),
                            Text(widget.listing.category, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (widget.listing.reviewCount > 0) ...[
                        const Icon(Icons.star_rounded, color: Color(0xFFFFE66D), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          widget.listing.avgRating.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          ' (${widget.listing.reviewCount})',
                          style: const TextStyle(color: Color(0xFF8892B0), fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.listing.name,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (widget.listing.createdByUsername.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Added by @${widget.listing.createdByUsername}',
                      style: const TextStyle(color: Color(0xFF8892B0), fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.navigation_outlined,
                          label: 'Directions',
                          color: const Color(0xFF4ECDC4),
                          onTap: _launchNavigation,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.phone_outlined,
                          label: 'Call',
                          color: const Color(0xFF6BCB77),
                          onTap: _launchPhone,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.rate_review_outlined,
                          label: 'Review',
                          color: const Color(0xFFFFE66D),
                          onTap: _showReviewSheet,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard([
                    _buildInfoRow(Icons.location_on_outlined, widget.listing.address, const Color(0xFF4ECDC4)),
                    const Divider(color: Color(0xFF1F2937), height: 20),
                    _buildInfoRow(Icons.phone_outlined, widget.listing.contactNumber, const Color(0xFF6BCB77)),
                    const Divider(color: Color(0xFF1F2937), height: 20),
                    _buildInfoRow(
                      Icons.my_location,
                      '${widget.listing.latitude.toStringAsFixed(5)}, ${widget.listing.longitude.toStringAsFixed(5)}',
                      const Color(0xFF8892B0),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  const Text('About', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    widget.listing.description,
                    style: const TextStyle(color: Color(0xFF8892B0), fontSize: 14, height: 1.7),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Reviews', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: _showReviewSheet,
                        child: const Text('Write one', style: TextStyle(color: Color(0xFF4ECDC4), fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<ReviewModel>>(
                    stream: listingProvider.getReviews(widget.listing.id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF1F2937)),
                          ),
                          child: const Center(
                            child: Text('No reviews yet — be the first!', style: TextStyle(color: Color(0xFF8892B0))),
                          ),
                        );
                      }
                      return Column(
                        children: snapshot.data!.map((review) => _buildReviewCard(review)).toList(),
                      );
                    },
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

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF8892B0), fontSize: 14))),
      ],
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(review.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: const Color(0xFFFFE66D),
                  size: 14,
                )),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.comment, style: const TextStyle(color: Color(0xFF8892B0), fontSize: 13, height: 1.5)),
          ],
        ],
      ),
    );
  }
}