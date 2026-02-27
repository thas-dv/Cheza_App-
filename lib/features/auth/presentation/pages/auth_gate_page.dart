import 'package:cheza_app/features/auth/domain/entities/startup_destination.dart';
import 'package:cheza_app/features/auth/domain/usecases/get_startup_destination_usecase.dart';
import 'package:cheza_app/pages/login.dart';
import 'package:cheza_app/pages/start.dart';
import 'package:flutter/material.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({
    required GetStartupDestinationUseCase getStartupDestination,
    super.key,
  }) : _getStartupDestination = getStartupDestination;

  final GetStartupDestinationUseCase _getStartupDestination;
  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  late final Future<StartupDestination> _startupFuture;

  @override
  void initState() {
    super.initState();
    _startupFuture = widget._getStartupDestination();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StartupDestination>(
      future: _startupFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          debugPrint('AuthGate startup failure: ${snapshot.error}');
          return const LoginAdminPage();
        }

        if (!snapshot.hasData) {
          return const LoginAdminPage();
        }
        return switch (snapshot.data!) {
          StartupDestination.dashboard => const WelcomePage(),
          StartupDestination.login => const LoginAdminPage(),
        };
      },
    );
  }
}
