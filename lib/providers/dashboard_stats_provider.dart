import 'package:flutter_riverpod/legacy.dart';
import 'package:cheza_app/services/supabase_service_clientel.dart';
import 'package:cheza_app/services/supabase_service_notes.dart';
import 'package:cheza_app/services/supabase_service_poste.dart';

/// =======================
/// MODEL
/// =======================
class DashboardStats {
  final int visitors;
  final int posts;
  final int notes;
  final int engagement;

  DashboardStats({
    required this.visitors,
    required this.posts,
    required this.notes,
    required this.engagement,
  });
}

/// =======================
/// PROVIDER (LEGACY)
/// =======================
final dashboardStatsProvider =
    StateNotifierProvider<DashboardStatsNotifier, DashboardStats?>(
      (ref) => DashboardStatsNotifier(),
    );

class DashboardStatsNotifier extends StateNotifier<DashboardStats?> {
  DashboardStatsNotifier() : super(null);

  Future<void> load(int partyId) async {
    final visitors = await SupabaseServiceClientel.countClienteleByParty(
      partyId,
    );

    final posts = await SupabaseServicePoste.countPostsByParty(partyId);

    final notes = await SupabaseServiceNotes.countRatingsByParty(partyId);

    final engagement = await SupabaseServiceNotes.countEngagementByParty(
      partyId,
    );

    state = DashboardStats(
      visitors: visitors,
      posts: posts,
      notes: notes,
      engagement: engagement,
    );
  }

  void clear() {
    state = null;
  }
}
