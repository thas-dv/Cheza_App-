import 'package:flutter_riverpod/legacy.dart';

class DashboardStats {
  final int visitors;
  final int posts;
  final int notes;
  final int engagement;

  DashboardStats({
    required this.visitors,
    required this.posts,
    required this.notes,
    required this.engagement,
  });
}

// ✅ SIMPLE STATE (PAS ASYNC)
final dashboardStatsProvider = StateProvider<DashboardStats?>((ref) => null);

// =======================
// CLIENTÈLE
// =======================
final clienteleProvider =
    StateNotifierProvider<ClienteleNotifier, List<Map<String, dynamic>>>(
      (ref) => ClienteleNotifier(),
    );

class ClienteleNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ClienteleNotifier() : super([]);

  void setClients(List<Map<String, dynamic>> clients) {
    state = clients;
  }

  void clear() {
    state = [];
  }
}
