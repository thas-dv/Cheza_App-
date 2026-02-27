import 'package:cheza_app/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:cheza_app/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:cheza_app/features/dashboard/domain/entities/party_summary.dart';
import 'package:cheza_app/features/dashboard/domain/entities/place_info.dart';

abstract class DashboardRepository {
  Future<PlaceInfo> fetchMyPlace();
  Future<PartySummary?> fetchActiveParty(int placeId);
  Future<DashboardStats> loadDashboardStats(int partyId);
  Future<List<Map<String, dynamic>>> fetchClientele(int partyId);
  Future<bool> closeParty({required int partyId, required DateTime closedAt});
  Future<int?> createParty({
    required int placeId,
    required String name,
    required DateTime openedAt,
    required DateTime closedAt,
  });
  Future<List<PartySummary>> fetchClosedParties(int placeId);
  Future<DashboardSnapshot> loadDashboardSnapshot();
}