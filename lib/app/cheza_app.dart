import 'package:cheza_app/features/auth/presentation/pages/auth_gate_page.dart';
import 'package:cheza_app/features/auth/domain/usecases/get_startup_destination_usecase.dart';
import 'package:cheza_app/themes/app_colors.dart';
import 'package:flutter/material.dart';

class ChezaApp extends StatelessWidget {
  const ChezaApp({required this.getStartupDestination, super.key});

  final GetStartupDestinationUseCase getStartupDestination;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark().copyWith(
          primary: AppColors.neonPurple,
          secondary: AppColors.neonPink,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundDark,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.deepIndigo,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: AppColors.textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          ),
        ),
      ),
      home: AuthGatePage(getStartupDestination: getStartupDestination),
    );
  }
}