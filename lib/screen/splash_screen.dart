import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:math' as math;

import 'welcome_onvord.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _waveController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Create animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations sequence
    _startAnimations();

    // Navigate after animations complete
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
            const WelcomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _fadeController.forward();

    _rotationController.repeat();
    _waveController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Clean white background
      body: Container(
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
        child: Stack(
          children: [
            // Subtle geometric background
            AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: GeometricBackgroundPainter(_waveAnimation.value),
                  size: Size.infinite,
                );
              },
            ),

            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo with modern design
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _scaleAnimation,
                        _rotationAnimation,
                        _pulseAnimation
                      ]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value * _pulseAnimation.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow ring
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFF3B82F6).withOpacity(0.1),
                                      const Color(0xFF3B82F6).withOpacity(0.05),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),

                              // Rotating accent ring
                              Transform.rotate(
                                angle: _rotationAnimation.value,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF3B82F6).withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: CustomPaint(
                                    painter: ModernRingPainter(),
                                  ),
                                ),
                              ),

                              // Main logo container
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF3B82F6), // Blue 500
                                      Color(0xFF1E40AF), // Blue 800
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF3B82F6).withOpacity(0.25),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF1E40AF).withOpacity(0.15),
                                      blurRadius: 40,
                                      offset: const Offset(0, 16),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '幽玄',
                                    style: GoogleFonts.notoSansJp(
                                      fontSize: 38,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 48),

                    // Animated App Name
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: DefaultTextStyle(
                        style: GoogleFonts.inter(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B), // Slate 800
                          letterSpacing: -0.5,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Yūgen',
                              speed: const Duration(milliseconds: 120),
                            ),
                          ],
                          isRepeatingAnimation: false,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Animated Subtitle
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: DefaultTextStyle(
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF64748B), // Slate 500
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            FadeAnimatedText(
                              'AI-POWERED JAPANESE LEARNING',
                              duration: const Duration(milliseconds: 1500),
                            ),
                          ],
                          isRepeatingAnimation: false,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Modern floating cards
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildModernCard('学', 0, const Color(0xFF3B82F6)),
                          const SizedBox(width: 16),
                          _buildModernCard('習', 300, const Color(0xFF10B981)),
                          const SizedBox(width: 16),
                          _buildModernCard('愛', 600, const Color(0xFFF59E0B)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80),

                    // Modern loading indicator
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CustomPaint(
                              painter: ModernLoadingPainter(_waveAnimation.value),
                            ),
                          ),

                          const SizedBox(height: 24),

                          DefaultTextStyle(
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                            child: AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  'あなたの学習旅行を始めています...',
                                  speed: const Duration(milliseconds: 80),
                                ),
                              ],
                              isRepeatingAnimation: false,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Initializing your learning experience',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF94A3B8), // Slate 400
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernCard(String kanji, int delay, Color accentColor) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 1000 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -8 * math.sin(value * math.pi * 2)),
          child: Transform.scale(
            scale: 0.9 + (0.1 * value),
            child: Opacity(
              opacity: value,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accentColor.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    kanji,
                    style: GoogleFonts.notoSansJp(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Modern geometric background painter
class GeometricBackgroundPainter extends CustomPainter {
  final double animationValue;

  GeometricBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6).withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Draw subtle geometric shapes
    for (int i = 0; i < 8; i++) {
      final offset = animationValue * 50;
      final x = (size.width * 0.1 * i + offset) % size.width;
      final y = (size.height * 0.15 * i + offset * 0.5) % size.height;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: 60, height: 60),
          const Radius.circular(12),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Modern ring painter
class ModernRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8;
      final x1 = center.dx + (radius - 8) * math.cos(angle);
      final y1 = center.dy + (radius - 8) * math.sin(angle);
      final x2 = center.dx + (radius + 8) * math.cos(angle);
      final y2 = center.dy + (radius + 8) * math.sin(angle);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Modern loading painter
class ModernLoadingPainter extends CustomPainter {
  final double animationValue;

  ModernLoadingPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final sweepAngle = animationValue * 1.5 * math.pi;
    final startAngle = animationValue * 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}



// import 'package:flutter/material.dart';
//
// import 'package:google_fonts/google_fonts.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'dart:math' as math;
//
// import 'welcome_onvord.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _fadeController;
//   late AnimationController _scaleController;
//   late AnimationController _rotationController;
//   late AnimationController _particleController;
//
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _rotationAnimation;
//   late Animation<double> _particleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Initialize animation controllers
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     );
//
//     _scaleController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
//
//     _rotationController = AnimationController(
//       duration: const Duration(seconds: 8),
//       vsync: this,
//     );
//
//     _particleController = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     );
//
//     // Create animations
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );
//
//     _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
//     );
//
//     _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
//       CurvedAnimation(parent: _rotationController, curve: Curves.linear),
//     );
//
//     _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _particleController, curve: Curves.easeOut),
//     );
//
//     // Start animations sequence
//     _startAnimations();
//
//     // Navigate after animations complete
//     Future.delayed(const Duration(seconds: 10), () {
//       if (mounted) {
//         Navigator.of(context).pushReplacement(
//           PageRouteBuilder(
//             pageBuilder: (context, animation, secondaryAnimation) =>
//             const WelcomeScreen(), // We'll create this next
//             transitionsBuilder: (context, animation, secondaryAnimation, child) {
//               return FadeTransition(opacity: animation, child: child);
//             },
//             transitionDuration: const Duration(milliseconds: 800),
//           ),
//         );
//       }
//     });
//   }
//
//   void _startAnimations() async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     _scaleController.forward();
//
//     await Future.delayed(const Duration(milliseconds: 500));
//     _fadeController.forward();
//
//     _rotationController.repeat();
//     _particleController.forward();
//   }
//
//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _scaleController.dispose();
//     _rotationController.dispose();
//     _particleController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF0D1117), // GitHub Dark
//               Color(0xFF1C2128), // Dark Slate
//               Color(0xFF2D1B69), // Deep Purple
//               Color(0xFF8B5CF6), // Purple
//               Color(0xFFEC4899), // Pink
//             ],
//           ),
//         ),
//         child: Stack(
//           children: [
//             // Floating particles background
//             AnimatedBuilder(
//               animation: _particleAnimation,
//               builder: (context, child) {
//                 return CustomPaint(
//                   painter: ParticlePainter(_particleAnimation.value),
//                   size: Size.infinite,
//                 );
//               },
//             ),
//
//             // Main content
//             SafeArea(
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Animated Logo with rotation ring
//                     AnimatedBuilder(
//                       animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
//                       builder: (context, child) {
//                         return Transform.scale(
//                           scale: _scaleAnimation.value,
//                           child: Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               // Rotating ring
//                               Transform.rotate(
//                                 angle: _rotationAnimation.value,
//                                 child: Container(
//                                   width: 160,
//                                   height: 160,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       color: Colors.white.withOpacity(0.3),
//                                       width: 2,
//                                     ),
//                                   ),
//                                   child: CustomPaint(
//                                     painter: JapaneseRingPainter(),
//                                   ),
//                                 ),
//                               ),
//
//                               // Logo container
//                               Container(
//                                 width: 130,
//                                 height: 130,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(65),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.3),
//                                       blurRadius: 25,
//                                       offset: const Offset(0, 15),
//                                     ),
//                                     BoxShadow(
//                                       color: const Color(0xFFE91E63).withOpacity(0.4),
//                                       blurRadius: 40,
//                                       offset: const Offset(0, 0),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Center(
//                                   child: ShaderMask(
//                                     shaderCallback: (bounds) => const LinearGradient(
//                                       colors: [Color(0xFF1A237E), Color(0xFFE91E63)],
//                                     ).createShader(bounds),
//                                     child: Text(
//                                       '幽玄',
//                                       style: GoogleFonts.notoSansJp(
//                                         fontSize: 42,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//
//                     const SizedBox(height: 40),
//
//                     // Animated App Name
//                     FadeTransition(
//                       opacity: _fadeAnimation,
//                       child: DefaultTextStyle(
//                         style: GoogleFonts.notoSansJp(
//                           fontSize: 38,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           shadows: [
//                             Shadow(
//                               color: Colors.black.withOpacity(0.3),
//                               offset: const Offset(2, 2),
//                               blurRadius: 4,
//                             ),
//                           ],
//                         ),
//                         child: AnimatedTextKit(
//                           animatedTexts: [
//                             TypewriterAnimatedText(
//                               'Yūgen',
//                               speed: const Duration(milliseconds: 150),
//                             ),
//                           ],
//                           isRepeatingAnimation: false,
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     // Animated Subtitle
//                     FadeTransition(
//                       opacity: _fadeAnimation,
//                       child: DefaultTextStyle(
//                         style: GoogleFonts.notoSansJp(
//                           fontSize: 18,
//                           color: Colors.white.withOpacity(0.9),
//                           fontWeight: FontWeight.w300,
//                         ),
//                         child: AnimatedTextKit(
//                           animatedTexts: [
//                             FadeAnimatedText(
//                               'AI-Powered Japanese Learning',
//                               duration: const Duration(milliseconds: 2000),
//                             ),
//                           ],
//                           isRepeatingAnimation: false,
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // Japanese characters floating
//                     FadeTransition(
//                       opacity: _fadeAnimation,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           _buildFloatingKanji('学', 0),
//                           const SizedBox(width: 20),
//                           _buildFloatingKanji('習', 500),
//                           const SizedBox(width: 20),
//                           _buildFloatingKanji('愛', 1000),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 80),
//
//                     // Custom loading indicator
//                     FadeTransition(
//                       opacity: _fadeAnimation,
//                       child: Column(
//                         children: [
//                           SizedBox(
//                             width: 50,
//                             height: 50,
//                             child: CustomPaint(
//                               painter: LoadingPainter(_particleAnimation.value),
//                             ),
//                           ),
//
//                           const SizedBox(height: 24),
//
//                           DefaultTextStyle(
//                             style: GoogleFonts.notoSansJp(
//                               fontSize: 16,
//                               color: Colors.white.withOpacity(0.8),
//                             ),
//                             child: AnimatedTextKit(
//                               animatedTexts: [
//                                 TypewriterAnimatedText(
//                                   'あなたの学習旅行を始めています...',
//                                   speed: const Duration(milliseconds: 100),
//                                 ),
//                               ],
//                               isRepeatingAnimation: false,
//                             ),
//                           ),
//
//                           const SizedBox(height: 8),
//
//                           Text(
//                             'Starting your learning journey...',
//                             style: GoogleFonts.notoSansJp(
//                               fontSize: 14,
//                               color: Colors.white.withOpacity(0.6),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFloatingKanji(String kanji, int delay) {
//     return TweenAnimationBuilder<double>(
//       duration: Duration(milliseconds: 2000 + delay),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, value, child) {
//         return Transform.translate(
//           offset: Offset(0, -10 * math.sin(value * math.pi)),
//           child: Opacity(
//             opacity: value,
//             child: Container(
//               width: 45,
//               height: 45,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.3),
//                   width: 1,
//                 ),
//               ),
//               child: Center(
//                 child: Text(
//                   kanji,
//                   style: GoogleFonts.notoSansJp(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// // Custom painter for particles
// class ParticlePainter extends CustomPainter {
//   final double animationValue;
//
//   ParticlePainter(this.animationValue);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withOpacity(0.1)
//       ..style = PaintingStyle.fill;
//
//     for (int i = 0; i < 50; i++) {
//       final x = (size.width * (i * 0.1 + animationValue * 0.5)) % size.width;
//       final y = (size.height * (i * 0.07 + animationValue * 0.3)) % size.height;
//       final radius = 1 + (i % 3);
//
//       canvas.drawCircle(Offset(x, y), radius as double, paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
//
// // Custom painter for Japanese ring
// class JapaneseRingPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withOpacity(0.2)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1;
//
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2 - 10;
//
//     for (int i = 0; i < 12; i++) {
//       final angle = (i * math.pi * 2) / 12;
//       final x1 = center.dx + (radius - 5) * math.cos(angle);
//       final y1 = center.dy + (radius - 5) * math.sin(angle);
//       final x2 = center.dx + (radius + 5) * math.cos(angle);
//       final y2 = center.dy + (radius + 5) * math.sin(angle);
//
//       canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
//
// // Custom loading painter
// class LoadingPainter extends CustomPainter {
//   final double animationValue;
//
//   LoadingPainter(this.animationValue);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3
//       ..strokeCap = StrokeCap.round;
//
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2 - 5;
//
//     final sweepAngle = animationValue * 2 * math.pi;
//
//     canvas.drawArc(
//       Rect.fromCircle(center: center, radius: radius),
//       -math.pi / 2,
//       sweepAngle,
//       false,
//       paint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
//
// // Temporary welcome screen - we'll create this properly next
//
//
//
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:animated_text_kit/animated_text_kit.dart';
// // import 'dart:math' as math;
// //
// // class SplashScreen extends StatefulWidget {
// //   const SplashScreen({super.key});
// //
// //   @override
// //   State<SplashScreen> createState() => _SplashScreenState();
// // }
// //
// // class _SplashScreenState extends State<SplashScreen>
// //     with TickerProviderStateMixin {
// //   late AnimationController _fadeController;
// //   late AnimationController _scaleController;
// //   late AnimationController _rotationController;
// //   late AnimationController _particleController;
// //
// //   late Animation<double> _fadeAnimation;
// //   late Animation<double> _scaleAnimation;
// //   late Animation<double> _rotationAnimation;
// //   late Animation<double> _particleAnimation;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     // Initialize animation controllers
// //     _fadeController = AnimationController(
// //       duration: const Duration(milliseconds: 2000),
// //       vsync: this,
// //     );
// //
// //     _scaleController = AnimationController(
// //       duration: const Duration(milliseconds: 1500),
// //       vsync: this,
// //     );
// //
// //     _rotationController = AnimationController(
// //       duration: const Duration(seconds: 8),
// //       vsync: this,
// //     );
// //
// //     _particleController = AnimationController(
// //       duration: const Duration(seconds: 3),
// //       vsync: this,
// //     );
// //
// //     // Create animations
// //     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
// //       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
// //     );
// //
// //     _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
// //       CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
// //     );
// //
// //     _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
// //       CurvedAnimation(parent: _rotationController, curve: Curves.linear),
// //     );
// //
// //     _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
// //       CurvedAnimation(parent: _particleController, curve: Curves.easeOut),
// //     );
// //
// //     // Start animations sequence
// //     _startAnimations();
// //
// //     // Navigate after animations complete
// //     Future.delayed(const Duration(seconds: 10), () {
// //       if (mounted) {
// //         Navigator.of(context).pushReplacement(
// //           PageRouteBuilder(
// //             pageBuilder: (context, animation, secondaryAnimation) =>
// //             const WelcomeScreen(), // We'll create this next
// //             transitionsBuilder: (context, animation, secondaryAnimation, child) {
// //               return FadeTransition(opacity: animation, child: child);
// //             },
// //             transitionDuration: const Duration(milliseconds: 800),
// //           ),
// //         );
// //       }
// //     });
// //   }
// //
// //   void _startAnimations() async {
// //     await Future.delayed(const Duration(milliseconds: 300));
// //     _scaleController.forward();
// //
// //     await Future.delayed(const Duration(milliseconds: 500));
// //     _fadeController.forward();
// //
// //     _rotationController.repeat();
// //     _particleController.forward();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _fadeController.dispose();
// //     _scaleController.dispose();
// //     _rotationController.dispose();
// //     _particleController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         decoration: const BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topLeft,
// //             end: Alignment.bottomRight,
// //             colors: [
// //               Color(0xFF1A237E), // Deep Indigo
// //               Color(0xFF3949AB), // Indigo
// //               Color(0xFF7986CB), // Light Indigo
// //               Color(0xFFE91E63), // Pink
// //             ],
// //           ),
// //         ),
// //         child: Stack(
// //           children: [
// //             // Floating particles background
// //             AnimatedBuilder(
// //               animation: _particleAnimation,
// //               builder: (context, child) {
// //                 return CustomPaint(
// //                   painter: ParticlePainter(_particleAnimation.value),
// //                   size: Size.infinite,
// //                 );
// //               },
// //             ),
// //
// //             // Main content
// //             SafeArea(
// //               child: Center(
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     // Animated Logo with rotation ring
// //                     AnimatedBuilder(
// //                       animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
// //                       builder: (context, child) {
// //                         return Transform.scale(
// //                           scale: _scaleAnimation.value,
// //                           child: Stack(
// //                             alignment: Alignment.center,
// //                             children: [
// //                               // Rotating ring
// //                               Transform.rotate(
// //                                 angle: _rotationAnimation.value,
// //                                 child: Container(
// //                                   width: 160,
// //                                   height: 160,
// //                                   decoration: BoxDecoration(
// //                                     shape: BoxShape.circle,
// //                                     border: Border.all(
// //                                       color: Colors.white.withOpacity(0.3),
// //                                       width: 2,
// //                                     ),
// //                                   ),
// //                                   child: CustomPaint(
// //                                     painter: JapaneseRingPainter(),
// //                                   ),
// //                                 ),
// //                               ),
// //
// //                               // Logo container
// //                               Container(
// //                                 width: 130,
// //                                 height: 130,
// //                                 decoration: BoxDecoration(
// //                                   color: Colors.white,
// //                                   borderRadius: BorderRadius.circular(65),
// //                                   boxShadow: [
// //                                     BoxShadow(
// //                                       color: Colors.black.withOpacity(0.3),
// //                                       blurRadius: 25,
// //                                       offset: const Offset(0, 15),
// //                                     ),
// //                                     BoxShadow(
// //                                       color: const Color(0xFFE91E63).withOpacity(0.4),
// //                                       blurRadius: 40,
// //                                       offset: const Offset(0, 0),
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 child: Center(
// //                                   child: ShaderMask(
// //                                     shaderCallback: (bounds) => const LinearGradient(
// //                                       colors: [Color(0xFF1A237E), Color(0xFFE91E63)],
// //                                     ).createShader(bounds),
// //                                     child: Text(
// //                                       '幽玄',
// //                                       style: GoogleFonts.notoSansJp(
// //                                         fontSize: 42,
// //                                         fontWeight: FontWeight.bold,
// //                                         color: Colors.white,
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         );
// //                       },
// //                     ),
// //
// //                     const SizedBox(height: 40),
// //
// //                     // Animated App Name
// //                     FadeTransition(
// //                       opacity: _fadeAnimation,
// //                       child: DefaultTextStyle(
// //                         style: GoogleFonts.notoSansJp(
// //                           fontSize: 38,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.white,
// //                           shadows: [
// //                             Shadow(
// //                               color: Colors.black.withOpacity(0.3),
// //                               offset: const Offset(2, 2),
// //                               blurRadius: 4,
// //                             ),
// //                           ],
// //                         ),
// //                         child: AnimatedTextKit(
// //                           animatedTexts: [
// //                             TypewriterAnimatedText(
// //                               'Yūgen',
// //                               speed: const Duration(milliseconds: 150),
// //                             ),
// //                           ],
// //                           isRepeatingAnimation: false,
// //                         ),
// //                       ),
// //                     ),
// //
// //                     const SizedBox(height: 16),
// //
// //                     // Animated Subtitle
// //                     FadeTransition(
// //                       opacity: _fadeAnimation,
// //                       child: DefaultTextStyle(
// //                         style: GoogleFonts.notoSansJp(
// //                           fontSize: 18,
// //                           color: Colors.white.withOpacity(0.9),
// //                           fontWeight: FontWeight.w300,
// //                         ),
// //                         child: AnimatedTextKit(
// //                           animatedTexts: [
// //                             FadeAnimatedText(
// //                               'AI-Powered Japanese Learning',
// //                               duration: const Duration(milliseconds: 2000),
// //                             ),
// //                           ],
// //                           isRepeatingAnimation: false,
// //                         ),
// //                       ),
// //                     ),
// //
// //                     const SizedBox(height: 20),
// //
// //                     // Japanese characters floating
// //                     FadeTransition(
// //                       opacity: _fadeAnimation,
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: [
// //                           _buildFloatingKanji('学', 0),
// //                           const SizedBox(width: 20),
// //                           _buildFloatingKanji('習', 500),
// //                           const SizedBox(width: 20),
// //                           _buildFloatingKanji('愛', 1000),
// //                         ],
// //                       ),
// //                     ),
// //
// //                     const SizedBox(height: 80),
// //
// //                     // Custom loading indicator
// //                     FadeTransition(
// //                       opacity: _fadeAnimation,
// //                       child: Column(
// //                         children: [
// //                           SizedBox(
// //                             width: 50,
// //                             height: 50,
// //                             child: CustomPaint(
// //                               painter: LoadingPainter(_particleAnimation.value),
// //                             ),
// //                           ),
// //
// //                           const SizedBox(height: 24),
// //
// //                           DefaultTextStyle(
// //                             style: GoogleFonts.notoSansJp(
// //                               fontSize: 16,
// //                               color: Colors.white.withOpacity(0.8),
// //                             ),
// //                             child: AnimatedTextKit(
// //                               animatedTexts: [
// //                                 TypewriterAnimatedText(
// //                                   'あなたの学習旅行を始めています...',
// //                                   speed: const Duration(milliseconds: 100),
// //                                 ),
// //                               ],
// //                               isRepeatingAnimation: false,
// //                             ),
// //                           ),
// //
// //                           const SizedBox(height: 8),
// //
// //                           Text(
// //                             'Starting your learning journey...',
// //                             style: GoogleFonts.notoSansJp(
// //                               fontSize: 14,
// //                               color: Colors.white.withOpacity(0.6),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildFloatingKanji(String kanji, int delay) {
// //     return TweenAnimationBuilder<double>(
// //       duration: Duration(milliseconds: 2000 + delay),
// //       tween: Tween(begin: 0.0, end: 1.0),
// //       builder: (context, value, child) {
// //         return Transform.translate(
// //           offset: Offset(0, -10 * math.sin(value * math.pi)),
// //           child: Opacity(
// //             opacity: value,
// //             child: Container(
// //               width: 45,
// //               height: 45,
// //               decoration: BoxDecoration(
// //                 color: Colors.white.withOpacity(0.1),
// //                 borderRadius: BorderRadius.circular(8),
// //                 border: Border.all(
// //                   color: Colors.white.withOpacity(0.3),
// //                   width: 1,
// //                 ),
// //               ),
// //               child: Center(
// //                 child: Text(
// //                   kanji,
// //                   style: GoogleFonts.notoSansJp(
// //                     fontSize: 24,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.white,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }
// //
// // // Custom painter for particles
// // class ParticlePainter extends CustomPainter {
// //   final double animationValue;
// //
// //   ParticlePainter(this.animationValue);
// //
// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final paint = Paint()
// //       ..color = Colors.white.withOpacity(0.1)
// //       ..style = PaintingStyle.fill;
// //
// //     for (int i = 0; i < 50; i++) {
// //       final x = (size.width * (i * 0.1 + animationValue * 0.5)) % size.width;
// //       final y = (size.height * (i * 0.07 + animationValue * 0.3)) % size.height;
// //       final radius = 1 + (i % 3);
// //
// //       canvas.drawCircle(Offset(x, y), radius as double, paint);
// //     }
// //   }
// //
// //   @override
// //   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// // }
// //
// // // Custom painter for Japanese ring
// // class JapaneseRingPainter extends CustomPainter {
// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final paint = Paint()
// //       ..color = Colors.white.withOpacity(0.2)
// //       ..style = PaintingStyle.stroke
// //       ..strokeWidth = 1;
// //
// //     final center = Offset(size.width / 2, size.height / 2);
// //     final radius = size.width / 2 - 10;
// //
// //     for (int i = 0; i < 12; i++) {
// //       final angle = (i * math.pi * 2) / 12;
// //       final x1 = center.dx + (radius - 5) * math.cos(angle);
// //       final y1 = center.dy + (radius - 5) * math.sin(angle);
// //       final x2 = center.dx + (radius + 5) * math.cos(angle);
// //       final y2 = center.dy + (radius + 5) * math.sin(angle);
// //
// //       canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
// //     }
// //   }
// //
// //   @override
// //   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// // }
// //
// // // Custom loading painter
// // class LoadingPainter extends CustomPainter {
// //   final double animationValue;
// //
// //   LoadingPainter(this.animationValue);
// //
// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final paint = Paint()
// //       ..color = Colors.white
// //       ..style = PaintingStyle.stroke
// //       ..strokeWidth = 3
// //       ..strokeCap = StrokeCap.round;
// //
// //     final center = Offset(size.width / 2, size.height / 2);
// //     final radius = size.width / 2 - 5;
// //
// //     final sweepAngle = animationValue * 2 * math.pi;
// //
// //     canvas.drawArc(
// //       Rect.fromCircle(center: center, radius: radius),
// //       -math.pi / 2,
// //       sweepAngle,
// //       false,
// //       paint,
// //     );
// //   }
// //
// //   @override
// //   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// // }
// //
// // // Temporary welcome screen - we'll create this properly next
// // class WelcomeScreen extends StatelessWidget {
// //   const WelcomeScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Center(
// //         child: Text(
// //           'Welcome Screen - Coming Next!',
// //           style: GoogleFonts.notoSansJp(fontSize: 24),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// //
