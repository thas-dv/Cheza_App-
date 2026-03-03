import 'package:flutter/material.dart';

class HeroPlaceCard extends StatelessWidget {
  final String placeName;
  final String? imageUrl;
  final bool isOpen;
  final String adminName;
  final int visitors;
  final int posts;
  final int notes;
  final int engagement;
  final bool isStatusUpdating;
  final VoidCallback onToggleStatus;
  const HeroPlaceCard({
    super.key,
    required this.placeName,
    this.imageUrl,
    required this.isOpen,
    required this.adminName,
    required this.visitors,
    required this.posts,
    required this.notes,
    required this.engagement,
    required this.isStatusUpdating,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
      final isMobile = MediaQuery.of(context).size.width < 700;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: isMobile ? 16 / 11 : 16 / 7,
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF1E293B),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        size: 44,
                        color: Colors.white70,
                      ),
                    ),
                  )
                : Container(
                    color: const Color(0xFF1E293B),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_outlined,
                      size: 44,
                      color: Colors.white70,
                    ),
                  ),
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
            top: 16,
            right: 16,
            child: FilledButton.tonalIcon(
              onPressed: isStatusUpdating ? null : onToggleStatus,
              icon: isStatusUpdating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      isOpen ? Icons.lock_outline : Icons.lock_open_outlined,
                    ),
              style: FilledButton.styleFrom(
                backgroundColor: isOpen
                    ? Colors.red.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
                side: BorderSide(
                  color: isOpen
                      ? Colors.red.withOpacity(0.5)
                      : Colors.green.withOpacity(0.5),
                ),
              ),
              label: Text(
                isOpen ? 'Fermer' : 'Ouvrir',
                style: TextStyle(
                  color: isOpen ? Colors.redAccent : Colors.greenAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  placeName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 22 : 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Connecté: $adminName',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _StatBadge(label: 'Visiteurs', value: visitors.toString()),
                    _StatBadge(label: 'Posts', value: posts.toString()),
                    _StatBadge(label: 'Notes', value: notes.toString()),
                    _StatBadge(label: 'Engagement', value: '$engagement%'),
                    _StatBadge(
                      label: 'Statut',
                      value: isOpen ? 'Ouvert' : 'Fermé',
                      color: isOpen
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                    ),
                  ],
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
class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatBadge({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color ?? Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.white, fontSize: 12),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(color: Colors.white70)),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}