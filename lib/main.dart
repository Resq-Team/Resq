import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'constants/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/local_storage_service.dart';
import 'widgets/connectivity_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await LocalStorageService.init();

  runApp(const ResQApp());
}

class ResQApp extends StatelessWidget {
  const ResQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQ - Smart Disaster Relief',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Keep ConnectivityBanner alive for the whole app,
      // not only for SplashScreen.
      builder: (context, child) {
        return ConnectivityBanner(
          child: child ?? const SizedBox.shrink(),
        );
      },

      home: const SplashScreen(),
    );
  }
}