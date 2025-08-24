import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'utils/theme_colors.dart';
import 'utils/app_constants.dart';
import 'models/tracking_models.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_screen.dart';
import 'screens/add_item_screen.dart';
import 'screens/add_refund_screen.dart';
import 'screens/item_detail_screen.dart';
import 'screens/notification_settings_screen.dart';

import 'services/notification_service.dart';
import 'services/app_info_service.dart';

void main() {
  runApp(const RefundTrackerApp());
}

class RefundTrackerApp extends StatelessWidget {
  const RefundTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService();

    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        navigatorKey: notificationService.navigatorKey,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: AppConstants.primaryFont,
          scaffoldBackgroundColor: ThemeColors.backgroundColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: ThemeColors.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const AppInitializer(),
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/main': (context) => const MainScreen(),
          '/add-item': (context) => const AddItemScreen(),
          '/add-refund': (context) => const AddRefundScreen(),
          '/item-detail': (context) => const ItemDetailScreen(itemId: ''),
          '/notification-settings': (context) =>
              const NotificationSettingsScreen(),
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _isFirstLaunch = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Use a post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Initialize services
        final appInfoService = AppInfoService();
        await appInfoService.initialize();

        if (!mounted) return;
        final provider = Provider.of<AppProvider>(context, listen: false);
        await provider.initialize();

        // Clear notification badges when app opens
        final notificationService = NotificationService();
        await notificationService.clearNotificationBadges();

        if (mounted) {
          setState(() {
            _isLoading = false;
            // Check if this is first launch by looking at isDone flag and tracking mode
            // If user has completed welcome flow or has a non-default tracking mode, they should go to main screen
            final isDone = provider.settings.isDone;
            final hasCustomSettings =
                provider.settings.trackingMode != TrackingMode.perItem ||
                    provider.settings.currency != 'TND' ||
                    !provider.settings.notificationsEnabled ||
                    provider.settings.criticalDays != 15;

            // If user has completed welcome flow OR has custom settings, they should go to main screen
            _isFirstLaunch = !isDone && !hasCustomSettings;

            // Debug logging
            debugPrint(
                'App initialization - isDone: $isDone, hasCustomSettings: $hasCustomSettings, isFirstLaunch: $_isFirstLaunch');
          });
        }
      });
    } catch (e) {
      debugPrint('Error initializing app: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFirstLaunch = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: ThemeColors.primaryGradient,
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 24),
                Text(
                  'Loading RefundTracker Pro...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _isFirstLaunch ? const WelcomeScreen() : const MainScreen();
  }
}
