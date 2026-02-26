import 'package:flutter/material.dart';

class AppBackHandler extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBack;

  const AppBackHandler({super.key, required this.child, this.onBack});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (onBack != null) {
          onBack!();
          return false;
        }

        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          return false;
        }

        // ✅ SEULEMENT ICI on autorise la sortie de l’app
        return true;
      },
      child: child,
    );
  }
}
