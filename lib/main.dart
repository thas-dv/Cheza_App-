// import 'package:cheza_app/pages/login.dart';
// import 'package:flutter/material.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // await Supabase.initialize(
//   //   url: 'https://xjpdbjymgszhupibxmyj.supabase.co',
//   //   anonKey:
//   //       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhqcGRianltZ3N6aHVwaWJ4bXlqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUxMTE1NDQsImV4cCI6MjA4MDY4NzU0NH0.1FsYm4JP0ieJrI_nMWd-DoHwIxtlf2R6gOG8av50tE4',
//   // );
//   await Supabase.initialize(
//     anonKey:
//         "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im13cHVlbWNicnpxa3BodXR4cWFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4MzYyMDksImV4cCI6MjA3NTQxMjIwOX0.W1Tt-PmWcQ2O4KWOfGKCM6lUwu_ATpbXEZTlVEs9HeM",
//     url: "https://mwpuemcbrzqkphutxqaq.supabase.co",
//      authOptions: const FlutterAuthClientOptions(
//     autoRefreshToken: true, // 🔥 CRUCIAL
//   ),
//   );
//   WidgetsFlutterBinding.ensureInitialized();
//   MediaKit.ensureInitialized();
//   runApp(const MyApp());
// }
import 'package:cheza_app/pages/login.dart';
import 'package:cheza_app/pages/start.dart';
// import 'package:cheza_app/services/supabase_service_admin.dart';
import 'package:cheza_app/themes/app_colors.dart';
import 'package:cheza_app/services/supabase_network_service.dart';
import 'package:cheza_app/widgets/local_party_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://mwpuemcbrzqkphutxqaq.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im13cHVlbWNicnpxa3BodXR4cWFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4MzYyMDksImV4cCI6MjA3NTQxMjIwOX0.W1Tt-PmWcQ2O4KWOfGKCM6lUwu_ATpbXEZTlVEs9HeM",
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: true, // comme Facebook
    ),
  );

  MediaKit.ensureInitialized();
  NetworkService.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data!.session;

        // ✅ Session valide
        if (session != null) {
          return const WelcomePage();
        }

        // ❗ Session null → vérifier stockage local
        return FutureBuilder<bool>(
          future: LocalPartyStorage.isPartyOpen(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final isOpen = snapshot.data!;

            if (isOpen) {
              // 🔥 Fête ouverte → accès autorisé
              return const WelcomePage();
            }

            // ❌ Fête fermée → login obligatoire
            return const LoginAdminPage();
          },
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

      // ICI LA MAGIE
      home: const AuthGate(),
    );
  }
}
