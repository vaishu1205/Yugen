import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_programs/screen/welcome_onvord.dart';

// Import your screens
import 'screen/splash_screen.dart';
import 'screen/Login_Screen.dart';
import 'screen/HomeScreen.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const YugenApp());
}

class YugenApp extends StatelessWidget {
  const YugenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Japanese Learning App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthChecker(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> with WidgetsBindingObserver {
  bool showSplash = true;
  bool hasShownLoginOnce = false;
  bool isFirstTime = true; // Track if this is first time user
  StreamSubscription<User?>? _authSubscription;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      print("🔥 Auth state changed: ${user?.email}");
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    super.dispose();
  }

  // This method is called when app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Don't automatically sign out on lifecycle changes
    // Let the user stay logged in across app launches
    // Only sign out when they explicitly choose to logout
  }

  Future<void> _initializeApp() async {
    // Don't sign out automatically - let user stay logged in
    // Only sign out if they explicitly log out

    // Check if user has opened the app before
    await _checkFirstTimeUser();

    // Show splash screen for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        showSplash = false;
      });
    }
  }

  Future<void> _checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final hasOpenedBefore = prefs.getBool('has_opened_before') ?? false;

    setState(() {
      isFirstTime = !hasOpenedBefore;
    });
  }

  Future<void> _markAsNotFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_opened_before', true);
    setState(() {
      isFirstTime = false;
    });
  }

  Future<void> _signOut() async {
    // Sign out the current user
    await FirebaseAuth.instance.signOut();

    // Reset state to show login screen
    if (mounted) {
      setState(() {
        hasShownLoginOnce = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen first
    if (showSplash) {
      return const SplashScreen();
    }

    // Show welcome/onboarding screen for first time users
    if (isFirstTime) {
      return WelcomeScreen(); // Remove the onComplete parameter
    }

    // Always show login screen - no persistent authentication
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D1117),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              ),
            ),
          );
        }

        // If user is logged in, show home screen
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        // If user is not logged in, show login screen
        return const LoginScreen();
      },
    );
  }
}
