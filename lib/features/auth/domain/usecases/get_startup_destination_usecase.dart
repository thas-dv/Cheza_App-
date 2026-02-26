import 'package:cheza_app/features/auth/domain/entities/startup_destination.dart';
import 'package:cheza_app/features/auth/domain/repositories/auth_repository.dart';

class GetStartupDestinationUseCase {
  const GetStartupDestinationUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<StartupDestination> call() {
    return _authRepository.getStartupDestination();
  }
}