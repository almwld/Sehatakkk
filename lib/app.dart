import 'package:flutter/material.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/auth/splash_screen.dart';
import 'presentation/screens/home/main_navigation.dart';
import 'presentation/screens/doctor/doctors_list_screen.dart';
import 'presentation/screens/pharmacy/pharmacy_screen.dart';
import 'presentation/screens/patient/patient_appointments.dart';
import 'presentation/screens/chat/chat_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String login = '/login';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String doctors = '/doctors';
  static const String pharmacy = '/pharmacy';
  static const String appointments = '/appointments';
  static const String chat = '/chat';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const MainNavigation());
      case doctors:
        return MaterialPageRoute(builder: (_) => const DoctorsListScreen());
      case pharmacy:
        return MaterialPageRoute(builder: (_) => const PharmacyScreen());
      case appointments:
        return MaterialPageRoute(builder: (_) => const PatientAppointments());
      case chat:
        return MaterialPageRoute(builder: (_) => const ChatScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('الصفحة غير موجودة')),
          ),
        );
    }
  }
}
