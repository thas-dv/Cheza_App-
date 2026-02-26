import 'package:cheza_app/widgets/local_party_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource(this._client);

  final SupabaseClient _client;

  bool hasActiveSession() => _client.auth.currentSession != null;

  Future<bool> hasOpenPartyOfflineAccess() {
    return LocalPartyStorage.isPartyOpen();
  }
}