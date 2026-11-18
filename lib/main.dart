import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'constants/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/language_provider.dart';
import 'services/local_storage_service.dart';
import 'widgets/connectivity_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize push notifications
  await NotificationService.initialize();

  // Initialize local storage for offline functionality
  await LocalStorageService.init();

  // Set screen orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Provide LanguageProvider to the whole app
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const ResQApp(),
    ),
  );
}

class ResQApp extends StatelessWidget {
  const ResQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQ - Smart Disaster Relief',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Keep the connectivity banner active throughout the app
      builder: (context, child) {
        return ConnectivityBanner(
          child: child ?? const SizedBox.shrink(),
        );
      },

      home: const SplashScreen(),
    );
  }
}