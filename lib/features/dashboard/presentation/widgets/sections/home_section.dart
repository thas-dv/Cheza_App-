import 'package:flutter/material.dart';

class HomeSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_heroCard(), const SizedBox(height: 30), _statsGrid()],
      ),
    );
  }

  // ================= HERO IMAGE =================
  Widget _heroCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          SizedBox(
            height: 160,
            width: double.infinity,
            child: imageUrl == null || imageUrl!.isEmpty
                ? Container(
                    color: const Color(0xFF1F2937),
                    child: const Icon(
                      Icons.place,
                      color: Colors.white,
                      size: 40,
                    ),
                  )
                : Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.place, size: 40),
                  ),
          ),

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),
          ),

          // Place Name
          Positioned(
            bottom: 20,
            left: 20,
            child: Text(
              placeName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATS GRID =================
  Widget _statsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1,
      children: const [
        _StatCard(
          icon: Icons.group,
          color: Colors.blue,
          value: 0,
          label: "Visiteurs",
        ),
        _StatCard(
          icon: Icons.image,
          color: Colors.purple,
          value: 0,
          label: "Posts",
        ),
        _StatCard(
          icon: Icons.star,
          color: Colors.orange,
          value: 0,
          label: "Notes",
        ),
        _StatCard(
          icon: Icons.show_chart,
          color: Colors.green,
          value: 0,
          label: "Engagement",
        ),
      ],
    );
  }
}

// ================= STAT CARD =================
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 15),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
