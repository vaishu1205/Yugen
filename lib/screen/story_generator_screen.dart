import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

class StoryGeneratorScreen extends StatefulWidget {
  const StoryGeneratorScreen({super.key});

  @override
  State<StoryGeneratorScreen> createState() => _StoryGeneratorScreenState();
}

class _StoryGeneratorScreenState extends State<StoryGeneratorScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _storyController;

  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _storyAnimation;

  // Controllers
  final TextEditingController _topicController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // State Variables
  bool _isGenerating = false;
  bool _hasGeneratedStory = false;
  String _selectedDifficulty = 'N5';
  int _storyLength = 100; // words

  // Story Data
  StoryData? _currentStory;

  // UI State
  int _selectedTab = 0; // 0: Japanese, 1: Romaji, 2: English
  bool _showGrammarTips = false;

  // Sample story topics for suggestions
  final List<String> _topicSuggestions = [
    'A day at the park',
    'Meeting a new friend',
    'Going to a Japanese restaurant',
    'First day at school',
    'Weekend adventure',
    'Shopping in Tokyo',
    'Visiting a temple',
    'Learning to cook',
    'Train journey',
    'Festival celebration'
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _storyController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _storyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _storyController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _storyController.dispose();
    _topicController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;
    final padding = isSmallScreen ? size.width * 0.03 : size.width * 0.04;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header
            _buildHeader(size, isSmallScreen, padding),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height - kToolbarHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_hasGeneratedStory) ...[
                        _buildInputSection(size, isSmallScreen, padding),
                        SizedBox(height: size.height * 0.02),
                        _buildDifficultySelector(size, isSmallScreen),
                        SizedBox(height: size.height * 0.02),
                        _buildTopicSuggestions(size, isSmallScreen),
                        SizedBox(height: size.height * 0.02),
                        _buildGenerateButton(size, isSmallScreen),
                      ],

                      if (_hasGeneratedStory && _currentStory != null) ...[
                        SizedBox(height: size.height * 0.02),
                        _buildStoryTabs(size, isSmallScreen),
                        SizedBox(height: size.height * 0.02),
                        _buildStoryContent(size, isSmallScreen),
                        SizedBox(height: size.height * 0.02),
                        _buildActionButtons(size, isSmallScreen),
                        if (_showGrammarTips) ...[
                          SizedBox(height: size.height * 0.02),
                          _buildGrammarTips(size, isSmallScreen),
                        ],
                        SizedBox(height: size.height * 0.02),
                        _buildNewStoryButton(size, isSmallScreen),
                        SizedBox(height: padding), // Bottom padding
                      ],

                      if (_isGenerating)
                        SizedBox(
                          height: size.height * 0.4,
                          child: _buildLoadingState(size, isSmallScreen),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _hasGeneratedStory
          ? Padding(
        padding: EdgeInsets.only(bottom: size.height * 0.02),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: FloatingActionButton(
                onPressed: _saveStory,
                backgroundColor: const Color(0xFF10B981),
                child: const Icon(Icons.bookmark_add, color: Colors.white),
              ),
            );
          },
        ),
      )
          : null,
    );
  }

  Widget _buildHeader(Size size, bool isSmallScreen, double padding) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: isSmallScreen ? size.height * 0.01 : size.height * 0.02,
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
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
                size: isSmallScreen ? 16 : 20,
              ),
            ),
          ),

          SizedBox(width: isSmallScreen ? 10 : 15),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Story Generator',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'AI-powered Japanese stories',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Progress Indicator
          if (!isSmallScreen) _buildProgressIndicator(size),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.03,
        vertical: size.height * 0.01,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_stories,
            color: Colors.white,
            size: size.width * 0.04,
          ),
          SizedBox(width: size.width * 0.01),
          Text(
            '5 stories',
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.03,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(Size size, bool isSmallScreen, double padding) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF06B6D4).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
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
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '✨',
                  style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What story would you like?',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Enter any topic',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          TextField(
            controller: _topicController,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
            ),
            decoration: InputDecoration(
              hintText: 'e.g., "A cat who loves ramen"',
              hintStyle: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.5),
                fontSize: isSmallScreen ? 14 : 16,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
              ),
              prefixIcon: Icon(
                Icons.edit_note,
                color: const Color(0xFF10B981),
                size: isSmallScreen ? 20 : 24,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 12 : 16,
              ),
            ),
            maxLines: 2,
            minLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector(Size size, bool isSmallScreen) {
    final difficulties = [
      {'level': 'N5', 'desc': 'Beginner', 'color': const Color(0xFF10B981)},
      {'level': 'N4', 'desc': 'Elementary', 'color': const Color(0xFF06B6D4)},
      {'level': 'N3', 'desc': 'Intermediate', 'color': const Color(0xFF8B5CF6)},
      {'level': 'N2', 'desc': 'Upper-Int', 'color': const Color(0xFFEC4899)},
      {'level': 'N1', 'desc': 'Advanced', 'color': const Color(0xFFF59E0B)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Difficulty Level',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: size.height * 0.015),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: difficulties.map((difficulty) {
              final isSelected = _selectedDifficulty == difficulty['level'];
              final color = difficulty['color'] as Color;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDifficulty = difficulty['level'] as String;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: size.width * 0.03),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: isSmallScreen ? 8 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        difficulty['level'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : color,
                        ),
                      ),
                      Text(
                        difficulty['desc'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: isSelected ? Colors.white.withOpacity(0.8) : color.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicSuggestions(Size size, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Topics',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: size.height * 0.015),
        Wrap(
          spacing: size.width * 0.02,
          runSpacing: size.width * 0.02,
          children: _topicSuggestions.map((topic) {
            return GestureDetector(
              onTap: () {
                _topicController.text = topic;
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  topic,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenerateButton(Size size, bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      height: isSmallScreen ? size.height * 0.06 : size.height * 0.065,
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generateStory,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isGenerating)
              SizedBox(
                width: isSmallScreen ? 16 : 20,
                height: isSmallScreen ? 16 : 20,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              Icon(
                Icons.auto_stories,
                size: isSmallScreen ? 16 : 20,
              ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Text(
              _isGenerating ? 'Creating...' : 'Generate Story',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(Size size, bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: isSmallScreen ? 60 : 80,
            height: isSmallScreen ? 60 : 80,
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              strokeWidth: 4,
            ),
          ),
          SizedBox(height: size.height * 0.03),
          Text(
            'AI is crafting your story...',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            'This might take a few moments',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryTabs(Size size, bool isSmallScreen) {
    final tabs = [
      {'label': '日本語', 'subtitle': 'Japanese'},
      {'label': 'Romaji', 'subtitle': 'Roman'},
      {'label': 'English', 'subtitle': 'Translation'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = _selectedTab == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTab = index;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: isSmallScreen ? 8 : 12),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 8 : 12,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF10B981)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF10B981)
                      : Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    tab['label']!,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    tab['subtitle']!,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStoryContent(Size size, bool isSmallScreen) {
    String content = '';
    TextStyle textStyle;

    switch (_selectedTab) {
      case 0: // Japanese
        content = _currentStory?.japaneseText ?? '';
        textStyle = GoogleFonts.notoSansJp(
          fontSize: isSmallScreen ? 15 : 17,
          color: Colors.white,
          height: 1.6,
        );
        break;
      case 1: // Romaji
        content = _currentStory?.romajiText ?? '';
        textStyle = GoogleFonts.poppins(
          fontSize: isSmallScreen ? 15 : 17,
          color: Colors.white,
          height: 1.6,
        );
        break;
      case 2: // English
        content = _currentStory?.englishText ?? '';
        textStyle = GoogleFonts.poppins(
          fontSize: isSmallScreen ? 15 : 17,
          color: Colors.white,
          height: 1.6,
        );
        break;
      default:
        content = '';
        textStyle = GoogleFonts.poppins(color: Colors.white);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      constraints: BoxConstraints(
        minHeight: size.height * 0.2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Text(
          content,
          style: textStyle,
        ),
      ),
    );
  }

  Widget _buildActionButtons(Size size, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.volume_up,
          label: 'Listen',
          color: const Color(0xFF06B6D4),
          onTap: _playAudio,
          size: size,
          isSmallScreen: isSmallScreen,
        ),
        _buildActionButton(
          icon: _showGrammarTips ? Icons.close : Icons.school,
          label: _showGrammarTips ? 'Hide Tips' : 'Grammar',
          color: const Color(0xFF8B5CF6),
          onTap: _toggleGrammarTips,
          size: size,
          isSmallScreen: isSmallScreen,
        ),
        _buildActionButton(
          icon: Icons.share,
          label: 'Share',
          color: const Color(0xFFEC4899),
          onTap: _shareStory,
          size: size,
          isSmallScreen: isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required Size size,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 8 : 12,
        ),
        constraints: BoxConstraints(
          minWidth: size.width * 0.25,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: isSmallScreen ? 20 : 24,
            ),
            SizedBox(height: isSmallScreen ? 4 : 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrammarTips(Size size, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.school,
                color: const Color(0xFF8B5CF6),
                size: isSmallScreen ? 20 : 24,
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Text(
                'Grammar Points',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          ..._currentStory?.grammarPoints.map((point) {
            return Padding(
              padding: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF8B5CF6),
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 13 : 15,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList() ??
              [],
        ],
      ),
    );
  }

  Widget _buildNewStoryButton(Size size, bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      height: isSmallScreen ? size.height * 0.06 : size.height * 0.065,
      child: ElevatedButton(
        onPressed: _createNewStory,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: isSmallScreen ? 16 : 20,
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Text(
              'Create New Story',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Action Methods
  Future<void> _generateStory() async {
    if (_topicController.text.trim().isEmpty) {
      _showMessage('Please enter a topic for your story!', isError: true);
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // Simulate AI story generation
      await Future.delayed(const Duration(seconds: 3));

      final topic = _topicController.text.trim();
      final story = _generateSampleStory(topic);

      setState(() {
        _currentStory = story;
        _hasGeneratedStory = true;
        _isGenerating = false;
      });

      _storyController.forward();
      _showMessage('Story generated successfully! 🎉');

      // Auto scroll to story
      await Future.delayed(const Duration(milliseconds: 500));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      _showMessage('Failed to generate story. Please try again.', isError: true);
    }
  }

  StoryData _generateSampleStory(String topic) {
    return StoryData(
      title: 'A Story About $topic',
      japaneseText: 'これは$topicについての物語です。昨日、私は友達と一緒に公園に行きました。天気がとても良くて、青い空と白い雲が見えました。公園には多くの人がいて、子供たちが楽しそうに遊んでいました。私たちはベンチに座って、美しい景色を見ながら話をしました。',
      romajiText: 'Kore wa $topic ni tsuite no monogatari desu. Kinou, watashi wa tomodachi to issho ni kouen ni ikimashita. Tenki ga totemo yokute, aoi sora to shiroi kumo ga miemashita. Kouen ni wa ooku no hito ga ite, kodomo-tachi ga tanoshisou ni asonde imashita. Watashi-tachi wa benchi ni suwatte, utsukushii keshiki wo mi nagara hanashi wo shimashita.',
      englishText: 'This is a story about $topic. Yesterday, I went to the park with my friends. The weather was very good, and I could see the blue sky and white clouds. There were many people in the park, and children were playing happily. We sat on a bench and talked while looking at the beautiful scenery.',
      grammarPoints: [
        'について (ni tsuite) - "about" - used to indicate the topic of discussion',
        'と一緒に (to issho ni) - "together with" - indicates doing something with someone',
        'ながら (nagara) - "while" - indicates doing two actions simultaneously',
        'そうに (sou ni) - "seems like" - expresses appearance or impression',
      ],
      wordCount: 85,
      difficulty: _selectedDifficulty,
    );
  }

  void _playAudio() {
    _showMessage('Audio playback coming soon! 🔊');
  }

  void _toggleGrammarTips() {
    setState(() {
      _showGrammarTips = !_showGrammarTips;
    });
  }

  void _shareStory() {
    _showMessage('Sharing functionality coming soon! 📤');
  }

  void _saveStory() {
    _showMessage('Story saved to your collection! 📚');
  }

  void _createNewStory() {
    setState(() {
      _hasGeneratedStory = false;
      _currentStory = null;
      _selectedTab = 0;
      _showGrammarTips = false;
      _topicController.clear();
    });
    _storyController.reset();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class StoryData {
  final String title;
  final String japaneseText;
  final String romajiText;
  final String englishText;
  final List<String> grammarPoints;
  final int wordCount;
  final String difficulty;

  StoryData({
    required this.title,
    required this.japaneseText,
    required this.romajiText,
    required this.englishText,
    required this.grammarPoints,
    required this.wordCount,
    required this.difficulty,
  });
}



// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// //
// // class StoryGeneratorScreen extends StatefulWidget {
// //   const StoryGeneratorScreen({super.key});
// //
// //   @override
// //   State<StoryGeneratorScreen> createState() => _StoryGeneratorScreenState();
// // }
// //
// // class _StoryGeneratorScreenState extends State<StoryGeneratorScreen> {
// //   final TextEditingController _topicController = TextEditingController();
// //   final ScrollController _scrollController = ScrollController();
// //
// //   bool _isGenerating = false;
// //   bool _hasGeneratedStory = false;
// //   String _selectedDifficulty = 'N5';
// //   StoryData? _currentStory;
// //   int _selectedTab = 0;
// //   bool _showGrammarTips = false;
// //
// //   final List<String> _topicSuggestions = [
// //     'A day at the park',
// //     'Meeting a new friend',
// //     'Going to a Japanese restaurant',
// //     'First day at school',
// //     'Weekend adventure',
// //   ];
// //
// //   @override
// //   void dispose() {
// //     _topicController.dispose();
// //     _scrollController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final size = MediaQuery.of(context).size;
// //     final padding = size.width * 0.04;
// //     final isSmallScreen = size.width < 360;
// //
// //     return Scaffold(
// //       backgroundColor: const Color(0xFF0D1117),
// //       body: SafeArea(
// //         child: Column(
// //           children: [
// //             // Header with fixed height
// //             Container(
// //               height: size.height * 0.1,
// //               padding: EdgeInsets.symmetric(horizontal: padding),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   IconButton(
// //                     icon: const Icon(Icons.arrow_back, color: Colors.white),
// //                     onPressed: () => Navigator.pop(context),
// //                   ),
// //                   Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         'Story Generator',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: isSmallScreen ? 18 : 20,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.white,
// //                         ),
// //                       ),
// //                       Text(
// //                         'Create Japanese stories',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: isSmallScreen ? 12 : 14,
// //                           color: Colors.white.withOpacity(0.7),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   _buildProgressIndicator(size, isSmallScreen),
// //                 ],
// //               ),
// //             ),
// //
// //             // Content area
// //             Expanded(
// //               child: SingleChildScrollView(
// //                 controller: _scrollController,
// //                 physics: const BouncingScrollPhysics(),
// //                 padding: EdgeInsets.only(
// //                   left: padding,
// //                   right: padding,
// //                   bottom: padding * 2, // Extra bottom padding
// //                 ),
// //                 child: ConstrainedBox(
// //                   constraints: BoxConstraints(
// //                     minHeight: size.height * 0.8,
// //                   ),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       if (!_hasGeneratedStory) ...[
// //                         _buildInputSection(size, isSmallScreen),
// //                         SizedBox(height: padding),
// //                         _buildDifficultySelector(size, isSmallScreen),
// //                         SizedBox(height: padding),
// //                         _buildTopicSuggestions(size, isSmallScreen),
// //                         SizedBox(height: padding),
// //                         _buildGenerateButton(size, isSmallScreen),
// //                       ],
// //
// //                       if (_hasGeneratedStory && _currentStory != null) ...[
// //                         _buildStoryTabs(size, isSmallScreen),
// //                         SizedBox(height: padding),
// //                         _buildStoryContent(size, isSmallScreen),
// //                         SizedBox(height: padding),
// //                         _buildActionButtons(size, isSmallScreen),
// //                         if (_showGrammarTips) ...[
// //                           SizedBox(height: padding),
// //                           _buildGrammarTips(size, isSmallScreen),
// //                         ],
// //                         SizedBox(height: padding),
// //                         _buildNewStoryButton(size, isSmallScreen),
// //                       ],
// //
// //                       if (_isGenerating) _buildLoadingState(size, isSmallScreen),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //       floatingActionButton: _hasGeneratedStory
// //           ? FloatingActionButton(
// //         onPressed: _saveStory,
// //         backgroundColor: const Color(0xFF10B981),
// //         child: const Icon(Icons.bookmark_add, color: Colors.white),
// //       )
// //           : null,
// //     );
// //   }
// //
// //   Widget _buildProgressIndicator(Size size, bool isSmallScreen) {
// //     return Container(
// //       padding: EdgeInsets.symmetric(
// //         horizontal: size.width * 0.03,
// //         vertical: size.height * 0.008,
// //       ),
// //       decoration: BoxDecoration(
// //         gradient: const LinearGradient(
// //           colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
// //         ),
// //         borderRadius: BorderRadius.circular(20),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           const Icon(Icons.auto_stories, color: Colors.white, size: 16),
// //           SizedBox(width: size.width * 0.01),
// //           Text(
// //             '5 stories',
// //             style: GoogleFonts.poppins(
// //               fontSize: isSmallScreen ? 12 : 14,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.white,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildInputSection(Size size, bool isSmallScreen) {
// //     final padding = size.width * 0.04;
// //
// //     return Container(
// //       width: double.infinity,
// //       padding: EdgeInsets.all(padding),
// //       decoration: BoxDecoration(
// //         gradient:  LinearGradient(
// //           colors: [
// //             Color(0xFF10B981).withOpacity(0.1),
// //             Color(0xFF06B6D4).withOpacity(0.1),
// //           ],
// //         ),
// //         borderRadius: BorderRadius.circular(12),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               const Icon(Icons.edit_note, color: Color(0xFF10B981)),
// //               SizedBox(width: size.width * 0.02),
// //               Text(
// //                 'Story Topic',
// //                 style: GoogleFonts.poppins(
// //                   fontSize: isSmallScreen ? 16 : 18,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.white,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: size.height * 0.02),
// //           TextField(
// //             controller: _topicController,
// //             decoration: InputDecoration(
// //               hintText: 'e.g., "A cat who loves ramen"',
// //               hintStyle: GoogleFonts.poppins(
// //                 color: Colors.white.withOpacity(0.5),
// //               ),
// //               filled: true,
// //               fillColor: Colors.white.withOpacity(0.05),
// //               border: OutlineInputBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //                 borderSide: BorderSide.none,
// //               ),
// //               contentPadding: EdgeInsets.all(size.width * 0.04),
// //             ),
// //             style: GoogleFonts.poppins(color: Colors.white),
// //             maxLines: 2,
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildDifficultySelector(Size size, bool isSmallScreen) {
// //     final List<Map<String, dynamic>> difficulties = [
// //       {'level': 'N5', 'color': const Color(0xFF10B981)},
// //       {'level': 'N4', 'color': const Color(0xFF06B6D4)},
// //       {'level': 'N3', 'color': const Color(0xFF8B5CF6)},
// //     ];
// //
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'Difficulty Level',
// //           style: GoogleFonts.poppins(
// //             fontSize: isSmallScreen ? 16 : 18,
// //             fontWeight: FontWeight.bold,
// //             color: Colors.white,
// //           ),
// //         ),
// //         SizedBox(height: size.height * 0.01),
// //         SingleChildScrollView(
// //           scrollDirection: Axis.horizontal,
// //           child: Row(
// //             children: difficulties.map((difficulty) {
// //               final String level = difficulty['level'] as String;
// //               final Color color = difficulty['color'] as Color;
// //               final bool isSelected = _selectedDifficulty == level;
// //
// //               return Padding(
// //                 padding: EdgeInsets.only(right: size.width * 0.02),
// //                 child: ChoiceChip(
// //                   label: Text(level),
// //                   selected: isSelected,
// //                   onSelected: (selected) {
// //                     setState(() {
// //                       _selectedDifficulty = level;
// //                     });
// //                   },
// //                   backgroundColor: color.withOpacity(0.1),
// //                   selectedColor: color,
// //                   labelStyle: GoogleFonts.poppins(
// //                     color: isSelected ? Colors.white : color,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               );
// //             }).toList(),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //   Widget _buildTopicSuggestions(Size size, bool isSmallScreen) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'Popular Topics',
// //           style: GoogleFonts.poppins(
// //             fontSize: isSmallScreen ? 16 : 18,
// //             fontWeight: FontWeight.bold,
// //             color: Colors.white,
// //           ),
// //         ),
// //         SizedBox(height: size.height * 0.01),
// //         Wrap(
// //           spacing: size.width * 0.02,
// //           runSpacing: size.width * 0.02,
// //           children: _topicSuggestions.map((topic) {
// //             return GestureDetector(
// //               onTap: () => _topicController.text = topic,
// //               child: Container(
// //                 padding: EdgeInsets.symmetric(
// //                   horizontal: size.width * 0.04,
// //                   vertical: size.height * 0.008,
// //                 ),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white.withOpacity(0.05),
// //                   borderRadius: BorderRadius.circular(20),
// //                 ),
// //                 child: Text(
// //                   topic,
// //                   style: GoogleFonts.poppins(
// //                     fontSize: isSmallScreen ? 14 : 16,
// //                     color: Colors.white.withOpacity(0.8),
// //                   ),
// //                 ),
// //               ),
// //             );
// //           }).toList(),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildGenerateButton(Size size, bool isSmallScreen) {
// //     return SizedBox(
// //       width: double.infinity,
// //       child: ElevatedButton(
// //         onPressed: _isGenerating ? null : _generateStory,
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: const Color(0xFF10B981),
// //           padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //         ),
// //         child: _isGenerating
// //             ? const CircularProgressIndicator(color: Colors.white)
// //             : Text(
// //           'Generate Story',
// //           style: GoogleFonts.poppins(
// //             fontSize: isSmallScreen ? 16 : 18,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildStoryTabs(Size size, bool isSmallScreen) {
// //     final tabs = ['Japanese', 'Romaji', 'English'];
// //     return SingleChildScrollView(
// //       scrollDirection: Axis.horizontal,
// //       child: Row(
// //         children: tabs.asMap().entries.map((entry) {
// //           final index = entry.key;
// //           return Padding(
// //             padding: EdgeInsets.only(right: size.width * 0.02),
// //             child: ChoiceChip(
// //               label: Text(tabs[index]),
// //               selected: _selectedTab == index,
// //               onSelected: (selected) {
// //                 setState(() {
// //                   _selectedTab = index;
// //                 });
// //               },
// //               selectedColor: const Color(0xFF10B981),
// //               labelStyle: GoogleFonts.poppins(
// //                 color: _selectedTab == index ? Colors.white : Colors.white70,
// //               ),
// //             ),
// //           );
// //         }).toList(),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildStoryContent(Size size, bool isSmallScreen) {
// //     final content = _selectedTab == 0
// //         ? _currentStory?.japaneseText ?? ''
// //         : _selectedTab == 1
// //         ? _currentStory?.romajiText ?? ''
// //         : _currentStory?.englishText ?? '';
// //
// //     return Container(
// //       width: double.infinity,
// //       padding: EdgeInsets.all(size.width * 0.04),
// //       decoration: BoxDecoration(
// //         color: Colors.white.withOpacity(0.05),
// //         borderRadius: BorderRadius.circular(12),
// //       ),
// //       child: Text(
// //         content,
// //         style: GoogleFonts.poppins(
// //           fontSize: isSmallScreen ? 14 : 16,
// //           color: Colors.white,
// //           height: 1.5,
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildActionButtons(Size size, bool isSmallScreen) {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceAround,
// //       children: [
// //         _buildIconButton(
// //           icon: Icons.volume_up,
// //           label: 'Listen',
// //           onPressed: _playAudio,
// //           size: size,
// //         ),
// //         _buildIconButton(
// //           icon: _showGrammarTips ? Icons.close : Icons.school,
// //           label: _showGrammarTips ? 'Hide Tips' : 'Grammar',
// //           onPressed: _toggleGrammarTips,
// //           size: size,
// //         ),
// //         _buildIconButton(
// //           icon: Icons.share,
// //           label: 'Share',
// //           onPressed: _shareStory,
// //           size: size,
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildIconButton({
// //     required IconData icon,
// //     required String label,
// //     required VoidCallback onPressed,
// //     required Size size,
// //   }) {
// //     return Column(
// //       children: [
// //         IconButton(
// //           icon: Icon(icon, color: Colors.white),
// //           onPressed: onPressed,
// //         ),
// //         Text(
// //           label,
// //           style: GoogleFonts.poppins(
// //             fontSize: 12,
// //             color: Colors.white.withOpacity(0.8),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildGrammarTips(Size size, bool isSmallScreen) {
// //     return Container(
// //       width: double.infinity,
// //       padding: EdgeInsets.all(size.width * 0.04),
// //       decoration: BoxDecoration(
// //         color: const Color(0xFF8B5CF6).withOpacity(0.1),
// //         borderRadius: BorderRadius.circular(12),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               Icon(Icons.school, color: const Color(0xFF8B5CF6)),
// //               SizedBox(width: size.width * 0.02),
// //               Text(
// //                 'Grammar Points',
// //                 style: GoogleFonts.poppins(
// //                   fontSize: isSmallScreen ? 16 : 18,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.white,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: size.height * 0.01),
// //           ...?(_currentStory?.grammarPoints.map((point) => Padding(
// //             padding: EdgeInsets.only(bottom: size.height * 0.008),
// //             child: Text(
// //               '• $point',
// //               style: GoogleFonts.poppins(
// //                 fontSize: isSmallScreen ? 14 : 16,
// //                 color: Colors.white.withOpacity(0.9),
// //               ),
// //             ),
// //           ))),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildNewStoryButton(Size size, bool isSmallScreen) {
// //     return SizedBox(
// //       width: double.infinity,
// //       child: OutlinedButton(
// //         onPressed: _createNewStory,
// //         style: OutlinedButton.styleFrom(
// //           side: BorderSide(color: Colors.white.withOpacity(0.3)),
// //           padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //         ),
// //         child: Text(
// //           'Create New Story',
// //           style: GoogleFonts.poppins(
// //             fontSize: isSmallScreen ? 16 : 18,
// //             color: Colors.white,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildLoadingState(Size size, bool isSmallScreen) {
// //     return SizedBox(
// //       height: size.height * 0.4,
// //       child: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             const CircularProgressIndicator(color: Color(0xFF10B981)),
// //             SizedBox(height: size.height * 0.02),
// //             Text(
// //               'Generating your story...',
// //               style: GoogleFonts.poppins(
// //                 fontSize: isSmallScreen ? 16 : 18,
// //                 color: Colors.white,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Future<void> _generateStory() async {
// //     if (_topicController.text.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Please enter a topic first!')),
// //       );
// //       return;
// //     }
// //
// //     setState(() => _isGenerating = true);
// //
// //     await Future.delayed(const Duration(seconds: 2));
// //
// //     setState(() {
// //       _isGenerating = false;
// //       _hasGeneratedStory = true;
// //       _currentStory = StoryData(
// //         title: 'Story about ${_topicController.text}',
// //         japaneseText: 'これはサンプルの日本語のストーリーです。',
// //         romajiText: 'Kore wa sanpuru no nihongo no sutōrī desu.',
// //         englishText: 'This is a sample Japanese story.',
// //         grammarPoints: [
// //           'Sample grammar point 1',
// //           'Sample grammar point 2',
// //         ],
// //         wordCount: 50,
// //         difficulty: _selectedDifficulty,
// //       );
// //     });
// //   }
// //
// //   void _playAudio() {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(content: Text('Audio playback coming soon!')),
// //     );
// //   }
// //
// //   void _toggleGrammarTips() {
// //     setState(() => _showGrammarTips = !_showGrammarTips);
// //   }
// //
// //   void _shareStory() {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(content: Text('Sharing coming soon!')),
// //     );
// //   }
// //
// //   void _saveStory() {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(content: Text('Story saved!')),
// //     );
// //   }
// //
// //   void _createNewStory() {
// //     setState(() {
// //       _hasGeneratedStory = false;
// //       _currentStory = null;
// //       _selectedTab = 0;
// //       _showGrammarTips = false;
// //       _topicController.clear();
// //     });
// //   }
// // }
// //
// // class StoryData {
// //   final String title;
// //   final String japaneseText;
// //   final String romajiText;
// //   final String englishText;
// //   final List<String> grammarPoints;
// //   final int wordCount;
// //   final String difficulty;
// //
// //   StoryData({
// //     required this.title,
// //     required this.japaneseText,
// //     required this.romajiText,
// //     required this.englishText,
// //     required this.grammarPoints,
// //     required this.wordCount,
// //     required this.difficulty,
// //   });
// // }
//
//
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:math' as math;
//
// class StoryGeneratorScreen extends StatefulWidget {
//   const StoryGeneratorScreen({super.key});
//
//   @override
//   State<StoryGeneratorScreen> createState() => _StoryGeneratorScreenState();
// }
//
// class _StoryGeneratorScreenState extends State<StoryGeneratorScreen>
//     with TickerProviderStateMixin {
//   // Animation Controllers
//   late AnimationController _slideController;
//   late AnimationController _pulseController;
//   late AnimationController _storyController;
//
//   late Animation<double> _slideAnimation;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _storyAnimation;
//
//   // Controllers
//   final TextEditingController _topicController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//
//   // State Variables
//   bool _isGenerating = false;
//   bool _hasGeneratedStory = false;
//   String _selectedDifficulty = 'N5';
//   int _storyLength = 100; // words
//
//   // Story Data
//   StoryData? _currentStory;
//
//   // UI State
//   int _selectedTab = 0; // 0: Japanese, 1: Romaji, 2: English
//   bool _showGrammarTips = false;
//
//   // Sample story topics for suggestions
//   final List<String> _topicSuggestions = [
//     'A day at the park',
//     'Meeting a new friend',
//     'Going to a Japanese restaurant',
//     'First day at school',
//     'Weekend adventure',
//     'Shopping in Tokyo',
//     'Visiting a temple',
//     'Learning to cook',
//     'Train journey',
//     'Festival celebration'
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//   }
//
//   void _initAnimations() {
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
//
//     _storyController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );
//
//     _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
//       CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
//     );
//
//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//
//     _storyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _storyController, curve: Curves.easeInOut),
//     );
//
//     _slideController.forward();
//     _pulseController.repeat(reverse: true);
//   }
//
//   @override
//   void dispose() {
//     _slideController.dispose();
//     _pulseController.dispose();
//     _storyController.dispose();
//     _topicController.dispose();
//     _scrollController.dispose();
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
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Fixed Header
//             _buildHeader(size, isSmallScreen),
//
//             // Scrollable Content
//             Expanded(
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 child: Padding(
//                   padding: EdgeInsets.all(size.width * 0.04),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Only show content area here (remove header from here)
//                       if (!_hasGeneratedStory) ...[
//                         _buildInputSection(size, isSmallScreen),
//                         SizedBox(height: size.height * 0.03),
//                         _buildDifficultySelector(size, isSmallScreen),
//                         SizedBox(height: size.height * 0.03),
//                         _buildTopicSuggestions(size, isSmallScreen),
//                         SizedBox(height: size.height * 0.03),
//                         _buildGenerateButton(size, isSmallScreen),
//                       ],
//
//                       if (_hasGeneratedStory && _currentStory != null) ...[
//                         SizedBox(height: size.height * 0.02),
//                         _buildStoryTabs(size, isSmallScreen),
//                         SizedBox(height: size.height * 0.02),
//                         _buildStoryContent(size, isSmallScreen),
//                         SizedBox(height: size.height * 0.02),
//                         _buildActionButtons(size, isSmallScreen),
//                         if (_showGrammarTips) ...[
//                           SizedBox(height: size.height * 0.02),
//                           _buildGrammarTips(size, isSmallScreen),
//                         ],
//                         SizedBox(height: size.height * 0.03),
//                         _buildNewStoryButton(size, isSmallScreen),
//                       ],
//
//                       if (_isGenerating)
//                         _buildLoadingState(size, isSmallScreen),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: _hasGeneratedStory
//           ? AnimatedBuilder(
//         animation: _pulseAnimation,
//         builder: (context, child) {
//           return Transform.scale(
//             scale: _pulseAnimation.value,
//             child: FloatingActionButton(
//               onPressed: _saveStory,
//               backgroundColor: const Color(0xFF10B981),
//               child: const Icon(Icons.bookmark_add, color: Colors.white),
//             ),
//           );
//         },
//       )
//           : null,
//     );
//   }
//
//   Widget _buildHeader(Size size, bool isSmallScreen) {
//     return SlideTransition(
//       position: Tween<Offset>(
//         begin: const Offset(0, -1),
//         end: Offset.zero,
//       ).animate(_slideAnimation),
//       child: Container(
//         padding: EdgeInsets.all(size.width * 0.04),
//         child: Row(
//           children: [
//             // Back Button
//             GestureDetector(
//               onTap: () => Navigator.of(context).pop(),
//               child: Container(
//                 padding: EdgeInsets.all(size.width * 0.025),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: Colors.white.withOpacity(0.2),
//                     width: 1,
//                   ),
//                 ),
//                 child: Icon(
//                   Icons.arrow_back_ios,
//                   color: Colors.white,
//                   size: size.width * 0.05,
//                 ),
//               ),
//             ),
//
//             SizedBox(width: size.width * 0.04),
//
//             // Title
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Story Generator',
//                     style: GoogleFonts.poppins(
//                       fontSize: isSmallScreen ? size.width * 0.055 : size.width * 0.06,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   Text(
//                     'Create AI-powered Japanese stories',
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.03,
//                       color: Colors.white.withOpacity(0.7),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Progress Indicator
//             _buildProgressIndicator(size),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProgressIndicator(Size size) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: size.width * 0.03,
//         vertical: size.height * 0.01,
//       ),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF10B981).withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.auto_stories,
//             color: Colors.white,
//             size: size.width * 0.04,
//           ),
//           SizedBox(width: size.width * 0.01),
//           Text(
//             '5 stories',
//             style: GoogleFonts.poppins(
//               fontSize: size.width * 0.03,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInputSection(Size size, bool isSmallScreen) {
//     return Container(
//       padding: EdgeInsets.all(size.width * 0.05),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             const Color(0xFF10B981).withOpacity(0.1),
//             const Color(0xFF06B6D4).withOpacity(0.1),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
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
//               Container(
//                 padding: EdgeInsets.all(size.width * 0.025),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF10B981).withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   '✨',
//                   style: TextStyle(fontSize: size.width * 0.06),
//                 ),
//               ),
//               SizedBox(width: size.width * 0.03),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'What story would you like?',
//                       style: GoogleFonts.poppins(
//                         fontSize: isSmallScreen ? size.width * 0.045 : size.width * 0.05,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       'Enter any topic and watch AI create magic!',
//                       style: GoogleFonts.poppins(
//                         fontSize: size.width * 0.032,
//                         color: Colors.white.withOpacity(0.7),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//
//           SizedBox(height: size.height * 0.02),
//
//           // Topic Input Field
//           TextField(
//             controller: _topicController,
//             style: GoogleFonts.poppins(
//               color: Colors.white,
//               fontSize: size.width * 0.035,
//             ),
//             decoration: InputDecoration(
//               hintText: 'e.g., "A cat who loves ramen"',
//               hintStyle: GoogleFonts.poppins(
//                 color: Colors.white.withOpacity(0.5),
//                 fontSize: size.width * 0.035,
//               ),
//               filled: true,
//               fillColor: Colors.white.withOpacity(0.05),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
//               ),
//               prefixIcon: Icon(
//                 Icons.edit_note,
//                 color: const Color(0xFF10B981),
//                 size: size.width * 0.05,
//               ),
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: size.width * 0.04,
//                 vertical: size.height * 0.02,
//               ),
//             ),
//             maxLines: 3,
//             minLines: 1,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDifficultySelector(Size size, bool isSmallScreen) {
//     final difficulties = [
//       {'level': 'N5', 'desc': 'Beginner', 'color': const Color(0xFF10B981)},
//       {'level': 'N4', 'desc': 'Elementary', 'color': const Color(0xFF06B6D4)},
//       {'level': 'N3', 'desc': 'Intermediate', 'color': const Color(0xFF8B5CF6)},
//       {'level': 'N2', 'desc': 'Upper-Int', 'color': const Color(0xFFEC4899)},
//       {'level': 'N1', 'desc': 'Advanced', 'color': const Color(0xFFF59E0B)},
//     ];
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Difficulty Level',
//           style: GoogleFonts.poppins(
//             fontSize: isSmallScreen ? size.width * 0.045 : size.width * 0.05,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         SizedBox(height: size.height * 0.015),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: difficulties.map((difficulty) {
//               final isSelected = _selectedDifficulty == difficulty['level'];
//               final color = difficulty['color'] as Color;
//
//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _selectedDifficulty = difficulty['level'] as String;
//                   });
//                 },
//                 child: Container(
//                   margin: EdgeInsets.only(right: size.width * 0.03),
//                   padding: EdgeInsets.symmetric(
//                     horizontal: size.width * 0.04,
//                     vertical: size.height * 0.015,
//                   ),
//                   decoration: BoxDecoration(
//                     color: isSelected ? color : color.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(15),
//                     border: Border.all(
//                       color: color.withOpacity(0.3),
//                       width: isSelected ? 2 : 1,
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       Text(
//                         difficulty['level'] as String,
//                         style: GoogleFonts.poppins(
//                           fontSize: size.width * 0.035,
//                           fontWeight: FontWeight.bold,
//                           color: isSelected ? Colors.white : color,
//                         ),
//                       ),
//                       Text(
//                         difficulty['desc'] as String,
//                         style: GoogleFonts.poppins(
//                           fontSize: size.width * 0.025,
//                           color: isSelected ? Colors.white.withOpacity(0.8) : color.withOpacity(0.7),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTopicSuggestions(Size size, bool isSmallScreen) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Popular Topics',
//           style: GoogleFonts.poppins(
//             fontSize: isSmallScreen ? size.width * 0.045 : size.width * 0.05,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         SizedBox(height: size.height * 0.015),
//         Wrap(
//           spacing: size.width * 0.02,
//           runSpacing: size.width * 0.02,
//           children: _topicSuggestions.map((topic) {
//             return GestureDetector(
//               onTap: () {
//                 _topicController.text = topic;
//               },
//               child: Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: size.width * 0.03,
//                   vertical: size.height * 0.008,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.05),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: Colors.white.withOpacity(0.2),
//                     width: 1,
//                   ),
//                 ),
//                 child: Text(
//                   topic,
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.03,
//                     color: Colors.white.withOpacity(0.8),
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildGenerateButton(Size size, bool isSmallScreen) {
//     return SizedBox(
//       width: double.infinity,
//       height: size.height * 0.065,
//       child: ElevatedButton(
//         onPressed: _isGenerating ? null : _generateStory,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF10B981),
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           elevation: 5,
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (_isGenerating)
//               SizedBox(
//                 width: size.width * 0.05,
//                 height: size.width * 0.05,
//                 child: const CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 ),
//               )
//             else
//               Icon(
//                 Icons.auto_stories,
//                 size: size.width * 0.05,
//               ),
//             SizedBox(width: size.width * 0.02),
//             Text(
//               _isGenerating ? 'Creating Magic...' : 'Generate Story',
//               style: GoogleFonts.poppins(
//                 fontSize: size.width * 0.04,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoadingState(Size size, bool isSmallScreen) {
//     return Container(
//       padding: EdgeInsets.all(size.width * 0.08),
//       child: Column(
//         children: [
//           SizedBox(
//             width: size.width * 0.2,
//             height: size.width * 0.2,
//             child: CircularProgressIndicator(
//               valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
//               strokeWidth: 4,
//             ),
//           ),
//           SizedBox(height: size.height * 0.03),
//           Text(
//             'AI is crafting your story...',
//             style: GoogleFonts.poppins(
//               fontSize: size.width * 0.045,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           SizedBox(height: size.height * 0.01),
//           Text(
//             'This might take a few moments',
//             style: GoogleFonts.poppins(
//               fontSize: size.width * 0.032,
//               color: Colors.white.withOpacity(0.7),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStoryHeader(Size size, bool isSmallScreen) {
//     return Container(
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
//       child: Row(
//         children: [
//           // ... rest of the header content
//           Container(
//             padding: EdgeInsets.all(size.width * 0.025),
//             decoration: BoxDecoration(
//               color: const Color(0xFF10B981).withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               '📚',
//               style: TextStyle(fontSize: size.width * 0.06),
//             ),
//           ),
//           SizedBox(width: size.width * 0.03),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _currentStory?.title ?? 'Your Story',
//                   style: GoogleFonts.poppins(
//                     fontSize: isSmallScreen ? size.width * 0.045 : size.width * 0.05,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Text(
//                   'Level: $_selectedDifficulty • ${_currentStory?.wordCount ?? 0} words',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.03,
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
//   Widget _buildStoryTabs(Size size, bool isSmallScreen) {
//     final tabs = [
//       {'label': '日本語', 'subtitle': 'Japanese'},
//       {'label': 'Romaji', 'subtitle': 'Roman'},
//       {'label': 'English', 'subtitle': 'Translation'},
//     ];
//
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: tabs.asMap().entries.map((entry) {
//           final index = entry.key;
//           final tab = entry.value;
//           final isSelected = _selectedTab == index;
//
//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 _selectedTab = index;
//               });
//             },
//             child: Container(
//               margin: EdgeInsets.only(right: size.width * 0.03),
//               padding: EdgeInsets.symmetric(
//                 horizontal: size.width * 0.04,
//                 vertical: size.height * 0.015,
//               ),
//               decoration: BoxDecoration(
//                 color: isSelected
//                     ? const Color(0xFF10B981)
//                     : Colors.white.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(15),
//                 border: Border.all(
//                   color: isSelected
//                       ? const Color(0xFF10B981)
//                       : Colors.white.withOpacity(0.2),
//                   width: 1,
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Text(
//                     tab['label']!,
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.035,
//                       fontWeight: FontWeight.bold,
//                       color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
//                     ),
//                   ),
//                   Text(
//                     tab['subtitle']!,
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.025,
//                       color: isSelected
//                           ? Colors.white.withOpacity(0.8)
//                           : Colors.white.withOpacity(0.6),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _buildStoryContent(Size size, bool isSmallScreen) {
//     String content = '';
//     TextStyle textStyle;
//
//     switch (_selectedTab) {
//       case 0: // Japanese
//         content = _currentStory?.japaneseText ?? '';
//         textStyle = GoogleFonts.notoSansJp(
//           fontSize: size.width * 0.035,
//           color: Colors.white,
//           height: 1.6,
//         );
//         break;
//       case 1: // Romaji
//         content = _currentStory?.romajiText ?? '';
//         textStyle = GoogleFonts.poppins(
//           fontSize: size.width * 0.035,
//           color: Colors.white,
//           height: 1.6,
//         );
//         break;
//       case 2: // English
//         content = _currentStory?.englishText ?? '';
//         textStyle = GoogleFonts.poppins(
//           fontSize: size.width * 0.035,
//           color: Colors.white,
//           height: 1.6,
//         );
//         break;
//       default:
//         content = '';
//         textStyle = GoogleFonts.poppins(color: Colors.white);
//     }
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
//       child: Text(
//         content,
//         style: textStyle,
//       ),
//     );
//   }
//
//   Widget _buildActionButtons(Size size, bool isSmallScreen) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         _buildActionButton(
//           icon: Icons.volume_up,
//           label: 'Listen',
//           color: const Color(0xFF06B6D4),
//           onTap: _playAudio,
//           size: size,
//           isSmallScreen: isSmallScreen,
//         ),
//         _buildActionButton(
//           icon: _showGrammarTips ? Icons.close : Icons.school,
//           label: _showGrammarTips ? 'Hide Tips' : 'Grammar',
//           color: const Color(0xFF8B5CF6),
//           onTap: _toggleGrammarTips,
//           size: size,
//           isSmallScreen: isSmallScreen,
//         ),
//         _buildActionButton(
//           icon: Icons.share,
//           label: 'Share',
//           color: const Color(0xFFEC4899),
//           onTap: _shareStory,
//           size: size,
//           isSmallScreen: isSmallScreen,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//     required Size size,
//     required bool isSmallScreen,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(
//           horizontal: size.width * 0.04,
//           vertical: size.height * 0.015,
//         ),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: color.withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Column(
//           children: [
//             Icon(
//               icon,
//               color: color,
//               size: size.width * 0.06,
//             ),
//             SizedBox(height: size.height * 0.005),
//             Text(
//               label,
//               style: GoogleFonts.poppins(
//                 fontSize: size.width * 0.025,
//                 color: Colors.white.withOpacity(0.8),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildGrammarTips(Size size, bool isSmallScreen) {
//     return Container(
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
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.school,
//                 color: const Color(0xFF8B5CF6),
//                 size: size.width * 0.05,
//               ),
//               SizedBox(width: size.width * 0.02),
//               Text(
//                 'Grammar Points',
//                 style: GoogleFonts.poppins(
//                   fontSize: size.width * 0.04,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: size.height * 0.015),
//           ..._currentStory?.grammarPoints.map((point) {
//             return Padding(
//               padding: EdgeInsets.only(bottom: size.height * 0.01),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '• ',
//                     style: GoogleFonts.poppins(
//                       color: const Color(0xFF8B5CF6),
//                       fontSize: size.width * 0.035,
//                     ),
//                   ),
//                   Expanded(
//                     child: Text(
//                       point,
//                       style: GoogleFonts.poppins(
//                         fontSize: size.width * 0.032,
//                         color: Colors.white.withOpacity(0.9),
//                         height: 1.4,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }).toList() ??
//               [],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNewStoryButton(Size size, bool isSmallScreen) {
//     return SizedBox(
//       width: double.infinity,
//       height: size.height * 0.06,
//       child: ElevatedButton(
//         onPressed: _createNewStory,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.white.withOpacity(0.1),
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//             side: BorderSide(
//               color: Colors.white.withOpacity(0.3),
//               width: 1,
//             ),
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.add_circle_outline,
//               size: size.width * 0.05,
//             ),
//             SizedBox(width: size.width * 0.02),
//             Text(
//               'Create New Story',
//               style: GoogleFonts.poppins(
//                 fontSize: size.width * 0.04,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Action Methods
//   Future<void> _generateStory() async {
//     if (_topicController.text.trim().isEmpty) {
//       _showMessage('Please enter a topic for your story!', isError: true);
//       return;
//     }
//
//     setState(() {
//       _isGenerating = true;
//     });
//
//     try {
//       // Simulate AI story generation
//       await Future.delayed(const Duration(seconds: 3));
//
//       final topic = _topicController.text.trim();
//       final story = _generateSampleStory(topic);
//
//       setState(() {
//         _currentStory = story;
//         _hasGeneratedStory = true;
//         _isGenerating = false;
//       });
//
//       _storyController.forward();
//       _showMessage('Story generated successfully! 🎉');
//
//       // Auto scroll to story
//       await Future.delayed(const Duration(milliseconds: 500));
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 800),
//         curve: Curves.easeInOut,
//       );
//     } catch (e) {
//       setState(() {
//         _isGenerating = false;
//       });
//       _showMessage('Failed to generate story. Please try again.', isError: true);
//     }
//   }
//
//   StoryData _generateSampleStory(String topic) {
//     // This would be replaced with actual AI API call
//     return StoryData(
//       title: 'A Story About $topic',
//       japaneseText: 'これは$topicについての物語です。昨日、私は友達と一緒に公園に行きました。天気がとても良くて、青い空と白い雲が見えました。公園には多くの人がいて、子供たちが楽しそうに遊んでいました。私たちはベンチに座って、美しい景色を見ながら話をしました。',
//       romajiText: 'Kore wa $topic ni tsuite no monogatari desu. Kinou, watashi wa tomodachi to issho ni kouen ni ikimashita. Tenki ga totemo yokute, aoi sora to shiroi kumo ga miemashita. Kouen ni wa ooku no hito ga ite, kodomo-tachi ga tanoshisou ni asonde imashita. Watashi-tachi wa benchi ni suwatte, utsukushii keshiki wo mi nagara hanashi wo shimashita.',
//       englishText: 'This is a story about $topic. Yesterday, I went to the park with my friends. The weather was very good, and I could see the blue sky and white clouds. There were many people in the park, and children were playing happily. We sat on a bench and talked while looking at the beautiful scenery.',
//       grammarPoints: [
//         'について (ni tsuite) - "about" - used to indicate the topic of discussion',
//         'と一緒に (to issho ni) - "together with" - indicates doing something with someone',
//         'ながら (nagara) - "while" - indicates doing two actions simultaneously',
//         'そうに (sou ni) - "seems like" - expresses appearance or impression',
//       ],
//       wordCount: 85,
//       difficulty: _selectedDifficulty,
//     );
//   }
//
//   void _playAudio() {
//     // TODO: Implement TTS functionality
//     _showMessage('Audio playback coming soon! 🔊');
//   }
//
//   void _toggleGrammarTips() {
//     setState(() {
//       _showGrammarTips = !_showGrammarTips;
//     });
//   }
//
//   void _shareStory() {
//     // TODO: Implement sharing functionality
//     _showMessage('Sharing functionality coming soon! 📤');
//   }
//
//   void _saveStory() {
//     // TODO: Save story to user's collection
//     _showMessage('Story saved to your collection! 📚');
//   }
//
//   void _createNewStory() {
//     setState(() {
//       _hasGeneratedStory = false;
//       _currentStory = null;
//       _selectedTab = 0;
//       _showGrammarTips = false;
//       _topicController.clear();
//     });
//     _storyController.reset();
//   }
//
//   void _showMessage(String message, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : const Color(0xFF10B981),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
// }
//
// // Story Data Model
// class StoryData {
//   final String title;
//   final String japaneseText;
//   final String romajiText;
//   final String englishText;
//   final List<String> grammarPoints;
//   final int wordCount;
//   final String difficulty;
//
//   StoryData({
//     required this.title,
//     required this.japaneseText,
//     required this.romajiText,
//     required this.englishText,
//     required this.grammarPoints,
//     required this.wordCount,
//     required this.difficulty,
//   });
// }