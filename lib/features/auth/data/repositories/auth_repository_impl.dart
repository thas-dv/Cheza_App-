import 'package:cheza_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:cheza_app/features/auth/domain/entities/startup_destination.dart';
import 'package:cheza_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._localDataSource);

  final AuthLocalDataSource _localDataSource;

  @override
  Future<StartupDestination> getStartupDestination() async {
    try {
      final seenWelcome = await _localDataSource.hasSeenWelcome();

      if (!seenWelcome) {
        await _localDataSource.markWelcomeSeen();
        return StartupDestination.welcome;
      }

      if (_localDataSource.hasActiveSession()) {
        final canOpenDashboard = await _localDataSource
            .hasActiveOpenedPlaceForCurrentUser()
            .timeout(const Duration(seconds: 4), onTimeout: () => false);

        if (canOpenDashboard) {
          return StartupDestination.dashboard;
        }

        final hasOfflineAccess = await _localDataSource
            .hasOpenPartyOfflineAccessForCurrentUser()
            .timeout(const Duration(seconds: 2), onTimeout: () => false);

        if (hasOfflineAccess) {
          return StartupDestination.dashboard;
        }
      }
    } catch (_) {
      return StartupDestination.login;
    }

    return StartupDestination.login;
  }
}