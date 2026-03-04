import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cheza_app/services/supabase_service_poste.dart';

final postsProvider = StateNotifierProvider.autoDispose
    .family<PostsNotifier, PostsState, int>((ref, partyId) {
      final link = ref.keepAlive();
      ref.onDispose(() => link.close());

      return PostsNotifier(partyId);
    });

class PostsState {
  final bool loading;
  final bool networkError;
  final List<Map<String, dynamic>> posts;
  final bool hasLoadedOnce;

  const PostsState({
    required this.loading,
    required this.networkError,
    required this.posts,
    required this.hasLoadedOnce,
  });

  factory PostsState.initial() => const PostsState(
    loading: true,
    networkError: false,
    posts: [],
    hasLoadedOnce: false,
  );
}

class PostsNotifier extends StateNotifier<PostsState> {
  final int partyId;

  PostsNotifier(this.partyId) : super(PostsState.initial());

  /// 🔄 FETCH + MERGE (CORRECTION CLÉ)
  Future<void> load({bool silent = false}) async {
    if (!mounted) return;

    if (!silent) {
      state = PostsState(
        loading: true,
        networkError: false,
        posts: state.posts,
        hasLoadedOnce: state.hasLoadedOnce,
      );
    }

    try {
      final data = await SupabaseServicePoste.fetchPostsByParty(partyId);
      if (!mounted) return;

      final current = state.posts;

      // 🔥 MERGE : on garde les posts locaux absents du fetch
      final merged = [
        ...current.where(
          (local) => !data.any((remote) => remote['id'] == local['id']),
        ),
        ...data,
      ];

      state = PostsState(
        loading: false,
        networkError: false,
        posts: merged,
        hasLoadedOnce: true,
      );
    } catch (_) {
      if (!mounted) return;

      state = PostsState(
        loading: false,
        networkError: true,
        posts: state.hasLoadedOnce ? state.posts : [],
        hasLoadedOnce: state.hasLoadedOnce,
      );
    }
  }

  /// ⚡ AJOUT LOCAL IMMÉDIAT (OPTIMISTIC)
  void insertOptimisticPost(Map<String, dynamic> post) {
    if (!mounted) return;

    final id = post['id'];
    if (id == null) return;

    final exists = state.posts.any((p) => p['id'] == id);
    if (exists) return;

    state = PostsState(
      loading: false,
      networkError: false,
      posts: [post, ...state.posts],
      hasLoadedOnce: true,
    );
  }
}

/// =======================
/// COUNT (SOURCE DASHBOARD)
/// =======================

final postsCountProvider =
    StateNotifierProvider.family<PostsCountNotifier, int, int>(
      (ref, partyId) => PostsCountNotifier(partyId),
    );

// class PostsCountNotifier extends StateNotifier<int> {
//   final int partyId;

//   PostsCountNotifier(this.partyId) : super(0) {
//     refresh();
//   }

//   Future<void> refresh() async {
//     try {
//       final count = await SupabaseServicePoste.countPostsByParty(partyId);

//       // ✅ mise à jour seulement si succès
//       state = count;
//     } catch (e) {
//       // ❌ ON NE TOUCHE PAS AU STATE
//       // 👉 on garde la dernière valeur valide
//       state = await SupabaseServicePoste.countPostsByParty(partyId);
//       debugPrint("⚠️ PostsCount offline → keep last value (partyId=$partyId)");
//     }
//   }
// }
class PostsCountNotifier extends StateNotifier<int> {
  final int partyId;

  PostsCountNotifier(this.partyId) : super(0) {
    refresh();
  }

  Future<void> refresh() async {
    try {
      final count = await SupabaseServicePoste.countPostsByParty(partyId);

      state = count;
    } catch (e) {
      // ❌ NE RIEN FAIRE
      // 👉 on garde le dernier count connu
      debugPrint("⚠️ PostsCount offline → keep last value (partyId=$partyId)");
    }
  }
}
