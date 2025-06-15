import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// Import your other screens - update these paths as needed
import 'Grammer_Learning_Screen.dart';
import 'Vocabulary_learning_screen.dart';
import 'conversation_learning_screen.dart';

class LearnNavigationScreen extends StatefulWidget {
  const LearnNavigationScreen({super.key});

  @override
  State<LearnNavigationScreen> createState() => _LearnNavigationScreenState();
}

class _LearnNavigationScreenState extends State<LearnNavigationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  String selectedLevel = "N5";
  final levels = ["N5", "N4", "N3", "N2", "N1"];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(size, isSmallScreen),
                    SizedBox(height: size.height * 0.03),

                    // Level Selector
                    _buildLevelSelector(size, isSmallScreen),
                    SizedBox(height: size.height * 0.03),

                    // Learning Categories
                    _buildLearningCategories(size, isSmallScreen),
                    SizedBox(height: size.height * 0.02),

                    // Progress Overview
                    _buildProgressOverview(size, isSmallScreen),
                    SizedBox(height: size.height * 0.02),

                    // Tips Section
                    _buildTipsSection(size, isSmallScreen),
                  ],
                ),
              ),
            ),
          ),
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
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
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
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: size.width * 0.05,
                  ),
                ),
              ),
              SizedBox(width: size.width * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learn Japanese',
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.065,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Choose your learning path',
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.035,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Animated Japanese character
              AnimatedBuilder(
                animation: _floatingController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatingController.value * 5),
                    child: Container(
                      padding: EdgeInsets.all(size.width * 0.03),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        '学',
                        style: GoogleFonts.notoSansJp(
                          fontSize: size.width * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLevelSelector(Size size, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Level',
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: size.height * 0.015),
        Container(
          height: size.height * 0.06,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final level = levels[index];
              final isSelected = level == selectedLevel;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedLevel = level;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(right: size.width * 0.03),
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.06,
                    vertical: size.height * 0.015,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    )
                        : null,
                    color: isSelected ? null : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      level,
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.04,
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

  Widget _buildLearningCategories(Size size, bool isSmallScreen) {
    final categories = [
      {
        'icon': '📚',
        'title': 'Grammar',
        'subtitle': 'Learn sentence structures',
        'description': 'Master Japanese grammar rules',
        'color': const Color(0xFF8B5CF6),
        'onTap': () => _navigateToGrammar(),
      },
      {
        'icon': '📖',
        'title': 'Vocabulary',
        'subtitle': 'Expand your word bank',
        'description': 'Learn essential Japanese words',
        'color': const Color(0xFF10B981),
        'onTap': () => _navigateToVocabulary(),
      },
      {
        'icon': '💬',
        'title': 'Conversation',
        'subtitle': 'Practice daily phrases',
        'description': 'Learn practical speaking skills',
        'color': const Color(0xFF06B6D4),
        'onTap': () => _navigateToConversation(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Categories',
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: size.height * 0.015),
        ...categories.map((category) => _buildCategoryCard(category, size, isSmallScreen)),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, Size size, bool isSmallScreen) {
    return GestureDetector(
      onTap: category['onTap'] as VoidCallback,
      child: Container(
        margin: EdgeInsets.only(bottom: size.height * 0.015),
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: (category['color'] as Color).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (category['color'] as Color).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(size.width * 0.03),
              decoration: BoxDecoration(
                color: (category['color'] as Color).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                category['icon'] as String,
                style: TextStyle(fontSize: size.width * 0.08),
              ),
            ),
            SizedBox(width: size.width * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['title'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    category['subtitle'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.032,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: size.height * 0.005),
                  Text(
                    category['description'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.03,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: category['color'] as Color,
              size: size.width * 0.05,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressOverview(Size size, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF59E0B).withOpacity(0.1),
            const Color(0xFFFF6B35).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: const Color(0xFFF59E0B),
                size: size.width * 0.06,
              ),
              SizedBox(width: size.width * 0.02),
              Text(
                'Your Progress',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.015),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem('Grammar', '75%', 0.75, const Color(0xFF8B5CF6), size),
              ),
              SizedBox(width: size.width * 0.04),
              Expanded(
                child: _buildProgressItem('Vocabulary', '60%', 0.60, const Color(0xFF10B981), size),
              ),
              SizedBox(width: size.width * 0.04),
              Expanded(
                child: _buildProgressItem('Speaking', '45%', 0.45, const Color(0xFF06B6D4), size),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String title, String percentage, double value, Color color, Size size) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.03,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: size.height * 0.005),
        Text(
          percentage,
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.035,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: size.height * 0.005),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: size.height * 0.006,
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection(Size size, bool isSmallScreen) {
    final tips = [
      "Start with ${selectedLevel} level basics",
      "Practice 15 minutes daily for best results",
      "Don't skip the fundamentals",
      "Use spaced repetition for memory",
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
                'Learning Tips',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.015),
          ...tips.map((tip) => Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.008),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: size.height * 0.008),
                  width: size.width * 0.015,
                  height: size.width * 0.015,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(size.width * 0.0075),
                  ),
                ),
                SizedBox(width: size.width * 0.03),
                Expanded(
                  child: Text(
                    tip,
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.032,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToGrammar() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            GrammarLearningScreen(level: selectedLevel),
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

  void _navigateToVocabulary() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            VocabularyLearningScreen(level: selectedLevel),
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

  void _navigateToConversation() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ConversationLearningScreen(level: selectedLevel),
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
// // Import screens (update these paths to match your project structure)
// // import 'letters_learning_screen.dart';
// import 'learn_kani_screen.dart';
// // import 'vocabulary_screen.dart';
// // import 'grammar_patterns_screen.dart';
// // import 'listening_practice_screen.dart';
// // import 'speaking_practice_screen.dart';
// // import 'flashcards_screen.dart';
// // import 'achievement_screen.dart';
//
// class LearnMainScreen extends StatefulWidget {
//   const LearnMainScreen({super.key});
//
//   @override
//   State<LearnMainScreen> createState() => _LearnMainScreenState();
// }
//
// class _LearnMainScreenState extends State<LearnMainScreen>
//     with TickerProviderStateMixin {
//   // Animation Controllers
//   late AnimationController _animationController;
//   late AnimationController _floatingController;
//   late AnimationController _pulseController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _slideAnimation;
//   late Animation<double> _floatingAnimation;
//   late Animation<double> _pulseAnimation;
//
//   // User Progress Data
//   Map<String, int> userProgress = {
//     'hiragana': 65,
//     'katakana': 45,
//     'kanji': 30,
//     'vocabulary': 80,
//     'grammar': 55,
//     'listening': 40,
//     'speaking': 25,
//     'overall': 0,
//   };
//
//   Map<String, int> streakData = {
//     'daily': 7,
//     'weekly': 3,
//     'monthly': 1,
//   };
//
//   List<String> achievements = [
//     'First Steps 🌱',
//     'Hiragana Master 🎯',
//     'Week Warrior 🔥',
//     'Vocabulary Builder 📚',
//   ];
//
//   bool _isLoading = false;
//   String _selectedCategory = 'all';
//
//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//     _loadUserProgress();
//     _calculateOverallProgress();
//   }
//
//   void _initAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );
//
//     _floatingController = AnimationController(
//       duration: const Duration(seconds: 4),
//       vsync: this,
//     );
//
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
//
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//
//     _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
//     );
//
//     _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
//     );
//
//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//
//     _animationController.forward();
//     _floatingController.repeat(reverse: true);
//     _pulseController.repeat(reverse: true);
//   }
//
//   Future<void> _loadUserProgress() async {
//     setState(() => _isLoading = true);
//
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final doc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();
//
//         if (doc.exists) {
//           final data = doc.data()!;
//           setState(() {
//             userProgress = Map<String, int>.from(data['progress'] ?? userProgress);
//             streakData = Map<String, int>.from(data['streaks'] ?? streakData);
//             achievements = List<String>.from(data['achievements'] ?? achievements);
//           });
//           _calculateOverallProgress();
//         }
//       }
//     } catch (e) {
//       print('Error loading progress: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _calculateOverallProgress() {
//     final total = userProgress.values.where((key) => key != userProgress['overall']).reduce((a, b) => a + b);
//     final average = total / (userProgress.length - 1);
//     setState(() {
//       userProgress['overall'] = average.round();
//     });
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     _floatingController.dispose();
//     _pulseController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isSmallScreen = size.width < 360;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1117),
//       body: Container(
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
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: CustomScrollView(
//               physics: const BouncingScrollPhysics(),
//               slivers: [
//                 // Custom App Bar
//                 _buildSliverAppBar(size, isSmallScreen),
//
//                 // Content
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: EdgeInsets.all(size.width * 0.04),
//                     child: Column(
//                       children: [
//                         // Progress Overview
//                         _buildProgressOverview(size, isSmallScreen),
//
//                         SizedBox(height: size.height * 0.025),
//
//                         // Category Filter
//                         _buildCategoryFilter(size, isSmallScreen),
//
//                         SizedBox(height: size.height * 0.025),
//
//                         // Learning Modules
//                         _buildLearningModules(size, isSmallScreen),
//
//                         SizedBox(height: size.height * 0.025),
//
//                         // Daily Challenge
//                         _buildDailyChallenge(size, isSmallScreen),
//
//                         SizedBox(height: size.height * 0.025),
//
//                         // Recent Achievements
//                         _buildRecentAchievements(size, isSmallScreen),
//
//                         SizedBox(height: size.height * 0.03),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       floatingActionButton: AnimatedBuilder(
//         animation: _pulseAnimation,
//         builder: (context, child) {
//           return Transform.scale(
//             scale: _pulseAnimation.value,
//             child: FloatingActionButton.extended(
//               onPressed: _startAdaptiveLearning,
//               backgroundColor: const Color(0xFF8B5CF6),
//               heroTag: "adaptive_learning",
//               icon: const Icon(Icons.psychology, color: Colors.white),
//               label: Text(
//                 'AI Learning',
//                 style: GoogleFonts.poppins(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: size.width * 0.035,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildSliverAppBar(Size size, bool isSmallScreen) {
//     return SliverAppBar(
//       expandedHeight: size.height * 0.12,
//       floating: false,
//       pinned: true,
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       flexibleSpace: FlexibleSpaceBar(
//         title: AnimatedBuilder(
//           animation: _slideAnimation,
//           builder: (context, child) {
//             return Transform.translate(
//               offset: Offset(0, _slideAnimation.value),
//               child: Text(
//                 'Learn Japanese',
//                 style: GoogleFonts.poppins(
//                   fontSize: isSmallScreen ? size.width * 0.05 : size.width * 0.055,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             );
//           },
//         ),
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 const Color(0xFF8B5CF6).withOpacity(0.3),
//                 const Color(0xFFEC4899).withOpacity(0.3),
//               ],
//             ),
//           ),
//         ),
//       ),
//       actions: [
//         IconButton(
//           onPressed: _showProgressDetails,
//           icon: Icon(
//             Icons.analytics_outlined,
//             color: Colors.white,
//             size: size.width * 0.06,
//           ),
//         ),
//         IconButton(
//           onPressed: _showSettings,
//           icon: Icon(
//             Icons.settings_outlined,
//             color: Colors.white,
//             size: size.width * 0.06,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildProgressOverview(Size size, bool isSmallScreen) {
//     return Container(
//       padding: EdgeInsets.all(size.width * 0.04),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             const Color(0xFF8B5CF6).withOpacity(0.1),
//             const Color(0xFFEC4899).withOpacity(0.1),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: const Color(0xFF8B5CF6).withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         children: [
//           // Overall Progress Circle
//           Row(
//             children: [
//               Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   SizedBox(
//                     width: size.width * 0.2,
//                     height: size.width * 0.2,
//                     child: CircularProgressIndicator(
//                       value: userProgress['overall']! / 100,
//                       strokeWidth: 6,
//                       backgroundColor: Colors.white.withOpacity(0.2),
//                       valueColor: const AlwaysStoppedAnimation<Color>(
//                         Color(0xFF8B5CF6),
//                       ),
//                     ),
//                   ),
//                   Text(
//                     '${userProgress['overall']}%',
//                     style: GoogleFonts.poppins(
//                       fontSize: isSmallScreen ? size.width * 0.04 : size.width * 0.045,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(width: size.width * 0.04),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Overall Progress',
//                       style: GoogleFonts.poppins(
//                         fontSize: isSmallScreen ? size.width * 0.045 : size.width * 0.05,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.005),
//                     Text(
//                       'Keep going! You\'re doing great!',
//                       style: GoogleFonts.poppins(
//                         fontSize: size.width * 0.032,
//                         color: Colors.white.withOpacity(0.7),
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.01),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.local_fire_department,
//                           color: const Color(0xFFFF6B35),
//                           size: size.width * 0.05,
//                         ),
//                         SizedBox(width: size.width * 0.01),
//                         Text(
//                           '${streakData['daily']} day streak',
//                           style: GoogleFonts.poppins(
//                             fontSize: size.width * 0.03,
//                             color: const Color(0xFFFF6B35),
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//
//           SizedBox(height: size.height * 0.02),
//
//           // Quick Stats
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildQuickStat('🎯', 'Accuracy', '89%', size),
//               _buildQuickStat('⚡', 'Speed', 'Fast', size),
//               _buildQuickStat('🏆', 'Rank', 'Expert', size),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQuickStat(String emoji, String label, String value, Size size) {
//     return Column(
//       children: [
//         Text(
//           emoji,
//           style: TextStyle(fontSize: size.width * 0.06),
//         ),
//         SizedBox(height: size.height * 0.005),
//         Text(
//           value,
//           style: GoogleFonts.poppins(
//             fontSize: size.width * 0.035,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: size.width * 0.025,
//             color: Colors.white.withOpacity(0.7),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildCategoryFilter(Size size, bool isSmallScreen) {
//     final categories = [
//       {'id': 'all', 'name': 'All', 'icon': '🌟'},
//       {'id': 'letters', 'name': 'Letters', 'icon': '🔤'},
//       {'id': 'kanji', 'name': 'Kanji', 'icon': '🈶'},
//       {'id': 'grammar', 'name': 'Grammar', 'icon': '📚'},
//       {'id': 'practice', 'name': 'Practice', 'icon': '🎯'},
//     ];
//
//     return SizedBox(
//       height: size.height * 0.05,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: categories.length,
//         itemBuilder: (context, index) {
//           final category = categories[index];
//           final isSelected = _selectedCategory == category['id'];
//
//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 _selectedCategory = category['id'] as String;
//               });
//             },
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               margin: EdgeInsets.only(right: size.width * 0.03),
//               padding: EdgeInsets.symmetric(
//                 horizontal: size.width * 0.04,
//                 vertical: size.height * 0.01,
//               ),
//               decoration: BoxDecoration(
//                 color: isSelected
//                     ? const Color(0xFF8B5CF6)
//                     : Colors.white.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(25),
//                 border: Border.all(
//                   color: isSelected
//                       ? const Color(0xFF8B5CF6)
//                       : Colors.white.withOpacity(0.3),
//                   width: 1,
//                 ),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     category['icon'] as String,
//                     style: TextStyle(fontSize: size.width * 0.04),
//                   ),
//                   SizedBox(width: size.width * 0.02),
//                   Text(
//                     category['name'] as String,
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.032,
//                       fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildLearningModules(Size size, bool isSmallScreen) {
//     final modules = _getFilteredModules();
//
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: size.width * 0.03,
//         mainAxisSpacing: size.width * 0.03,
//         childAspectRatio: isSmallScreen ? 0.85 : 0.9,
//       ),
//       itemCount: modules.length,
//       itemBuilder: (context, index) {
//         final module = modules[index];
//         return _buildModuleCard(module, size, isSmallScreen, index);
//       },
//     );
//   }
//
//   List<Map<String, dynamic>> _getFilteredModules() {
//     final allModules = [
//       {
//         'title': 'Letters',
//         'subtitle': 'Hiragana & Katakana',
//         'icon': '🔤',
//         'progress': (userProgress['hiragana']! + userProgress['katakana']!) / 2,
//         'color': const Color(0xFFEC4899),
//         'category': 'letters',
//         'onTap': () => _navigateToLetters(),
//         'isNew': true,
//       },
//       {
//         'title': 'Kanji',
//         'subtitle': 'Characters & Meanings',
//         'icon': '🈶',
//         'progress': userProgress['kanji']!,
//         'color': const Color(0xFF8B5CF6),
//         'category': 'kanji',
//         'onTap': () => _navigateToKanji(),
//         'isNew': false,
//       },
//       {
//         'title': 'Vocabulary',
//         'subtitle': 'Words & Phrases',
//         'icon': '📝',
//         'progress': userProgress['vocabulary']!,
//         'color': const Color(0xFF10B981),
//         'category': 'practice',
//         'onTap': () => _navigateToVocabulary(),
//         'isNew': false,
//       },
//       {
//         'title': 'Grammar',
//         'subtitle': 'Patterns & Rules',
//         'icon': '📚',
//         'progress': userProgress['grammar']!,
//         'color': const Color(0xFF06B6D4),
//         'category': 'grammar',
//         'onTap': () => _navigateToGrammarPatterns(),
//         'isNew': false,
//       },
//       {
//         'title': 'Listening',
//         'subtitle': 'Audio Practice',
//         'icon': '🎧',
//         'progress': userProgress['listening']!,
//         'color': const Color(0xFFF59E0B),
//         'category': 'practice',
//         'onTap': () => _navigateToListening(),
//         'isNew': false,
//       },
//       {
//         'title': 'Speaking',
//         'subtitle': 'Pronunciation',
//         'icon': '🎤',
//         'progress': userProgress['speaking']!,
//         'color': const Color(0xFFFF6B35),
//         'category': 'practice',
//         'onTap': () => _navigateToSpeaking(),
//         'isNew': false,
//       },
//       {
//         'title': 'Flashcards',
//         'subtitle': 'Quick Review',
//         'icon': '🃏',
//         'progress': 75,
//         'color': const Color(0xFF8B5CF6),
//         'category': 'practice',
//         'onTap': () => _navigateToFlashcards(),
//         'isNew': false,
//       },
//       {
//         'title': 'Achievements',
//         'subtitle': 'Your Progress',
//         'icon': '🏆',
//         'progress': achievements.length * 25,
//         'color': const Color(0xFFF59E0B),
//         'category': 'all',
//         'onTap': () => _navigateToAchievements(),
//         'isNew': false,
//       },
//     ];
//
//     if (_selectedCategory == 'all') return allModules;
//     return allModules.where((module) => module['category'] == _selectedCategory).toList();
//   }
//
//   Widget _buildModuleCard(Map<String, dynamic> module, Size size, bool isSmallScreen, int index) {
//     return AnimatedBuilder(
//       animation: _floatingAnimation,
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(0, math.sin(_floatingAnimation.value * 2 * math.pi + index * 0.5) * 3),
//           child: GestureDetector(
//             onTap: module['onTap'] as VoidCallback,
//             child: Container(
//               padding: EdgeInsets.all(size.width * 0.04),
//               decoration: BoxDecoration(
//                 color: (module['color'] as Color).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: (module['color'] as Color).withOpacity(0.3),
//                   width: 1,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: (module['color'] as Color).withOpacity(0.1),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header with icon and badge
//                   Row(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(size.width * 0.025),
//                         decoration: BoxDecoration(
//                           color: (module['color'] as Color).withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           module['icon'] as String,
//                           style: TextStyle(fontSize: size.width * 0.06),
//                         ),
//                       ),
//                       const Spacer(),
//                       if (module['isNew'] as bool)
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: size.width * 0.02,
//                             vertical: size.height * 0.003,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFFF6B35),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             'NEW',
//                             style: GoogleFonts.poppins(
//                               fontSize: size.width * 0.025,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//
//                   SizedBox(height: size.height * 0.015),
//
//                   // Title and Subtitle
//                   Text(
//                     module['title'] as String,
//                     style: GoogleFonts.poppins(
//                       fontSize: isSmallScreen ? size.width * 0.04 : size.width * 0.045,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//
//                   Text(
//                     module['subtitle'] as String,
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.03,
//                       color: Colors.white.withOpacity(0.7),
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//
//                   const Spacer(),
//
//                   // Progress Bar
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Progress',
//                             style: GoogleFonts.poppins(
//                               fontSize: size.width * 0.028,
//                               color: Colors.white.withOpacity(0.8),
//                             ),
//                           ),
//                           Text(
//                             '${module['progress']}%',
//                             style: GoogleFonts.poppins(
//                               fontSize: size.width * 0.028,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: size.height * 0.005),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: LinearProgressIndicator(
//                           value: (module['progress'] as int) / 100,
//                           backgroundColor: Colors.white.withOpacity(0.2),
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             module['color'] as Color,
//                           ),
//                           minHeight: size.height * 0.006,
//                         ),
//                       ),
//                     ],
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
//   Widget _buildDailyChallenge(Size size, bool isSmallScreen) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(size.width * 0.04),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             const Color(0xFFFF6B35).withOpacity(0.1),
//             const Color(0xFFF59E0B).withOpacity(0.1),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: const Color(0xFFFF6B35).withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(size.width * 0.025),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFF6B35).withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   '⚡',
//                   style: TextStyle(fontSize: size.width * 0.06),
//                 ),
//               ),
//               SizedBox(width: size.width * 0.03),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Daily Challenge',
//                       style: GoogleFonts.poppins(
//                         fontSize: isSmallScreen ? size.width * 0.045 : size.width * 0.05,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       'Complete 10 Hiragana characters',
//                       style: GoogleFonts.poppins(
//                         fontSize: size.width * 0.032,
//                         color: Colors.white.withOpacity(0.7),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: _startDailyChallenge,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFFF6B35),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   'Start',
//                   style: GoogleFonts.poppins(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: size.width * 0.03,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           SizedBox(height: size.height * 0.015),
//
//           Row(
//             children: [
//               Icon(
//                 Icons.timer_outlined,
//                 color: const Color(0xFFFF6B35),
//                 size: size.width * 0.04,
//               ),
//               SizedBox(width: size.width * 0.01),
//               Text(
//                 'Time remaining: 23h 45m',
//                 style: GoogleFonts.poppins(
//                   fontSize: size.width * 0.028,
//                   color: Colors.white.withOpacity(0.7),
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 '7/10 completed',
//                 style: GoogleFonts.poppins(
//                   fontSize: size.width * 0.028,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFFFF6B35),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRecentAchievements(Size size, bool isSmallScreen) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Recent Achievements',
//               style: GoogleFonts.poppins(
//                 fontSize: isSmallScreen ? size.width * 0.045 : size.width * 0.05,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             TextButton(
//               onPressed: _navigateToAchievements,
//               child: Text(
//                 'View All',
//                 style: GoogleFonts.poppins(
//                   fontSize: size.width * 0.032,
//                   color: const Color(0xFF8B5CF6),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//
//         SizedBox(height: size.height * 0.01),
//
//         SizedBox(
//           height: size.height * 0.08,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: achievements.length,
//             itemBuilder: (context, index) {
//               return Container(
//                 margin: EdgeInsets.only(right: size.width * 0.03),
//                 padding: EdgeInsets.symmetric(
//                   horizontal: size.width * 0.04,
//                   vertical: size.height * 0.01,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       const Color(0xFFF59E0B).withOpacity(0.1),
//                       const Color(0xFFFF6B35).withOpacity(0.1),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color: const Color(0xFFF59E0B).withOpacity(0.3),
//                     width: 1,
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       '🏆',
//                       style: TextStyle(fontSize: size.width * 0.05),
//                     ),
//                     SizedBox(width: size.width * 0.02),
//                     Text(
//                       achievements[index],
//                       style: GoogleFonts.poppins(
//                         fontSize: size.width * 0.032,
//                         color: Colors.white,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   // Navigation Methods
//   void _navigateToLetters() {
//     // Navigator.of(context).push(
//     //   PageRouteBuilder(
//     //     pageBuilder: (context, animation, secondaryAnimation) =>
//     //     const LettersLearningScreen(),
//     //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//     //       return SlideTransition(
//     //         position: Tween<Offset>(
//     //           begin: const Offset(1.0, 0.0),
//     //           end: Offset.zero,
//     //         ).animate(CurvedAnimation(
//     //           parent: animation,
//     //           curve: Curves.easeInOut,
//     //         )),
//     //         child: child,
//     //       );
//     //     },
//     //     transitionDuration: const Duration(milliseconds: 500),
//     //   ),
//     // );
//   }
//
//   void _navigateToKanji() {
//     // Navigator.of(context).push(
//     //   PageRouteBuilder(
//     //     pageBuilder: (context, animation, secondaryAnimation) =>
//     //     const KanjiLearningScreen(),
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
//
//   void _navigateToVocabulary() {
//     // Navigator.of(context).push(
//     //   PageRouteBuilder(
//     //     pageBuilder: (context, animation, secondaryAnimation) =>
//     //     const VocabularyScreen(),
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
//
//   void _navigateToGrammarPatterns() {
//     // Navigator.of(context).push(
//     //   PageRouteBuilder(
//     //     pageBuilder: (context, animation, secondaryAnimation) =>
//     //     const GrammarPatternsScreen(),
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
//
//   void _navigateToListening() {
//     // Navigator.of(context).push(
//     //   PageRouteBuilder(
//     //     pageBuilder: (context, animation, secondaryAnimation) =>
//     //     const ListeningPracticeScreen(),
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
//
//   void _navigateToSpeaking() {
//     // Navigator.of(context).push(
//     //   PageRouteBuilder(
//     //     pageBuilder: (context, animation, secondaryAnimation) =>
//     //     const SpeakingPracticeScreen(),
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
//
//   void _navigateToFlashcards() {
//     // Navigator.of(context).push(
//     //   PageRouteBuilder(
//     //     pageBuilder: (context, animation, secondaryAnimation) =>
//     //     const FlashcardsScreen(),
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
//
//   void _navigateToAchievements() {
//     // Navigator.of(context).push(
//     //   PageRouteBuilder(
//     //     pageBuilder: (context, animation, secondaryAnimation) =>
//     //     const AchievementScreen(),
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
//
//   // Action Methods
//   void _startAdaptiveLearning() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1C2128),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Row(
//           children: [
//             Icon(
//               Icons.psychology,
//               color: const Color(0xFF8B5CF6),
//               size: MediaQuery.of(context).size.width * 0.06,
//             ),
//             SizedBox(width: MediaQuery.of(context).size.width * 0.02),
//             Text(
//               'AI Learning',
//               style: GoogleFonts.poppins(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         content: Text(
//           'AI will analyze your progress and create a personalized learning path. This feature is coming soon!',
//           style: GoogleFonts.poppins(
//             color: Colors.white70,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Got it',
//               style: GoogleFonts.poppins(
//                 color: const Color(0xFF8B5CF6),
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _startDailyChallenge() {
//     _navigateToLetters(); // Start with hiragana challenge
//   }
//
//   void _showProgressDetails() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1C2128),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Text(
//           'Progress Details',
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: userProgress.entries.map((entry) {
//             if (entry.key == 'overall') return const SizedBox.shrink();
//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 4.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     entry.key.toUpperCase(),
//                     style: GoogleFonts.poppins(
//                       color: Colors.white70,
//                       fontSize: 14,
//                     ),
//                   ),
//                   Text(
//                     '${entry.value}%',
//                     style: GoogleFonts.poppins(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Close',
//               style: GoogleFonts.poppins(
//                 color: const Color(0xFF8B5CF6),
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showSettings() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1C2128),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Text(
//           'Learning Settings',
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         content: Text(
//           'Customize your learning experience, set daily goals, and adjust difficulty levels.',
//           style: GoogleFonts.poppins(
//             color: Colors.white70,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Close',
//               style: GoogleFonts.poppins(
//                 color: const Color(0xFF8B5CF6),
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }