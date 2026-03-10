import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart' as ap;
import 'providers/listing_provider.dart';
import 'providers/interaction_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_shell.dart';
import 'screens/auth/verify_email_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const KigaliServicesApp());
}

class KigaliServicesApp extends StatelessWidget {
  const KigaliServicesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ap.AuthProvider()),
        ChangeNotifierProvider(create: (_) => ListingProvider()),
        ChangeNotifierProvider(create: (_) => InteractionProvider()),
      ],
      child: MaterialApp(
        title: 'Kigali Services',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0D1B2A),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF005A9C),
            brightness: Brightness.dark,
          ),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 1,
            backgroundColor: Color(0xFF0D1B2A),
          ),
          cardTheme: CardThemeData(
            elevation: 1,
            color: const Color(0xFF1B263B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        home: const _AuthGate(),
      ),
    );
  }
}

// Listens to AuthProvider and routes to the correct screen.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<ap.AuthProvider>().status;

    switch (authStatus) {
      case ap.AuthStatus.authenticated:
        if (!context.watch<ap.AuthProvider>().isEmailVerified) {
          return const VerifyEmailScreen();
        }
        return const HomeShell();

      case ap.AuthStatus.initial:
      case ap.AuthStatus.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );

      case ap.AuthStatus.unauthenticated:
      case ap.AuthStatus.error:
        return const LoginScreen();
    }
  }
}
