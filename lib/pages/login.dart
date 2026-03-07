// import 'package:cheza_app/pages/dashboard/dashboard.dart';
import 'dart:async';
import 'dart:ui';

import 'package:cheza_app/core/storage/local_party_storage.dart';
import 'package:cheza_app/pages/dashboard/dashboard_page.dart';
// import 'package:cheza_app/pages/register_place.dart';
import 'package:cheza_app/services/supabase_network_service.dart';
import 'package:cheza_app/services/supabase_service_admin.dart';
import 'package:cheza_app/themes/app_colors.dart';
import 'package:cheza_app/widgets/network_aware_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:cheza_app/pages/registerAdmin.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class LoginAdminPage extends StatefulWidget {
  const LoginAdminPage({super.key});

  @override
  State<LoginAdminPage> createState() => _LoginAdminPageState();
}

class _LoginAdminPageState extends State<LoginAdminPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  late StreamSubscription<bool> _networkSub;
  final ScrollController _scrollController = ScrollController();

  bool hasConnection = true;
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool _hover = false;

  bool isLoading = false;
  bool isPasswordVisible = false;
  @override
  void initState() {
    super.initState();

    _networkSub = NetworkService.connectionStream.listen((connected) {
      if (!mounted) return;
      setState(() => hasConnection = connected);
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _networkSub.cancel();
    emailCtrl.dispose();
    passCtrl.dispose();
    _controller.dispose();
    _scrollController.dispose();

    super.dispose();
  }

 
 
  @override
  Widget build(BuildContext context) {
    return NetworkToastWrapper(
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: _buildBackgroundStack(
          MediaQuery.of(context).size.width > 900 &&
              MediaQuery.of(context).size.height > 600,
        ),
      ),
    );
  }

  ////////////////////////////////////////////

  Widget _buildBackgroundStack(bool isDesktop) {
    return Stack(
      children: [
        /// BACKGROUND
        Positioned.fill(
          child: Image.asset(
            "assets/images/fondlogin.png",
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
          ),
        ),

        /// OVERLAY
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

        /// CONTENU (SCROLL)
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Scrollbar(
                controller: _scrollController,
                thumbVisibility: !isDesktop,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 0 : 30,
                          vertical: 40,
                        ),
                        child: _loginCard(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        /// 🔥 BOUTON RETOUR (MIS EN DERNIER = CLIQUABLE)
        if (isDesktop)
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.4),
                        border: Border.all(
                          color: AppColors.neonPurple.withOpacity(0.4),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  ///////////////////////////////////////////////////
  Widget _neonInput({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 18,
        ),
        filled: true,
        fillColor: const Color(0xFF1A1443).withOpacity(0.6),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: Color(0xFF6A5AE0), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: Color(0xFFB44CFF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  ///////////////////////////////////

  ///////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////

  // ----------- Login logic simulation -----------
  void login() async {
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2)); // simulate

    setState(() => isLoading = false);

    // Remplacer par la vraie connexion Supabase
    // Navigator.pushReplacementNamed(context, "/dashboard");
  }

  Widget _loginCard() {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColors.deepIndigo.withOpacity(0.6),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: AppColors.neonPurple.withOpacity(0.3),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ICON
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Connexion Administrateur",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // TextFormField(
                    //   controller: emailCtrl,
                    //   decoration: _input("Email"),
                    //   validator: (v) {
                    //     if (v == null || v.isEmpty) return "Email obligatoire";
                    //     if (!v.contains("@")) return "Email invalide";
                    //     return null;
                    //   },
                    // ),
                    _neonInput(
                      controller: emailCtrl,
                      hint: "Email",
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Email obligatoire";
                        if (!v.contains("@")) return "Email invalide";
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // TextFormField(
                    //   controller: passCtrl,
                    //   obscureText: !isPasswordVisible,
                    //   decoration: _input("Mot de passe").copyWith(
                    //     suffixIcon: IconButton(
                    //       icon: Icon(
                    //         isPasswordVisible
                    //             ? Icons.visibility
                    //             : Icons.visibility_off,
                    //         color: Colors.white70,
                    //       ),
                    //       onPressed: () {
                    //         setState(() {
                    //           isPasswordVisible = !isPasswordVisible;
                    //         });
                    //       },
                    //     ),
                    //   ),
                    //   validator: (v) =>
                    //       v == null || v.isEmpty ? "Mot de passe requis" : null,
                    // ),
                    _neonInput(
                      controller: passCtrl,
                      hint: "Mot de passe",
                      obscure: !isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Mot de passe requis" : null,
                    ),

                    const SizedBox(height: 30),

                    // 🔥 BOUTON PREMIUM AVEC GLOW + HOVER
                    MouseRegion(
                      onEnter: (_) => setState(() => _hover = true),
                      onExit: (_) => setState(() => _hover = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: _hover
                              ? [
                                  BoxShadow(
                                    color: AppColors.neonPurple.withOpacity(
                                      0.7,
                                    ),
                                    blurRadius: 25,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                        child: ElevatedButton(
                          onPressed: (isLoading || !hasConnection)
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate())
                                    return;

                                  if (!hasConnection) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Aucune connexion Internet",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => isLoading = true);

                                  try {
                                    final email = emailCtrl.text
                                        .trim()
                                        .toLowerCase();
                                    final password = passCtrl.text.trim();

                                    final authRes = await supabase.auth
                                        .signInWithPassword(
                                          email: email,
                                          password: password,
                                        );

                                    final user = authRes.user;
                                    if (user == null) throw Exception();

                                    final admin = await supabase
                                        .from('admins')
                                        .select(
                                          'id, type_admin, is_active',
                                        )
                                        .eq('id', user.id)
                                        .eq('is_active', true)
                                        .maybeSingle();

                                    if (admin == null) throw Exception();
                                     final link = await supabase
                                        .from('admins_place')
                                        .select('place_id')
                                        .eq('admin_id', user.id)
                                        .eq('active', true)
                                        .limit(1)
                                        .maybeSingle();

                                    await LocalPartyStorage.clearSession();
                                    await LocalPartyStorage.setPartySession(
                                      isOpen: false,
                                      userId: user.id,
                                      placeId: (link?['place_id'] as int?) ?? 0,
                                    );

                                    // 🔥 TRANSITION SMOOTH VERS DASHBOARD
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        transitionDuration: const Duration(
                                          milliseconds: 600,
                                        ),
                                        pageBuilder: (_, __, ___) =>
                                            const DashboardPage(),
                                        transitionsBuilder:
                                            (_, animation, __, child) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              );
                                            },
                                      ),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          hasConnection
                                              ? "Erreur réseau"
                                              : "Connexion Internet requise",
                                        ),
                                      ),
                                    );
                                  } finally {
                                    if (mounted)
                                      setState(() => isLoading = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  hasConnection
                                      ? "Connexion"
                                      : "Connexion indisponible",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Pas de compte ?",
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterAdminPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Créer un compte",
                            style: TextStyle(
                              color: AppColors.neonPink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
