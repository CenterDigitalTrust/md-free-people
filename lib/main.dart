import 'core/queue/workmanager_task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'screens/onboarding_screen.dart';
import 'screens/capture_screen.dart';
import 'screens/records_list_screen.dart';
import 'screens/verify_file_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/bottom_nav_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeProvider = LocaleProvider();
  await localeProvider.restore();
  WorkmanagerService.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (_) => localeProvider,
      child: const MdfpApp(),
    ),
  );
}

class MdfpApp extends StatelessWidget {
  const MdfpApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      onGenerateTitle: (context) =>
          AppLocalizations.of(context).translate('app_title'),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _showOnboarding = true;

  final List<Widget> _screens = const [
    CaptureScreen(),
    RecordsListScreen(),
    VerifyFileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return OnboardingScreen(
        onFinish: () {
          setState(() {
            _showOnboarding = false;
          });
        },
      );
    }

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: MdfpBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Keep the capture widget alive until its media has been persisted.
          if (CaptureScreen.captureInProgress) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(AppLocalizations.of(context)
                    .translate('finish_recording'))));
            return;
          }
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
