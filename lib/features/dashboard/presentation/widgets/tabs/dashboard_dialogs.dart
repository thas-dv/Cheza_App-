import 'package:flutter/material.dart';

class ClosePartyDialog extends StatelessWidget {
  const ClosePartyDialog({super.key});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Fermer l'établissement ?"),
      content: const Text("Voulez-vous vraiment passer en mode FERMÉ ?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Confirmer")),
      ],
    );
  }
}

class OpenPartyDialog extends StatelessWidget {
  const OpenPartyDialog({super.key});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Ouvrir l'établissement ?"),
      content: const Text("Prêt pour une nouvelle session ?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Ouvrir")),
      ],
    );
  }
}