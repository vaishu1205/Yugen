import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

// Import your actual screens - update these paths to match your files
import 'Letters_Learning_Screen.dart';
import 'Resume_Builder_Screen.dart';
import 'grammer_quiz_screen.dart';
import 'learn_kani_screen.dart';

import 'navigation_learn_screen.dart';
import 'profile_screen.dart';
import 'story_generator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _floatingAnimation;

  // User Data Variables
  String _userName = "Student";
  int _studyStreak = 0;
  int _kanjiLearned = 0;
  String _currentLevel = "N5";
  int _dailyGoal = 50;
  int _todayProgress = 30;

  // Loading and Error States
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadUserData();
  }

  void _initAnimations() {
    try {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );

      _floatingController = AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this,
      );

      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );

      _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutBack),
      );

      _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
      );

      _animationController.forward();
      _floatingController.repeat(reverse: true);
    } catch (e) {
      print('Animation initialization error: $e');
      setState(() {
        _hasError = true;
        _errorMessage = "Animation setup failed";
      });
    }
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists && mounted) {
          final data = userData.data();
          setState(() {
            _userName = data?['name']?.split(' ')[0] ?? "Student";
            _studyStreak = data?['studyStreak'] ?? 0;
            _kanjiLearned = data?['totalKanjiLearned'] ?? 0;
            _currentLevel = data?['jlptLevel'] ?? "N5";
            _isLoading = false;
          });
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = "Failed to load user data";
        });
      }
    }
  }

  @override
  void dispose() {
    try {
      _animationController.dispose();
      _floatingController.dispose();
    } catch (e) {
      print('Dispose error: $e');
    }
    super.dispose();
  }

  // Responsive helper methods
  double _getResponsiveFontSize(Size size, double baseSize,
      {bool isSmall = false}) {
    if (isSmall && size.width < 360) {
      return baseSize * 0.9;
    }
    return baseSize;
  }

  double _getResponsiveSpacing(Size size, double baseSpacing) {
    return size.width * baseSpacing;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final safePadding = MediaQuery.of(context).padding;

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
          child: _hasError
              ? _buildErrorState(size)
              : FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(_getResponsiveSpacing(size, 0.04)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildHeader(size, isSmallScreen),

                    SizedBox(height: _getResponsiveSpacing(size, 0.02)),

                    // Welcome Message
                    _buildWelcomeMessage(size, isSmallScreen),

                    SizedBox(height: _getResponsiveSpacing(size, 0.025)),

                    // Progress Cards
                    _buildProgressCards(size, isSmallScreen),

                    SizedBox(height: _getResponsiveSpacing(size, 0.025)),

                    // Quick Actions
                    _buildQuickActions(size, isSmallScreen),

                    SizedBox(height: _getResponsiveSpacing(size, 0.025)),

                    // Daily Goals
                    _buildDailyGoals(size, isSmallScreen),

                    SizedBox(height: _getResponsiveSpacing(size, 0.025)),

                    // Featured Kanji
                    _buildFeaturedKanji(size, isSmallScreen),

                    SizedBox(height: _getResponsiveSpacing(size, 0.025)),

                    // Study Tips
                    _buildStudyTips(size, isSmallScreen),

                    SizedBox(height: _getResponsiveSpacing(size, 0.03)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _hasError
          ? null
          : AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatingAnimation.value * 8),
            child: FloatingActionButton.extended(
              onPressed: _startQuickStudy,
              backgroundColor: const Color(0xFF8B5CF6),
              icon: const Icon(Icons.flash_on, color: Colors.white),
              label: Text(
                'Quick Study',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: _getResponsiveFontSize(size, size.width * 0.035),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigation(size),
    );
  }

  Widget _buildErrorState(Size size) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.06),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: size.width * 0.15,
              color: Colors.red.withOpacity(0.7),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              _errorMessage,
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.035,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.03),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _errorMessage = "";
                });
                _loadUserData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.08,
                  vertical: size.height * 0.015,
                ),
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Size size, bool isSmallScreen) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(
                          size,
                          isSmallScreen ? size.width * 0.04 : size.width * 0.045,
                          isSmall: isSmallScreen,
                        ),
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      _userName,
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(
                          size,
                          isSmallScreen ? size.width * 0.065 : size.width * 0.07,
                          isSmall: isSmallScreen,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Notifications
                  GestureDetector(
                    onTap: _showNotifications,
                    child: Container(
                      padding: EdgeInsets.all(size.width * 0.025),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: size.width * 0.06,
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.03),

                  // Profile Avatar
                  GestureDetector(
                    onTap: _navigateToProfile,
                    child: Container(
                      width: size.width * 0.12,
                      height: size.width * 0.12,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                        ),
                        borderRadius: BorderRadius.circular(size.width * 0.06),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _userName.isNotEmpty
                              ? _userName[0].toUpperCase()
                              : 'S',
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeMessage(Size size, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.1),
            const Color(0xFFEC4899).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(size.width * 0.03),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '🌸',
              style: TextStyle(fontSize: size.width * 0.08),
            ),
          ),
          SizedBox(width: size.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to continue your journey?',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(
                      size,
                      isSmallScreen ? size.width * 0.04 : size.width * 0.045,
                      isSmall: isSmallScreen,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: size.height * 0.005),
                Text(
                  'You\'re doing great! Keep up the momentum.',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(size, size.width * 0.035),
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCards(Size size, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Progress',
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(
              size,
              isSmallScreen ? size.width * 0.05 : size.width * 0.055,
              isSmall: isSmallScreen,
            ),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: size.height * 0.015),
        Row(
          children: [
            Expanded(
              child: _buildProgressCard(
                icon: '🔥',
                title: 'Study Streak',
                value: '$_studyStreak',
                subtitle: 'days',
                color: const Color(0xFFFF6B35),
                size: size,
                isSmallScreen: isSmallScreen,
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: _buildProgressCard(
                icon: '🈶',
                title: 'Kanji Learned',
                value: '$_kanjiLearned',
                subtitle: 'characters',
                color: const Color(0xFF10B981),
                size: size,
                isSmallScreen: isSmallScreen,
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.015),
        Row(
          children: [
            Expanded(
              child: _buildProgressCard(
                icon: '📚',
                title: 'Current Level',
                value: _currentLevel,
                subtitle: 'JLPT',
                color: const Color(0xFF8B5CF6),
                size: size,
                isSmallScreen: isSmallScreen,
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: _buildProgressCard(
                icon: '⭐',
                title: 'Total XP',
                value: '${_kanjiLearned * 10}',
                subtitle: 'points',
                color: const Color(0xFFF59E0B),
                size: size,
                isSmallScreen: isSmallScreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressCard({
    required String icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Size size,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                icon,
                style: TextStyle(fontSize: size.width * 0.06),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.02,
                  vertical: size.height * 0.005,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: color,
                  size: size.width * 0.04,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(
                size,
                isSmallScreen ? size.width * 0.065 : size.width * 0.07,
                isSmall: isSmallScreen,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(size, size.width * 0.03),
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(size, size.width * 0.025),
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(Size size, bool isSmallScreen) {
    final actions = [
      {
        'icon': '🈶',
        'title': 'Learn Kanji',
        'subtitle': 'Daily practice',
        'color': const Color(0xFFEC4899),
        'onTap': _navigateToKanji, // This will go to the existing Kanji screen
      },
      {
        'icon': '📖',
        'title': 'Read Stories',
        'subtitle': 'AI-generated',
        'color': const Color(0xFF10B981),
        'onTap': _navigateToStories,
      },
      {
        'icon': '📚',
        'title': 'Grammar Quiz',
        'subtitle': 'Test yourself',
        'color': const Color(0xFF06B6D4),
        'onTap': _navigateToGrammarQuiz, // This will go to the existing Grammar Quiz screen
      },
      {
        'icon': '📄',
        'title': 'Resume Builder',
        'subtitle': 'Create CV',
        'color': const Color(0xFFF59E0B),
        'onTap': _navigateToResume,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(
              size,
              isSmallScreen ? size.width * 0.05 : size.width * 0.055,
              isSmall: isSmallScreen,
            ),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: size.height * 0.015),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - size.width * 0.03) / 2;
            final cardHeight = isSmallScreen ? cardWidth * 0.8 : cardWidth * 0.85;

            return Wrap(
              spacing: size.width * 0.03,
              runSpacing: size.width * 0.03,
              children: actions.map((action) {
                return GestureDetector(
                  onTap: action['onTap'] as VoidCallback,
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    padding: EdgeInsets.all(size.width * 0.035),
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (action['color'] as Color).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          action['icon'] as String,
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(
                              size,
                              isSmallScreen ? size.width * 0.065 : size.width * 0.075,
                              isSmall: isSmallScreen,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                action['title'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: _getResponsiveFontSize(
                                    size,
                                    isSmallScreen ? size.width * 0.032 : size.width * 0.035,
                                    isSmall: isSmallScreen,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: size.height * 0.003),
                              Text(
                                action['subtitle'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: _getResponsiveFontSize(
                                    size,
                                    isSmallScreen ? size.width * 0.028 : size.width * 0.03,
                                    isSmall: isSmallScreen,
                                  ),
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDailyGoals(Size size, bool isSmallScreen) {
    final progress = _todayProgress / _dailyGoal;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF06B6D4).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Daily Goal',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(
                    size,
                    isSmallScreen ? size.width * 0.045 : size.width * 0.05,
                    isSmall: isSmallScreen,
                  ),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '$_todayProgress / $_dailyGoal XP',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(size, size.width * 0.035),
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.015),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              minHeight: size.height * 0.01,
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            '${(progress * 100).toInt()}% complete',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(size, size.width * 0.03),
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedKanji(Size size, bool isSmallScreen) {
    final featuredKanji = ['愛', '学', '友', '夢', '心'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Kanji',
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(
              size,
              isSmallScreen ? size.width * 0.05 : size.width * 0.055,
              isSmall: isSmallScreen,
            ),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: size.height * 0.015),
        SizedBox(
          height: size.height * 0.12,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: featuredKanji.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _navigateToKanji(), // Navigate to existing Kanji screen
                child: Container(
                  margin: EdgeInsets.only(right: size.width * 0.03),
                  width: size.width * 0.2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF8B5CF6).withOpacity(0.1),
                        const Color(0xFFEC4899).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      featuredKanji[index],
                      style: GoogleFonts.notoSansJp(
                        fontSize: size.width * 0.08,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudyTips(Size size, bool isSmallScreen) {
    final tips = [
      'Practice for 15 minutes daily to build consistency',
      'Use mnemonics to remember Kanji more effectively',
      'Read Japanese stories to improve comprehension',
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: const Color(0xFFF59E0B),
                size: size.width * 0.06,
              ),
              SizedBox(width: size.width * 0.02),
              Text(
                'Study Tip',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(
                    size,
                    isSmallScreen ? size.width * 0.045 : size.width * 0.05,
                    isSmall: isSmallScreen,
                  ),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            tips[DateTime.now().day % tips.length],
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(size, size.width * 0.035),
              color: Colors.white.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(Size size) {
    return Container(
      height: size.height * 0.09,
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 'Home', true, size, () {}),
          _buildNavItem(Icons.school, 'Learn', false, size, _navigateToLearnNavigation), // Updated to go to new Learn Navigation screen
          _buildNavItem(Icons.text_fields, 'Letters', false, size, _navigateToLetters), // Updated to Letters instead of Quiz
          _buildNavItem(Icons.person, 'Profile', false, size, _navigateToProfile),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, Size size, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF8B5CF6) : Colors.white.withOpacity(0.6),
            size: size.width * 0.06,
          ),
          SizedBox(height: size.height * 0.005),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(size, size.width * 0.025),
              color: isActive ? const Color(0xFF8B5CF6) : Colors.white.withOpacity(0.6),
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Navigation Methods
  void _startQuickStudy() {
    _showSuccessMessage('Quick Study mode activated! 🚀');
    // Navigate to the new Learn Navigation screen for quick study
    _navigateToLearnNavigation();
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2128),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          'No new notifications',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: const Color(0xFF8B5CF6)),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ProfileScreen(),
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

  // Updated navigation method for Learn - goes to new Learn Navigation screen
  void _navigateToLearnNavigation() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LearnNavigationScreen(),
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

  // Updated navigation method for Letters - goes to new Letters Learning screen
  void _navigateToLetters() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LettersLearningScreen(),
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

  // Existing navigation methods for cards - these go to the existing screens
  void _navigateToKanji() {
    print("🈶 Navigating to Kanji screen...");

    try {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            print("🏗️ Building KanjiLearningScreen...");
            return const KanjiLearningScreen();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      print("❌ Navigation error: $e");
      _showErrorMessage('Navigation failed: $e');
    }
  }

  void _navigateToStories() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const StoryGeneratorScreen(),
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

  void _navigateToGrammarQuiz() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const GrammarQuizScreen(),
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

  void _navigateToResume() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ResumeBuilderScreen(),
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




// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:math' as math;
//
// // Import your actual Kanji screen - update this path to match your file
// import 'Resume_Builder_Screen.dart';
// import 'grammer_quiz_screen.dart';
// import 'learn_kani_screen.dart';
// import 'navigation_learn_screen.dart';
// import 'profile_screen.dart';
// import 'story_generator_screen.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen>
//     with TickerProviderStateMixin {
//   // Animation Controllers
//   late AnimationController _animationController;
//   late AnimationController _floatingController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _slideAnimation;
//   late Animation<double> _floatingAnimation;
//
//   // User Data Variables
//   String _userName = "Student";
//   int _studyStreak = 0;
//   int _kanjiLearned = 0;
//   String _currentLevel = "N5";
//   int _dailyGoal = 50;
//   int _todayProgress = 30;
//
//   // Loading and Error States
//   bool _isLoading = false;
//   bool _hasError = false;
//   String _errorMessage = "";
//
//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//     _loadUserData();
//   }
//
//   void _initAnimations() {
//     try {
//       _animationController = AnimationController(
//         duration: const Duration(milliseconds: 1200),
//         vsync: this,
//       );
//
//       _floatingController = AnimationController(
//         duration: const Duration(seconds: 3),
//         vsync: this,
//       );
//
//       _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//       );
//
//       _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
//         CurvedAnimation(
//             parent: _animationController, curve: Curves.easeOutBack),
//       );
//
//       _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
//       );
//
//       _animationController.forward();
//       _floatingController.repeat(reverse: true);
//     } catch (e) {
//       print('Animation initialization error: $e');
//       setState(() {
//         _hasError = true;
//         _errorMessage = "Animation setup failed";
//       });
//     }
//   }
//
//   Future<void> _loadUserData() async {
//     if (!mounted) return;
//
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//     });
//
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final userData = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();
//
//         if (userData.exists && mounted) {
//           final data = userData.data();
//           setState(() {
//             _userName = data?['name']?.split(' ')[0] ?? "Student";
//             _studyStreak = data?['studyStreak'] ?? 0;
//             _kanjiLearned = data?['totalKanjiLearned'] ?? 0;
//             _currentLevel = data?['jlptLevel'] ?? "N5";
//             _isLoading = false;
//           });
//         } else {
//           if (mounted) {
//             setState(() {
//               _isLoading = false;
//             });
//           }
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       print('Error loading user data: $e');
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _hasError = true;
//           _errorMessage = "Failed to load user data";
//         });
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     try {
//       _animationController.dispose();
//       _floatingController.dispose();
//     } catch (e) {
//       print('Dispose error: $e');
//     }
//     super.dispose();
//   }
//
//   // Responsive helper methods
//   double _getResponsiveFontSize(Size size, double baseSize,
//       {bool isSmall = false}) {
//     if (isSmall && size.width < 360) {
//       return baseSize * 0.9;
//     }
//     return baseSize;
//   }
//
//   double _getResponsiveSpacing(Size size, double baseSpacing) {
//     return size.width * baseSpacing;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery
//         .of(context)
//         .size;
//     final isSmallScreen = size.width < 360;
//     final safePadding = MediaQuery
//         .of(context)
//         .padding;
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
//           child: _hasError
//               ? _buildErrorState(size)
//               : FadeTransition(
//             opacity: _fadeAnimation,
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: Padding(
//                 padding: EdgeInsets.all(_getResponsiveSpacing(size, 0.04)),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header Section
//                     _buildHeader(size, isSmallScreen),
//
//                     SizedBox(height: _getResponsiveSpacing(size, 0.02)),
//
//                     // Welcome Message
//                     _buildWelcomeMessage(size, isSmallScreen),
//
//                     SizedBox(height: _getResponsiveSpacing(size, 0.025)),
//
//                     // Progress Cards
//                     _buildProgressCards(size, isSmallScreen),
//
//                     SizedBox(height: _getResponsiveSpacing(size, 0.025)),
//
//                     // Quick Actions
//                     _buildQuickActions(size, isSmallScreen),
//
//                     SizedBox(height: _getResponsiveSpacing(size, 0.025)),
//
//                     // Daily Goals
//                     _buildDailyGoals(size, isSmallScreen),
//
//                     SizedBox(height: _getResponsiveSpacing(size, 0.025)),
//
//                     // Featured Kanji
//                     _buildFeaturedKanji(size, isSmallScreen),
//
//                     SizedBox(height: _getResponsiveSpacing(size, 0.025)),
//
//                     // Study Tips
//                     _buildStudyTips(size, isSmallScreen),
//
//                     SizedBox(height: _getResponsiveSpacing(size, 0.03)),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       floatingActionButton: _hasError
//           ? null
//           : AnimatedBuilder(
//         animation: _floatingAnimation,
//         builder: (context, child) {
//           return Transform.translate(
//             offset: Offset(0, _floatingAnimation.value * 8),
//             child: FloatingActionButton.extended(
//               onPressed: _startQuickStudy,
//               backgroundColor: const Color(0xFF8B5CF6),
//               icon: const Icon(Icons.flash_on, color: Colors.white),
//               label: Text(
//                 'Quick Study',
//                 style: GoogleFonts.poppins(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: _getResponsiveFontSize(size, size.width * 0.035),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//       bottomNavigationBar: _buildBottomNavigation(size),
//     );
//   }
//
//   Widget _buildErrorState(Size size) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(size.width * 0.06),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline,
//               size: size.width * 0.15,
//               color: Colors.red.withOpacity(0.7),
//             ),
//             SizedBox(height: size.height * 0.02),
//             Text(
//               'Oops! Something went wrong',
//               style: GoogleFonts.poppins(
//                 fontSize: size.width * 0.05,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: size.height * 0.01),
//             Text(
//               _errorMessage,
//               style: GoogleFonts.poppins(
//                 fontSize: size.width * 0.035,
//                 color: Colors.white.withOpacity(0.7),
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: size.height * 0.03),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _hasError = false;
//                   _errorMessage = "";
//                 });
//                 _loadUserData();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF8B5CF6),
//                 padding: EdgeInsets.symmetric(
//                   horizontal: size.width * 0.08,
//                   vertical: size.height * 0.015,
//                 ),
//               ),
//               child: Text(
//                 'Try Again',
//                 style: GoogleFonts.poppins(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(Size size, bool isSmallScreen) {
//     return AnimatedBuilder(
//       animation: _slideAnimation,
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(0, _slideAnimation.value),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Flexible(
//                 flex: 2,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       _getGreeting(),
//                       style: GoogleFonts.poppins(
//                         fontSize: _getResponsiveFontSize(
//                           size,
//                           isSmallScreen ? size.width * 0.04 : size.width *
//                               0.045,
//                           isSmall: isSmallScreen,
//                         ),
//                         color: Colors.white.withOpacity(0.7),
//                       ),
//                     ),
//                     Text(
//                       _userName,
//                       style: GoogleFonts.poppins(
//                         fontSize: _getResponsiveFontSize(
//                           size,
//                           isSmallScreen ? size.width * 0.065 : size.width *
//                               0.07,
//                           isSmall: isSmallScreen,
//                         ),
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Notifications
//                   GestureDetector(
//                     onTap: _showNotifications,
//                     child: Container(
//                       padding: EdgeInsets.all(size.width * 0.025),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.2),
//                           width: 1,
//                         ),
//                       ),
//                       child: Icon(
//                         Icons.notifications_outlined,
//                         color: Colors.white,
//                         size: size.width * 0.06,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: size.width * 0.03),
//
//                   // Profile Avatar
//                   GestureDetector(
//                     onTap: _navigateToProfile,
//                     child: Container(
//                       width: size.width * 0.12,
//                       height: size.width * 0.12,
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
//                         ),
//                         borderRadius: BorderRadius.circular(size.width * 0.06),
//                         boxShadow: [
//                           BoxShadow(
//                             color: const Color(0xFF8B5CF6).withOpacity(0.3),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Center(
//                         child: Text(
//                           _userName.isNotEmpty
//                               ? _userName[0].toUpperCase()
//                               : 'S',
//                           style: GoogleFonts.poppins(
//                             fontSize: size.width * 0.05,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildWelcomeMessage(Size size, bool isSmallScreen) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(size.width * 0.04),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             const Color(0xFF8B5CF6).withOpacity(0.1),
//             const Color(0xFFEC4899).withOpacity(0.1),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0xFF8B5CF6).withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(size.width * 0.03),
//             decoration: BoxDecoration(
//               color: const Color(0xFF8B5CF6).withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               '🌸',
//               style: TextStyle(fontSize: size.width * 0.08),
//             ),
//           ),
//           SizedBox(width: size.width * 0.04),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Ready to continue your journey?',
//                   style: GoogleFonts.poppins(
//                     fontSize: _getResponsiveFontSize(
//                       size,
//                       isSmallScreen ? size.width * 0.04 : size.width * 0.045,
//                       isSmall: isSmallScreen,
//                     ),
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.005),
//                 Text(
//                   'You\'re doing great! Keep up the momentum.',
//                   style: GoogleFonts.poppins(
//                     fontSize: _getResponsiveFontSize(size, size.width * 0.035),
//                     color: Colors.white.withOpacity(0.7),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildProgressCards(Size size, bool isSmallScreen) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Your Progress',
//           style: GoogleFonts.poppins(
//             fontSize: _getResponsiveFontSize(
//               size,
//               isSmallScreen ? size.width * 0.05 : size.width * 0.055,
//               isSmall: isSmallScreen,
//             ),
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         SizedBox(height: size.height * 0.015),
//         Row(
//           children: [
//             Expanded(
//               child: _buildProgressCard(
//                 icon: '🔥',
//                 title: 'Study Streak',
//                 value: '$_studyStreak',
//                 subtitle: 'days',
//                 color: const Color(0xFFFF6B35),
//                 size: size,
//                 isSmallScreen: isSmallScreen,
//               ),
//             ),
//             SizedBox(width: size.width * 0.03),
//             Expanded(
//               child: _buildProgressCard(
//                 icon: '🈶',
//                 title: 'Kanji Learned',
//                 value: '$_kanjiLearned',
//                 subtitle: 'characters',
//                 color: const Color(0xFF10B981),
//                 size: size,
//                 isSmallScreen: isSmallScreen,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: size.height * 0.015),
//         Row(
//           children: [
//             Expanded(
//               child: _buildProgressCard(
//                 icon: '📚',
//                 title: 'Current Level',
//                 value: _currentLevel,
//                 subtitle: 'JLPT',
//                 color: const Color(0xFF8B5CF6),
//                 size: size,
//                 isSmallScreen: isSmallScreen,
//               ),
//             ),
//             SizedBox(width: size.width * 0.03),
//             Expanded(
//               child: _buildProgressCard(
//                 icon: '⭐',
//                 title: 'Total XP',
//                 value: '${_kanjiLearned * 10}',
//                 subtitle: 'points',
//                 color: const Color(0xFFF59E0B),
//                 size: size,
//                 isSmallScreen: isSmallScreen,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildProgressCard({
//     required String icon,
//     required String title,
//     required String value,
//     required String subtitle,
//     required Color color,
//     required Size size,
//     required bool isSmallScreen,
//   }) {
//     return Container(
//       padding: EdgeInsets.all(size.width * 0.04),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: color.withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 icon,
//                 style: TextStyle(fontSize: size.width * 0.06),
//               ),
//               const Spacer(),
//               Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: size.width * 0.02,
//                   vertical: size.height * 0.005,
//                 ),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   Icons.trending_up,
//                   color: color,
//                   size: size.width * 0.04,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: size.height * 0.01),
//           Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: _getResponsiveFontSize(
//                 size,
//                 isSmallScreen ? size.width * 0.065 : size.width * 0.07,
//                 isSmall: isSmallScreen,
//               ),
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           Text(
//             title,
//             style: GoogleFonts.poppins(
//               fontSize: _getResponsiveFontSize(size, size.width * 0.03),
//               color: Colors.white.withOpacity(0.8),
//               fontWeight: FontWeight.w500,
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//           Text(
//             subtitle,
//             style: GoogleFonts.poppins(
//               fontSize: _getResponsiveFontSize(size, size.width * 0.025),
//               color: Colors.white.withOpacity(0.6),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQuickActions(Size size, bool isSmallScreen) {
//     final actions = [
//       {
//         'icon': '🈶',
//         'title': 'Learn Kanji',
//         'subtitle': 'Daily practice',
//         'color': const Color(0xFFEC4899),
//         'onTap': _navigateToKanji,
//       },
//       {
//         'icon': '📖',
//         'title': 'Read Stories',
//         'subtitle': 'AI-generated',
//         'color': const Color(0xFF10B981),
//         'onTap': _navigateToStories,
//       },
//       {
//         'icon': '📚',
//         'title': 'Grammar Quiz',
//         'subtitle': 'Test yourself',
//         'color': const Color(0xFF06B6D4),
//         'onTap': _navigateToQuiz,
//       },
//       {
//         'icon': '📄',
//         'title': 'Resume Builder',
//         'subtitle': 'Create CV',
//         'color': const Color(0xFFF59E0B),
//         'onTap': _navigateToResume,
//       },
//     ];
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Quick Actions',
//           style: GoogleFonts.poppins(
//             fontSize: _getResponsiveFontSize(
//               size,
//               isSmallScreen ? size.width * 0.05 : size.width * 0.055,
//               isSmall: isSmallScreen,
//             ),
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         SizedBox(height: size.height * 0.015),
//         LayoutBuilder(
//           builder: (context, constraints) {
//             final cardWidth = (constraints.maxWidth - size.width * 0.03) / 2;
//             final cardHeight = isSmallScreen ? cardWidth * 0.8 : cardWidth *
//                 0.85;
//
//             return Wrap(
//               spacing: size.width * 0.03,
//               runSpacing: size.width * 0.03,
//               children: actions.map((action) {
//                 return GestureDetector(
//                   onTap: action['onTap'] as VoidCallback,
//                   child: Container(
//                     width: cardWidth,
//                     height: cardHeight,
//                     padding: EdgeInsets.all(size.width * 0.035),
//                     decoration: BoxDecoration(
//                       color: (action['color'] as Color).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(
//                         color: (action['color'] as Color).withOpacity(0.3),
//                         width: 1,
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           action['icon'] as String,
//                           style: TextStyle(
//                             fontSize: _getResponsiveFontSize(
//                               size,
//                               isSmallScreen ? size.width * 0.065 : size.width *
//                                   0.075,
//                               isSmall: isSmallScreen,
//                             ),
//                           ),
//                         ),
//                         Flexible(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(
//                                 action['title'] as String,
//                                 style: GoogleFonts.poppins(
//                                   fontSize: _getResponsiveFontSize(
//                                     size,
//                                     isSmallScreen ? size.width * 0.032 : size
//                                         .width * 0.035,
//                                     isSmall: isSmallScreen,
//                                   ),
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               SizedBox(height: size.height * 0.003),
//                               Text(
//                                 action['subtitle'] as String,
//                                 style: GoogleFonts.poppins(
//                                   fontSize: _getResponsiveFontSize(
//                                     size,
//                                     isSmallScreen ? size.width * 0.028 : size
//                                         .width * 0.03,
//                                     isSmall: isSmallScreen,
//                                   ),
//                                   color: Colors.white.withOpacity(0.7),
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDailyGoals(Size size, bool isSmallScreen) {
//     final progress = _todayProgress / _dailyGoal;
//
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(size.width * 0.04),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             const Color(0xFF10B981).withOpacity(0.1),
//             const Color(0xFF06B6D4).withOpacity(0.1),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0xFF10B981).withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 'Daily Goal',
//                 style: GoogleFonts.poppins(
//                   fontSize: _getResponsiveFontSize(
//                     size,
//                     isSmallScreen ? size.width * 0.045 : size.width * 0.05,
//                     isSmall: isSmallScreen,
//                   ),
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 '$_todayProgress / $_dailyGoal XP',
//                 style: GoogleFonts.poppins(
//                   fontSize: _getResponsiveFontSize(size, size.width * 0.035),
//                   color: Colors.white.withOpacity(0.8),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: size.height * 0.015),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: LinearProgressIndicator(
//               value: progress,
//               backgroundColor: Colors.white.withOpacity(0.2),
//               valueColor: const AlwaysStoppedAnimation<Color>(
//                   Color(0xFF10B981)),
//               minHeight: size.height * 0.01,
//             ),
//           ),
//           SizedBox(height: size.height * 0.01),
//           Text(
//             '${(progress * 100).toInt()}% complete',
//             style: GoogleFonts.poppins(
//               fontSize: _getResponsiveFontSize(size, size.width * 0.03),
//               color: Colors.white.withOpacity(0.7),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFeaturedKanji(Size size, bool isSmallScreen) {
//     final featuredKanji = ['愛', '学', '友', '夢', '心'];
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Today\'s Kanji',
//           style: GoogleFonts.poppins(
//             fontSize: _getResponsiveFontSize(
//               size,
//               isSmallScreen ? size.width * 0.05 : size.width * 0.055,
//               isSmall: isSmallScreen,
//             ),
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         SizedBox(height: size.height * 0.015),
//         SizedBox(
//           height: size.height * 0.12,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: featuredKanji.length,
//             itemBuilder: (context, index) {
//               return GestureDetector(
//                 onTap: () => _navigateToKanji(),
//                 child: Container(
//                   margin: EdgeInsets.only(right: size.width * 0.03),
//                   width: size.width * 0.2,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         const Color(0xFF8B5CF6).withOpacity(0.1),
//                         const Color(0xFFEC4899).withOpacity(0.1),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: const Color(0xFF8B5CF6).withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Center(
//                     child: Text(
//                       featuredKanji[index],
//                       style: GoogleFonts.notoSansJp(
//                         fontSize: size.width * 0.08,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStudyTips(Size size, bool isSmallScreen) {
//     final tips = [
//       'Practice for 15 minutes daily to build consistency',
//       'Use mnemonics to remember Kanji more effectively',
//       'Read Japanese stories to improve comprehension',
//     ];
//
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(size.width * 0.04),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.1),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.lightbulb_outline,
//                 color: const Color(0xFFF59E0B),
//                 size: size.width * 0.06,
//               ),
//               SizedBox(width: size.width * 0.02),
//               Text(
//                 'Study Tip',
//                 style: GoogleFonts.poppins(
//                   fontSize: _getResponsiveFontSize(
//                     size,
//                     isSmallScreen ? size.width * 0.045 : size.width * 0.05,
//                     isSmall: isSmallScreen,
//                   ),
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: size.height * 0.01),
//           Text(
//             tips[DateTime
//                 .now()
//                 .day % tips.length],
//             style: GoogleFonts.poppins(
//               fontSize: _getResponsiveFontSize(size, size.width * 0.035),
//               color: Colors.white.withOpacity(0.8),
//               height: 1.4,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBottomNavigation(Size size) {
//     return Container(
//       height: size.height * 0.09,
//       decoration: BoxDecoration(
//         color: const Color(0xFF1C2128),
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _buildNavItem(Icons.home, 'Home', true, size, () {}),
//           _buildNavItem(Icons.school, 'Learn', false, size, _navigateToKanji),
//           _buildNavItem(Icons.quiz, 'Quiz', false, size, _navigateToQuiz),
//           _buildNavItem(
//               Icons.person, 'Profile', false, size, _navigateToProfile),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNavItem(IconData icon, String label, bool isActive, Size size,
//       VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon,
//             color: isActive ? const Color(0xFF8B5CF6) : Colors.white
//                 .withOpacity(0.6),
//             size: size.width * 0.06,
//           ),
//           SizedBox(height: size.height * 0.005),
//           Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: _getResponsiveFontSize(size, size.width * 0.025),
//               color: isActive ? const Color(0xFF8B5CF6) : Colors.white
//                   .withOpacity(0.6),
//               fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Helper Methods
//   String _getGreeting() {
//     final hour = DateTime
//         .now()
//         .hour;
//     if (hour < 12) return 'Good Morning';
//     if (hour < 17) return 'Good Afternoon';
//     return 'Good Evening';
//   }
//
//   void _showSuccessMessage(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: const Color(0xFF10B981),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   void _showErrorMessage(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
//
//   // Navigation Methods
//   void _startQuickStudy() {
//     _showSuccessMessage('Quick Study mode activated! 🚀');
//     // TODO: Implement quick study functionality
//   }
//
//   void _showNotifications() {
//     showDialog(
//       context: context,
//       builder: (context) =>
//           AlertDialog(
//             backgroundColor: const Color(0xFF1C2128),
//             title: Text(
//               'Notifications',
//               style: GoogleFonts.poppins(color: Colors.white),
//             ),
//             content: Text(
//               'No new notifications',
//               style: GoogleFonts.poppins(color: Colors.white70),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text(
//                   'Close',
//                   style: GoogleFonts.poppins(color: const Color(0xFF8B5CF6)),
//                 ),
//               ),
//             ],
//           ),
//     );
//   }
//
//   void _navigateToProfile() {
//     Navigator.of(context).push(
//       PageRouteBuilder(
//         pageBuilder: (context, animation, secondaryAnimation) =>
//         const ProfileScreen(),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           return SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(1.0, 0.0),
//               end: Offset.zero,
//             ).animate(animation),
//             child: child,
//           );
//         },
//         transitionDuration: const Duration(milliseconds: 500),
//       ),
//     );
//   }
//
//   void _navigateToKanji() {
//     print("🈶 Navigating to Kanji screen...");
//
//     try {
//       Navigator.of(context).push(
//         PageRouteBuilder(
//           pageBuilder: (context, animation, secondaryAnimation) {
//             print("🏗️ Building KanjiLearningScreen...");
//             return const KanjiLearningScreen ();
//           },
//           transitionsBuilder: (context, animation, secondaryAnimation, child) {
//             return SlideTransition(
//               position: Tween<Offset>(
//                 begin: const Offset(1.0, 0.0),
//                 end: Offset.zero,
//               ).animate(CurvedAnimation(
//                 parent: animation,
//                 curve: Curves.easeInOut,
//               )),
//               child: child,
//             );
//           },
//           transitionDuration: const Duration(milliseconds: 500),
//         ),
//       );
//     } catch (e) {
//       print("❌ Navigation error: $e");
//       _showErrorMessage('Navigation failed: $e');
//     }
//   }
//
//   void _navigateToStories() {
//     Navigator.of(context).push(
//       PageRouteBuilder(
//         pageBuilder: (context, animation, secondaryAnimation) =>
//         const StoryGeneratorScreen(),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           return SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(1.0, 0.0),
//               end: Offset.zero,
//             ).animate(animation),
//             child: child,
//           );
//         },
//         transitionDuration: const Duration(milliseconds: 500),
//       ),
//     );
//   }
//
//   void _navigateToQuiz() {
//     Navigator.of(context).push(
//       PageRouteBuilder(
//         pageBuilder: (context, animation, secondaryAnimation) =>
//         const GrammarQuizScreen(),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           return SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(1.0, 0.0),
//               end: Offset.zero,
//             ).animate(animation),
//             child: child,
//           );
//         },
//         transitionDuration: const Duration(milliseconds: 500),
//       ),
//     );
//   }
//
//   void _navigateToResume() {
//     Navigator.of(context).push(
//       PageRouteBuilder(
//         pageBuilder: (context, animation, secondaryAnimation) =>
//         const ResumeBuilderScreen(),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           return SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(1.0, 0.0),
//               end: Offset.zero,
//             ).animate(animation),
//             child: child,
//           );
//         },
//         transitionDuration: const Duration(milliseconds: 500),
//       ),
//     );
//   }
// }
//
