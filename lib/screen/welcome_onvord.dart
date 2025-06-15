import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:math' as math;

import 'HomeScreen.dart';

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

  final List<OnboardingData> onboardingData = [
    OnboardingData(
      title: "Welcome to Yūgen",
      subtitle: "Your AI Japanese Learning Companion",
      description: "Master Japanese with personalized AI-powered lessons, quizzes, and interactive content designed for every skill level.",
      icon: "🌸",
      kanji: "学",
      color: const Color(0xFF8B5CF6),
    ),
    OnboardingData(
      title: "Learn Kanji Effectively",
      subtitle: "Master Japanese Characters",
      description: "Learn Kanji with AI-generated mnemonics, stroke animations, and smart spaced repetition system.",
      icon: "🈶",
      kanji: "漢",
      color: const Color(0xFFEC4899),
    ),
    OnboardingData(
      title: "Practice Grammar",
      subtitle: "JLPT Level Quizzes",
      description: "Practice grammar with AI-generated quizzes from N5 to N1 level with instant feedback and explanations.",
      icon: "📚",
      kanji: "文",
      color: const Color(0xFF06B6D4),
    ),
    OnboardingData(
      title: "Read Japanese Stories",
      subtitle: "Interactive Reading Practice",
      description: "Enjoy AI-generated Japanese stories with translations, pronunciation, and grammar explanations.",
      icon: "📖",
      kanji: "物",
      color: const Color(0xFF10B981),
    ),
    OnboardingData(
      title: "Create Japanese Resumes",
      subtitle: "Professional Documents",
      description: "Generate professional Japanese resumes and cover letters with AI assistance for job applications.",
      icon: "📄",
      kanji: "履",
      color: const Color(0xFFF59E0B),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0D1117),
              const Color(0xFF1C2128),
              onboardingData[currentPage].color.withOpacity(0.1),
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
                    Text(
                      'Yūgen',
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (currentPage < onboardingData.length - 1)
                      TextButton(
                        onPressed: () => _navigateToAuth(),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: size.width * 0.04,
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
                  },
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) {
                    return OnboardingPage(
                      data: onboardingData[index],
                      size: size,
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
                          width: currentPage == index ? size.width * 0.06 : size.width * 0.02,
                          height: size.height * 0.01,
                          decoration: BoxDecoration(
                            color: currentPage == index
                                ? onboardingData[currentPage].color
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),

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
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 16,
                            ),
                            label: Text(
                              'Back',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: size.width * 0.035,
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
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 5,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentPage < onboardingData.length - 1
                                    ? 'Next'
                                    : 'Get Started',
                                style: GoogleFonts.poppins(
                                  fontSize: size.width * 0.04,
                                  fontWeight: FontWeight.bold,
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

  void _navigateToAuth() {
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
          // Icon and Kanji combination - FIXED VERSION
          _buildResponsiveIconCircle(),
          SizedBox(height: size.height * 0.06),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.065,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(height: size.height * 0.015),

          // Subtitle
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.w500,
              color: data.color,
            ),
          ),

          SizedBox(height: size.height * 0.03),

          // Description
          Container(
            margin: EdgeInsets.symmetric(horizontal: size.width * 0.02),
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: data.color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.035,
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildResponsiveIconCircle() {
    // Calculate responsive sizes with constraints
    final maxCircleSize = math.min(size.width * 0.4, size.height * 0.25);
    final outerCircleSize = math.max(120.0, math.min(maxCircleSize, 180.0));
    final innerCircleSize = outerCircleSize * 0.75;
    final isSmallScreen = size.width < 360 || size.height < 640;

    // Responsive font sizes
    final iconSize = isSmallScreen ? outerCircleSize * 0.2 : outerCircleSize * 0.25;
    final kanjiSize = isSmallScreen ? outerCircleSize * 0.18 : outerCircleSize * 0.22;

    return SizedBox(
      width: outerCircleSize,
      height: outerCircleSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle with gradient
          Container(
            width: outerCircleSize,
            height: outerCircleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  data.color.withOpacity(0.1),
                  data.color.withOpacity(0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),

          // Main icon circle
          Container(
            width: innerCircleSize,
            height: innerCircleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.color.withOpacity(0.15),
              border: Border.all(
                color: data.color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with proper constraints
                Container(
                  constraints: BoxConstraints(
                    maxWidth: innerCircleSize * 0.6,
                    maxHeight: innerCircleSize * 0.4,
                  ),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      data.icon,
                      style: TextStyle(
                        fontSize: iconSize,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: innerCircleSize * 0.02),

                // Kanji with proper constraints
                Container(
                  constraints: BoxConstraints(
                    maxWidth: innerCircleSize * 0.7,
                    maxHeight: innerCircleSize * 0.4,
                  ),
                  child: FittedBox(
                    fit: BoxFit.contain,
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
                ),
              ],
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

// Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool isLoading = false;
  late AnimationController _animationController;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1117),
              Color(0xFF1C2128),
              Color(0xFF2D1B69),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(size.width * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.05),

                  // Header
                  Column(
                    children: [
                      // Logo
                      Container(
                        width: size.width * 0.2,
                        height: size.width * 0.2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(size.width * 0.1),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '幽玄',
                            style: GoogleFonts.notoSansJp(
                              fontSize: size.width * 0.065,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D1B69),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.03),

                      Text(
                        'Welcome Back!',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.07,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: size.height * 0.01),

                      Text(
                        'Sign in to continue your Japanese learning journey',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.035,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.05),

                  // Form fields
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    size: size,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: size.height * 0.02),

                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock,
                    obscureText: true,
                    size: size,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: size.height * 0.06,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'Sign In',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.03),

                  // Forgot password
                  TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF8B5CF6),
                        fontSize: size.width * 0.035,
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.02),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                        child: Text(
                          'or',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: size.width * 0.035,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.03),

                  // Sign up navigation
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                          const SignUpScreen(),
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
                    },
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: size.width * 0.035,
                        ),
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: "Sign Up",
                            style: TextStyle(
                              color: const Color(0xFF8B5CF6),
                              fontWeight: FontWeight.bold,
                              fontSize: size.width * 0.04,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Size size,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: size.width * 0.035,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: size.width * 0.035,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF8B5CF6),
          size: size.width * 0.05,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.02,
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email';
          break;
        case 'wrong-password':
          message = 'Wrong password';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}

// Sign Up Screen
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  bool isLoading = false;
  late AnimationController _animationController;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1117),
              Color(0xFF1C2128),
              Color(0xFF2D1B69),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(size.width * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.03),

                  // Header
                  Column(
                    children: [
                      // Logo
                      Container(
                        width: size.width * 0.2,
                        height: size.width * 0.2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(size.width * 0.1),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '幽玄',
                            style: GoogleFonts.notoSansJp(
                              fontSize: size.width * 0.065,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D1B69),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.03),

                      Text(
                        'Create Account',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.07,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: size.height * 0.01),

                      Text(
                        'Join thousands of learners mastering Japanese',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.035,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Form fields
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    size: size,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: size.height * 0.02),

                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    size: size,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: size.height * 0.02),

                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock,
                    obscureText: true,
                    size: size,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: size.height * 0.02),

                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    size: size,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Sign up button
                  SizedBox(
                    width: double.infinity,
                    height: size.height * 0.06,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'Create Account',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.03),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                        child: Text(
                          'or',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: size.width * 0.035,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.03),

                  // Login navigation
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                          const LoginScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(-1.0, 0.0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: size.width * 0.035,
                        ),
                        children: [
                          const TextSpan(text: "Already have an account? "),
                          TextSpan(
                            text: "Sign In",
                            style: TextStyle(
                              color: const Color(0xFF8B5CF6),
                              fontWeight: FontWeight.bold,
                              fontSize: size.width * 0.04,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Size size,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: size.width * 0.035,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: size.width * 0.035,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF8B5CF6),
          size: size.width * 0.05,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.02,
        ),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'jlptLevel': 'N5', // Default level
        'studyStreak': 0,
        'totalKanjiLearned': 0,
        'favoriteKanji': [],
        'completedStories': [],
        'grammarProgress': {},
        'profileComplete': false,
      });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) =>  HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email already in use';
          break;
        case 'weak-password':
          message = 'Password is too weak';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}

// Temporary Home Screen - we'll create this properly next
