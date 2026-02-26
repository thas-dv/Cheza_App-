import 'package:flutter/material.dart';

class NetworkErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const NetworkErrorView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "Impossible de charger les données.\nVérifiez votre connexion Internet.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Réessayer"),
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
