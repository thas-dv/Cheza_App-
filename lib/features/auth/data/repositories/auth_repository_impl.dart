import 'package:cheza_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:cheza_app/features/auth/domain/entities/startup_destination.dart';
import 'package:cheza_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._localDataSource);

  final AuthLocalDataSource _localDataSource;

  @override
  Future<StartupDestination> getStartupDestination() async {
    try {
      if (_localDataSource.hasActiveSession()) {
        return StartupDestination.dashboard;
      }

      final hasOfflineAccess = await _localDataSource
          .hasOpenPartyOfflineAccess()
          .timeout(const Duration(seconds: 3), onTimeout: () => false);
      if (hasOfflineAccess) {
        return StartupDestination.dashboard;
      }
    } catch (_) {
      return StartupDestination.login;
    }

    return StartupDestination.login;
  }
}
