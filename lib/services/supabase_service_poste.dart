import 'package:cheza_app/services/network_guard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseServicePoste {
  // =====================================================
  // POSTS D’UNE FÊTE (OPTIMISÉ)
  // =====================================================

  // static Future<List<Map<String, dynamic>>> fetchPostsByParty(
  //   int partyId,
  // ) async {
  //   final res = await Supabase.instance.client
  //       .from('posts')
  //       .select('''
  //       id,
  //       caption,
  //       image_url,
  //       created_at,
  //       likes(count),
  //       comments(count),
  //       parties_attandance!inner(
  //         party_id,
  //         profiles(
  //           username,
  //           avatar_url
  //         )
  //       )
  //     ''')
  //       .eq('parties_attandance.party_id', partyId)
  //       .order('created_at', ascending: false);

  //   return res.map<Map<String, dynamic>>((p) {
  //     final likes = (p['likes'] as List).isNotEmpty
  //         ? p['likes'][0]['count']
  //         : 0;

  //     final comments = (p['comments'] as List).isNotEmpty
  //         ? p['comments'][0]['count']
  //         : 0;

  //     final profile = p['parties_attandance']['profiles'];

  //     return {
  //       'id': p['id'],
  //       'username': profile?['username'] ?? 'Utilisateur',
  //       'avatar_url': profile?['avatar_url'],
  //       'content': p['caption'],
  //       'media_url': p['image_url'],
  //       'likes': likes,
  //       'comments': comments,
  //       'created_at': p['created_at'],
  //     };
  //   }).toList();
  // }
  static Future<List<Map<String, dynamic>>> fetchPostsByParty(
    int partyId,
  ) async {
    final res = await Supabase.instance.client
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
        parties_attandance!inner(
          party_id,
          profiles(
            username,
            avatar_url
          )
        )
      ''')
        .eq('parties_attandance.party_id', partyId)
        .order('created_at', ascending: false);

    return res.map<Map<String, dynamic>>((p) {
      final likes = (p['likes'] as List).isNotEmpty
          ? p['likes'][0]['count']
          : 0;

      final comments = (p['comments'] as List).isNotEmpty
          ? p['comments'][0]['count']
          : 0;

      final profile = p['parties_attandance']['profiles'];

      return {
        'id': p['id'],
        'username': profile?['username'] ?? 'Utilisateur',
        'avatar_url': profile?['avatar_url'],

        // 🔥 CONTENU
        'content': p['caption'],
        'media_url': p['image_url'],

        // 🔥 STATUT
        'is_status': p['is_status'] == true,
        'bg_color': p['bg_color'],

        // 🔥 META
        'likes': likes,
        'comments': comments,
        'created_at': p['created_at'],
      };
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchPostsByUser(
    String userId,
  ) async {
    try {
      final res = await supabase
          .from('posts')
          .select('''
          id,
          caption,
          image_url,
          created_at,
          parties_attandance(
            user_id,
            profiles(username, avatar_url)
          )
        ''')
          .eq('parties_attandance.user_id', userId)
          .order('created_at', ascending: false);

      return res.map<Map<String, dynamic>>((p) {
        final profile = p['parties_attandance']['profiles'];

        return {
          'id': p['id'],
          'content': p['caption'],
          'image_url': p['image_url'],
          'created_at': p['created_at'],
          'username': profile?['username'] ?? 'Utilisateur',
          'avatar_url': profile?['avatar_url'],
        };
      }).toList();
    } catch (e) {
      print("❌ fetchPostsByUser error: $e");
      return [];
    }
  }
  // static Future<List<Map<String, dynamic>>> fetchPostsByUser(
  //   String userId,
  // ) async {
  //   try {
  //     final res = await supabase
  //         .from('posts')
  //         .select('''
  //           id,
  //           caption,
  //           image_url,
  //           is_status,
  //           bg_color,
  //           created_at,
  //           parties_attandance(
  //             user_id,
  //             profiles(username, avatar_url)
  //           )
  //         ''')
  //         .eq('parties_attandance.user_id', userId)
  //         .order('created_at', ascending: false);

  //     return res.map<Map<String, dynamic>>((p) {
  //       final profile = p['parties_attandance']['profiles'];

  //       return {
  //         'id': p['id'],
  //         'content': p['caption'],
  //         'image_url': p['image_url'],

  //         // 🔥 STATUT
  //         'is_status': p['is_status'] == true,
  //         'bg_color': p['bg_color'],

  //         'created_at': p['created_at'],
  //         'username': profile?['username'] ?? 'Utilisateur',
  //         'avatar_url': profile?['avatar_url'],
  //       };
  //     }).toList();
  //   } catch (e) {
  //     print("❌ fetchPostsByUser error: $e");
  //     return [];
  //   }
  // }

  // =====================================================
  // COMPTER LES POSTS D’UNE FÊTE (OK)
  // =====================================================
  // static Future<int> countPostsByParty(int partyId) async {
  //   if (!NetworkGuard.allowRequest()) return 0;
  //   try {
  //     // 1️⃣ toutes les présences liées à la fête (présents ou non)
  //     final attendances = await supabase
  //         .from('parties_attandance')
  //         .select('id')
  //         .eq('party_id', partyId);

  //     if (attendances.isEmpty) return 0;

  //     final attendanceIds = attendances.map((a) => a['id']).toList();

  //     // 2️⃣ COUNT DB = vérité
  //     final res = await supabase
  //         .from('posts')
  //         .select('id')
  //         .inFilter('attandance_id', attendanceIds)
  //         .count(CountOption.exact);

  //     print("📝 DB POSTS COUNT → party=$partyId | count=${res.count}");

  //     return res.count;
  //   } catch (e) {
  //     print("❌ countPostsByParty error: $e");
  //     return 0;
  //   }
  // }
  static Future<int> countPostsByParty(int partyId) async {
    // 🛑 Guard rapide
    if (!NetworkGuard.allowRequest()) return 0;

    try {
      // 1️⃣ toutes les présences liées à la fête
      final attendances = await supabase
          .from('parties_attandance')
          .select('id')
          .eq('party_id', partyId);

      if (attendances.isEmpty) return 0;

      final attendanceIds = attendances.map((a) => a['id'] as int).toList();

      // 2️⃣ COUNT = vérité DB
      final res = await supabase
          .from('posts')
          .select('id')
          .inFilter('attandance_id', attendanceIds)
          .count(CountOption.exact);

      return res.count;
    } catch (_) {
      // 🧼 SILENCE TOTAL (réseau instable / offline / timeout)
      return 0;
    }
  }

  ///////////////////////////////////////////////////////////
  
  // =====================================================
  // SUPPRESSION POST
  // =====================================================
  static Future<bool> deletePost(int postId) async {
    try {
      await supabase.from('likes').delete().eq('post_id', postId);
      await supabase.from('comments').delete().eq('post_id', postId);
      await supabase.from('posts').delete().eq('id', postId);
      return true;
    } catch (e) {
      print("❌ deletePost error: $e");
      return false;
    }
  }
}
