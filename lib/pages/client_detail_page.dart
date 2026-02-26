import 'dart:async';

import 'package:cheza_app/services/supabase_service_clientel.dart';
// import 'package:cheza_app/widgets/network_aware_wrapper.dart';
import 'package:cheza_app/widgets/video_plays.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientDetailPage extends StatefulWidget {
  final String userId;
  final int attendeeId;
  final VoidCallback? onBack;

  const ClientDetailPage({
    super.key,
    required this.userId,
    required this.attendeeId,
    this.onBack,
  });

  @override
  State<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends State<ClientDetailPage>
    with SingleTickerProviderStateMixin {
  bool loading = true;
  bool networkError = false;
  late final RealtimeChannel _clientChannel;
  Timer? _refreshTimer;
  bool _realtimeStarted = false;

  Map<String, dynamic>? profile;
  List posts = [];
  List invites = [];
  List ratings = [];
  List rewards = [];

  late TabController _tabController;
  //////////////////////////////////////////////////////////
  // @override
  // void initState() {
  //   super.initState();
  //   _tabController = TabController(length: 4, vsync: this);

  //   _tabController.addListener(() {
  //     if (mounted) setState(() {});
  //   });

  //   loadData();
  //   _initClientChannel();
  // }
  // @override
  // void initState() {
  //   super.initState();
  //   _tabController = TabController(length: 4, vsync: this);

  //   _loadInitialData(); // 🔹 UNE SEULE FOIS
  //   _initClientChannel();
  // }
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _loadInitialData();

    if (Supabase.instance.client.realtime.isConnected) {
      _initClientChannel();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => loading = true);

    final data = await SupabaseServiceClientel.fetchClientDetails(
      widget.userId,
      widget.attendeeId,
    );

    final allUserPosts = await SupabaseServiceClientel.fetchAllPostsByUser(
      widget.userId,
    );

    if (!mounted) return;

    setState(() {
      profile = data['profile'];
      invites = data['invites'];
      ratings = data['ratings'];
      rewards = data['rewards'];
      posts = allUserPosts;
      loading = false;
    });
  }

  /////////////////////////////////////////////////////////
  @override
  void dispose() {
    _refreshTimer?.cancel();
    _clientChannel.unsubscribe();
    _tabController.dispose();
    super.dispose();
  }

  /////////////////////////////////////////////:
  // void _safeRefresh() {
  //   _refreshTimer?.cancel();
  //   _refreshTimer = Timer(const Duration(milliseconds: 300), () {
  //     if (mounted) {
  //       loadData(); // 🔥 recalcul DB
  //     }
  //   });
  // }

  ///////////////////////////////////////
  bool _isVideo(String url) {
    final u = url.toLowerCase();
    return u.contains('.mp4') ||
        u.contains('.mov') ||
        u.contains('.webm') ||
        u.contains('.mkv') ||
        u.contains('.avi');
  }

  ////////////////////////////////////////////////////
  String _cleanUrl(String url) {
    return url.split('?').first;
  }

  //////////////////////////////////////////////////
  void _initClientChannel() {
    if (_realtimeStarted) return;
    _realtimeStarted = true;
    _clientChannel = Supabase.instance.client
        .channel('client-posts-global-${widget.userId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'posts',
          callback: (payload) {
            final newPost = payload.newRecord;

            debugPrint("🟢 NEW POST RECEIVED");

            // ignore: unnecessary_null_comparison
            if (newPost == null) return;

            // 🔍 Vérification utilisateur
            if (newPost['user_id'] == widget.userId) {
              debugPrint("✅ POST MATCH USER → REFRESH");

              _addPostLocally(newPost);
            } else {
              debugPrint("⏭ POST IGNORED (OTHER USER)");
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'party_invites',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'attendee_id',
            value: widget.attendeeId,
          ),
          callback: (_) {
            debugPrint("📩 INVITE CHANGED → REFRESH");
            _refreshInvites();
          },
        )
        .subscribe((status, err) {
          debugPrint("📡 REALTIME STATUS: $status");
          if (err != null) {
            debugPrint("❌ REALTIME ERROR: $err");
          }
        });
  }

  void _addPostLocally(Map<String, dynamic> newPost) {
    if (!mounted) return;

    final exists = posts.any((p) => p['id'] == newPost['id']);
    if (exists) return; // 🛑 anti-doublon ultime

    setState(() {
      posts.insert(0, newPost); // Instagram-style
    });
  }

  // Future<void> _refreshPosts() async {
  //   debugPrint("🔄 REFRESH POSTS");

  //   debugPrint("🔥 fetchAllPostsByUser CALLED");

  //   final allUserPosts = await SupabaseServiceClientel.fetchAllPostsByUser(
  //     widget.userId,
  //   );

  //   if (!mounted) return;

  //   setState(() {
  //     posts = allUserPosts;
  //   });

  //   debugPrint("✅ POSTS UPDATED → count=${posts.length}");
  // }

  void _refreshInvites() async {
    final data = await Supabase.instance.client
        .from('party_invites')
        .select('id, accepted')
        .eq('attendee_id', widget.attendeeId);

    if (!mounted) return;

    setState(() {
      invites = data;
    });
  }

  ////////////////////////////////////////////
  int get rewardsTotal {
    if (rewards.isEmpty) return 0;

    int total = 0;

    for (final r in rewards) {
      final raw = r['reward_points'];

      if (raw is num) {
        total += raw.toInt(); // ✅ conversion sûre
      }
    }

    return total;
  }

  ///////////////////////////////////////////////////////////////
  // Future<void> loadData() async {
  //   setState(() {
  //     loading = true;
  //     networkError = false;
  //   });

  //   try {
  //     final data = await SupabaseServiceClientel.fetchClientDetails(
  //       widget.userId,
  //       widget.attendeeId,
  //     );
  //     final posts = await SupabaseServiceClientel.fetchAllPostsByUser(widget.userId);

  //     setState(() {
  //       profile = data['profile'];
  //       posts = data['posts'];
  //       invites = data['invites'];
  //       ratings = data['ratings'];
  //       rewards = data['rewards'];
  //       loading = false;
  //     });
  //   } catch (e) {
  //     debugPrint("❌ ERREUR CONNEXION : $e");

  //     setState(() {
  //       loading = false;
  //       networkError = true;
  //     });
  //   }
  // }
  Future<void> loadData() async {
    setState(() {
      loading = true;
      networkError = false;
    });

    try {
      // 🔹 Infos client (invites, ratings, rewards, profil)
      final data = await SupabaseServiceClientel.fetchClientDetails(
        widget.userId,
        widget.attendeeId,
      );

      // 🔥 TOUS LES POSTS DE L’UTILISATEUR (TOUTES FÊTES)
      final allUserPosts = await SupabaseServiceClientel.fetchAllPostsByUser(
        widget.userId,
      );

      setState(() {
        profile = data['profile'];

        posts = allUserPosts; // ✅ LA BONNE VARIABLE

        invites = data['invites'];
        ratings = data['ratings'];
        rewards = data['rewards'];

        loading = false;
      });
    } catch (e, s) {
      debugPrint("❌ ERREUR CONNEXION : $e");
      debugPrint("📍 STACK: $s");

      setState(() {
        loading = false;
        networkError = true;
      });
    }
  }

  /////////////////////////////////////////////////
  Widget _internetError({String message = "Problème de connexion Internet"}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Réessayer"),
              onPressed: loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _profileHeader(), // header (avatar + boutons)
            ),
            SliverPersistentHeader(
              pinned: true, // reste collé comme Instagram
              delegate: _TabBarDelegate(_tabBar()),
            ),
          ];
        },
        body: _tabViews(), // GridView / ListView
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   if (loading) {
  //     return NetworkToastWrapper(
  //       child: const Scaffold(body: Center(child: CircularProgressIndicator())),
  //     );
  //   }

  //   return NetworkToastWrapper(
  //     child: Scaffold(
  //       backgroundColor: const Color(0xFF0F0F0F),
  //       body: NestedScrollView(
  //         headerSliverBuilder: (context, innerBoxIsScrolled) {
  //           return [
  //             SliverToBoxAdapter(
  //               child: _profileHeader(), // ton header (avatar + boutons)
  //             ),

  //             SliverPersistentHeader(
  //               pinned: true, // 👈 reste collé comme Instagram
  //               delegate: _TabBarDelegate(_tabBar()),
  //             ),
  //           ];
  //         },
  //         body: _tabViews(), // 👈 GridView / ListView
  //       ),
  //     ),
  //   );
  // }

  ///////////////////////////////////////////////////
  Widget _profileHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min, // ✅ CLÉ ANTI-OVERFLOW
          children: [
            // ===== TOP BAR =====
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onBack,
                ),
                Expanded(
                  child: Text(
                    profile?['username'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _confirmDisconnect,
                ),
              ],
            ),

            const SizedBox(height: 12),

            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.shade800,
              backgroundImage: profile?['avatar_url'] != null
                  ? NetworkImage(profile!['avatar_url'])
                  : null,
            ),

            const SizedBox(height: 8),

            Text(
              "@${profile?['username'] ?? ''}",
              style: TextStyle(color: Colors.grey.shade400),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _profileStat(posts.length, "Posts"),
                _profileStat(invites.length, "Invitations"),
                _profileStat(ratings.length, "Notes"),
                _profileStat(rewardsTotal, "Récomp."),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(child: _profileButton("Déconnecter", Colors.red)),
                const SizedBox(width: 8),
                Expanded(
                  child: _profileButton("Recompenser", Colors.grey.shade800),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /////////////////////////////////////////////////////////
  Widget _profileStat(int value, String label) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  //////////////////////////////////////////////////////////////////
  Widget _profileButton(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  /////////////////////////////////////////////////////
  Future<void> _confirmDisconnect() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Déconnecter"),
        content: const Text(
          "Voulez-vous vraiment déconnecter ce visiteur de la soirée ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Déconnecter"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    // await SupabaseServiceClientel.disconnect(widget.attendeeId);

    widget.onBack?.call();
  }

  /////////////////////////////////////////////////////
  Widget _tabBar() {
    return SizedBox(
      height: 72,
      child: AnimatedBuilder(
        animation: _tabController.animation!,
        builder: (context, _) {
          return Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _tabItem(Icons.grid_on, 0),
                _tabItem(Icons.mail_outline, 1),
                _tabItem(Icons.star_border, 2),
                _tabItem(Icons.card_giftcard, 3),
              ],
            ),
          );
        },
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  Widget _tabItem(IconData icon, int index) {
    final value = _tabController.animation!.value;
    final isSelected = (value - index).abs() < 0.5;

    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: isSelected ? Colors.white : Colors.grey),
          const SizedBox(height: 6),
          Container(
            height: 2,
            width: isSelected ? 24 : 0,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 223, 212, 212),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  /////////////////////////////////////////////////////
  // void _openPost(Map<String, dynamic> post) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (_) {
  //       return Container(
  //         height: MediaQuery.of(context).size.height * 0.95,
  //         decoration: const BoxDecoration(
  //           color: Color(0xFF0F0F0F),
  //           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  //         ),
  //         child: Column(
  //           children: [
  //             // ====== BARRE DE FERMETURE ======
  //             Padding(
  //               padding: const EdgeInsets.symmetric(vertical: 10),
  //               child: Container(
  //                 width: 40,
  //                 height: 4,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey.shade600,
  //                   borderRadius: BorderRadius.circular(4),
  //                 ),
  //               ),
  //             ),

  //             // ====== HEADER ======
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 16),
  //               child: Row(
  //                 children: [
  //                   CircleAvatar(
  //                     radius: 18,
  //                     backgroundColor: Colors.grey.shade700,
  //                     backgroundImage: profile?['avatar_url'] != null
  //                         ? NetworkImage(profile!['avatar_url'])
  //                         : null,
  //                   ),
  //                   const SizedBox(width: 10),
  //                   Expanded(
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           profile?['username'] ?? 'Utilisateur',
  //                           style: const TextStyle(fontWeight: FontWeight.w600),
  //                         ),
  //                         Text(
  //                           post['created_at']?.toString().substring(0, 16) ??
  //                               '',
  //                           style: TextStyle(
  //                             fontSize: 12,
  //                             color: Colors.grey.shade400,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   IconButton(
  //                     icon: const Icon(Icons.close),
  //                     onPressed: () => Navigator.pop(context),
  //                   ),
  //                 ],
  //               ),
  //             ),

  //             const SizedBox(height: 12),

  //             // ====== MEDIA CENTRÉ (CLÉ) ======
  //             Expanded(
  //               child: Center(
  //                 child: AspectRatio(
  //                   aspectRatio: 1, // 👈 carré type Instagram
  //                   child: buildPostMedia(
  //                     mediaUrl: post['image_url'] ?? post['media_url'],
  //                     text: post['caption'],
  //                     preview: false,
  //                   ),
  //                 ),
  //               ),
  //             ),

  //             // ====== TEXTE (SI EXISTE) ======
  //             if ((post['caption'] ?? '').toString().isNotEmpty)
  //               Padding(
  //                 padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
  //                 child: Text(
  //                   post['caption'],
  //                   textAlign: TextAlign.center,
  //                   style: const TextStyle(fontSize: 15),
  //                 ),
  //               ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  void _openPost(Map<String, dynamic> post) {
    final mediaUrl = (post['image_url'] ?? post['media_url'])?.toString();
    final bool isStatus = post['is_status'] == true;
    final Color backgroundColor = isStatus && post['bg_color'] != null
        ? Color(int.parse(post['bg_color']))
        : const Color(0xFF0F0F0F);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.95,
          decoration: BoxDecoration(
            color: backgroundColor, // ✅ DYNAMIQUE
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ====== BARRE DE FERMETURE ======
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: 40,
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
                      backgroundImage: post['avatar_url'] != null
                          ? NetworkImage(post['avatar_url'])
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['username'] ?? 'Utilisateur',
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

                    // ❌ FERMER
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ====== MEDIA ======
              Expanded(
                child: Center(
                  child: isStatus
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            post['caption'] ?? '',
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
                            mediaUrl: mediaUrl,
                            text: post['caption'],
                            preview: false,
                          ),
                        ),
                ),
              ),

              // ====== TEXTE ======
              if (!isStatus && (post['caption'] ?? '').toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Text(
                    post['caption'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),

              // ====== STATS + SUPPRESSION ======
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ❤️ 💬 STATS
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 18, color: Colors.red),
                        const SizedBox(width: 6),
                        Text(post['likes'].toString()),
                        const SizedBox(width: 18),
                        const Icon(Icons.comment, size: 18, color: Colors.blue),
                        const SizedBox(width: 6),
                        Text(post['comments'].toString()),
                      ],
                    ),

                    // 🗑️ SUPPRIMER
                    // IconButton(
                    //   icon: const Icon(Icons.delete, color: Colors.red),
                    //   onPressed: () => _confirmDelete(post['id']),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ///////////////////////////////////////////
  Widget _tabViews() {
    return TabBarView(
      controller: _tabController,
      children: [_postsTab(), _invitesTab(), _ratingsTab(), _rewardsTab()],
    );
  }

  ///////////////////////////////////////////
  Widget _invitesTab() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (networkError) {
      return _internetError(
        message:
            "Impossible de charger les invitations.\nVérifiez votre connexion Internet.",
      );
    }

    if (invites.isEmpty) {
      return _empty("Aucune invitation");
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invites.length,
      itemBuilder: (_, i) {
        final invite = invites[i];
        final bool accepted = invite['accepted'] == true;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              // ✉️ ICÔNE
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accepted
                      ? Colors.green.withOpacity(0.15)
                      : Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  accepted ? Icons.check_circle : Icons.mail_outline,
                  color: accepted ? Colors.green : Colors.orange,
                ),
              ),

              const SizedBox(width: 12),

              // TEXTE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      accepted ? "Invitation acceptée" : "Invitation envoyée",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      accepted
                          ? "Le visiteur a accepté"
                          : "En attente de réponse",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
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

  ///////////////////////////////////////
  Widget _ratingsTab() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (networkError) {
      return _internetError(
        message:
            "Impossible de charger les notes.\nVérifiez votre connexion Internet.",
      );
    }

    if (ratings.isEmpty) {
      return _empty("Aucune note");
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ratings.length,
      itemBuilder: (_, i) {
        final r = ratings[i];

        final double avg =
            (((r['service'] ?? 0) +
                        (r['music'] ?? 0) +
                        (r['vibe'] ?? 0) +
                        (r['decor'] ?? 0)) /
                    4)
                .toDouble();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              // ICÔNE + NOTE
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    avg.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // TEXTE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Note du visiteur",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Service • Musique • Ambiance • Décor",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
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

  //////////////////////////////////////////////////
  Widget _rewardsTab() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (networkError) {
      return _internetError(
        message:
            "Impossible de charger les récompenses.\nVérifiez votre connexion Internet.",
      );
    }

    if (rewards.isEmpty) {
      return _empty("Aucune récompense");
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rewards.length,
      itemBuilder: (_, i) {
        final reward = rewards[i];

        final String title = reward['reward_desc']?.toString() ?? "Récompense";
        final int points = (reward['reward_points'] is num)
            ? reward['reward_points'].toInt()
            : 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              // 🎁 ICÔNE
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.card_giftcard, color: Colors.amber),
              ),

              const SizedBox(width: 12),

              // 📄 TEXTE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Récompense attribuée",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),

              // ⭐ POINTS
              Text(
                "+$points",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //////////////////////////////////////////////////////////////
  Widget _postsTab() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (networkError) {
      return _internetError(
        message:
            "Impossible de charger les publications.\nVérifiez votre connexion Internet.",
      );
    }

    if (posts.isEmpty) {
      return _empty("Aucun post publié");
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      primary: false,
      physics: const ClampingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: posts.length,
      itemBuilder: (_, index) {
        final post = posts[index];
        return _tabPostTile(post);
      },
    );
  }

  ///////////////////////////////////////////////////////////
  Widget _tabPostTile(Map<String, dynamic> post) {
    // final mediaUrl = post['image_url'] ?? post['media_url'];
    final mediaUrl = (post['image_url'] ?? post['media_url'])?.toString();
    final bool isStatus = post['is_status'] == true;
    final Color backgroundColor = isStatus && post['bg_color'] != null
        ? Color(int.parse(post['bg_color']))
        : const Color(0xFF0F0F0F);
    final caption = post['caption'] ?? '';

    return InkWell(
      onTap: () {
        _openPost(post);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          color: backgroundColor,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 🖼️ IMAGE / 🎥 VIDÉO
              if (mediaUrl != null && mediaUrl.toString().isNotEmpty)
                buildPostMedia(mediaUrl: mediaUrl, preview: true)
              // 📝 TEXTE SEUL
              else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      caption,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                    ),
                  ),
                ),

              // 🎥 ICÔNE VIDÉO
              if (mediaUrl != null &&
                  (mediaUrl.toString().endsWith('.mp4') ||
                      mediaUrl.toString().endsWith('.mov') ||
                      mediaUrl.toString().endsWith('.webm')))
                const Positioned(
                  top: 6,
                  right: 6,
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  // Widget _tabPostTile(Map<String, dynamic> post) {
  //   final bool isStatus = post['is_status'] == true;
  //   final mediaUrl = post['image_url'] ?? post['media_url'];
  //   final caption = post['caption'] ?? post['content'] ?? '';

  //   final Color bgColor = isStatus && post['bg_color'] != null
  //       ? Color(int.parse(post['bg_color']))
  //       : const Color(0xFF1E1E1E);

  //   return InkWell(
  //     onTap: () => _openPost(post),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(4),
  //       child: Container(
  //         color: bgColor, // ✅ FOND DYNAMIQUE
  //         child: Stack(
  //           fit: StackFit.expand,
  //           children: [
  //             // 🟢 STATUS (TEXTE SEUL)
  //             if (isStatus)
  //               Center(
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(8),
  //                   child: Text(
  //                     caption,
  //                     maxLines: 4,
  //                     overflow: TextOverflow.ellipsis,
  //                     textAlign: TextAlign.center,
  //                     style: const TextStyle(
  //                       fontSize: 13,
  //                       color: Colors.white,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //                 ),
  //               )
  //             // 🔵 IMAGE / VIDÉO
  //             else if (mediaUrl != null && mediaUrl.toString().isNotEmpty)
  //               buildPostMedia(mediaUrl: mediaUrl, preview: true)
  //             // ⚪ TEXTE SIMPLE
  //             else
  //               Center(
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(8),
  //                   child: Text(
  //                     caption,
  //                     maxLines: 4,
  //                     overflow: TextOverflow.ellipsis,
  //                     textAlign: TextAlign.center,
  //                     style: const TextStyle(fontSize: 13, color: Colors.white),
  //                   ),
  //                 ),
  //               ),

  //             // 🎥 ICÔNE VIDÉO
  //             if (!isStatus &&
  //                 mediaUrl != null &&
  //                 _isVideo(mediaUrl.toString()))
  //               const Positioned(
  //                 top: 6,
  //                 right: 6,
  //                 child: Icon(
  //                   Icons.play_circle_fill,
  //                   color: Colors.white,
  //                   size: 20,
  //                 ),
  //               ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  //////////////////////////////////////////////
  Widget _empty(String text) {
    return Center(
      child: Text(text, style: TextStyle(color: Colors.grey.shade500)),
    );
  }

  ////////////////////////////////////////////////////////////
  Widget buildPostMedia({
    required String? mediaUrl,
    String? text,
    bool preview = false,
  }) {
    // 📝 TEXTE SEUL
    if (mediaUrl == null || mediaUrl.isEmpty) {
      return Text(
        text ?? '',
        maxLines: preview ? 3 : null,
        overflow: preview ? TextOverflow.ellipsis : null,
        textAlign: TextAlign.center,
      );
    }

    final rawUrl = mediaUrl;
    final cleanUrl = _cleanUrl(rawUrl);

    // 🎥 VIDÉO (TOUS TYPES)
    if (_isVideo(cleanUrl)) {
      if (preview) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Icon(Icons.play_circle_fill, size: 36, color: Colors.white),
          ),
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: VideoPlayerWidget(url: rawUrl),
      );
    }

    // 🖼️ IMAGE (TOUT LE RESTE)
    return Image.network(
      rawUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _mediaError(),
    );
  }

  ////////////////////////////////////////////////
  Widget _mediaError() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey, size: 28),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => 72; // ✅ EXACTEMENT la même valeur

  @override
  double get maxExtent => 72;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xFF0F0F0F), child: tabBar);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
