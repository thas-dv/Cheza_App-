import 'dart:async';
import 'dart:io';

class NetworkService {
  static final _controller = StreamController<bool>.broadcast();
  static bool _isConnected = true;
  static Timer? _timer;

  static bool get isConnected => _isConnected;
  static Stream<bool> get connectionStream => _controller.stream;

  static void initialize() {
    // check toutes les 3 secondes (léger & efficace)
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final hasInternet = await _checkInternet();
      if (hasInternet != _isConnected) {
        _isConnected = hasInternet;
        _controller.add(_isConnected);
      }
    });
  }

  static Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
