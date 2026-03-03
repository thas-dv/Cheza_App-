import 'package:cheza_app/features/dashboard/presentation/widgets/hero_place_card.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/layout/dashboard_state.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/stats_row.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/tabs/dashboard_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:cheza_app/core/ui/responsive_layout.dart' show Breakpoints;
import 'package:cheza_app/widgets/stat_card.dart';
import 'package:flutter/material.dart';

class ModernHomeWidget extends StatelessWidget {
  final DashboardState state;
  const ModernHomeWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = Breakpoints.isMobile(constraints.maxWidth);
        return ListView(
          padding: EdgeInsets.all(isMobile ? 16 : 28),
          children: [
            HeroPlaceCard(
              placeName: state.placeName,
              imageUrl: state.placeImageUrl,
              isOpen: state.isOpen,
              adminName: state.adminName,
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: 'Statistique'),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: isMobile ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: isMobile ? 1.1 : 1.4,
              children: [
                StatCard(
                  label: 'Visiteurs',
                  value: state.visitors,
                  icon: Icons.groups_rounded,
                  color: Colors.blueAccent,
                ),
                StatCard(
                  label: 'Posts',
                  value: state.posts,
                  icon: Icons.photo_library_outlined,
                  color: Colors.purpleAccent,
                ),
                StatCard(
                  label: 'Notes',
                  value: state.notes,
                  icon: Icons.star_outline_rounded,
                  color: Colors.orangeAccent,
                ),
                StatCard(
                  label: 'Engagement',
                  value: state.engagement,
                  icon: Icons.bolt_rounded,
                  color: Colors.greenAccent,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: 'Informations du lieu'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.placeDescription?.isNotEmpty == true
                        ? state.placeDescription!
                        : 'Aucune description disponible pour le moment.',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Coordonnées',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.placeAddress?.isNotEmpty == true
                        ? '📍 ${state.placeAddress}'
                        : '📍 Adresse non renseignée',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}
