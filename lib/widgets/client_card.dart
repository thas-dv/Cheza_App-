import 'package:flutter/material.dart';

class ClientCard extends StatelessWidget {
  final String username;
  final String? avatarUrl;
  final String userId;
  final int attendeeId;
  final int posts;
  final int invites;
  final VoidCallback onTap;

  const ClientCard({
    super.key,
    required this.username,
    this.avatarUrl,
    required this.userId,
    required this.attendeeId,
    required this.posts,
    required this.invites,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ───────── AVATAR ─────────
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.deepPurple,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: avatarUrl == null
                  ? Text(
                      username.isNotEmpty ? username[0].toUpperCase() : "?",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 14),

            // ───────── INFOS CLIENT ─────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom
                  Text(
                    username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Stats
                  Row(
                    children: [
                      _statChip(
                        icon: Icons.photo,
                        label: "Posts",
                        value: posts,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 8),
                      _statChip(
                        icon: Icons.send,
                        label: "Invites",
                        value: invites,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ───────── CHEVRON ─────────
            const Icon(Icons.chevron_right, color: Colors.grey, size: 26),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // PETIT CHIP STAT (POSTS / INVITES)
  // ---------------------------------------------------
  Widget _statChip({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            "$label: $value",
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
