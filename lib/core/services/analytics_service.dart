import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logEvent(String event, {Map<String, dynamic>? params}) async {
    await _analytics.logEvent(name: event, parameters: params);
  }

  static Future<void> logScreenView(String screen) async {
    await _analytics.logScreenView(screenName: screen);
  }
}
