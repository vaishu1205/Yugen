import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'HomeScreen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isForgotPasswordMode = false;
  bool isResetEmailSent = false;

  late AnimationController _animationController;
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _forgotEmailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _forgotPasswordFormKey = GlobalKey<FormState>();

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

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _forgotEmailController.dispose();
    _animationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  void _toggleForgotPasswordMode() {
    setState(() {
      isForgotPasswordMode = !isForgotPasswordMode;
      isResetEmailSent = false;
    });

    if (isForgotPasswordMode) {
      _slideAnimationController.forward();
      _forgotEmailController.text = _emailController.text;
    } else {
      _slideAnimationController.reverse();
    }
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
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                      child: isForgotPasswordMode
                          ? _buildForgotPasswordForm(size)
                          : _buildLoginForm(size),
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Navigation section
                  if (!isForgotPasswordMode) ...[
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
                          style: GoogleFonts.inter(
                            color: const Color(0xFF64748B),
                            fontSize: size.width * 0.035,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: "Sign Up",
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
          _getHeaderTitle(),
          style: GoogleFonts.inter(
            fontSize: size.width * 0.07,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: size.height * 0.015),

        Text(
          _getHeaderSubtitle(),
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

  String _getHeaderTitle() {
    if (isForgotPasswordMode) {
      return isResetEmailSent ? 'Check Your Email' : 'Reset Password';
    }
    return 'Welcome Back';
  }

  String _getHeaderSubtitle() {
    if (isForgotPasswordMode) {
      return isResetEmailSent
          ? 'We sent password reset instructions to your email'
          : 'Enter your email to receive reset instructions';
    }
    return 'Continue your Japanese learning journey';
  }

  Widget _buildLoginForm(Size size) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('login_form'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email field
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

          // Password field
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            hintText: 'Enter your password',
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
              return null;
            },
          ),

          SizedBox(height: size.height * 0.02),

          // Forgot password link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _toggleForgotPasswordMode,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6366F1),
                  fontSize: size.width * 0.035,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: size.height * 0.04),

          // Login button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleLogin,
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
                'Sign In',
                style: GoogleFonts.inter(
                  fontSize: size.width * 0.042,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordForm(Size size) {
    if (isResetEmailSent) {
      return _buildResetEmailSentUI(size);
    }

    return Form(
      key: _forgotPasswordFormKey,
      child: Column(
        key: const ValueKey('forgot_password_form'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email field for reset
          _buildTextField(
            controller: _forgotEmailController,
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

          SizedBox(height: size.height * 0.04),

          // Send reset email button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleForgotPassword,
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
                'Send Reset Email',
                style: GoogleFonts.inter(
                  fontSize: size.width * 0.042,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          SizedBox(height: size.height * 0.03),

          // Back to login button
          Center(
            child: TextButton(
              onPressed: _toggleForgotPasswordMode,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_ios,
                    color: const Color(0xFF6366F1),
                    size: size.width * 0.04,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Back to Sign In',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6366F1),
                      fontSize: size.width * 0.038,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetEmailSentUI(Size size) {
    return Column(
      key: const ValueKey('reset_email_sent'),
      children: [
        // Success icon
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF10B981).withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.email_outlined,
            size: size.width * 0.12,
            color: const Color(0xFF10B981),
          ),
        ),

        SizedBox(height: size.height * 0.03),

        Text(
          'Reset Email Sent!',
          style: GoogleFonts.inter(
            fontSize: size.width * 0.055,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),

        SizedBox(height: size.height * 0.02),

        Text(
          'We sent password reset instructions to:',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: size.width * 0.038,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(height: size.height * 0.01),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _forgotEmailController.text,
            style: GoogleFonts.inter(
              fontSize: size.width * 0.038,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6366F1),
            ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: size.height * 0.03),

        Text(
          'Please check your email and follow the instructions to reset your password.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: size.width * 0.035,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),

        SizedBox(height: size.height * 0.04),

        // Resend email button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: isLoading ? null : _handleForgotPassword,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: const Color(0xFF6366F1), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1),
                strokeWidth: 2.5,
              ),
            )
                : Text(
              'Resend Email',
              style: GoogleFonts.inter(
                fontSize: size.width * 0.042,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6366F1),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),

        SizedBox(height: size.height * 0.02),

        // Back to login button
        Center(
          child: TextButton(
            onPressed: _toggleForgotPasswordMode,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  color: const Color(0xFF6366F1),
                  size: size.width * 0.04,
                ),
                const SizedBox(width: 4),
                Text(
                  'Back to Sign In',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6366F1),
                    fontSize: size.width * 0.038,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

  // In your LoginScreen's _handleLogin method, replace this part:

// Replace your _handleLogin method with this corrected version:

  // Replace your _handleLogin method with this working version:

  Future<void> _handleLogin() async {
    print("🔥 Login button pressed");

    if (!_formKey.currentState!.validate()) {
      print("🔥 Form validation failed");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      print("🔥 Attempting Firebase login...");

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      print("🔥 Firebase login successful!");
      print("🔥 User: ${credential.user?.email}");

      // ADD THIS PART - Create/Update user document after login
      if (credential.user != null) {
        await _createOrUpdateUserDocument(credential.user!);
      }

      if (mounted) {
        _showSuccessMessage('Welcome back!');
        print("🔥 Login completed, navigating to HomeScreen...");

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      // ... your existing error handling
    } catch (e) {
      print("🔥 General exception: $e");
      _showErrorMessage('An unexpected error occurred');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

// ADD THIS NEW METHOD to LoginScreen
  Future<void> _createOrUpdateUserDocument(User user) async {
    try {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDoc = await userDocRef.get();

      print("🔥 Checking if user document exists: ${userDoc.exists}");

      if (!userDoc.exists) {
        // Create new document for existing user
        print("🔥 Creating new user document for existing user");
        await userDocRef.set({
          'name': user.displayName ?? 'User', // Use Firebase displayName or default
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'emailVerified': user.emailVerified,
          'jlptLevel': 'N5',
          'studyStreak': 0,
          'totalXP': 0,
          'totalKanjiLearned': 0,
          'storiesRead': 0,
          'quizzesCompleted': 0,
          'lessonsCompleted': 0,
          'perfectScores': 0,
          'kanjiPracticesSessions': 0,
          'profileComplete': false,
          'lastSeen': FieldValue.serverTimestamp(),
          'isOnline': true,
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
      } else {
        // Update existing document
        print("🔥 Updating existing user document");
        final userData = userDoc.data()!;

        // Check if name field is missing or empty
        if (userData['name'] == null || userData['name'] == '') {
          await userDocRef.update({
            'name': user.displayName ?? user.email?.split('@')[0] ?? 'User',
            'lastSeen': FieldValue.serverTimestamp(),
            'isOnline': true,
          });
        } else {
          // Just update last seen
          await userDocRef.update({
            'lastSeen': FieldValue.serverTimestamp(),
            'isOnline': true,
          });
        }
      }

      print("🔥 User document created/updated successfully");
    } catch (e) {
      print("🔥 Error creating/updating user document: $e");
    }
  }

  Future<void> _handleForgotPassword() async {
    if (!_forgotPasswordFormKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _forgotEmailController.text.trim(),
      );

      if (mounted) {
        setState(() {
          isResetEmailSent = true;
        });
        _showSuccessMessage('Password reset email sent!');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to send reset email';
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email address';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'too-many-requests':
          message = 'Too many requests. Please try again later';
          break;
      }
      _showErrorMessage(message);
    } catch (e) {
      _showErrorMessage('An unexpected error occurred');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
