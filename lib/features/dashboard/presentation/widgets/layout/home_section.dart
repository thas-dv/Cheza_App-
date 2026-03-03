import 'package:cheza_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/hero_place_card.dart';
import 'package:cheza_app/widgets/stat_card.dart' show StatCard;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeSection extends ConsumerWidget {
  final String placeName;
  final String? imageUrl;
  final bool isOpen;

  const HomeSection({
    super.key,
    required this.placeName,
    required this.imageUrl,
    required this.isOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HERO
          HeroPlaceCard(
            placeName: placeName,
            imageUrl: imageUrl,
            visitors: stats?.visitors ?? 0,
            posts: stats?.posts ?? 0,
            notes: stats?.notes ?? 0,
            engagement: stats?.engagement ?? 0,
            onActionPressed: () => {},
          ),

          const SizedBox(height: 40),

          // BARRE STATISTIQUE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              "Statistique",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // GRID STATS
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.3,
            children: [
              StatCard(
                label: "Visiteurs",
                value: stats?.visitors ?? 0,
                icon: Icons.group,
                color: Colors.blue,
              ),
              StatCard(
                label: "Posts",
                value: stats?.posts ?? 0,
                icon: Icons.image,
                color: Colors.purple,
              ),
              StatCard(
                label: "Notes",
                value: stats?.notes ?? 0,
                icon: Icons.star,
                color: Colors.orange,
              ),
              StatCard(
                label: "Engagement",
                value: stats?.engagement ?? 0,
                icon: Icons.show_chart,
                color: Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 40),

          // INFORMATION DU LIEU
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Empire Lounge est un espace moderne situé à Conakry.",
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 30),
                Text(
                  "Coordonnées",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "📍 Conakry, Guinée\n📞 +224 xxx xxx xxx",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
