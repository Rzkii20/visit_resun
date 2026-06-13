import 'package:flutter/material.dart';

class AppConfig {
  // Toggle backend mode
  // If true, will use Firebase Auth and Firestore.
  // If false, will use Mock Auth and Mock Database (SharedPreferences) with rich preset data.
  static const bool useFirebase = true;

  // Premium UI Theme Colors
  static const Color primaryColor = Color(0xFF004D40); // Deep Emerald Green
  static const Color primaryLight = Color(0xFF00796B); // Emerald Green Light
  static const Color primaryDark = Color(0xFF00251A); // Forest Green
  static const Color accentColor = Color(0xFFFF8F00); // Golden Amber
  static const Color accentLight = Color(0xFFFFC107); // Warm Amber
  static const Color backgroundColor = Color(0xFFF5F7F8); // Premium Light Gray
  static const Color cardColor = Colors.white;
  static const Color textColorPrimary = Color(0xFF212121);
  static const Color textColorSecondary = Color(0xFF757575);

  // Gradient definitions
  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [accentColor, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient darkGlassGradient = LinearGradient(
    colors: [Color(0x9900251A), Color(0x66004D40)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Default testing credentials
  static const String adminEmail = 'admin@visitresun.com';
  static const String adminPassword = 'admin123';
  static const String userEmail = 'user@visitresun.com';
  static const String userPassword = 'user123';

  // Beautiful curated preset image URLs to select from in the Admin Form
  static const List<String> presetImages = [
    'https://images.unsplash.com/photo-1508459855340-fb63ac591728?q=80&w=600', // Waterfall
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=600', // Luxury Homestay
    'https://images.unsplash.com/photo-1586040140378-b5634cb4c8fc?q=80&w=600', // Souvenir/Bamboo
    'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=600', // Nature Lake
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?q=80&w=600', // Forest
    'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=600', // Mountain River
  ];
}
