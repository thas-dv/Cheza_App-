import 'package:cheza_app/features/dashboard/presentation/widgets/hero_place_card.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/layout/dashboard_state.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/stats_row.dart';
import 'package:cheza_app/features/dashboard/presentation/widgets/tabs/dashboard_dialogs.dart';
import 'package:flutter/material.dart';

class ModernHomeWidget extends StatelessWidget {
  final DashboardState state;
  const ModernHomeWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // HERO PLACE CARD : Tous les paramètres sont maintenant reconnus
        HeroPlaceCard(
          placeName: state.placeName,
          imageUrl: state.imageUrl,
          openTime: state.openTime,
          closeTime: state.closeTime,
          visitors: state.visitors,
          posts: state.posts,
          notes: state.notes,
          engagement: state.engagement,
          onActionPressed: () => _handleStatusChange(context),
        ),

        const SizedBox(height: 24),

        // STATS ROW : On passe les paramètres obligatoires ici
        // J'utilise state.revenue et state.bookings (à adapter selon ton DashboardState)
        StatsRow(
          revenue: state.totalRevenue ?? 0.0,
          bookings: state.totalBookings ?? 0,
        ),
      ],
    );
  }

  void _handleStatusChange(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) =>
          state.isOpen ? const ClosePartyDialog() : const OpenPartyDialog(),
    );
  }
}
