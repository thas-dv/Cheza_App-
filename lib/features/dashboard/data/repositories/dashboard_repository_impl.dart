
import 'package:cheza_app/features/dashboard/data/datasources/dashboard_supabase_data_source.dart';
import 'package:cheza_app/features/dashboard/data/models/party_summary_model.dart';
import 'package:cheza_app/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:cheza_app/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:cheza_app/features/dashboard/domain/entities/party_summary.dart';
import 'package:cheza_app/features/dashboard/domain/entities/place_info.dart';
import 'package:cheza_app/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._dataSource);

  final DashboardSupabaseDataSource _dataSource;

  @override
  Future<PlaceInfo> fetchMyPlace() async {
    final profile = await _dataSource.fetchMyAdminProfile();
    final placeId = profile?['place_id'] as int?;
    if (placeId == null) {
      throw Exception('Place ID introuvable');
    }

    final place = await _dataSource.fetchMyPlaceDetails(placeId);
    if (place == null) {
      throw Exception('Détails du lieu introuvables');
    }

    return PlaceInfo(
      id: placeId,
      name: (place['name'] ?? 'Nom du Lieu') as String,
      photoUrl: place['photo_url'] as String?,
    );
  }

  @override
  Future<PartySummary?> fetchActiveParty(int placeId) async {
    final json = await _dataSource.fetchActiveParty(placeId);
    if (json == null) return null;
    return PartySummaryModel.fromJson(json).toEntity();
  }

  @override
  Future<DashboardStats> loadDashboardStats(int partyId) async {
    final visitors = await _dataSource.countVisitors(partyId);
    final posts = await _dataSource.countPosts(partyId);
    final notes = await _dataSource.countRatings(partyId);
    final engagement = await _dataSource.countEngagement(partyId);

    return DashboardStats(
      visitors: visitors,
      posts: posts,
      notes: notes,
      engagement: engagement,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchClientele(int partyId) {
    return _dataSource.fetchClientele(partyId);
  }

  @override
  Future<bool> closeParty({required int partyId, required DateTime closedAt}) {
    return _dataSource.closeParty(partyId: partyId, closedAt: closedAt);
  }

  @override
  Future<int?> createParty({
    required int placeId,
    required String name,
    required DateTime openedAt,
    required DateTime closedAt,
  }) {
    return _dataSource.createParty(
      placeId: placeId,
      name: name,
      openedAt: openedAt,
      closedAt: closedAt,
    );
  }

  @override
  Future<List<PartySummary>> fetchClosedParties(int placeId) async {
    final json = await _dataSource.fetchClosedParties(placeId);
    return json.map((item) => PartySummaryModel.fromJson(item).toEntity()).toList();
  }

  @override
  Future<DashboardSnapshot> loadDashboardSnapshot() async {
    final place = await fetchMyPlace();
    final activeParty = await fetchActiveParty(place.id);

    if (activeParty == null) {
      return DashboardSnapshot(
        place: place,
        activeParty: null,
        stats: null,
        clientele: const [],
      );
    }

    final stats = await loadDashboardStats(activeParty.id);
    final clientele = await fetchClientele(activeParty.id);

    return DashboardSnapshot(
      place: place,
      activeParty: activeParty,
      stats: stats,
      clientele: clientele,
    );
  }
}