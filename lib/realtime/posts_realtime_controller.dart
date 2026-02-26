import 'dart:async';
// import 'package:cheza_app/services/supabase_service_poste.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostsRealtimeController {
  RealtimeChannel? _channel;
  Timer? _fallbackTimer;

  void start({
    required int partyId,
    required void Function(Map<String, dynamic>) onInsert,
    required Future<void> Function() refreshCount,
    required Future<void> Function() refreshList,
  }) {
    stop();

    _channel = Supabase.instance.client
        .channel('posts')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'posts',
          callback: (payload) async {
            debugPrint("🟢 POSTS INSERT REALTIME");

            // 🔥 1️⃣ AJOUT LOCAL IMMÉDIAT
            onInsert(payload.newRecord);

            // 🔁 2️⃣ RESYNC APRÈS PROPAGATION
            Future.delayed(const Duration(seconds: 2), () async {
              debugPrint("🔁 POSTS RESYNC AFTER JOIN");
              await refreshList();
            });
          },
        );

    // 🛟 fallback sécurité
    _fallbackTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      debugPrint("🛟 POSTS FALLBACK");
      await refreshCount();
      await refreshList();
    });
  }


  void stop() {
    _channel?.unsubscribe();
    _fallbackTimer?.cancel();
  }
}
