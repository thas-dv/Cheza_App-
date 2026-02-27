
import 'package:cheza_app/pages/client_detail_page.dart';
// import 'package:cheza_app/providers/clientele_provider.dart';
import 'package:cheza_app/providers/party_providers.dart';
import 'package:cheza_app/widgets/client_card.dart';
import 'package:cheza_app/widgets/retour_interne.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClienteleTab extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final int? partyId; // ✅ accepté pour compatibilité dashboard
  final int cachedCount;
  final bool isOnline;

  const ClienteleTab({
    super.key,
    required this.onBack,
    required this.cachedCount,
    required this.isOnline,
    this.partyId,
  });

  @override
  ConsumerState<ClienteleTab> createState() => _ClienteleTabState();
}

class _ClienteleTabState extends ConsumerState<ClienteleTab> {
  bool showDetail = false;
  Map<String, dynamic>? selectedClient;

  @override
  Widget build(BuildContext context) {
    return AppBackHandler(onBack: _handleBack, child: _buildBody());
  }

  void _handleBack() {
    if (showDetail) {
      setState(() {
        showDetail = false;
        selectedClient = null;
      });
      return;
    }
    widget.onBack();
  }

  Widget _buildBody() {
    final clients = ref.watch(clienteleProvider);

    // 🔥 EXACTEMENT COMME POSTS
    final int totalClients = clients.isNotEmpty
        ? clients.length
        : widget.cachedCount;

    final bool showOfflineFallback =
        !widget.isOnline && clients.isEmpty && widget.cachedCount > 0;

    debugPrint(
      "👥 CLIENTELE TAB | online=${widget.isOnline} | list=${clients.length} | cached=${widget.cachedCount}",
    );

    if (showDetail && selectedClient != null) {
      return ClientDetailPage(
        userId: selectedClient!['user_id'].toString(),
        attendeeId: selectedClient!['attendee_id'],
        onBack: _handleBack,
      );
    }

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
                "Visiteurs",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // ================= STAT =================
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              Text(
                totalClients.toString(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Visiteurs présents",
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ],
          ),
        ),

        // ================= LISTE =================
        Expanded(
          child: clients.isEmpty && !showOfflineFallback
              ? Center(
                  child: Text(
                    "Aucun visiteur connecté",
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                )
              : showOfflineFallback
              ? ListView.builder(
                  itemCount: widget.cachedCount,
                  itemBuilder: (_, __) => _offlinePlaceholderCard(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: clients.length,
                  itemBuilder: (_, index) {
                    final c = clients[index];

                    return ClientCard(
                      username: (c['username'] ?? 'Utilisateur').toString(),
                      avatarUrl: c['avatar_url'],
                      userId: (c['user_id'] ?? '').toString(),
                      attendeeId: c['attendee_id'] ?? 0,
                      posts: c['posts_count'] ?? 0,
                      invites: c['invites_count'] ?? 0,
                      onTap: () {
                        setState(() {
                          selectedClient = c;
                          showDetail = true;
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ================= OFFLINE PLACEHOLDER =================
  Widget _offlinePlaceholderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 22, backgroundColor: Colors.grey.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12, width: 120, color: Colors.grey.shade700),
                const SizedBox(height: 8),
                Container(height: 10, width: 80, color: Colors.grey.shade800),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
