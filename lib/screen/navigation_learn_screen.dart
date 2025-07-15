


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
  String selectedCategory = "All";
  final categories = ["All", "Beginner", "Intermediate", "Advanced"];

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

  // Responsive helper methods
  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 350) return baseSize * 0.85;
    if (screenWidth < 400) return baseSize * 0.9;
    if (screenWidth > 600) return baseSize * 1.1;
    return baseSize;
  }

  double _getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * baseSpacing;
  }

  EdgeInsets _getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final basePadding = screenWidth * 0.04;
    return EdgeInsets.all(basePadding.clamp(12.0, 24.0));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FE),
              Color(0xFFE8F0FE),
              Color(0xFFE3F2FD),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: _getResponsivePadding(context),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Header
                      _buildHeader(context),
                      SizedBox(height: _getResponsiveSpacing(context, 0.03)),

                      // Level Selector
                      _buildLevelSelector(context),
                      SizedBox(height: _getResponsiveSpacing(context, 0.025)),

                      // Category Filter
                      _buildCategoryFilter(context),
                      SizedBox(height: _getResponsiveSpacing(context, 0.025)),

                      // Core Learning Modules
                      _buildCoreLearningModules(context),
                      SizedBox(height: _getResponsiveSpacing(context, 0.025)),

                      // Skill Building Section
                      _buildSkillBuildingSection(context),
                      SizedBox(height: _getResponsiveSpacing(context, 0.025)),

                      // Assessment Tools
                      _buildAssessmentTools(context),
                      SizedBox(height: _getResponsiveSpacing(context, 0.02)),

                      // Progress Overview
                      _buildProgressOverview(context),
                      SizedBox(height: _getResponsiveSpacing(context, 0.02)),

                      // Study Plan
                      _buildStudyPlan(context),
                      SizedBox(height: _getResponsiveSpacing(context, 0.05)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: size.width * 0.12,
                  height: size.width * 0.12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: const Color(0xFF6366F1),
                    size: _getResponsiveFontSize(context, 20),
                  ),
                ),
              ),
              SizedBox(width: _getResponsiveSpacing(context, 0.04)),

              // Title Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learn Japanese',
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(context, 24),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Master the language step by step',
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(context, 14),
                        color: const Color(0xFF6B7280),
                      ),
                      overflow: TextOverflow.ellipsis,
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
                      width: size.width * 0.14,
                      height: size.width * 0.14,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '学',
                          style: GoogleFonts.notoSansJp(
                            fontSize: _getResponsiveFontSize(context, 22),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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

  Widget _buildLevelSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your JLPT Level',
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: _getResponsiveSpacing(context, 0.015)),
        SizedBox(
          height: 50,
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
                  margin: EdgeInsets.only(right: _getResponsiveSpacing(context, 0.03)),
                  padding: EdgeInsets.symmetric(
                    horizontal: _getResponsiveSpacing(context, 0.06),
                    vertical: 12,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 60,
                    maxHeight: 50,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    )
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : const Color(0xFF6366F1).withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(isSelected ? 0.3 : 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      level,
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF6366F1),
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

  Widget _buildCategoryFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Path',
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: _getResponsiveSpacing(context, 0.01)),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == selectedCategory;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(right: _getResponsiveSpacing(context, 0.03)),
                  padding: EdgeInsets.symmetric(
                    horizontal: _getResponsiveSpacing(context, 0.04),
                    vertical: 8,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 60,
                    maxHeight: 40,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF10B981) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: _getResponsiveFontSize(context, 12),
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF10B981),
                      ),
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildCoreLearningModules(BuildContext context) {
    final coreModules = [
      {
        'icon': '📚',
        'title': 'Grammar Mastery',
        'subtitle': 'Essential sentence structures',
        'description': 'Learn $selectedLevel grammar patterns',
        'color': const Color(0xFF6366F1),
        'progress': 0.75,
        'lessons': '24 lessons',
        'onTap': () => _navigateToGrammar(),
      },
      {
        'icon': '📖',
        'title': 'Vocabulary Builder',
        'subtitle': 'Core words and phrases',
        'description': 'Master essential $selectedLevel vocabulary',
        'color': const Color(0xFF10B981),
        'progress': 0.60,
        'lessons': '18 lessons',
        'onTap': () => _navigateToVocabulary(),
      },
      {
        'icon': '💬',
        'title': 'Conversation Practice',
        'subtitle': 'Real-world communication',
        'description': 'Practice daily Japanese conversations',
        'color': const Color(0xFF06B6D4),
        'progress': 0.45,
        'lessons': '15 lessons',
        'onTap': () => _navigateToConversation(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Core Learning Modules',
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: _getResponsiveSpacing(context, 0.015)),
        ...coreModules.map((module) => _buildModuleCard(context, module)),
      ],
    );
  }

  Widget _buildSkillBuildingSection(BuildContext context) {
    final skillModules = [
      {
        'icon': '🎧',
        'title': 'Listening Skills',
        'subtitle': 'Audio comprehension',
        'description': 'Improve your listening abilities',
        'color': const Color(0xFF8B5CF6),
        'onTap': () => _showComingSoon('Listening Skills'),
      },
      {
        'icon': '✍️',
        'title': 'Writing Practice',
        'subtitle': 'Kanji & composition',
        'description': 'Master Japanese writing systems',
        'color': const Color(0xFFDC2626),
        'onTap': () => _showComingSoon('Writing Practice'),
      },
      {
        'icon': '🗣️',
        'title': 'Pronunciation',
        'subtitle': 'Perfect your accent',
        'description': 'Speak like a native speaker',
        'color': const Color(0xFFF59E0B),
        'onTap': () => _showComingSoon('Pronunciation'),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skill Building',
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: _getResponsiveSpacing(context, 0.015)),
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final spacing = _getResponsiveSpacing(context, 0.02);
            final cardWidth = (availableWidth - spacing) / 2;
            final cardHeight = cardWidth * 0.8;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: skillModules.take(2).map((skill) {
                return GestureDetector(
                  onTap: skill['onTap'] as VoidCallback,
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    padding: EdgeInsets.all(_getResponsiveSpacing(context, 0.035)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (skill['color'] as Color).withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (skill['color'] as Color).withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skill['icon'] as String,
                          style: TextStyle(fontSize: _getResponsiveFontSize(context, 32)),
                        ),
                        SizedBox(height: _getResponsiveSpacing(context, 0.01)),
                        Flexible(
                          child: Text(
                            skill['title'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: _getResponsiveFontSize(context, 14),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2937),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: _getResponsiveSpacing(context, 0.005)),
                        Flexible(
                          child: Text(
                            skill['subtitle'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: _getResponsiveFontSize(context, 11),
                              color: const Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
        if (skillModules.length > 2) ...[
          SizedBox(height: _getResponsiveSpacing(context, 0.02)),
          GestureDetector(
            onTap: skillModules[2]['onTap'] as VoidCallback,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(_getResponsiveSpacing(context, 0.04)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (skillModules[2]['color'] as Color).withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (skillModules[2]['color'] as Color).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    skillModules[2]['icon'] as String,
                    style: TextStyle(fontSize: _getResponsiveFontSize(context, 32)),
                  ),
                  SizedBox(width: _getResponsiveSpacing(context, 0.04)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skillModules[2]['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: _getResponsiveFontSize(context, 16),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          skillModules[2]['subtitle'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: _getResponsiveFontSize(context, 12),
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: skillModules[2]['color'] as Color,
                    size: _getResponsiveFontSize(context, 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAssessmentTools(BuildContext context) {
    final assessments = [
      {
        'icon': '🎯',
        'title': 'Quick Quiz',
        'subtitle': 'Test your knowledge',
        'color': const Color(0xFF06B6D4),
        'onTap': () => _showComingSoon('Quick Quiz'),
      },
      {
        'icon': '📊',
        'title': 'Progress Test',
        'subtitle': 'Comprehensive evaluation',
        'color': const Color(0xFFEC4899),
        'onTap': () => _showComingSoon('Progress Test'),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assessment Tools',
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: _getResponsiveSpacing(context, 0.015)),
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final spacing = _getResponsiveSpacing(context, 0.02);
            final cardWidth = (availableWidth - spacing) / 2;

            return Row(
              children: assessments.map((assessment) {
                final isFirst = assessments.indexOf(assessment) == 0;
                return Expanded(
                  child: GestureDetector(
                    onTap: assessment['onTap'] as VoidCallback,
                    child: Container(
                      margin: EdgeInsets.only(right: isFirst ? spacing : 0),
                      padding: EdgeInsets.all(_getResponsiveSpacing(context, 0.04)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (assessment['color'] as Color).withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (assessment['color'] as Color).withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            assessment['icon'] as String,
                            style: TextStyle(fontSize: _getResponsiveFontSize(context, 32)),
                          ),
                          SizedBox(height: _getResponsiveSpacing(context, 0.01)),
                          Text(
                            assessment['title'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: _getResponsiveFontSize(context, 14),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2937),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: _getResponsiveSpacing(context, 0.005)),
                          Text(
                            assessment['subtitle'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: _getResponsiveFontSize(context, 11),
                              color: const Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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

  Widget _buildModuleCard(BuildContext context, Map<String, dynamic> module) {
    return GestureDetector(
      onTap: module['onTap'] as VoidCallback,
      child: Container(
        margin: EdgeInsets.only(bottom: _getResponsiveSpacing(context, 0.015)),
        padding: EdgeInsets.all(_getResponsiveSpacing(context, 0.04)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (module['color'] as Color).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (module['color'] as Color).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: (module['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      module['icon'] as String,
                      style: TextStyle(fontSize: _getResponsiveFontSize(context, 32)),
                    ),
                  ),
                ),
                SizedBox(width: _getResponsiveSpacing(context, 0.04)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              module['title'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: _getResponsiveFontSize(context, 16),
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2937),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (module.containsKey('lessons'))
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: _getResponsiveSpacing(context, 0.025),
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: (module['color'] as Color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                module['lessons'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: _getResponsiveFontSize(context, 10),
                                  fontWeight: FontWeight.w600,
                                  color: module['color'] as Color,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        module['subtitle'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: _getResponsiveFontSize(context, 12),
                          color: const Color(0xFF6B7280),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        module['description'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: _getResponsiveFontSize(context, 11),
                          color: const Color(0xFF9CA3AF),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: module['color'] as Color,
                  size: _getResponsiveFontSize(context, 16),
                ),
              ],
            ),
            if (module.containsKey('progress')) ...[
              SizedBox(height: _getResponsiveSpacing(context, 0.015)),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: module['progress'] as double,
                        backgroundColor: (module['color'] as Color).withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(module['color'] as Color),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  SizedBox(width: _getResponsiveSpacing(context, 0.03)),
                  Text(
                    '${((module['progress'] as double) * 100).toInt()}%',
                    style: GoogleFonts.poppins(
                      fontSize: _getResponsiveFontSize(context, 12),
                      fontWeight: FontWeight.bold,
                      color: module['color'] as Color,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressOverview(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_getResponsiveSpacing(context, 0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: const Color(0xFF6366F1),
                size: _getResponsiveFontSize(context, 24),
              ),
              SizedBox(width: _getResponsiveSpacing(context, 0.02)),
              Expanded(
                child: Text(
                  'Your $selectedLevel Progress',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: _getResponsiveSpacing(context, 0.015)),
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final spacing = _getResponsiveSpacing(context, 0.04);
              final itemWidth = (availableWidth - (spacing * 2)) / 3;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: _buildProgressItem(context, 'Grammar', '75%', 0.75, const Color(0xFF6366F1)),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildProgressItem(context, 'Vocabulary', '60%', 0.60, const Color(0xFF10B981)),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildProgressItem(context, 'Speaking', '45%', 0.45, const Color(0xFF06B6D4)),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(BuildContext context, String title, String percentage, double value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(context, 12),
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4),
        Text(
          percentage,
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(context, 14),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildStudyPlan(BuildContext context) {
    final todayPlan = [
      "📚 Review $selectedLevel grammar: 10 minutes",
      "📖 Learn 5 new vocabulary words",
      "💬 Practice conversation phrases",
      "🎧 Listen to Japanese audio: 5 minutes",
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_getResponsiveSpacing(context, 0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.today_outlined,
                color: const Color(0xFF10B981),
                size: _getResponsiveFontSize(context, 24),
              ),
              SizedBox(width: _getResponsiveSpacing(context, 0.02)),
              Expanded(
                child: Text(
                  'Today\'s Study Plan',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: _getResponsiveSpacing(context, 0.015)),
          ...todayPlan.map((task) => Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 8),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                SizedBox(width: _getResponsiveSpacing(context, 0.03)),
                Expanded(
                  child: Text(
                    task,
                    style: GoogleFonts.poppins(
                      fontSize: _getResponsiveFontSize(context, 12),
                      color: const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
          SizedBox(height: _getResponsiveSpacing(context, 0.015)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Estimated time: 25 minutes',
              style: GoogleFonts.poppins(
                fontSize: _getResponsiveFontSize(context, 12),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF10B981),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon! 🚀'),
        backgroundColor: const Color(0xFF6366F1),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Navigation methods
  void _navigateToGrammar() {
    _showSuccessMessage('Opening Grammar lessons for $selectedLevel! 📚');
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
    _showSuccessMessage('Opening Vocabulary lessons for $selectedLevel! 📖');
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
    _showSuccessMessage('Opening Conversation practice for $selectedLevel! 💬');
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
// import 'dart:math' as math;
//
// // Import your other screens - update these paths as needed
// import 'Grammer_Learning_Screen.dart';
// import 'Vocabulary_learning_screen.dart';
// import 'conversation_learning_screen.dart';
//
// class LearnNavigationScreen extends StatefulWidget {
//   const LearnNavigationScreen({super.key});
//
//   @override
//   State<LearnNavigationScreen> createState() => _LearnNavigationScreenState();
// }
//
// class _LearnNavigationScreenState extends State<LearnNavigationScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late AnimationController _floatingController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _slideAnimation;
//   late Animation<double> _scaleAnimation;
//
//   String selectedLevel = "N5";
//   final levels = ["N5", "N4", "N3", "N2", "N1"];
//
//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//   }
//
//   void _initAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
//
//     _floatingController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );
//
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//
//     _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
//     );
//
//     _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
//     );
//
//     _animationController.forward();
//     _floatingController.repeat(reverse: true);
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     _floatingController.dispose();
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
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: Padding(
//                 padding: EdgeInsets.all(size.width * 0.04),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header
//                     _buildHeader(size, isSmallScreen),
//                     SizedBox(height: size.height * 0.03),
//
//                     // Level Selector
//                     _buildLevelSelector(size, isSmallScreen),
//                     SizedBox(height: size.height * 0.03),
//
//                     // Learning Categories
//                     _buildLearningCategories(size, isSmallScreen),
//                     SizedBox(height: size.height * 0.02),
//
//                     // Progress Overview
//                     _buildProgressOverview(size, isSmallScreen),
//                     SizedBox(height: size.height * 0.02),
//
//                     // Tips Section
//                     _buildTipsSection(size, isSmallScreen),
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
//   Widget _buildHeader(Size size, bool isSmallScreen) {
//     return AnimatedBuilder(
//       animation: _slideAnimation,
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(0, _slideAnimation.value),
//           child: Row(
//             children: [
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   padding: EdgeInsets.all(size.width * 0.025),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: Colors.white.withOpacity(0.2),
//                       width: 1,
//                     ),
//                   ),
//                   child: Icon(
//                     Icons.arrow_back_ios,
//                     color: Colors.white,
//                     size: size.width * 0.05,
//                   ),
//                 ),
//               ),
//               SizedBox(width: size.width * 0.04),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Learn Japanese',
//                       style: GoogleFonts.poppins(
//                         fontSize: size.width * 0.065,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       'Choose your learning path',
//                       style: GoogleFonts.poppins(
//                         fontSize: size.width * 0.035,
//                         color: Colors.white.withOpacity(0.7),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Animated Japanese character
//               AnimatedBuilder(
//                 animation: _floatingController,
//                 builder: (context, child) {
//                   return Transform.translate(
//                     offset: Offset(0, _floatingController.value * 5),
//                     child: Container(
//                       padding: EdgeInsets.all(size.width * 0.03),
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
//                         ),
//                         borderRadius: BorderRadius.circular(15),
//                         boxShadow: [
//                           BoxShadow(
//                             color: const Color(0xFF8B5CF6).withOpacity(0.3),
//                             blurRadius: 15,
//                             offset: const Offset(0, 5),
//                           ),
//                         ],
//                       ),
//                       child: Text(
//                         '学',
//                         style: GoogleFonts.notoSansJp(
//                           fontSize: size.width * 0.06,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildLevelSelector(Size size, bool isSmallScreen) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Select Your Level',
//           style: GoogleFonts.poppins(
//             fontSize: size.width * 0.05,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         SizedBox(height: size.height * 0.015),
//         Container(
//           height: size.height * 0.06,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: levels.length,
//             itemBuilder: (context, index) {
//               final level = levels[index];
//               final isSelected = level == selectedLevel;
//
//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     selectedLevel = level;
//                   });
//                 },
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 300),
//                   margin: EdgeInsets.only(right: size.width * 0.03),
//                   padding: EdgeInsets.symmetric(
//                     horizontal: size.width * 0.06,
//                     vertical: size.height * 0.015,
//                   ),
//                   decoration: BoxDecoration(
//                     gradient: isSelected
//                         ? const LinearGradient(
//                       colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
//                     )
//                         : null,
//                     color: isSelected ? null : Colors.white.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(25),
//                     border: Border.all(
//                       color: isSelected
//                           ? Colors.transparent
//                           : Colors.white.withOpacity(0.2),
//                       width: 1,
//                     ),
//                     boxShadow: isSelected
//                         ? [
//                       BoxShadow(
//                         color: const Color(0xFF8B5CF6).withOpacity(0.3),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ]
//                         : null,
//                   ),
//                   child: Center(
//                     child: Text(
//                       level,
//                       style: GoogleFonts.poppins(
//                         fontSize: size.width * 0.04,
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
//   Widget _buildLearningCategories(Size size, bool isSmallScreen) {
//     final categories = [
//       {
//         'icon': '📚',
//         'title': 'Grammar',
//         'subtitle': 'Learn sentence structures',
//         'description': 'Master Japanese grammar rules',
//         'color': const Color(0xFF8B5CF6),
//         'onTap': () => _navigateToGrammar(),
//       },
//       {
//         'icon': '📖',
//         'title': 'Vocabulary',
//         'subtitle': 'Expand your word bank',
//         'description': 'Learn essential Japanese words',
//         'color': const Color(0xFF10B981),
//         'onTap': () => _navigateToVocabulary(),
//       },
//       {
//         'icon': '💬',
//         'title': 'Conversation',
//         'subtitle': 'Practice daily phrases',
//         'description': 'Learn practical speaking skills',
//         'color': const Color(0xFF06B6D4),
//         'onTap': () => _navigateToConversation(),
//       },
//     ];
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Learning Categories',
//           style: GoogleFonts.poppins(
//             fontSize: size.width * 0.05,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         SizedBox(height: size.height * 0.015),
//         ...categories.map((category) => _buildCategoryCard(category, size, isSmallScreen)),
//       ],
//     );
//   }
//
//   Widget _buildCategoryCard(Map<String, dynamic> category, Size size, bool isSmallScreen) {
//     return GestureDetector(
//       onTap: category['onTap'] as VoidCallback,
//       child: Container(
//         margin: EdgeInsets.only(bottom: size.height * 0.015),
//         padding: EdgeInsets.all(size.width * 0.04),
//         decoration: BoxDecoration(
//           color: (category['color'] as Color).withOpacity(0.1),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: (category['color'] as Color).withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(size.width * 0.03),
//               decoration: BoxDecoration(
//                 color: (category['color'] as Color).withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 category['icon'] as String,
//                 style: TextStyle(fontSize: size.width * 0.08),
//               ),
//             ),
//             SizedBox(width: size.width * 0.04),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     category['title'] as String,
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.045,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   Text(
//                     category['subtitle'] as String,
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.032,
//                       color: Colors.white.withOpacity(0.7),
//                     ),
//                   ),
//                   SizedBox(height: size.height * 0.005),
//                   Text(
//                     category['description'] as String,
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.03,
//                       color: Colors.white.withOpacity(0.6),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios,
//               color: category['color'] as Color,
//               size: size.width * 0.05,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProgressOverview(Size size, bool isSmallScreen) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(size.width * 0.04),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             const Color(0xFFF59E0B).withOpacity(0.1),
//             const Color(0xFFFF6B35).withOpacity(0.1),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: const Color(0xFFF59E0B).withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.analytics_outlined,
//                 color: const Color(0xFFF59E0B),
//                 size: size.width * 0.06,
//               ),
//               SizedBox(width: size.width * 0.02),
//               Text(
//                 'Your Progress',
//                 style: GoogleFonts.poppins(
//                   fontSize: size.width * 0.045,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: size.height * 0.015),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildProgressItem('Grammar', '75%', 0.75, const Color(0xFF8B5CF6), size),
//               ),
//               SizedBox(width: size.width * 0.04),
//               Expanded(
//                 child: _buildProgressItem('Vocabulary', '60%', 0.60, const Color(0xFF10B981), size),
//               ),
//               SizedBox(width: size.width * 0.04),
//               Expanded(
//                 child: _buildProgressItem('Speaking', '45%', 0.45, const Color(0xFF06B6D4), size),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildProgressItem(String title, String percentage, double value, Color color, Size size) {
//     return Column(
//       children: [
//         Text(
//           title,
//           style: GoogleFonts.poppins(
//             fontSize: size.width * 0.03,
//             color: Colors.white.withOpacity(0.8),
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         SizedBox(height: size.height * 0.005),
//         Text(
//           percentage,
//           style: GoogleFonts.poppins(
//             fontSize: size.width * 0.035,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         SizedBox(height: size.height * 0.005),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(4),
//           child: LinearProgressIndicator(
//             value: value,
//             backgroundColor: Colors.white.withOpacity(0.2),
//             valueColor: AlwaysStoppedAnimation<Color>(color),
//             minHeight: size.height * 0.006,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTipsSection(Size size, bool isSmallScreen) {
//     final tips = [
//       "Start with ${selectedLevel} level basics",
//       "Practice 15 minutes daily for best results",
//       "Don't skip the fundamentals",
//       "Use spaced repetition for memory",
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
//                 'Learning Tips',
//                 style: GoogleFonts.poppins(
//                   fontSize: size.width * 0.045,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: size.height * 0.015),
//           ...tips.map((tip) => Padding(
//             padding: EdgeInsets.only(bottom: size.height * 0.008),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   margin: EdgeInsets.only(top: size.height * 0.008),
//                   width: size.width * 0.015,
//                   height: size.width * 0.015,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF59E0B),
//                     borderRadius: BorderRadius.circular(size.width * 0.0075),
//                   ),
//                 ),
//                 SizedBox(width: size.width * 0.03),
//                 Expanded(
//                   child: Text(
//                     tip,
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.032,
//                       color: Colors.white.withOpacity(0.8),
//                       height: 1.4,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           )),
//         ],
//       ),
//     );
//   }
//
//   // Navigation methods
//   void _navigateToGrammar() {
//     Navigator.of(context).push(
//       PageRouteBuilder(
//         pageBuilder: (context, animation, secondaryAnimation) =>
//             GrammarLearningScreen(level: selectedLevel),
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
//   void _navigateToVocabulary() {
//     Navigator.of(context).push(
//       PageRouteBuilder(
//         pageBuilder: (context, animation, secondaryAnimation) =>
//             VocabularyLearningScreen(level: selectedLevel),
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
//   void _navigateToConversation() {
//     Navigator.of(context).push(
//       PageRouteBuilder(
//         pageBuilder: (context, animation, secondaryAnimation) =>
//             ConversationLearningScreen(level: selectedLevel),
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
//
//
