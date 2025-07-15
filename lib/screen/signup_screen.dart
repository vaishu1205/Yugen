import 'package:flutter/material.dart';
import 'package:flutter_programs/screen/Login_Screen.dart';
import 'package:flutter_programs/screen/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'HomeScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isEmailVerificationSent = false;
  bool isEmailVerified = false;
  bool isCheckingVerification = false;

  late AnimationController _animationController;
  late AnimationController _emailAnimationController;
  late AnimationController _successAnimationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  Timer? _verificationTimer;
  int _dotCount = 0;
  Timer? _dotTimer;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _emailAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _emailAnimationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _startEmailAnimation() {
    _emailAnimationController.repeat(reverse: true);

    // Start checking for email verification
    _startVerificationCheck();

    // Start dot animation
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
        });
      }
    });
  }

  void _startVerificationCheck() {
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      await _checkEmailVerificationSilently();
    });
  }

  void _stopAnimationsAndTimers() {
    _emailAnimationController.stop();
    _verificationTimer?.cancel();
    _dotTimer?.cancel();
  }

  void _showVerificationSuccess() {
    setState(() {
      isEmailVerified = true;
      isCheckingVerification = false;
    });

    _stopAnimationsAndTimers();
    _successAnimationController.forward();

    // Navigate to home screen after animation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _stopAnimationsAndTimers();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    _emailAnimationController.dispose();
    _successAnimationController.dispose();
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
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.05),

                    // Header
                    _buildHeader(size),

                    SizedBox(height: size.height * 0.06),

                    // Main content card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(size.width * 0.06),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.08),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _buildContent(size),
                    ),

                    SizedBox(height: size.height * 0.04),

                    // Navigation to login (only show if not in verification process)
                    if (!isEmailVerificationSent) ...[
                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                            child: Text(
                              'or',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF64748B),
                                fontSize: size.width * 0.035,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: const Color(0xFFE2E8F0),
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
                            style: GoogleFonts.inter(
                              color: const Color(0xFF64748B),
                              fontSize: size.width * 0.035,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              const TextSpan(text: "Already have an account? "),
                              TextSpan(
                                text: "Sign In",
                                style: TextStyle(
                                  color: const Color(0xFF6366F1),
                                  fontWeight: FontWeight.w600,
                                  fontSize: size.width * 0.035,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: size.height * 0.03),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Column(
      children: [
        // Logo
        Container(
          width: size.width * 0.18,
          height: size.width * 0.18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
              ],
            ),
            borderRadius: BorderRadius.circular(size.width * 0.05),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '幽玄',
              style: GoogleFonts.notoSansJp(
                fontSize: size.width * 0.055,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        SizedBox(height: size.height * 0.04),

        Text(
          _getHeaderText(),
          style: GoogleFonts.inter(
            fontSize: size.width * 0.07,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: size.height * 0.015),

        Text(
          _getSubHeaderText(),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: size.width * 0.038,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getHeaderText() {
    if (isEmailVerified) return 'Email Verified!';
    if (isEmailVerificationSent) return 'Check Your Email';
    return 'Create Account';
  }

  String _getSubHeaderText() {
    if (isEmailVerified) return 'Welcome to the Japanese learning community!';
    if (isEmailVerificationSent) return 'We\'re waiting for you to verify your email${'.' * _dotCount}';
    return 'Join thousands of learners mastering Japanese';
  }

  Widget _buildContent(Size size) {
    if (!isEmailVerificationSent) {
      return _buildSignUpForm(size);
    } else if (!isEmailVerified) {
      return _buildEmailVerificationWaiting(size);
    } else {
      return _buildEmailVerifiedSuccess(size);
    }
  }

  Widget _buildSignUpForm(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          hintText: 'Enter your full name',
          icon: Icons.person_outline,
          size: size,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),

        SizedBox(height: size.height * 0.025),

        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hintText: 'Enter your email address',
          icon: Icons.mail_outline,
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

        SizedBox(height: size.height * 0.025),

        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          hintText: 'Create a strong password',
          icon: Icons.lock_outline,
          obscureText: !isPasswordVisible,
          size: size,
          isPassword: true,
          isPasswordVisible: isPasswordVisible,
          onTogglePassword: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
              return 'Password must contain uppercase, lowercase and number';
            }
            return null;
          },
        ),

        SizedBox(height: size.height * 0.025),

        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          hintText: 'Confirm your password',
          icon: Icons.lock_outline,
          obscureText: !isConfirmPasswordVisible,
          size: size,
          isPassword: true,
          isPasswordVisible: isConfirmPasswordVisible,
          onTogglePassword: () {
            setState(() {
              isConfirmPasswordVisible = !isConfirmPasswordVisible;
            });
          },
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
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleSignUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF6366F1).withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
                : Text(
              'Create Account',
              style: GoogleFonts.inter(
                fontSize: size.width * 0.042,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailVerificationWaiting(Size size) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Column(
          children: [
            Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.email_outlined,
                  size: size.width * 0.12,
                  color: const Color(0xFF6366F1),
                ),
              ),
            ),

            SizedBox(height: size.height * 0.04),

            Text(
              'Verification Email Sent!',
              style: GoogleFonts.inter(
                fontSize: size.width * 0.055,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: size.height * 0.02),

            Text(
              'We sent a verification link to:',
              style: GoogleFonts.inter(
                fontSize: size.width * 0.038,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: size.height * 0.015),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _emailController.text,
                style: GoogleFonts.inter(
                  fontSize: size.width * 0.038,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6366F1),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            SizedBox(height: size.height * 0.04),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Waiting for verification',
                    style: GoogleFonts.inter(
                      fontSize: size.width * 0.038,
                      color: const Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: size.height * 0.025),

            Text(
              'Click the link in your email and we\'ll automatically sign you in!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: size.width * 0.035,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmailVerifiedSuccess(Size size) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: size.width * 0.12,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: size.height * 0.04),

                Text(
                  'Email Verified Successfully!',
                  style: GoogleFonts.inter(
                    fontSize: size.width * 0.055,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: size.height * 0.02),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Redirecting to your dashboard...',
                    style: GoogleFonts.inter(
                      fontSize: size.width * 0.038,
                      color: const Color(0xFF059669),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required Size size,
    bool obscureText = false,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: size.width * 0.038,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: size.height * 0.01),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.inter(
            color: const Color(0xFF1F2937),
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF9CA3AF),
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              margin: EdgeInsets.only(right: 12),
              child: Icon(
                icon,
                color: const Color(0xFF6B7280),
                size: size.width * 0.055,
              ),
            ),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: const Color(0xFF6B7280),
                size: size.width * 0.055,
              ),
              onPressed: onTogglePassword,
            )
                : null,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFFE5E7EB), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFFE5E7EB), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFF6366F1), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFFEF4444), width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFFEF4444), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.02,
            ),
            errorStyle: GoogleFonts.inter(
              color: const Color(0xFFEF4444),
              fontSize: size.width * 0.032,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Create user account
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Send email verification
      await credential.user!.sendEmailVerification();

      // Save user data to Firestore (but mark as unverified)
      // Save user data to Firestore (but mark as unverified)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        // Basic user info
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': false,

        // JLPT and Learning Progress - ADD THESE FIELDS
        'jlptLevel': 'N5',
        'studyStreak': 0,
        'totalXP': 0,
        'totalKanjiLearned': 0,
        'storiesRead': 0,
        'quizzesCompleted': 0,
        'lessonsCompleted': 0,
        'perfectScores': 0,
        'kanjiPracticesSessions': 0,

        // Profile and Activity
        'profileComplete': false,
        'lastSeen': FieldValue.serverTimestamp(),
        'isOnline': true,

        // Legacy fields (keep for compatibility)
        'favoriteKanji': [],
        'completedStories': [],
        'grammarProgress': {},

        // Settings (add these for the SettingsScreen)
        'settings': {
          'notifications': true,
          'studyReminders': true,
          'achievementNotifications': true,
          'weeklyReports': true,
          'soundEffects': true,
          'hapticFeedback': true,
          'darkMode': false,
          'offlineMode': false,
          'language': 'English',
          'difficulty': 'Intermediate',
          'studyGoal': '30 minutes',
        },
      });
      if (mounted) {
        setState(() {
          isEmailVerificationSent = true;
          isLoading = false;
        });

        _startEmailAnimation();
        _showSuccessMessage('Verification email sent! Please check your inbox.');
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
        _showErrorMessage(message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Failed to send verification email. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _checkEmailVerificationSilently() async {
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        // Update Firestore to mark email as verified AND ensure all fields exist
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'emailVerified': true,
          'lastSeen': FieldValue.serverTimestamp(),
          'isOnline': true,
        });

        if (mounted) {
          _showVerificationSuccess();
        }
      }
    } catch (e) {
      // Silent fail - continue checking
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_programs/screen/Login_Screen.dart';
// import 'package:flutter_programs/screen/splash_screen.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:async';
// import 'HomeScreen.dart';
//
// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});
//
//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }
//
// class _SignUpScreenState extends State<SignUpScreen>
//     with TickerProviderStateMixin {
//   bool isLoading = false;
//   bool isPasswordVisible = false;
//   bool isConfirmPasswordVisible = false;
//   bool isEmailVerificationSent = false;
//   bool isEmailVerified = false;
//   bool isCheckingVerification = false;
//
//   late AnimationController _animationController;
//   late AnimationController _emailAnimationController;
//   late AnimationController _successAnimationController;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _fadeAnimation;
//
//   Timer? _verificationTimer;
//   int _dotCount = 0;
//   Timer? _dotTimer;
//
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _nameController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//   }
//
//   void _initializeAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//
//     _emailAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
//
//     _successAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
//
//     _pulseAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.2,
//     ).animate(CurvedAnimation(
//       parent: _emailAnimationController,
//       curve: Curves.easeInOut,
//     ));
//
//     _scaleAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _successAnimationController,
//       curve: Curves.elasticOut,
//     ));
//
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _successAnimationController,
//       curve: Curves.easeInOut,
//     ));
//
//     _animationController.forward();
//   }
//
//   void _startEmailAnimation() {
//     _emailAnimationController.repeat(reverse: true);
//
//     // Start checking for email verification
//     _startVerificationCheck();
//
//     // Start dot animation
//     _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
//       if (mounted) {
//         setState(() {
//           _dotCount = (_dotCount + 1) % 4;
//         });
//       }
//     });
//   }
//
//   void _startVerificationCheck() {
//     _verificationTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }
//
//       await _checkEmailVerificationSilently();
//     });
//   }
//
//   void _stopAnimationsAndTimers() {
//     _emailAnimationController.stop();
//     _verificationTimer?.cancel();
//     _dotTimer?.cancel();
//   }
//
//   void _showVerificationSuccess() {
//     setState(() {
//       isEmailVerified = true;
//       isCheckingVerification = false;
//     });
//
//     _stopAnimationsAndTimers();
//     _successAnimationController.forward();
//
//     // Navigate to home screen after animation
//     Future.delayed(const Duration(seconds: 2), () {
//       if (mounted) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (_) => const HomeScreen()),
//         );
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _stopAnimationsAndTimers();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _nameController.dispose();
//     _confirmPasswordController.dispose();
//     _animationController.dispose();
//     _emailAnimationController.dispose();
//     _successAnimationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1117),
//       body: Container(
//         width: size.width,
//         height: size.height,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF0D1117),
//               Color(0xFF1C2128),
//               Color(0xFF2D1B69),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.all(size.width * 0.05),
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - (size.width * 0.1),
//               ),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(height: size.height * 0.02),
//
//                     // Header
//                     Column(
//                       children: [
//                         // Logo
//                         Container(
//                           width: size.width * 0.2,
//                           height: size.width * 0.2,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(size.width * 0.1),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: const Color(0xFF8B5CF6).withOpacity(0.3),
//                                 blurRadius: 20,
//                                 offset: const Offset(0, 10),
//                               ),
//                             ],
//                           ),
//                           child: Center(
//                             child: Text(
//                               '幽玄',
//                               style: GoogleFonts.notoSansJp(
//                                 fontSize: size.width * 0.065,
//                                 fontWeight: FontWeight.bold,
//                                 color: const Color(0xFF2D1B69),
//                               ),
//                             ),
//                           ),
//                         ),
//
//                         SizedBox(height: size.height * 0.03),
//
//                         Text(
//                           _getHeaderText(),
//                           style: GoogleFonts.poppins(
//                             fontSize: size.width * 0.06,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//
//                         SizedBox(height: size.height * 0.01),
//
//                         Text(
//                           _getSubHeaderText(),
//                           textAlign: TextAlign.center,
//                           style: GoogleFonts.poppins(
//                             fontSize: size.width * 0.035,
//                             color: const Color(0xFF8B5CF6),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     SizedBox(height: size.height * 0.04),
//
//                     // Content based on state
//                     if (!isEmailVerificationSent) ...[
//                       // Form fields
//                       _buildSignUpForm(size),
//                     ] else if (!isEmailVerified) ...[
//                       // Email verification waiting
//                       _buildEmailVerificationWaiting(size),
//                     ] else ...[
//                       // Email verified success
//                       _buildEmailVerifiedSuccess(size),
//                     ],
//
//                     SizedBox(height: size.height * 0.03),
//
//                     // Navigation to login (only show if not in verification process)
//                     if (!isEmailVerificationSent) ...[
//                       // Divider
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Divider(
//                               color: Colors.white.withOpacity(0.3),
//                             ),
//                           ),
//                           Padding(
//                             padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
//                             child: Text(
//                               'or',
//                               style: GoogleFonts.poppins(
//                                 color: Colors.white.withOpacity(0.7),
//                                 fontSize: size.width * 0.035,
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             child: Divider(
//                               color: Colors.white.withOpacity(0.3),
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       SizedBox(height: size.height * 0.03),
//
//                       // Login navigation
//                       TextButton(
//                         onPressed: () {
//                           Navigator.of(context).pushReplacement(
//                             PageRouteBuilder(
//                               pageBuilder: (context, animation, secondaryAnimation) =>
//                               const LoginScreen(),
//                               transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                                 return SlideTransition(
//                                   position: Tween<Offset>(
//                                     begin: const Offset(-1.0, 0.0),
//                                     end: Offset.zero,
//                                   ).animate(animation),
//                                   child: child,
//                                 );
//                               },
//                               transitionDuration: const Duration(milliseconds: 500),
//                             ),
//                           );
//                         },
//                         child: RichText(
//                           text: TextSpan(
//                             style: GoogleFonts.poppins(
//                               color: Colors.white70,
//                               fontSize: size.width * 0.035,
//                             ),
//                             children: [
//                               const TextSpan(text: "Already have an account? "),
//                               TextSpan(
//                                 text: "Sign In",
//                                 style: TextStyle(
//                                   color: const Color(0xFF8B5CF6),
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: size.width * 0.04,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//
//                     SizedBox(height: size.height * 0.02),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _getHeaderText() {
//     if (isEmailVerified) return 'Email Verified!';
//     if (isEmailVerificationSent) return 'Check Your Email';
//     return 'Create Account';
//   }
//
//   String _getSubHeaderText() {
//     if (isEmailVerified) return 'Welcome to the Japanese learning community!';
//     if (isEmailVerificationSent) return 'We\'re waiting for you to verify your email${'.' * _dotCount}';
//     return 'Join thousands of learners mastering Japanese';
//   }
//
//   Widget _buildSignUpForm(Size size) {
//     return Column(
//       children: [
//         _buildTextField(
//           controller: _nameController,
//           label: 'Full Name',
//           icon: Icons.person,
//           size: size,
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please enter your full name';
//             }
//             return null;
//           },
//         ),
//
//         SizedBox(height: size.height * 0.02),
//
//         _buildTextField(
//           controller: _emailController,
//           label: 'Email Address',
//           icon: Icons.email,
//           keyboardType: TextInputType.emailAddress,
//           size: size,
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please enter your email';
//             }
//             if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//               return 'Please enter a valid email';
//             }
//             return null;
//           },
//         ),
//
//         SizedBox(height: size.height * 0.02),
//
//         _buildTextField(
//           controller: _passwordController,
//           label: 'Password',
//           icon: Icons.lock,
//           obscureText: !isPasswordVisible,
//           size: size,
//           isPassword: true,
//           isPasswordVisible: isPasswordVisible,
//           onTogglePassword: () {
//             setState(() {
//               isPasswordVisible = !isPasswordVisible;
//             });
//           },
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please enter your password';
//             }
//             if (value.length < 6) {
//               return 'Password must be at least 6 characters';
//             }
//             if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
//               return 'Password must contain uppercase, lowercase and number';
//             }
//             return null;
//           },
//         ),
//
//         SizedBox(height: size.height * 0.02),
//
//         _buildTextField(
//           controller: _confirmPasswordController,
//           label: 'Confirm Password',
//           icon: Icons.lock_outline,
//           obscureText: !isConfirmPasswordVisible,
//           size: size,
//           isPassword: true,
//           isPasswordVisible: isConfirmPasswordVisible,
//           onTogglePassword: () {
//             setState(() {
//               isConfirmPasswordVisible = !isConfirmPasswordVisible;
//             });
//           },
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please confirm your password';
//             }
//             if (value != _passwordController.text) {
//               return 'Passwords do not match';
//             }
//             return null;
//           },
//         ),
//
//         SizedBox(height: size.height * 0.04),
//
//         // Sign up button
//         SizedBox(
//           width: double.infinity,
//           height: 50,
//           child: ElevatedButton(
//             onPressed: isLoading ? null : _handleSignUp,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF8B5CF6),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               elevation: 5,
//             ),
//             child: isLoading
//                 ? const SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(
//                 color: Colors.white,
//                 strokeWidth: 2,
//               ),
//             )
//                 : Text(
//               'Create Account',
//               style: GoogleFonts.poppins(
//                 fontSize: size.width * 0.04,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildEmailVerificationWaiting(Size size) {
//     return AnimatedBuilder(
//       animation: _pulseAnimation,
//       builder: (context, child) {
//         return Container(
//           padding: EdgeInsets.all(size.width * 0.05),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.05),
//             borderRadius: BorderRadius.circular(15),
//             border: Border.all(
//               color: const Color(0xFF8B5CF6).withOpacity(0.3),
//             ),
//           ),
//           child: Column(
//             children: [
//               Transform.scale(
//                 scale: _pulseAnimation.value,
//                 child: Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF8B5CF6).withOpacity(0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.email_outlined,
//                     size: size.width * 0.12,
//                     color: const Color(0xFF8B5CF6),
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: size.height * 0.03),
//
//               Text(
//                 'Verification Email Sent!',
//                 style: GoogleFonts.poppins(
//                   fontSize: size.width * 0.05,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//
//               SizedBox(height: size.height * 0.02),
//
//               Text(
//                 'We sent a verification link to:',
//                 style: GoogleFonts.poppins(
//                   fontSize: size.width * 0.035,
//                   color: Colors.white70,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//
//               SizedBox(height: size.height * 0.01),
//
//               Text(
//                 _emailController.text,
//                 style: GoogleFonts.poppins(
//                   fontSize: size.width * 0.035,
//                   fontWeight: FontWeight.w600,
//                   color: const Color(0xFF8B5CF6),
//                 ),
//                 textAlign: TextAlign.center,
//                 overflow: TextOverflow.ellipsis,
//               ),
//
//               SizedBox(height: size.height * 0.03),
//
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
//                       strokeWidth: 2,
//                     ),
//                   ),
//                   const SizedBox(width: 15),
//                   Text(
//                     'Waiting for verification',
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.035,
//                       color: Colors.white70,
//                     ),
//                   ),
//                 ],
//               ),
//
//               SizedBox(height: size.height * 0.02),
//
//               Text(
//                 'Click the link in your email and we\'ll automatically sign you in!',
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.poppins(
//                   fontSize: size.width * 0.032,
//                   color: Colors.white.withOpacity(0.6),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildEmailVerifiedSuccess(Size size) {
//     return AnimatedBuilder(
//       animation: _scaleAnimation,
//       builder: (context, child) {
//         return FadeTransition(
//           opacity: _fadeAnimation,
//           child: Transform.scale(
//             scale: _scaleAnimation.value,
//             child: Container(
//               padding: EdgeInsets.all(size.width * 0.05),
//               decoration: BoxDecoration(
//                 color: Colors.green.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(15),
//                 border: Border.all(
//                   color: Colors.green.withOpacity(0.3),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: const BoxDecoration(
//                       color: Colors.green,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.check,
//                       size: size.width * 0.12,
//                       color: Colors.white,
//                     ),
//                   ),
//
//                   SizedBox(height: size.height * 0.03),
//
//                   Text(
//                     'Email Verified Successfully!',
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.05,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//
//                   SizedBox(height: size.height * 0.02),
//
//                   Text(
//                     'Redirecting to your dashboard...',
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.035,
//                       color: Colors.white70,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     required Size size,
//     bool obscureText = false,
//     bool isPassword = false,
//     bool isPasswordVisible = false,
//     VoidCallback? onTogglePassword,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       keyboardType: keyboardType,
//       validator: validator,
//       style: GoogleFonts.poppins(
//         color: Colors.white,
//         fontSize: size.width * 0.035,
//       ),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: GoogleFonts.poppins(
//           color: Colors.white70,
//           fontSize: size.width * 0.035,
//         ),
//         prefixIcon: Icon(
//           icon,
//           color: const Color(0xFF8B5CF6),
//           size: size.width * 0.05,
//         ),
//         suffixIcon: isPassword
//             ? IconButton(
//           icon: Icon(
//             isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//             color: const Color(0xFF8B5CF6),
//             size: size.width * 0.05,
//           ),
//           onPressed: onTogglePassword,
//         )
//             : null,
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.05),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: const BorderSide(color: Colors.red, width: 2),
//         ),
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: size.width * 0.04,
//           vertical: size.height * 0.02,
//         ),
//       ),
//     );
//   }
//
//   Future<void> _handleSignUp() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       // Create user account
//       final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text,
//       );
//
//       // Send email verification
//       await credential.user!.sendEmailVerification();
//
//       // Save user data to Firestore (but mark as unverified)
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(credential.user!.uid)
//           .set({
//         'name': _nameController.text.trim(),
//         'email': _emailController.text.trim(),
//         'createdAt': FieldValue.serverTimestamp(),
//         'emailVerified': false,
//         'jlptLevel': 'N5',
//         'studyStreak': 0,
//         'totalKanjiLearned': 0,
//         'favoriteKanji': [],
//         'completedStories': [],
//         'grammarProgress': {},
//         'profileComplete': false,
//       });
//
//       if (mounted) {
//         setState(() {
//           isEmailVerificationSent = true;
//           isLoading = false;
//         });
//
//         _startEmailAnimation();
//         _showSuccessMessage('Verification email sent! Please check your inbox.');
//       }
//     } on FirebaseAuthException catch (e) {
//       String message = 'An error occurred';
//       switch (e.code) {
//         case 'email-already-in-use':
//           message = 'Email already in use';
//           break;
//         case 'weak-password':
//           message = 'Password is too weak';
//           break;
//         case 'invalid-email':
//           message = 'Invalid email address';
//           break;
//       }
//
//       if (mounted) {
//         _showErrorMessage(message);
//       }
//     } catch (e) {
//       if (mounted) {
//         _showErrorMessage('Failed to send verification email. Please try again.');
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _checkEmailVerificationSilently() async {
//     try {
//       await FirebaseAuth.instance.currentUser?.reload();
//       final user = FirebaseAuth.instance.currentUser;
//
//       if (user != null && user.emailVerified) {
//         // Update Firestore to mark email as verified
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .update({'emailVerified': true});
//
//         if (mounted) {
//           _showVerificationSuccess();
//         }
//       }
//     } catch (e) {
//       // Silent fail - continue checking
//     }
//   }
//
//   void _showSuccessMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
//
//   void _showErrorMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
// }
//
//
