import 'package:cheza_app/themes/app_colors.dart';
import 'package:cheza_app/widgets/network_aware_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:cheza_app/pages/login.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool _hover = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   final size = MediaQuery.of(context).size;
  //   final isDesktop = size.width > 900 && size.height > 600;

  //   return Scaffold(
  //     backgroundColor: AppColors.backgroundDark,

  //     body: FadeTransition(
  //       opacity: _fade,
  //       child: isDesktop
  //           ? Center(
  //               child: Container(
  //                 height: MediaQuery.of(context).size.height * 0.85,
  //                 margin: const EdgeInsets.all(25),
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(25),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.black.withOpacity(0.5),
  //                       blurRadius: 40,
  //                     ),
  //                   ],
  //                 ),
  //                 child: ClipRRect(
  //                   borderRadius: BorderRadius.circular(25),
  //                   child: _buildStackContent(isDesktop),
  //                 ),
  //               ),
  //             )
  //           : SingleChildScrollView(
  //               child: SizedBox(
  //                 height: MediaQuery.of(context).size.height,
  //                 width: double.infinity,
  //                 child: _buildStackContent(isDesktop),
  //               ),
  //             ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return NetworkToastWrapper(
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: _buildStackContent(
          MediaQuery.of(context).size.width > 900 &&
              MediaQuery.of(context).size.height > 600,
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////////
  Widget _buildStackContent(bool isDesktop) {
    return Stack(
      children: [
        /// 🔥 BACKGROUND FULL SCREEN
        Positioned.fill(
          child: Image.asset(
            "assets/images/fondlogin.png",
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
          ),
        ),

        /// 🔥 OVERLAY
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.background.withOpacity(0.98),
                  AppColors.background.withOpacity(0.90),
                  AppColors.background.withOpacity(0.65),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.55, 1],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 80 : 30,
            vertical: isDesktop ? 60 : 40,
          ),
          child: isDesktop
              ? Row(
                  children: [
                    Expanded(flex: 5, child: _leftSection(isDesktop)),
                    const Spacer(flex: 5),
                  ],
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 50),
                            _leftSection(isDesktop),
                            const SizedBox(
                              height: 20,
                            ), // sécurité anti-overflow
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================================
  // SECTION GAUCHE (TEXTE + BOUTON EN BAS)
  // ==========================================================
  Widget _leftSection(bool isDesktop) {
    return Column(
      crossAxisAlignment: isDesktop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      mainAxisAlignment: isDesktop
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,

      children: [
        const Text(
          "Welcome to",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 20),
        ),

        const SizedBox(height: 20),

        Text(
          "Gérez votre Lieu\n de Vie Nocturne\navec Facilité.",
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 48 : 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 25),

        SizedBox(
          // width: isDesktop ? 450 : double.infinity,
          width: isDesktop ? 450 : null,
          child: Text(
            "L'outil professionnel et convivial pour les propriétaires de clubs, lounges et événements.",
            textAlign: isDesktop ? TextAlign.left : TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ),

        const SizedBox(height: 40),

        // 🔥 BOUTON EN BAS DU TEXTE
        _gradientButton(),
      ],
    );
  }

  // ==========================================================
  // BOUTON AVEC GLOW + HOVER + NAVIGATION
  // ==========================================================
  Widget _gradientButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: AppColors.neonPurple.withOpacity(0.6),
                    blurRadius: 25,
                    spreadRadius: 3,
                  ),
                ]
              : [],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginAdminPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          ),
          child: const Text(
            "Commencer",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
