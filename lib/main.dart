import 'services/connectivity_service.dart';
import 'services/local_storage_service.dart';
import 'services/sync_service.dart';
import 'models/offline_data.dart';
import 'widgets/connectivity_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/app_theme.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  await LocalStorageService.init();
  final testSos = OfflineData(
  id: 'SOS_TEST_001',
  type: 'SOS',
  data: {
    'description': 'Test emergency request',
    'priority': 'High',
  },
  createdAt: DateTime.now(),
  syncStatus: 'pending',
);

await LocalStorageService.saveOfflineData(testSos);

await SyncService.syncPendingData();
  await SyncService.syncPendingData();


await LocalStorageService.saveOfflineData(testSos);
 
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
      home: const ConnectivityBanner(
  child: SplashScreen(),
),
    );
  }
}