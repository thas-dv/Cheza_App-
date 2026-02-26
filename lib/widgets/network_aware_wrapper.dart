import 'dart:async';
import 'package:cheza_app/widgets/network_banner.dart';
import 'package:flutter/material.dart';
import '../services/supabase_network_service.dart';


class NetworkToastWrapper extends StatefulWidget {
  final Widget child;

  const NetworkToastWrapper({super.key, required this.child});

  @override
  State<NetworkToastWrapper> createState() => _NetworkToastWrapperState();
}

class _NetworkToastWrapperState extends State<NetworkToastWrapper> {
  bool _showToast = false;
  bool _isConnected = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();

    NetworkService.connectionStream.listen((connected) {
      if (!mounted) return;

      setState(() {
        _isConnected = connected;
        _showToast = true;
      });

      // 🟢 Connexion restaurée → disparaît après 2,5s
      if (connected) {
        _hideTimer?.cancel();
        _hideTimer = Timer(const Duration(milliseconds: 2500), () {
          if (mounted) {
            setState(() => _showToast = false);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        if (_showToast)
          NetworkToast(isConnected: _isConnected),
      ],
    );
  }
}
