import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../utils/constants.dart';

class ListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;

  const ListingCard({super.key, required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final categoryData = kCategoryIcons[listing.category] ?? kCategoryIcons['Other']!;
    final color = Color(categoryData['color'] as int);
    final iconData = IconData(categoryData['icon'] as int, fontFamily: 'MaterialIcons');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1F2937)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Icon(iconData, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.name,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(listing.category, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                        if (listing.reviewCount > 0) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.star_rounded, color: Color(0xFFFFE66D), size: 12),
                          const SizedBox(width: 2),
                          Text(
                            listing.avgRating.toStringAsFixed(1),
                            style: const TextStyle(color: Color(0xFFFFE66D), fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            ' (${listing.reviewCount})',
                            style: const TextStyle(color: Color(0xFF8892B0), fontSize: 10),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Color(0xFF8892B0), size: 12),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            listing.address,
                            style: const TextStyle(color: Color(0xFF8892B0), fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Color(0xFF4A5568), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}