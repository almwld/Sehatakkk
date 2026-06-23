import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

class BackgroundServiceConfig {
  static const String notificationChannelId = 'sehatak_background';
  static const String notificationChannelName = 'Sehatak Background Service';
  static const String notificationChannelDesc = 'Keeps Sehatak running for notifications and calls';
  static const int notificationId = 888;
}

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: BackgroundServiceConfig.notificationChannelId,
      initialNotificationTitle: 'صحتك',
      initialNotificationContent: 'التطبيق يعمل في الخلفية',
      foregroundServiceNotificationId: BackgroundServiceConfig.notificationId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensure();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensure();
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: 'صحتك',
      content: 'التطبيق يعمل في الخلفية',
    );
  }
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    service.invoke('keepAlive', {'timestamp': DateTime.now().millisecondsSinceEpoch});
  });
}

class KeepAliveService {
  final FlutterBackgroundService _service = FlutterBackgroundService();
  Future<bool> isRunning() async => await _service.isRunning();
  Future<void> start() async { if (!await isRunning()) await _service.startService(); }
  Future<void> stop() async { _service.invoke('stopService'); }
}
