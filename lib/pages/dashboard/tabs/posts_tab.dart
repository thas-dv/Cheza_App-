import 'dart:async';
import 'package:cheza_app/providers/active_party_provider.dart';
import 'package:cheza_app/providers/posts_provider.dart';
import 'package:cheza_app/realtime/posts_realtime_controller.dart';
import 'package:cheza_app/services/supabase_network_service.dart';
import 'package:cheza_app/services/supabase_service_poste.dart';
// import 'package:cheza_app/widgets/network_error.dart';
import 'package:cheza_app/widgets/retour_interne.dart';
import 'package:cheza_app/widgets/video_plays.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class PostsTab extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const PostsTab({super.key, this.onBack});

  @override
  ConsumerState<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends ConsumerState<PostsTab> {
  // late final RealtimeChannel _postsChannel;
  StreamSubscription<bool>? _networkSub;

  // bool _hasDoneNetworkResync = false;

  final _realtime = PostsRealtimeController();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final partyId = ref.read(activePartyIdProvider);
      if (partyId == null) return;

      // 🔒 CAPTURE DES NOTIFIERS (OBLIGATOIRE)
      final postsNotifier = ref.read(postsProvider(partyId).notifier);
      final postsCountNotifier = ref.read(postsCountProvider(partyId).notifier);

      // 🔥 chargement initial
      postsNotifier.load();
      postsCountNotifier.refresh();

      // 🌐 écoute réseau (safe)
      _networkSub = NetworkService.connectionStream.listen((isConnected) {
        if (!mounted || !isConnected) return;

        postsNotifier.load(silent: true);
        postsCountNotifier.refresh();
      });

      // 🔁 realtime (safe, sans ref)
      _realtime.start(
        partyId: partyId,

        onInsert: (post) {
          if (!mounted) return;
          postsNotifier.insertOptimisticPost(post);
        },

        refreshCount: () async {
          if (!mounted) return;
          await postsCountNotifier.refresh();
        },

        refreshList: () async {
          if (!mounted) return;
          await postsNotifier.load(silent: true);
        },
      );
    });
  }

  @override
  void dispose() {
    _networkSub?.cancel(); // ✅ SAFE
    _realtime.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final partyId = ref.watch(activePartyIdProvider);

    if (partyId == null) {
      return const SizedBox();
    }

    final state = ref.watch(postsProvider(partyId));
    final serverCount = ref.watch(postsCountProvider(partyId));

    // 🔥 FALLBACK UI : si le serveur dit 0 mais que des posts sont affichés
    final totalPosts = serverCount > 0 ? serverCount : state.posts.length;

    return AppBackHandler(
      onBack: widget.onBack,
      child: _buildPostsContent(state: state, totalPosts: totalPosts),
    );
  }

  Future<void> loadPosts({bool silent = false}) async {
    if (!mounted) return;

    final partyId = ref.read(activePartyIdProvider);
    if (partyId == null) return;

    await ref.read(postsProvider(partyId).notifier).load(silent: silent);
  }

  bool _isVideo(String url) {
    final u = url.toLowerCase();
    return u.contains('.mp4') ||
        u.contains('.mov') ||
        u.contains('.webm') ||
        u.contains('.mkv') ||
        u.contains('.avi');
  }

  String _cleanUrl(String url) {
    // enlève ?token=... ou &...
    return url.split('?').first;
  }

  Widget _buildPostsContent({
    required PostsState state,
    required int totalPosts,
  }) {
    debugPrint("📦 POSTS UI COUNT = $totalPosts");

    return Column(
      children: [
        // ================= HEADER =================
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
              const SizedBox(width: 8),
              const Text(
                "Posts",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // ================= STAT =================
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Center(
            child: Column(
              children: [
                Text(
                  totalPosts.toString(), // ✅ ICI
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Total des posts",
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ),

        // ================= LISTE =================
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              int crossAxisCount;
              double ratio;

              if (width < 500) {
                // 📱 Téléphone
                crossAxisCount = 2;
                ratio = 2.2;
              } else if (width < 900) {
                // 📲 Tablette
                crossAxisCount = 3;
                ratio = 2.3;
              } else {
                // 💻 Desktop
                crossAxisCount = 4;
                ratio = 2.4;
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: ratio, // 👈 garde ton rendu horizontal
                ),
                itemCount: state.posts.length,
                itemBuilder: (_, i) => _postGridCard(state.posts[i]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _postGridCard(Map<String, dynamic> post) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openPost(post),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ IMAGE À GAUCHE
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 70,
                height: 70,
                child: buildPostPreview(post),
              ),
            ),

            const SizedBox(width: 8),

            // 📄 TEXTE À DROITE
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👤 USER
                  Text(
                    post['username'] ?? 'Utilisateur',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 2),

                  // 📝 CONTENU
                  Text(
                    post['content'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),

                  const SizedBox(height: 6),

                  // ❤️ 💬 STATS
                  Row(
                    children: [
                      const Icon(Icons.favorite, size: 14, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        (post['likes'] ?? 0).toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.comment, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        (post['comments'] ?? 0).toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPostContent(Map<String, dynamic> post) {
    final mediaUrl = post['media_url'];

    // 📝 TEXTE SEUL
    if (mediaUrl == null || mediaUrl.toString().isEmpty) {
      return Text(
        post['content'] ?? '',
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      );
    }

    final rawUrl = mediaUrl.toString();
    final url = _cleanUrl(rawUrl);

    // 🎥 VIDÉO
    if (_isVideo(url)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: VideoPlayerWidget(url: rawUrl),
      );
    }

    // 🖼️ IMAGE (TOUS TYPES : jpg, png, webp, heic, avif, gif, sans extension…)
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        rawUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Text("Image indisponible"),
      ),
    );
  }

  Widget buildPostPreview(Map<String, dynamic> post) {
    final bool isStatus = post['is_status'] == true;

    // 🟠 REAL / STATUS → BACKGROUND COLOR
    if (isStatus) {
      final Color bgColor = post['bg_color'] != null
          ? Color(int.parse(post['bg_color'].toString()))
          : const Color(0xFF333333);

      return Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        child: Text(
          post['content'] ?? '',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      );
    }

    // 🖼️ POST NORMAL (IMAGE / VIDEO)
    final mediaUrl = post['media_url'];
    if (mediaUrl == null || mediaUrl.toString().isEmpty) {
      return Container(
        color: Colors.grey.shade800,
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }

    final rawUrl = mediaUrl.toString();
    final url = _cleanUrl(rawUrl);

    // 🎥 VIDEO
    if (_isVideo(url)) {
      return videoPreview(rawUrl);
    }

    // 🖼️ IMAGE
    return Image.network(
      rawUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade800,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }

  Widget buildPostMedia({
    required String? mediaUrl,
    String? text,
    bool preview = false,
  }) {
    if (mediaUrl == null || mediaUrl.isEmpty) {
      return Text(
        text ?? '',
        maxLines: preview ? 3 : null,
        overflow: preview ? TextOverflow.ellipsis : null,
        textAlign: TextAlign.center,
      );
    }

    final rawUrl = mediaUrl;
    final url = _cleanUrl(rawUrl);

    // 🎥 VIDÉO
    if (_isVideo(url)) {
      if (preview) {
        return videoPreview(rawUrl);
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: VideoPlayerWidget(url: rawUrl),
      );
    }

    // 🖼️ IMAGE (AUCUNE RESTRICTION DE FORMAT)
    return Image.network(
      rawUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _mediaError(),
    );
  }

  Widget videoPreview(String url) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.play_circle_fill, size: 48, color: Colors.white),
      ),
    );
  }

  // void _showPostDetails(Map<String, dynamic> post) {
  //   showDialog(
  //     context: context,
  //     builder: (_) => Dialog(
  //       backgroundColor: const Color(0xFF1E1E1E),
  //       insetPadding: const EdgeInsets.all(20),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       child: SizedBox(
  //         width: 360, // ✅ LARGEUR FIXE (clé)
  //         child: Padding(
  //           padding: const EdgeInsets.all(16),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               // HEADER
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: Text(
  //                       post['username'],
  //                       style: const TextStyle(
  //                         fontWeight: FontWeight.w600,
  //                         fontSize: 16,
  //                       ),
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ),
  //                   IconButton(
  //                     icon: const Icon(Icons.close),
  //                     onPressed: () => Navigator.pop(context),
  //                   ),
  //                 ],
  //               ),

  //               const SizedBox(height: 14),

  //               // 📌 MEDIA (taille contrôlée)
  //               ConstrainedBox(
  //                 constraints: const BoxConstraints(
  //                   maxHeight: 200, // ✅ COMME SUR TON IMAGE
  //                 ),
  //                 child: Center(child: buildPostContent(post)),
  //               ),

  //               const SizedBox(height: 12),

  //               // TEXTE
  //               if ((post['content'] ?? '').toString().isNotEmpty)
  //                 Text(
  //                   post['content'],
  //                   textAlign: TextAlign.center,
  //                   maxLines: 4,
  //                   overflow: TextOverflow.ellipsis,
  //                   style: const TextStyle(fontSize: 15),
  //                 ),

  //               const SizedBox(height: 14),

  //               // STATS
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   const Icon(Icons.favorite, size: 18, color: Colors.red),
  //                   const SizedBox(width: 6),
  //                   Text(post['likes'].toString()),
  //                   const SizedBox(width: 16),
  //                   const Icon(Icons.comment, size: 18, color: Colors.blue),
  //                   const SizedBox(width: 6),
  //                   Text(post['comments'].toString()),
  //                   SizedBox(width: 10),
  //                   IconButton(
  //                     icon: const Icon(Icons.delete, color: Colors.red),
  //                     onPressed: () => _confirmDelete(post['id']),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _mediaError() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
      ),
    );
  }

  // ======================================================
  // DELETE
  // ======================================================
  void _confirmDelete(int postId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer le post"),
        content: const Text("Voulez-vous vraiment supprimer ce post ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await SupabaseServicePoste.deletePost(postId);

              if (!mounted) return;
              Navigator.pop(context);

              final partyId = ref.read(activePartyIdProvider);
              if (partyId != null) {
                ref.read(postsProvider(partyId).notifier).load(silent: true);
              }
            },
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }

  //////////////////////////////////////////////////////////////////////
  void _openPost(Map<String, dynamic> post) {
    final bool isStatus = post['is_status'] == true;

    // 🔹 PROFIL (relation imbriquée)

    final String username = post['username'] ?? 'Utilisateur';

    final String? avatarUrl = post['avatar_url'];

    // 🔹 TEXTE DU POST
    final String caption = post['content']?.toString() ?? '';

    // 🔹 COULEUR STATUS
    final Color backgroundColor = isStatus && post['bg_color'] != null
        ? Color(int.parse(post['bg_color'].toString()))
        : const Color(0xFF0F0F0F);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ====== BARRE DE FERMETURE ======
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: 10,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // ====== HEADER ======
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey.shade700,
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            post['created_at']?.toString().substring(0, 16) ??
                                '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ====== MEDIA / STATUS ======
              Expanded(
                child: Center(
                  child: isStatus
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            caption,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : AspectRatio(
                          aspectRatio: 1,
                          child: buildPostMedia(
                            mediaUrl: post['image_url'] ?? post['media_url'],
                            text: caption,
                            preview: false,
                          ),
                        ),
                ),
              ),

              // ====== TEXTE (hors status) ======
              if (!isStatus && caption.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Text(
                    caption,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),

              // ====== STATS ======
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 18, color: Colors.red),
                        const SizedBox(width: 6),
                        Text((post['likes'] ?? 0).toString()),
                        const SizedBox(width: 18),
                        const Icon(Icons.comment, size: 18, color: Colors.blue),
                        const SizedBox(width: 6),
                        Text((post['comments'] ?? 0).toString()),
                      ],
                    ),

                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(post['id']),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ======================================================
  // CONFIRM DELETE
  // ======================================================
  // void _confirmDelete(int postId) {
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text("Supprimer le post"),
  //       content: const Text("Voulez-vous vraiment supprimer ce post ?"),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("Annuler"),
  //         ),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //           onPressed: () async {
  //             await SupabaseServicePoste.deletePost(postId);

  //             if (!mounted) return;
  //             Navigator.pop(context);

  //             final partyId = ref.read(activePartyIdProvider);
  //             if (partyId != null) {
  //               ref.read(postsProvider(partyId).notifier).load(silent: true);
  //             }
  //           },
  //           child: const Text("Supprimer"),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
