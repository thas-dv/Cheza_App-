import 'package:cheza_app/services/network_guard.dart';
import 'package:cheza_app/services/supabase_network_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseServiceClientel {
  ///////////////////////////////////////////////////////
  static const _presenceColumns = ['is_present', 'is_presente'];

  static Future<List<dynamic>> _attendanceQueryWithPresence(
    PostgrestFilterBuilder<dynamic> query,
  ) async {
    for (final column in _presenceColumns) {
      try {
        final result = await query.eq(column, true);
        return result as List<dynamic>;
      } catch (_) {
        // essaie la prochaine colonne de présence
      }
    }
    return <dynamic>[];
  }
  // static Future<Map<String, dynamic>> fetchClientDetails(
  //   String userId,
  //   int attendeeId,
  // ) async {
  //   debugPrint("👀 fetchClientDetails attendee=$attendeeId user=$userId");

  //   // 1️⃣ PROFIL (clé primaire → ultra rapide)
  //   final profileFuture = supabase
  //       .from('profiles')
  //       .select('id, username, avatar_url')
  //       .eq('id', userId)
  //       .single();

  //   // 2️⃣ POSTS (via parties_attandance → relation correcte)
  //   final postsFuture = supabase
  //       .from('posts')
  //       .select('''
  //       id,
  //       caption,
  //       image_url,
  //       created_at,
  //       parties_attandance!inner (
  //         id
  //       )
  //     ''')
  //       .eq('parties_attandance.id', attendeeId)
  //       .order('created_at', ascending: false);

  //   // 3️⃣ AUTRES DONNÉES (simples & rapides)
  //   final invitesFuture = supabase
  //       .from('party_invites')
  //       .select('id, accepted')
  //       .eq('attendee_id', attendeeId);

  //   final ratingsFuture = supabase
  //       .from('party_ratings')
  //       .select('id, service, music, vibe, decor')
  //       .eq('attendee_id', attendeeId);

  //   final rewardsFuture = supabase
  //       .from('party_rewards')
  //       .select('id, reward_desc, reward_points')
  //       .eq('attendee_id', attendeeId);

  //   // ⚡ EXÉCUTION PARALLÈLE
  //   final results = await Future.wait([
  //     profileFuture,
  //     postsFuture,
  //     invitesFuture,
  //     ratingsFuture,
  //     rewardsFuture,
  //   ]);

  //   return {
  //     'profile': results[0],
  //     'posts': results[1] as List,
  //     'invites': results[2] as List,
  //     'ratings': results[3] as List,
  //     'rewards': results[4] as List,
  //   };
  // }
  static Future<Map<String, dynamic>> fetchClientDetails(
    String userId,
    int partyId,
  ) async {
    try {
      // 👤 PROFIL
      final profile = await supabase
          .from('profiles')
          .select('id, username, avatar_url')
          .eq('id', userId)
          .single();

      // 🎟️ TOUTES LES PRÉSENCES DE CE USER À CETTE FÊTE
      final attendances = await supabase
          .from('parties_attandance')
          .select('id')
          .eq('party_id', partyId)
          .eq('user_id', userId);

      if (attendances.isEmpty) {
        return {
          'profile': profile,
          'posts': [],
          'invites': [],
          'ratings': [],
          'rewards': [],
        };
      }

      final attendanceIds = attendances.map((a) => a['id']).toList();

      // 📝 TOUS LES POSTS
      final rawPosts = await supabase
          .from('posts')
          .select('''
          id,
          caption,
          image_url,
          is_status,
          bg_color,
          created_at,
          likes(count),
          comments(count)
        ''')
          .inFilter('attandance_id', attendanceIds)
          .order('created_at', ascending: false);

      final posts = (rawPosts as List).map<Map<String, dynamic>>((p) {
        final likes = (p['likes'] as List?)?.first?['count'] ?? 0;
        final comments = (p['comments'] as List?)?.first?['count'] ?? 0;

        return {
          'id': p['id'],
          'caption': p['caption'] ?? '',
          'image_url': p['image_url'],
          'is_status': p['is_status'] == true,
          'bg_color': p['bg_color'],
          'created_at': p['created_at'],
          'username': profile['username'],
          'avatar_url': profile['avatar_url'],
          'likes': likes,
          'comments': comments,
        };
      }).toList();

      return {
        'profile': profile,
        'posts': posts,
        'invites': await supabase
            .from('party_invites')
            .select('id, accepted')
            .eq('user_id', userId),
        'ratings': await supabase
            .from('party_ratings')
            .select('id, service, music, vibe, decor')
            .eq('user_id', userId),
        'rewards': await supabase
            .from('party_rewards')
            .select('id, reward_desc, reward_points')
            .eq('user_id', userId),
      };
    } catch (e, s) {
      debugPrint("❌ fetchClientDetails ERROR: $e");
      debugPrint("📍 STACK: $s");

      return {
        'profile': null,
        'posts': [],
        'invites': [],
        'ratings': [],
        'rewards': [],
      };
    }
  }

  //////////////////////////////////////////////////////////////
  // static Future<List<Map<String, dynamic>>> fetchClienteleData(
  //   int partyId,
  // ) async {
  //   debugPrint("👀 fetchClienteleData PARTY ID = $partyId");

  //   final data = await supabase
  //       .from('parties_attandance')
  //       .select('''
  //       id,
  //       user_id,
  //       profiles:profiles!parties_attandance_user_id_fkey (
  //         username,
  //         avatar_url
  //       )
  //     ''')
  //       .eq('party_id', partyId)
  //       .eq('is_present', true);

  //   debugPrint("🧪 RAW DATA = $data");

  //   final list = data.map<Map<String, dynamic>>((att) {
  //     final profile = att['profiles']; // ✅ MAP, PAS LISTE

  //     return {
  //       'attendee_id': att['id'],
  //       'user_id': att['user_id'],
  //       'username': profile?['username'] ?? 'Utilisateur',
  //       'avatar_url': profile?['avatar_url'],
  //       'posts_count': 0,
  //       'invites_count': 0,
  //     };
  //   }).toList();

  //   debugPrint("✅ FINAL CLIENT LIST = ${list.length}");
  //   return list;
  // }
  static Future<List<Map<String, dynamic>>> fetchAllPostsByUser(
    String userId,
  ) async {
    try {
      if (!NetworkService.isConnected) return [];
      // 👤 PROFIL (UNE SEULE FOIS)
      final profile = await supabase
          .from('profiles')
          .select('id, username, avatar_url')
          .eq('id', userId)
          .single();

      // 📝 TOUS LES POSTS DE L’UTILISATEUR (PEU IMPORTE LA FÊTE)
      final rawPosts = await supabase
          .from('posts')
          .select('''
          id,
          caption,
          image_url,
          is_status,
          bg_color,
          created_at,
          likes(count),
          comments(count),
          parties_attandance!inner (
            user_id
          )
        ''')
          .eq('parties_attandance.user_id', userId)
          .order('created_at', ascending: false);

      // 🧹 NORMALISATION
      final posts = (rawPosts as List).map<Map<String, dynamic>>((p) {
        final likes = (p['likes'] as List?)?.first?['count'] ?? 0;
        final comments = (p['comments'] as List?)?.first?['count'] ?? 0;

        return {
          'id': p['id'],
          'caption': p['caption'] ?? '',
          'image_url': p['image_url'],
          'is_status': p['is_status'] == true,
          'bg_color': p['bg_color'],
          'created_at': p['created_at'],

          // 👤 USER
          'username': profile['username'],
          'avatar_url': profile['avatar_url'],

          // ❤️ 💬
          'likes': likes,
          'comments': comments,
        };
      }).toList();

      debugPrint("🟢 TOTAL POSTS USER $userId = ${posts.length}");

      return posts;
    } catch (e, s) {
      debugPrint("❌ fetchAllPostsByUser ERROR: $e");
      debugPrint("📍 STACK: $s");
      return [];
    }
  }

  // static Future<List<Map<String, dynamic>>> fetchClienteleData(
  //   int partyId,
  // ) async {
  //    if (!NetworkGuard.allowRequest()) return [];
  //   debugPrint("👀 fetchClienteleData PARTY ID = $partyId");
  //   if (!NetworkService.isConnected) return [];
  //   final data = await supabase
  //       .from('parties_attandance')
  //       .select('''
  //       id,
  //       user_id,
  //       profiles:profiles!parties_attandance_user_id_fkey (
  //         username,
  //         avatar_url
  //       ),
  //       posts:posts!posts_attandance_id_fkey (
  //         id
  //       ),
  //       invites:party_invites!party_invites_attendee_id_fkey (
  //         id
  //       )
  //     ''')
  //       .eq('party_id', partyId)
  //       .eq('is_present', true);

  //   debugPrint("🧪 RAW DATA = $data");

  //   final list = data.map<Map<String, dynamic>>((att) {
  //     final profile = att['profiles'];
  //     final posts = att['posts'] as List? ?? [];
  //     final invites = att['invites'] as List? ?? [];

  //     return {
  //       'attendee_id': att['id'],
  //       'user_id': att['user_id'],
  //       'username': profile?['username'] ?? 'Utilisateur',
  //       'avatar_url': profile?['avatar_url'],
  //       'posts_count': posts.length,
  //       'invites_count': invites.length,
  //     };
  //   }).toList();

  //   // 🔥 Classement par activité
  //   list.sort(
  //     (a, b) => ((b['posts_count'] + b['invites_count'])).compareTo(
  //       a['posts_count'] + a['invites_count'],
  //     ),
  //   );

  //   debugPrint(" FINAL CLIENT LIST = ${list.length}");
  //   return list;
  // }
  static Future<List<Map<String, dynamic>>> fetchClienteleData(
    int partyId,
  ) async {
    // 1. Guard AVANT (rapide)
    if (!NetworkGuard.allowRequest()) return [];

    try {
      // 2. Requête protégée
      final baseQuery = supabase
          .from('parties_attandance')
          .select('''
          id,
          user_id,
          profiles:profiles!parties_attandance_user_id_fkey (
            username,
            avatar_url
          ),
          posts:posts!posts_attandance_id_fkey (
            id
          ),
          invites:party_invites!party_invites_attendee_id_fkey (
            id
          )
        ''')
          .eq('party_id', partyId)
            .eq('party_id', partyId);

      final data = await _attendanceQueryWithPresence(baseQuery);

      final list = data.map<Map<String, dynamic>>((att) {
        final profile = att['profiles'];
        final posts = att['posts'] as List? ?? [];
        final invites = att['invites'] as List? ?? [];

        return {
          'attendee_id': att['id'],
          'user_id': att['user_id'],
          'username': profile?['username'] ?? 'Utilisateur',
          'avatar_url': profile?['avatar_url'],
          'posts_count': posts.length,
          'invites_count': invites.length,
        };
      }).toList();

      // Classement par activité
      list.sort(
        (a, b) => ((b['posts_count'] + b['invites_count'])).compareTo(
          a['posts_count'] + a['invites_count'],
        ),
      );

      return list;
    } catch (_) {
      // SILENCE TOTAL (réseau instable / offline / timeout)
      return [];
    }
  }

  ////////////////////////////////////////////////////////////
  // static Future<int> countClienteleByParty(int partyId) async {
  //   final res = await supabase
  //       .from('parties_attandance')
  //       .select('id')
  //       .eq('party_id', partyId)
  //       .eq('is_present', true);

  //   return res.length;
  // }
  ///////////////////////////////////////////

  static Future<int> countPostsForUser({
    required int partyId,
    required String userId,
  }) async {
    if (!NetworkGuard.allowRequest()) return 0;
    final data = await Supabase.instance.client
        .from('posts')
        .select('id')
        .eq('party_id', partyId)
        .eq('user_id', userId);

    return (data as List).length;
  }

  //////////////////////////////////////////
  static Future<int> countPostsForUserInParty({
    required int partyId,
    required String userId,
  }) async {
    if (!NetworkGuard.allowRequest()) return 0;
    // 1️⃣ récupérer les attendances de l'utilisateur pour cette fête
    final attendances = await supabase
        .from('parties_attandance')
        .select('id')
        .eq('party_id', partyId)
        .eq('user_id', userId);

    if (attendances.isEmpty) return 0;

    final attendanceIds = (attendances as List).map((a) => a['id']).toList();

    // 2️⃣ compter les posts liés à ces attendances
    final posts = await supabase
        .from('posts')
        .select('id')
        .inFilter('attandance_id', attendanceIds);

    return (posts as List).length;
  }

  //////////////////////////////////////////////////////////////
  // static Future<int> countClienteleByParty(int partyId) async {
  //    if (!NetworkGuard.allowRequest()) return 0;
  //   final res = await supabase
  //       .from('parties_attandance')
  //       .select('id')
  //       .eq('party_id', partyId)
  //       .eq('is_present', true);

  //   debugPrint(
  //     "🔢 COUNT FROM DB (truth) → party=$partyId | count=${res.length}",
  //   );

  //   return res.length;
  // }
  static Future<int> countClienteleByParty(int partyId) async {
    //  1. Guard AVANT
    if (!NetworkGuard.allowRequest()) return 0;

    try {
      //  2. Guard AUTOUR (OBLIGATOIRE sur Windows)
      final res = await supabase
          .from('parties_attandance')
          .select('id')
          .eq('party_id', partyId)
          .eq('is_present', true);

      return res.length;
    } catch (_) {
      // 3. SILENCE TOTAL (comme Facebook)
      return 0;
    }
  }
}
