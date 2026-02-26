import 'package:flutter/material.dart';

class NetworkToast extends StatelessWidget {
  final bool isConnected;

  const NetworkToast({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      child: Material(
        color: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isConnected ? const Color(0xFF2E7D32) : Colors.black,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isConnected ? Icons.wifi : Icons.wifi_off,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isConnected
                    ? "Connexion Internet restaurée"
                    : "Vous êtes actuellement hors ligne",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
