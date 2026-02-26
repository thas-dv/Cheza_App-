// lib/pages/dashboard/tabs/parties_tab.dart

import 'package:cheza_app/widgets/retour_interne.dart';
import 'package:flutter/material.dart';

class PartiesTab extends StatelessWidget {
  final VoidCallback? onBack;
  const PartiesTab({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return AppBackHandler(
      onBack: onBack,
      child: const Center(
        child: Text(
          "Parties (à compléter)",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
