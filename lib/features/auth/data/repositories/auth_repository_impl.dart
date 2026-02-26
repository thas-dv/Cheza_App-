import 'package:cheza_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:cheza_app/features/auth/domain/entities/startup_destination.dart';
import 'package:cheza_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._localDataSource);

  final AuthLocalDataSource _localDataSource;

  @override
  Future<StartupDestination> getStartupDestination() async {
    if (_localDataSource.hasActiveSession()) {
      return StartupDestination.dashboard;
    }

    final hasOfflineAccess = await _localDataSource.hasOpenPartyOfflineAccess();
    if (hasOfflineAccess) {
      return StartupDestination.dashboard;
    }

    return StartupDestination.login;
  }
}
