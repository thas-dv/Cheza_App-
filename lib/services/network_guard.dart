import 'supabase_network_service.dart';

class NetworkGuard {
  static bool allowRequest({bool silent = true}) {
    if (!NetworkService.isConnected) {
      if (!silent) {
        // utile seulement en debug si tu veux
        print("🚫 Requête bloquée : pas d'internet");
      }
      return false;
    }
    return true;
  }
}
