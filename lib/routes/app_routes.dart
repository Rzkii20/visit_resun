import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/map_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/homestay_screen.dart';
import '../screens/suvenir_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/admin_form_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String map = '/map';
  static const String profile = '/profile';
  static const String homestays = '/homestays';
  static const String suvenirs = '/suvenirs';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminForm = '/admin/form';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        home: (context) => const HomeScreen(),
        detail: (context) => const DetailScreen(),
        map: (context) => const MapScreen(),
        profile: (context) => const ProfileScreen(),
        homestays: (context) => const HomestayScreen(),
        suvenirs: (context) => const SuvenirScreen(),
        adminDashboard: (context) => const AdminDashboardScreen(),
        adminForm: (context) => const AdminFormScreen(),
      };
}
