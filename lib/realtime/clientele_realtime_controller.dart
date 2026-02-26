import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClienteleRealtimeController {
  RealtimeChannel? _channel;
  Timer? _debounceTimer;

  void start({
    required int? partyId,
    required Future<void> Function() onRefresh,
  }) {
    if (partyId == null) return;

    // ✅ TOUJOURS nettoyer avant de recréer
    stop();

    void safeRefresh() {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(
        const Duration(milliseconds: 300),
        () async {
          try {
            await onRefresh();
          } catch (_) {
            // 🧘 silence — l’UI gère déjà les erreurs réseau
          }
        },
      );
    }

    _channel = Supabase.instance.client
        .channel('clientele-party-$partyId')

        // ======================================================
        // 👥 VISITEURS (ENTRÉE / SORTIE / UPDATE)
        // ======================================================
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'parties_attandance',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'party_id',
            value: partyId,
          ),
          callback: (_) {
            debugPrint("👥 CLIENTÈLE CHANGE → refresh");
            safeRefresh();
          },
        )

        // ======================================================
        // 📝 POSTS (impact activité visiteurs)
        // ======================================================
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'posts',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'party_id',
            value: partyId,
          ),
          callback: (_) {
            debugPrint("📝 POST INSERT → refresh clientele");
            safeRefresh();
          },
        )

        // ======================================================
        // ✉️ INVITATIONS (impact stats)
        // ======================================================
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'party_invites',
          callback: (_) {
            debugPrint("✉️ INVITES CHANGE → refresh clientele");
            safeRefresh();
          },
        )
        .subscribe();
  }

  // ======================================================
  // STOP / CLEAN
  // ======================================================
  void stop() {
    _debounceTimer?.cancel();
    _debounceTimer = null;

    _channel?.unsubscribe();
    _channel = null;
  }

  void dispose() {
    stop();
  }
}
