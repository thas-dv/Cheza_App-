import 'package:flutter/material.dart';

class HeroPlaceCard extends StatelessWidget {
  final String placeName;
  final String? imageUrl;
  final bool isOpen;
  final String adminName;

  const HeroPlaceCard({
    super.key,
    required this.placeName,
    this.imageUrl,
    required this.isOpen,
    required this.adminName,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 7,
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(imageUrl!, fit: BoxFit.cover)
                : Container(color: const Color(0xFF1E293B)),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.75),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: 24,
            right: 24,
            bottom: 22,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      placeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Connecté: $adminName',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isOpen ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isOpen ? 'OUVERT' : 'FERMÉ',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // const SizedBox(height: 20),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     _buildStat("Visiteurs", visitors.toString()),
                //     _buildStat("Posts", posts.toString()),
                //     _buildStat("Notes", notes.toString()),
                //     _buildStat("Engagement", "$engagement%"),
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
