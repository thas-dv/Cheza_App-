import 'package:flutter_riverpod/legacy.dart';
import 'package:cheza_app/services/supabase_service_clientel.dart';
import 'package:cheza_app/services/supabase_service_notes.dart';
import 'package:cheza_app/services/supabase_service_poste.dart';

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

final dashboardStatsProvider =
    StateNotifierProvider<DashboardStatsNotifier, DashboardStats?>(
      (ref) => DashboardStatsNotifier(),
    );
final placePhotoProvider = StateProvider<String?>((ref) => null);

class DashboardStatsNotifier extends StateNotifier<DashboardStats?> {
  DashboardStatsNotifier() : super(null);

  Future<void> load(int partyId) async {
    state = DashboardStats(
      visitors: await SupabaseServiceClientel.countClienteleByParty(partyId),
      posts: await SupabaseServicePoste.countPostsByParty(partyId),
      notes: await SupabaseServiceNotes.countRatingsByParty(partyId),
      engagement: await SupabaseServiceNotes.countEngagementByParty(partyId),
    );
  }

  void clear() => state = null;
}
