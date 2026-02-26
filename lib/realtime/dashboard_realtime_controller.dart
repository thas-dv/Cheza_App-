import 'dart:async';
import 'package:cheza_app/services/supabase_network_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class DashboardRealtimeController {
  RealtimeChannel? _attendanceChannel;
  RealtimeChannel? _dashboardChannel;
  Timer? _fallbackTimer;

  bool _disposed = false;

  // ===============================
  // ATTENDANCE REALTIME (VISITEURS)
  // ===============================
  void startAttendanceRealtime({
    required int partyId,
    required Future<void> Function() reloadClientele,
    required Future<void> Function() refreshClienteleCount,
  }) {
    if (!NetworkService.isConnected) {
      debugPrint("⛔ Realtime not started (offline)");
      return;
    }

    stopAttendanceRealtime();

    _attendanceChannel = Supabase.instance.client
        .channel('attendance-$partyId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'parties_attandance',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'party_id',
            value: partyId,
          ),
          callback: (_) async {
            if (_disposed) return;

            debugPrint("👥 ATTENDANCE REALTIME");

            await reloadClientele();
            await refreshClienteleCount();
          },
        )
        .subscribe();
  }

  void stopAttendanceRealtime() {
    _attendanceChannel?.unsubscribe();
    _attendanceChannel = null;
  }

  // ===============================
  // DASHBOARD REALTIME (POSTS)
  // ===============================
  void startDashboardRealtime({
    required int partyId,
    required Future<void> Function() refreshDashboardStats,
  }) {
    if (!NetworkService.isConnected) return;

    stopDashboardRealtime();

    _dashboardChannel = Supabase.instance.client
        .channel('dashboard-$partyId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'posts',
          callback: (_) async {
            if (_disposed) return;

            debugPrint("📝 POSTS REALTIME");
            await refreshDashboardStats();
          },
        )
        .subscribe();
  }

  void stopDashboardRealtime() {
    _dashboardChannel?.unsubscribe();
    _dashboardChannel = null;
  }

  // ===============================
  // FALLBACK RESYNC (SÉCURITÉ)
  // ===============================
  void startFallbackResync({
    required int partyId,
    required Future<void> Function() reloadClientele,
    required Future<void> Function() refreshClienteleCount,
    required Future<void> Function() refreshDashboardStats,
  }) {
    _fallbackTimer?.cancel();

    _fallbackTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (_disposed) return;
      if (!NetworkService.isConnected) return;

      debugPrint("🛟 FALLBACK RESYNC");

      await reloadClientele();
      await refreshClienteleCount();
      await refreshDashboardStats();
    });
  }

  // ===============================
  // CLEANUP
  // ===============================
  void dispose() {
    _disposed = true;

    _fallbackTimer?.cancel();
    _fallbackTimer = null;

    stopAttendanceRealtime();
    stopDashboardRealtime();
  }
}
