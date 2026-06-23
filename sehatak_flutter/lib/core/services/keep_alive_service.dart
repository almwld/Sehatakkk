import 'package:flutter_background_service/flutter_background_service.dart';

class KeepAliveManager {
  final FlutterBackgroundService _service = FlutterBackgroundService();

  Future<void> initialize() async {
    if (!await _service.isRunning()) {
      await _service.startService();
    }
  }

  Future<void> setKeepAliveEnabled(bool enabled) async {
    if (enabled) await initialize();
    else _service.invoke('stopService');
  }

  Future<void> dispose() async { await _service.invoke('stopService'); }
}
