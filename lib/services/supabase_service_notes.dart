import 'package:cheza_app/services/network_guard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseServiceNotes {
  // =====================================================
  // COMPTER LES NOTES D’UNE FÊTE
  // =====================================================
  static Future<int> countRatingsByParty(int partyId) async {
    if (!NetworkGuard.allowRequest()) return 0;
    try {
      // 1️⃣ récupérer les attendance de la fête
      final attendances = await supabase
          .from('parties_attandance')
          .select('id')
          .eq('party_id', partyId)
          .eq('is_present', true);

      if (attendances.isEmpty) return 0;

      final attendanceIds = attendances.map((a) => a['id']).toList();

      // 2️⃣ compter les notes liées aux attendance
      final res = await supabase
          .from('party_ratings')
          .select('id')
          .inFilter('attendee_id', attendanceIds)
          .count(CountOption.exact);

      return res.count;
    } catch (e) {
      print("❌ countRatingsByParty error: $e");
      return 0;
    }
  }

  static Future<bool> giveReward({
    required int attendeeId,
    required String description,
    int points = 0,
  }) async {
    try {
      await supabase.from('party_rewards').insert({
        'attendee_id': attendeeId,
        'reward_desc': description,
        'reward_points': points,
      });
      return true;
    } catch (e) {
      print("❌ giveReward error: $e");
      return false;
    }
  }

  static Future<bool> hasReward(int attendeeId) async {
    final res = await supabase
        .from('party_rewards')
        .select('id')
        .eq('attendee_id', attendeeId)
        .limit(1);

    return res.isNotEmpty;
  }

  static Future<List<Map<String, dynamic>>> fetchRewards(int attendeeId) async {
    return await supabase
        .from('party_rewards')
        .select('*')
        .eq('attendee_id', attendeeId)
        .order('created_at', ascending: false);
  }

  // =====================================================
  // COMPTER L’ENGAGEMENT GLOBAL D’UNE FÊTE
  // =====================================================
  static Future<int> countEngagementByParty(int partyId) async {
    if (!NetworkGuard.allowRequest()) return 0;
    try {
      // 1️⃣ récupérer les attendance
      final attendances = await supabase
          .from('parties_attandance')
          .select('id')
          .eq('party_id', partyId)
          .eq('is_present', true);

      if (attendances.isEmpty) return 0;

      final attendanceIds = attendances.map((a) => a['id']).toList();

      // 2️⃣ posts
      final posts = await supabase
          .from('posts')
          .select('id')
          .inFilter('attandance_id', attendanceIds)
          .count(CountOption.exact);

      // 3️⃣ invites
      final invites = await supabase
          .from('party_invites')
          .select('id')
          .inFilter('attendee_id', attendanceIds)
          .count(CountOption.exact);

      // 4️⃣ ratings
      final ratings = await supabase
          .from('party_ratings')
          .select('id')
          .inFilter('attendee_id', attendanceIds)
          .count(CountOption.exact);

      return posts.count + invites.count + ratings.count;
    } catch (e) {
      print("❌ countEngagementByParty error: $e");
      return 0;
    }
  }
}
