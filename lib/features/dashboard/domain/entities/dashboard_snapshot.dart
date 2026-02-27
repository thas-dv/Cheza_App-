import 'package:cheza_app/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:cheza_app/features/dashboard/domain/entities/party_summary.dart';
import 'package:cheza_app/features/dashboard/domain/entities/place_info.dart';

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.place,
    required this.activeParty,
    required this.stats,
    required this.clientele,
  });

  final PlaceInfo place;
  final PartySummary? activeParty;
  final DashboardStats? stats;
  final List<Map<String, dynamic>> clientele;
}