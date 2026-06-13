import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/app_config.dart';
import 'providers/app_state_provider.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try initializing Firebase if set in config.
  // Gracefully falls back to Mock mode if not configured (e.g., missing google-services.json).
  if (AppConfig.useFirebase) {
    try {
      // Firebase config - same for all platforms
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyC_gpgZPQw2V3Qkb-AY7Yer7OKxDzm4CqE',
          appId: '1:565872993507:android:626556362a4f635d10d1d6',
          messagingSenderId: '565872993507',
          projectId: 'visit-resun-c8723',
          authDomain: 'visit-resun-c8723.firebaseapp.com',
          databaseURL:
              'https://visit-resun-c8723-default-rtdb.asia-southeast1.firebasedatabase.app',
          storageBucket: 'visit-resun-c8723.firebasestorage.app',
        ),
      );
      debugPrint('✅ Firebase successfully initialized!');
    } catch (e) {
      debugPrint('❌ Firebase initialization failed: $e');
      debugPrint('⚠️ Continuing in offline Mock Mode fallback.');
    }
  } else {
    debugPrint('ℹ️ Firebase is disabled - using Mock Mode');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStateProvider>(
          create: (context) => AppStateProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Visit Resun GIS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConfig.primaryColor,
            primary: AppConfig.primaryColor,
            secondary: AppConfig.accentColor,
            background: AppConfig.backgroundColor,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppConfig.textColorPrimary,
            ),
            bodyLarge: TextStyle(color: AppConfig.textColorPrimary),
            bodyMedium: TextStyle(color: AppConfig.textColorSecondary),
          ),
        ),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
