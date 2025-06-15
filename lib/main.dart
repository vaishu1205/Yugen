import 'package:flutter/material.dart';
import 'package:flutter_programs/screen/HomeScreen.dart';
import 'package:flutter_programs/screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/theme.dart';
import 'firebase_options.dart'; // Auto-generated

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const YugenApp());
}

class YugenApp extends StatelessWidget {
  const YugenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yūgen - Japanese Learning',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_programs/screen/splash_screen.dart';
// import 'utils/theme.dart';
//
// void main() {
//   runApp(const YugenApp());
// }
//
// class YugenApp extends StatelessWidget {
//   const YugenApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Yūgen - Japanese Learning',
//       theme: AppTheme.lightTheme,
//       debugShowCheckedModeBanner: false,
//       home: const SplashScreen(), // 👈 Directly load SplashScreen
//     );
//   }
// }
//
//
//
//
// // // main.dart
// //
// // import 'package:flutter/material.dart';
// //
// // import 'package:flutter_programs/screen/splash_screen.dart';
// // import 'package:go_router/go_router.dart';
// // import 'utils/theme.dart';
// //
// // void main() {
// //   runApp(const YugenApp());
// // }
// //
// // class YugenApp extends StatelessWidget {
// //   const YugenApp({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp.router(
// //       title: 'Yūgen - Japanese Learning',
// //       theme: AppTheme.lightTheme,
// //       routerConfig: _router,
// //       debugShowCheckedModeBanner: false,
// //     );
// //   }
// // }
// //
// // // ✅ Updated router with ResumeScreen
// // final _router = GoRouter(
// //
// //   routes: [
// //     GoRoute(
// //       path: '/splash',
// //       builder: (context, state) => const SplashScreen(),
// //     ),
// //     // GoRoute(
// //     //   path: '/resume',
// //     //   builder: (context, state) => JapaneseResumeScreen(),
// //     // ),
// //   ],
// // );
