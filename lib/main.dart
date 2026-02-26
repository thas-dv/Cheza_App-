import 'package:cheza_app/app/cheza_app.dart';
import 'package:cheza_app/core/config/app_constants.dart';
import 'package:cheza_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:cheza_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cheza_app/features/auth/domain/usecases/get_startup_destination_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: true,
    ),
  );

  MediaKit.ensureInitialized();

  final authDataSource = AuthLocalDataSource(Supabase.instance.client);
  final authRepository = AuthRepositoryImpl(authDataSource);
  final getStartupDestination =
      GetStartupDestinationUseCase(authRepository);

  runApp(
    ProviderScope(
      child: ChezaApp(
        getStartupDestination: getStartupDestination,
      ),
    ),
  );
}