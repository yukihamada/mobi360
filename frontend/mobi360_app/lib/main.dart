import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/company_registration_screen.dart';
import 'screens/driver_registration_screen.dart';
import 'screens/login_screen.dart';
import 'screens/voice_dispatch_screen.dart';
import 'screens/customer_dispatch_screen.dart';
import 'screens/driver_app_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ステータスバーの設定
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppStateProvider(),
      child: MaterialApp(
        title: 'Mobility Ops 360',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF667EEA),
          ),
          useMaterial3: true,
          fontFamily: 'System',
          
          // アプリバーテーマ
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF667EEA),
            foregroundColor: Colors.white,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          
          // カードテーマ
          cardTheme: const CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            color: Colors.white,
          ),
          
          // 入力フィールドテーマ
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            labelStyle: const TextStyle(fontSize: 14),
          ),
          
          // ボタンテーマ
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          
          // スナックバーテーマ
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        home: const OnboardingScreen(),
        // ルート設定
        routes: {
          '/': (context) => const OnboardingScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/company-registration': (context) => const CompanyRegistrationScreen(),
          '/driver-registration': (context) => const DriverRegistrationScreen(),
          '/login': (context) => const LoginScreen(),
          '/voice-dispatch': (context) => const VoiceDispatchScreen(),
          '/customer-dispatch': (context) => const CustomerDispatchScreen(),
          '/driver-app': (context) => const DriverAppScreen(),
        },
      ),
    );
  }
}
