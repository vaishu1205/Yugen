import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'dart:math' as math;

import 'Login_Screen.dart';

// Welcome Screen with Onboarding
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  PageController pageController = PageController();
  int currentPage = 0;
  late AnimationController _animationController;
  late AnimationController _fadeController;

  final List<OnboardingData> onboardingData = [
    OnboardingData(
      title: "Welcome to Yūgen",
      subtitle: "Your AI Japanese Learning Companion",
      description: "Master Japanese with personalized AI-powered lessons, quizzes, and interactive content designed for every skill level.",
      icon: "🌸",
      kanji: "学",
      color: const Color(0xFF3B82F6), // Blue 500
    ),
    OnboardingData(
      title: "Learn Kanji Effectively",
      subtitle: "Master Japanese Characters",
      description: "Learn Kanji with AI-generated mnemonics, stroke animations, and smart spaced repetition system.",
      icon: "🈶",
      kanji: "漢",
      color: const Color(0xFF10B981), // Emerald 500
    ),
    OnboardingData(
      title: "Practice Grammar",
      subtitle: "JLPT Level Quizzes",
      description: "Practice grammar with AI-generated quizzes from N5 to N1 level with instant feedback and explanations.",
      icon: "📚",
      kanji: "文",
      color: const Color(0xFF8B5CF6), // Violet 500
    ),
    OnboardingData(
      title: "Read Japanese Stories",
      subtitle: "Interactive Reading Practice",
      description: "Enjoy AI-generated Japanese stories with translations, pronunciation, and grammar explanations.",
      icon: "📖",
      kanji: "物",
      color: const Color(0xFFF59E0B), // Amber 500
    ),
    OnboardingData(
      title: "Create Japanese Resumes",
      subtitle: "Professional Documents",
      description: "Generate professional Japanese resumes and cover letters with AI assistance for job applications.",
      icon: "📄",
      kanji: "履",
      color: const Color(0xFFEF4444), // Red 500
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    pageController.dispose();
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC), // Very light gray-white
              Color(0xFFF1F5F9), // Slightly darker gray-white
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.02,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '幽',
                              style: GoogleFonts.notoSansJp(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Yūgen',
                          style: GoogleFonts.inter(
                            fontSize: size.width * 0.055,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    if (currentPage < onboardingData.length - 1)
                      TextButton(
                        onPressed: () => _navigateToAuth(),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.04,
                            vertical: size.height * 0.01,
                          ),
                        ),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.inter(
                            fontSize: size.width * 0.035,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                    _fadeController.reset();
                    _fadeController.forward();
                  },
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) {
                    return FadeTransition(
                      opacity: _fadeController,
                      child: OnboardingPage(
                        data: onboardingData[index],
                        size: size,
                      ),
                    );
                  },
                ),
              ),

              // Navigation Section
              Container(
                padding: EdgeInsets.all(size.width * 0.05),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingData.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: size.width * 0.01),
                          width: currentPage == index ? size.width * 0.08 : size.width * 0.02,
                          height: size.height * 0.006,
                          decoration: BoxDecoration(
                            color: currentPage == index
                                ? onboardingData[currentPage].color
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.04),

                    // Navigation buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        if (currentPage > 0)
                          TextButton.icon(
                            onPressed: () {
                              pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF64748B),
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.04,
                                vertical: size.height * 0.01,
                              ),
                            ),
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              size: 16,
                            ),
                            label: Text(
                              'Back',
                              style: GoogleFonts.inter(
                                fontSize: size.width * 0.035,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        else
                          const SizedBox(),

                        // Next/Get Started button
                        ElevatedButton(
                          onPressed: () {
                            if (currentPage < onboardingData.length - 1) {
                              pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _navigateToAuth();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: onboardingData[currentPage].color,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.08,
                              vertical: size.height * 0.015,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentPage < onboardingData.length - 1
                                    ? 'Next'
                                    : 'Get Started',
                                style: GoogleFonts.inter(
                                  fontSize: size.width * 0.04,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: size.width * 0.02),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Updated method to mark onboarding as complete
  Future<void> _navigateToAuth() async {
    // Mark that the user has completed onboarding
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_opened_before', true);

    // Navigate to LoginScreen with your beautiful transition
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
          const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }
}

// Individual onboarding page
class OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final Size size;

  const OnboardingPage({
    super.key,
    required this.data,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon and Kanji combination
          _buildModernIconCard(),
          SizedBox(height: size.height * 0.06),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: size.width * 0.065,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),

          SizedBox(height: size.height * 0.01),

          // Subtitle
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.w600,
              color: data.color,
              letterSpacing: 0.2,
            ),
          ),

          SizedBox(height: size.height * 0.04),

          // Description
          Container(
            margin: EdgeInsets.symmetric(horizontal: size.width * 0.02),
            padding: EdgeInsets.all(size.width * 0.05),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: data.color.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: size.width * 0.035,
                color: const Color(0xFF475569),
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernIconCard() {
    // Calculate responsive sizes with constraints
    final maxCircleSize = math.min(size.width * 0.45, size.height * 0.25);
    final cardSize = math.max(140.0, math.min(maxCircleSize, 200.0));
    final isSmallScreen = size.width < 360 || size.height < 640;

    // Responsive font sizes
    final iconSize = isSmallScreen ? cardSize * 0.15 : cardSize * 0.18;
    final kanjiSize = isSmallScreen ? cardSize * 0.2 : cardSize * 0.25;

    return Container(
      width: cardSize,
      height: cardSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: data.color.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: data.color.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          Container(
            width: cardSize * 0.35,
            height: cardSize * 0.35,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  data.color.withOpacity(0.1),
                  data.color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                data.icon,
                style: TextStyle(
                  fontSize: iconSize,
                  height: 1.0,
                ),
              ),
            ),
          ),

          SizedBox(height: cardSize * 0.06),

          // Kanji character
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: cardSize * 0.08,
              vertical: cardSize * 0.04,
            ),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: data.color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              data.kanji,
              style: GoogleFonts.notoSansJp(
                fontSize: kanjiSize,
                fontWeight: FontWeight.bold,
                color: data.color,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Data class for onboarding
class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final String icon;
  final String kanji;
  final Color color;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.kanji,
    required this.color,
  });
}


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Add this import
// import 'dart:math' as math;
//
// import 'Login_Screen.dart';
//
// // Welcome Screen with Onboarding
// class WelcomeScreen extends StatefulWidget {
//   const WelcomeScreen({super.key});
//
//   @override
//   State<WelcomeScreen> createState() => _WelcomeScreenState();
// }
//
// class _WelcomeScreenState extends State<WelcomeScreen>
//     with TickerProviderStateMixin {
//   PageController pageController = PageController();
//   int currentPage = 0;
//   late AnimationController _animationController;
//   late AnimationController _fadeController;
//
//   final List<OnboardingData> onboardingData = [
//     OnboardingData(
//       title: "Welcome to Yūgen",
//       subtitle: "Your AI Japanese Learning Companion",
//       description: "Master Japanese with personalized AI-powered lessons, quizzes, and interactive content designed for every skill level.",
//       icon: "🌸",
//       kanji: "学",
//       color: const Color(0xFF3B82F6), // Blue 500
//     ),
//     OnboardingData(
//       title: "Learn Kanji Effectively",
//       subtitle: "Master Japanese Characters",
//       description: "Learn Kanji with AI-generated mnemonics, stroke animations, and smart spaced repetition system.",
//       icon: "🈶",
//       kanji: "漢",
//       color: const Color(0xFF10B981), // Emerald 500
//     ),
//     OnboardingData(
//       title: "Practice Grammar",
//       subtitle: "JLPT Level Quizzes",
//       description: "Practice grammar with AI-generated quizzes from N5 to N1 level with instant feedback and explanations.",
//       icon: "📚",
//       kanji: "文",
//       color: const Color(0xFF8B5CF6), // Violet 500
//     ),
//     OnboardingData(
//       title: "Read Japanese Stories",
//       subtitle: "Interactive Reading Practice",
//       description: "Enjoy AI-generated Japanese stories with translations, pronunciation, and grammar explanations.",
//       icon: "📖",
//       kanji: "物",
//       color: const Color(0xFFF59E0B), // Amber 500
//     ),
//     OnboardingData(
//       title: "Create Japanese Resumes",
//       subtitle: "Professional Documents",
//       description: "Generate professional Japanese resumes and cover letters with AI assistance for job applications.",
//       icon: "📄",
//       kanji: "履",
//       color: const Color(0xFFEF4444), // Red 500
//     ),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _animationController.forward();
//     _fadeController.forward();
//   }
//
//   @override
//   void dispose() {
//     pageController.dispose();
//     _animationController.dispose();
//     _fadeController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       body: Container(
//         width: size.width,
//         height: size.height,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFFF8FAFC), // Very light gray-white
//               Color(0xFFF1F5F9), // Slightly darker gray-white
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header
//               Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: size.width * 0.05,
//                   vertical: size.height * 0.02,
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           width: 32,
//                           height: 32,
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
//                             ),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Center(
//                             child: Text(
//                               '幽',
//                               style: GoogleFonts.notoSansJp(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Text(
//                           'Yūgen',
//                           style: GoogleFonts.inter(
//                             fontSize: size.width * 0.055,
//                             fontWeight: FontWeight.bold,
//                             color: const Color(0xFF1E293B),
//                           ),
//                         ),
//                       ],
//                     ),
//                     if (currentPage < onboardingData.length - 1)
//                       TextButton(
//                         onPressed: () => _navigateToAuth(),
//                         style: TextButton.styleFrom(
//                           foregroundColor: const Color(0xFF64748B),
//                           padding: EdgeInsets.symmetric(
//                             horizontal: size.width * 0.04,
//                             vertical: size.height * 0.01,
//                           ),
//                         ),
//                         child: Text(
//                           'Skip',
//                           style: GoogleFonts.inter(
//                             fontSize: size.width * 0.035,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//
//               // PageView
//               Expanded(
//                 child: PageView.builder(
//                   controller: pageController,
//                   onPageChanged: (index) {
//                     setState(() {
//                       currentPage = index;
//                     });
//                     _fadeController.reset();
//                     _fadeController.forward();
//                   },
//                   itemCount: onboardingData.length,
//                   itemBuilder: (context, index) {
//                     return FadeTransition(
//                       opacity: _fadeController,
//                       child: OnboardingPage(
//                         data: onboardingData[index],
//                         size: size,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//
//               // Navigation Section
//               Container(
//                 padding: EdgeInsets.all(size.width * 0.05),
//                 child: Column(
//                   children: [
//                     // Page indicators
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: List.generate(
//                         onboardingData.length,
//                             (index) => AnimatedContainer(
//                           duration: const Duration(milliseconds: 300),
//                           margin: EdgeInsets.symmetric(horizontal: size.width * 0.01),
//                           width: currentPage == index ? size.width * 0.08 : size.width * 0.02,
//                           height: size.height * 0.006,
//                           decoration: BoxDecoration(
//                             color: currentPage == index
//                                 ? onboardingData[currentPage].color
//                                 : const Color(0xFFE2E8F0),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     SizedBox(height: size.height * 0.04),
//
//                     // Navigation buttons
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // Back button
//                         if (currentPage > 0)
//                           TextButton.icon(
//                             onPressed: () {
//                               pageController.previousPage(
//                                 duration: const Duration(milliseconds: 300),
//                                 curve: Curves.easeInOut,
//                               );
//                             },
//                             style: TextButton.styleFrom(
//                               foregroundColor: const Color(0xFF64748B),
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: size.width * 0.04,
//                                 vertical: size.height * 0.01,
//                               ),
//                             ),
//                             icon: const Icon(
//                               Icons.arrow_back_ios,
//                               size: 16,
//                             ),
//                             label: Text(
//                               'Back',
//                               style: GoogleFonts.inter(
//                                 fontSize: size.width * 0.035,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           )
//                         else
//                           const SizedBox(),
//
//                         // Next/Get Started button
//                         ElevatedButton(
//                           onPressed: () {
//                             if (currentPage < onboardingData.length - 1) {
//                               pageController.nextPage(
//                                 duration: const Duration(milliseconds: 300),
//                                 curve: Curves.easeInOut,
//                               );
//                             } else {
//                               _navigateToAuth();
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: onboardingData[currentPage].color,
//                             foregroundColor: Colors.white,
//                             padding: EdgeInsets.symmetric(
//                               horizontal: size.width * 0.08,
//                               vertical: size.height * 0.015,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             elevation: 0,
//                             shadowColor: Colors.transparent,
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(
//                                 currentPage < onboardingData.length - 1
//                                     ? 'Next'
//                                     : 'Get Started',
//                                 style: GoogleFonts.inter(
//                                   fontSize: size.width * 0.04,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               SizedBox(width: size.width * 0.02),
//                               const Icon(Icons.arrow_forward_ios, size: 16),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Updated method to mark onboarding as complete
//   Future<void> _navigateToAuth() async {
//     // Mark that the user has completed onboarding
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('has_opened_before', true);
//
//     // The AuthChecker will automatically detect this change and show LoginScreen
//     // since the user isn't logged in yet. No manual navigation needed!
//
//     // Optional: You can still navigate manually if you want immediate transition
//     // Navigator.of(context).pushReplacement(
//     //   PageRouteBuilder(
//     //     pageBuilder: (context, animation, secondaryAnimation) =>
//     //     const LoginScreen(),
//     //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//     //       return SlideTransition(
//     //         position: Tween<Offset>(
//     //           begin: const Offset(1.0, 0.0),
//     //           end: Offset.zero,
//     //         ).animate(animation),
//     //         child: child,
//     //       );
//     //     },
//     //     transitionDuration: const Duration(milliseconds: 500),
//     //   ),
//     // );
//   }
// }
//
// // Individual onboarding page
// class OnboardingPage extends StatelessWidget {
//   final OnboardingData data;
//   final Size size;
//
//   const OnboardingPage({
//     super.key,
//     required this.data,
//     required this.size,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(size.width * 0.05),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Icon and Kanji combination
//           _buildModernIconCard(),
//           SizedBox(height: size.height * 0.06),
//
//           // Title
//           Text(
//             data.title,
//             textAlign: TextAlign.center,
//             style: GoogleFonts.inter(
//               fontSize: size.width * 0.065,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xFF1E293B),
//               letterSpacing: -0.5,
//             ),
//           ),
//
//           SizedBox(height: size.height * 0.01),
//
//           // Subtitle
//           Text(
//             data.subtitle,
//             textAlign: TextAlign.center,
//             style: GoogleFonts.inter(
//               fontSize: size.width * 0.045,
//               fontWeight: FontWeight.w600,
//               color: data.color,
//               letterSpacing: 0.2,
//             ),
//           ),
//
//           SizedBox(height: size.height * 0.04),
//
//           // Description
//           Container(
//             margin: EdgeInsets.symmetric(horizontal: size.width * 0.02),
//             padding: EdgeInsets.all(size.width * 0.05),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: const Color(0xFFE2E8F0),
//                 width: 1,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: data.color.withOpacity(0.08),
//                   blurRadius: 16,
//                   offset: const Offset(0, 4),
//                 ),
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.04),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Text(
//               data.description,
//               textAlign: TextAlign.center,
//               style: GoogleFonts.inter(
//                 fontSize: size.width * 0.035,
//                 color: const Color(0xFF475569),
//                 height: 1.6,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildModernIconCard() {
//     // Calculate responsive sizes with constraints
//     final maxCircleSize = math.min(size.width * 0.45, size.height * 0.25);
//     final cardSize = math.max(140.0, math.min(maxCircleSize, 200.0));
//     final isSmallScreen = size.width < 360 || size.height < 640;
//
//     // Responsive font sizes
//     final iconSize = isSmallScreen ? cardSize * 0.15 : cardSize * 0.18;
//     final kanjiSize = isSmallScreen ? cardSize * 0.2 : cardSize * 0.25;
//
//     return Container(
//       width: cardSize,
//       height: cardSize,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(32),
//         border: Border.all(
//           color: data.color.withOpacity(0.1),
//           width: 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: data.color.withOpacity(0.15),
//             blurRadius: 24,
//             offset: const Offset(0, 8),
//           ),
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Icon with gradient background
//           Container(
//             width: cardSize * 0.35,
//             height: cardSize * 0.35,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   data.color.withOpacity(0.1),
//                   data.color.withOpacity(0.05),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Center(
//               child: Text(
//                 data.icon,
//                 style: TextStyle(
//                   fontSize: iconSize,
//                   height: 1.0,
//                 ),
//               ),
//             ),
//           ),
//
//           SizedBox(height: cardSize * 0.06),
//
//           // Kanji character
//           Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: cardSize * 0.08,
//               vertical: cardSize * 0.04,
//             ),
//             decoration: BoxDecoration(
//               color: data.color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: data.color.withOpacity(0.2),
//                 width: 1,
//               ),
//             ),
//             child: Text(
//               data.kanji,
//               style: GoogleFonts.notoSansJp(
//                 fontSize: kanjiSize,
//                 fontWeight: FontWeight.bold,
//                 color: data.color,
//                 height: 1.0,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Data class for onboarding
// class OnboardingData {
//   final String title;
//   final String subtitle;
//   final String description;
//   final String icon;
//   final String kanji;
//   final Color color;
//
//   OnboardingData({
//     required this.title,
//     required this.subtitle,
//     required this.description,
//     required this.icon,
//     required this.kanji,
//     required this.color,
//   });
// }
//
//
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:animated_text_kit/animated_text_kit.dart';
// // import 'dart:math' as math;
// //
// // import 'Login_Screen.dart';
// //
// // // Welcome Screen with Onboarding
// // class WelcomeScreen extends StatefulWidget {
// //   const WelcomeScreen({super.key});
// //
// //   @override
// //   State<WelcomeScreen> createState() => _WelcomeScreenState();
// // }
// //
// // class _WelcomeScreenState extends State<WelcomeScreen>
// //     with TickerProviderStateMixin {
// //   PageController pageController = PageController();
// //   int currentPage = 0;
// //   late AnimationController _animationController;
// //   late AnimationController _fadeController;
// //
// //   final List<OnboardingData> onboardingData = [
// //     OnboardingData(
// //       title: "Welcome to Yūgen",
// //       subtitle: "Your AI Japanese Learning Companion",
// //       description: "Master Japanese with personalized AI-powered lessons, quizzes, and interactive content designed for every skill level.",
// //       icon: "🌸",
// //       kanji: "学",
// //       color: const Color(0xFF3B82F6), // Blue 500
// //     ),
// //     OnboardingData(
// //       title: "Learn Kanji Effectively",
// //       subtitle: "Master Japanese Characters",
// //       description: "Learn Kanji with AI-generated mnemonics, stroke animations, and smart spaced repetition system.",
// //       icon: "🈶",
// //       kanji: "漢",
// //       color: const Color(0xFF10B981), // Emerald 500
// //     ),
// //     OnboardingData(
// //       title: "Practice Grammar",
// //       subtitle: "JLPT Level Quizzes",
// //       description: "Practice grammar with AI-generated quizzes from N5 to N1 level with instant feedback and explanations.",
// //       icon: "📚",
// //       kanji: "文",
// //       color: const Color(0xFF8B5CF6), // Violet 500
// //     ),
// //     OnboardingData(
// //       title: "Read Japanese Stories",
// //       subtitle: "Interactive Reading Practice",
// //       description: "Enjoy AI-generated Japanese stories with translations, pronunciation, and grammar explanations.",
// //       icon: "📖",
// //       kanji: "物",
// //       color: const Color(0xFFF59E0B), // Amber 500
// //     ),
// //     OnboardingData(
// //       title: "Create Japanese Resumes",
// //       subtitle: "Professional Documents",
// //       description: "Generate professional Japanese resumes and cover letters with AI assistance for job applications.",
// //       icon: "📄",
// //       kanji: "履",
// //       color: const Color(0xFFEF4444), // Red 500
// //     ),
// //   ];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _animationController = AnimationController(
// //       duration: const Duration(milliseconds: 1000),
// //       vsync: this,
// //     );
// //     _fadeController = AnimationController(
// //       duration: const Duration(milliseconds: 800),
// //       vsync: this,
// //     );
// //     _animationController.forward();
// //     _fadeController.forward();
// //   }
// //
// //   @override
// //   void dispose() {
// //     pageController.dispose();
// //     _animationController.dispose();
// //     _fadeController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final size = MediaQuery.of(context).size;
// //
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8FAFC),
// //       body: Container(
// //         width: size.width,
// //         height: size.height,
// //         decoration: const BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [
// //               Color(0xFFF8FAFC), // Very light gray-white
// //               Color(0xFFF1F5F9), // Slightly darker gray-white
// //             ],
// //           ),
// //         ),
// //         child: SafeArea(
// //           child: Column(
// //             children: [
// //               // Header
// //               Container(
// //                 padding: EdgeInsets.symmetric(
// //                   horizontal: size.width * 0.05,
// //                   vertical: size.height * 0.02,
// //                 ),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Row(
// //                       children: [
// //                         Container(
// //                           width: 32,
// //                           height: 32,
// //                           decoration: BoxDecoration(
// //                             gradient: const LinearGradient(
// //                               colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
// //                             ),
// //                             borderRadius: BorderRadius.circular(8),
// //                           ),
// //                           child: Center(
// //                             child: Text(
// //                               '幽',
// //                               style: GoogleFonts.notoSansJp(
// //                                 fontSize: 16,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.white,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(width: 12),
// //                         Text(
// //                           'Yūgen',
// //                           style: GoogleFonts.inter(
// //                             fontSize: size.width * 0.055,
// //                             fontWeight: FontWeight.bold,
// //                             color: const Color(0xFF1E293B),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                     if (currentPage < onboardingData.length - 1)
// //                       TextButton(
// //                         onPressed: () => _navigateToAuth(),
// //                         style: TextButton.styleFrom(
// //                           foregroundColor: const Color(0xFF64748B),
// //                           padding: EdgeInsets.symmetric(
// //                             horizontal: size.width * 0.04,
// //                             vertical: size.height * 0.01,
// //                           ),
// //                         ),
// //                         child: Text(
// //                           'Skip',
// //                           style: GoogleFonts.inter(
// //                             fontSize: size.width * 0.035,
// //                             fontWeight: FontWeight.w500,
// //                           ),
// //                         ),
// //                       ),
// //                   ],
// //                 ),
// //               ),
// //
// //               // PageView
// //               Expanded(
// //                 child: PageView.builder(
// //                   controller: pageController,
// //                   onPageChanged: (index) {
// //                     setState(() {
// //                       currentPage = index;
// //                     });
// //                     _fadeController.reset();
// //                     _fadeController.forward();
// //                   },
// //                   itemCount: onboardingData.length,
// //                   itemBuilder: (context, index) {
// //                     return FadeTransition(
// //                       opacity: _fadeController,
// //                       child: OnboardingPage(
// //                         data: onboardingData[index],
// //                         size: size,
// //                       ),
// //                     );
// //                   },
// //                 ),
// //               ),
// //
// //               // Navigation Section
// //               Container(
// //                 padding: EdgeInsets.all(size.width * 0.05),
// //                 child: Column(
// //                   children: [
// //                     // Page indicators
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: List.generate(
// //                         onboardingData.length,
// //                             (index) => AnimatedContainer(
// //                           duration: const Duration(milliseconds: 300),
// //                           margin: EdgeInsets.symmetric(horizontal: size.width * 0.01),
// //                           width: currentPage == index ? size.width * 0.08 : size.width * 0.02,
// //                           height: size.height * 0.006,
// //                           decoration: BoxDecoration(
// //                             color: currentPage == index
// //                                 ? onboardingData[currentPage].color
// //                                 : const Color(0xFFE2E8F0),
// //                             borderRadius: BorderRadius.circular(4),
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //
// //                     SizedBox(height: size.height * 0.04),
// //
// //                     // Navigation buttons
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         // Back button
// //                         if (currentPage > 0)
// //                           TextButton.icon(
// //                             onPressed: () {
// //                               pageController.previousPage(
// //                                 duration: const Duration(milliseconds: 300),
// //                                 curve: Curves.easeInOut,
// //                               );
// //                             },
// //                             style: TextButton.styleFrom(
// //                               foregroundColor: const Color(0xFF64748B),
// //                               padding: EdgeInsets.symmetric(
// //                                 horizontal: size.width * 0.04,
// //                                 vertical: size.height * 0.01,
// //                               ),
// //                             ),
// //                             icon: const Icon(
// //                               Icons.arrow_back_ios,
// //                               size: 16,
// //                             ),
// //                             label: Text(
// //                               'Back',
// //                               style: GoogleFonts.inter(
// //                                 fontSize: size.width * 0.035,
// //                                 fontWeight: FontWeight.w500,
// //                               ),
// //                             ),
// //                           )
// //                         else
// //                           const SizedBox(),
// //
// //                         // Next/Get Started button
// //                         ElevatedButton(
// //                           onPressed: () {
// //                             if (currentPage < onboardingData.length - 1) {
// //                               pageController.nextPage(
// //                                 duration: const Duration(milliseconds: 300),
// //                                 curve: Curves.easeInOut,
// //                               );
// //                             } else {
// //                               _navigateToAuth();
// //                             }
// //                           },
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: onboardingData[currentPage].color,
// //                             foregroundColor: Colors.white,
// //                             padding: EdgeInsets.symmetric(
// //                               horizontal: size.width * 0.08,
// //                               vertical: size.height * 0.015,
// //                             ),
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(12),
// //                             ),
// //                             elevation: 0,
// //                             shadowColor: Colors.transparent,
// //                           ),
// //                           child: Row(
// //                             mainAxisSize: MainAxisSize.min,
// //                             children: [
// //                               Text(
// //                                 currentPage < onboardingData.length - 1
// //                                     ? 'Next'
// //                                     : 'Get Started',
// //                                 style: GoogleFonts.inter(
// //                                   fontSize: size.width * 0.04,
// //                                   fontWeight: FontWeight.w600,
// //                                 ),
// //                               ),
// //                               SizedBox(width: size.width * 0.02),
// //                               const Icon(Icons.arrow_forward_ios, size: 16),
// //                             ],
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void _navigateToAuth() {
// //     Navigator.of(context).pushReplacement(
// //       PageRouteBuilder(
// //         pageBuilder: (context, animation, secondaryAnimation) =>
// //         const LoginScreen(),
// //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
// //           return SlideTransition(
// //             position: Tween<Offset>(
// //               begin: const Offset(1.0, 0.0),
// //               end: Offset.zero,
// //             ).animate(animation),
// //             child: child,
// //           );
// //         },
// //         transitionDuration: const Duration(milliseconds: 500),
// //       ),
// //     );
// //   }
// // }
// //
// // // Individual onboarding page
// // class OnboardingPage extends StatelessWidget {
// //   final OnboardingData data;
// //   final Size size;
// //
// //   const OnboardingPage({
// //     super.key,
// //     required this.data,
// //     required this.size,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: EdgeInsets.all(size.width * 0.05),
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           // Icon and Kanji combination
// //           _buildModernIconCard(),
// //           SizedBox(height: size.height * 0.06),
// //
// //           // Title
// //           Text(
// //             data.title,
// //             textAlign: TextAlign.center,
// //             style: GoogleFonts.inter(
// //               fontSize: size.width * 0.065,
// //               fontWeight: FontWeight.bold,
// //               color: const Color(0xFF1E293B),
// //               letterSpacing: -0.5,
// //             ),
// //           ),
// //
// //           SizedBox(height: size.height * 0.01),
// //
// //           // Subtitle
// //           Text(
// //             data.subtitle,
// //             textAlign: TextAlign.center,
// //             style: GoogleFonts.inter(
// //               fontSize: size.width * 0.045,
// //               fontWeight: FontWeight.w600,
// //               color: data.color,
// //               letterSpacing: 0.2,
// //             ),
// //           ),
// //
// //           SizedBox(height: size.height * 0.04),
// //
// //           // Description
// //           Container(
// //             margin: EdgeInsets.symmetric(horizontal: size.width * 0.02),
// //             padding: EdgeInsets.all(size.width * 0.05),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(16),
// //               border: Border.all(
// //                 color: const Color(0xFFE2E8F0),
// //                 width: 1,
// //               ),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: data.color.withOpacity(0.08),
// //                   blurRadius: 16,
// //                   offset: const Offset(0, 4),
// //                 ),
// //                 BoxShadow(
// //                   color: Colors.black.withOpacity(0.04),
// //                   blurRadius: 8,
// //                   offset: const Offset(0, 2),
// //                 ),
// //               ],
// //             ),
// //             child: Text(
// //               data.description,
// //               textAlign: TextAlign.center,
// //               style: GoogleFonts.inter(
// //                 fontSize: size.width * 0.035,
// //                 color: const Color(0xFF475569),
// //                 height: 1.6,
// //                 fontWeight: FontWeight.w400,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildModernIconCard() {
// //     // Calculate responsive sizes with constraints
// //     final maxCircleSize = math.min(size.width * 0.45, size.height * 0.25);
// //     final cardSize = math.max(140.0, math.min(maxCircleSize, 200.0));
// //     final isSmallScreen = size.width < 360 || size.height < 640;
// //
// //     // Responsive font sizes
// //     final iconSize = isSmallScreen ? cardSize * 0.15 : cardSize * 0.18;
// //     final kanjiSize = isSmallScreen ? cardSize * 0.2 : cardSize * 0.25;
// //
// //     return Container(
// //       width: cardSize,
// //       height: cardSize,
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(32),
// //         border: Border.all(
// //           color: data.color.withOpacity(0.1),
// //           width: 1,
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: data.color.withOpacity(0.15),
// //             blurRadius: 24,
// //             offset: const Offset(0, 8),
// //           ),
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.06),
// //             blurRadius: 16,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           // Icon with gradient background
// //           Container(
// //             width: cardSize * 0.35,
// //             height: cardSize * 0.35,
// //             decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 begin: Alignment.topLeft,
// //                 end: Alignment.bottomRight,
// //                 colors: [
// //                   data.color.withOpacity(0.1),
// //                   data.color.withOpacity(0.05),
// //                 ],
// //               ),
// //               borderRadius: BorderRadius.circular(16),
// //             ),
// //             child: Center(
// //               child: Text(
// //                 data.icon,
// //                 style: TextStyle(
// //                   fontSize: iconSize,
// //                   height: 1.0,
// //                 ),
// //               ),
// //             ),
// //           ),
// //
// //           SizedBox(height: cardSize * 0.06),
// //
// //           // Kanji character
// //           Container(
// //             padding: EdgeInsets.symmetric(
// //               horizontal: cardSize * 0.08,
// //               vertical: cardSize * 0.04,
// //             ),
// //             decoration: BoxDecoration(
// //               color: data.color.withOpacity(0.1),
// //               borderRadius: BorderRadius.circular(12),
// //               border: Border.all(
// //                 color: data.color.withOpacity(0.2),
// //                 width: 1,
// //               ),
// //             ),
// //             child: Text(
// //               data.kanji,
// //               style: GoogleFonts.notoSansJp(
// //                 fontSize: kanjiSize,
// //                 fontWeight: FontWeight.bold,
// //                 color: data.color,
// //                 height: 1.0,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // Data class for onboarding
// // class OnboardingData {
// //   final String title;
// //   final String subtitle;
// //   final String description;
// //   final String icon;
// //   final String kanji;
// //   final Color color;
// //
// //   OnboardingData({
// //     required this.title,
// //     required this.subtitle,
// //     required this.description,
// //     required this.icon,
// //     required this.kanji,
// //     required this.color,
// //   });
// // }
// //
// //
// //
