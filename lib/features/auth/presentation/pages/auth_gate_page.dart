import 'package:cheza_app/features/auth/domain/entities/startup_destination.dart';
import 'package:cheza_app/features/auth/domain/usecases/get_startup_destination_usecase.dart';
import 'package:cheza_app/pages/login.dart';
import 'package:cheza_app/pages/start.dart';
import 'package:flutter/material.dart';

class AuthGatePage extends StatelessWidget {
  const AuthGatePage({
    required GetStartupDestinationUseCase getStartupDestination,
    super.key,
  }) : _getStartupDestination = getStartupDestination;

  final GetStartupDestinationUseCase _getStartupDestination;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StartupDestination>(
      future: _getStartupDestination(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return switch (snapshot.data!) {
          StartupDestination.dashboard => const WelcomePage(),
          StartupDestination.login => const LoginAdminPage(),
        };
      },
    );
  }
}