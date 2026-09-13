import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // Provider package එක import කරන ලදී
import 'firebase_options.dart';
import 'constants/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/language_provider.dart'; // LanguageProvider එක import කරන ලදී

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Push Notifications Initialize කිරීම
  await NotificationService.initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // ChangeNotifierProvider හරහා LanguageProvider එක මුළු App එකටම Wrap කරන ලදී
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
      home: const SplashScreen(),
    );
  }
}