import 'package:cheza_app/features/dashboard/presentation/widgets/hero_place_card.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/layout/dashboard_state.dart';
import 'package:cheza_app/core/ui/responsive_layout.dart' show Breakpoints;
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
          padding: EdgeInsets.fromLTRB(
            isMobile ? 12 : 28,
            isMobile ? 12 : 28,
            isMobile ? 12 : 28,
            isMobile ? 20 : 28,
          ),
          children: [
            HeroPlaceCard(
              placeName: state.placeName,
              imageUrl: state.placeImageUrl,
              isOpen: state.isOpen,
              adminName: state.adminName,
              visitors: state.visitors,
              posts: state.posts,
              notes: state.notes,
              engagement: state.engagement,
            ),

            SizedBox(height: isMobile ? 14 : 24),

            const _SectionTitle(title: 'Informations du lieu'),
            const SizedBox(height: 16),

            Container(
              padding: EdgeInsets.all(isMobile ? 14 : 20),
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
                    (state.placeDescription != null &&
                            state.placeDescription!.isNotEmpty)
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
                    (state.placeAddress != null &&
                            state.placeAddress!.isNotEmpty)
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
