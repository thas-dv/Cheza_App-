import 'package:cheza_app/features/auth/domain/entities/startup_destination.dart';

abstract class AuthRepository {
  Future<StartupDestination> getStartupDestination();
}