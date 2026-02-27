import 'package:cheza_app/core/storage/local_party_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource(this._client);

  final SupabaseClient _client;

  bool hasActiveSession() {
    try {
      return _client.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasOpenPartyOfflineAccess() async {
    try {
      return await LocalPartyStorage.isPartyOpen();
    } catch (_) {
      return false;
    }
  }
}
