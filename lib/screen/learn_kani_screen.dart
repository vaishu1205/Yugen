import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

import 'KanjiPractice_screen.dart';

class KanjiLearningScreen extends StatefulWidget {
  const KanjiLearningScreen({super.key});

  @override
  State<KanjiLearningScreen> createState() => _KanjiLearningScreenState();
}

class _KanjiLearningScreenState extends State<KanjiLearningScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _cardFlipController;
  late AnimationController _confettiController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _cardFlipAnimation;
  late Animation<double> _confettiAnimation;

  int _currentKanjiIndex = 0;
  bool _showMeaning = false;
  bool _isBookmarked = false;
  String _selectedLevel = 'N5';
  int _streak = 0;
  int _dailyProgress = 0;

  // Light theme colors
  static const Color _primaryColor = Color(0xFF6366F1); // Indigo
  static const Color _secondaryColor = Color(0xFFEC4899); // Pink
  static const Color _accentColor = Color(0xFF10B981); // Emerald
  static const Color _warningColor = Color(0xFFF59E0B); // Amber
  static const Color _backgroundColor = Color(0xFFF8FAFC); // Slate 50
  static const Color _cardColor = Colors.white;
  static const Color _textPrimary = Color(0xFF1E293B); // Slate 800
  static const Color _textSecondary = Color(0xFF64748B); // Slate 500

  // Complete Kanji database organized by JLPT levels
  final Map<String, List<KanjiData>> _kanjiDatabase = {
    'N5': [
      KanjiData(
        character: '学',
        meaning: 'Learn, Study',
        readings: ['がく', 'まな', 'GAKU', 'mana'],
        strokeCount: 8,
        examples: ['学校 (gakkou) - school', '学ぶ (manabu) - to learn'],
        mnemonic: 'A child (子) under a roof learning - perfect place to study!',
        level: 'N5',
      ),
      KanjiData(
        character: '友',
        meaning: 'Friend',
        readings: ['とも', 'ゆう', 'tomo', 'YUU'],
        strokeCount: 4,
        examples: ['友達 (tomodachi) - friend', '友人 (yuujin) - friend (formal)'],
        mnemonic: 'Two hands reaching out to each other - making friends!',
        level: 'N5',
      ),
      KanjiData(
        character: '日',
        meaning: 'Sun, Day',
        readings: ['ひ', 'にち', 'hi', 'NICHI'],
        strokeCount: 4,
        examples: ['今日 (kyou) - today', '日本 (nihon) - Japan'],
        mnemonic: 'Picture of the sun in the sky!',
        level: 'N5',
      ),
      KanjiData(
        character: '本',
        meaning: 'Book, Origin',
        readings: ['ほん', 'もと', 'HON', 'moto'],
        strokeCount: 5,
        examples: ['本 (hon) - book', '日本 (nihon) - Japan'],
        mnemonic: 'A tree (木) with roots, the origin of all things!',
        level: 'N5',
      ),
      KanjiData(
        character: '人',
        meaning: 'Person, Human',
        readings: ['ひと', 'じん', 'hito', 'JIN'],
        strokeCount: 2,
        examples: ['人 (hito) - person', '日本人 (nihonjin) - Japanese person'],
        mnemonic: 'Looks like a person walking with two legs!',
        level: 'N5',
      ),
    ],
    'N4': [
      KanjiData(
        character: '愛',
        meaning: 'Love, Affection',
        readings: ['あい', 'AI'],
        strokeCount: 13,
        examples: ['愛する (aisuru) - to love', '愛情 (aijou) - affection'],
        mnemonic: 'A heart (心) with a hand reaching out and legs walking - showing love through action!',
        level: 'N4',
      ),
      KanjiData(
        character: '心',
        meaning: 'Heart, Mind, Spirit',
        readings: ['こころ', 'しん', 'kokoro', 'SHIN'],
        strokeCount: 4,
        examples: ['心配 (shinpai) - worry', '安心 (anshin) - peace of mind'],
        mnemonic: 'Looks like a heart with three chambers pumping emotions!',
        level: 'N4',
      ),
      KanjiData(
        character: '思',
        meaning: 'Think, Thought',
        readings: ['おも', 'し', 'omo', 'SHI'],
        strokeCount: 9,
        examples: ['思う (omou) - to think', '思考 (shikou) - thinking'],
        mnemonic: 'A field (田) over a heart (心) - thinking with your heart!',
        level: 'N4',
      ),
    ],
    'N3': [
      KanjiData(
        character: '夢',
        meaning: 'Dream, Vision',
        readings: ['ゆめ', 'む', 'yume', 'MU'],
        strokeCount: 13,
        examples: ['夢見る (yume miru) - to dream', '夢想 (musou) - reverie'],
        mnemonic: 'Grass (艹) over eyes (目) in the evening (夕) - dreaming under the stars!',
        level: 'N3',
      ),
      KanjiData(
        character: '実',
        meaning: 'Reality, Truth, Fruit',
        readings: ['み', 'じつ', 'mi', 'JITSU'],
        strokeCount: 8,
        examples: ['実際 (jissai) - reality', '果実 (kajitsu) - fruit'],
        mnemonic: 'A house (宀) full (八) of real things!',
        level: 'N3',
      ),
    ],
    'N2': [
      KanjiData(
        character: '認',
        meaning: 'Recognize, Acknowledge',
        readings: ['みと', 'にん', 'mito', 'NIN'],
        strokeCount: 14,
        examples: ['認める (mitomeru) - to recognize', '確認 (kakunin) - confirmation'],
        mnemonic: 'Words (言) and patience (忍) to truly recognize something!',
        level: 'N2',
      ),
    ],
    'N1': [
      KanjiData(
        character: '憂',
        meaning: 'Worry, Melancholy',
        readings: ['うれ', 'ゆう', 'ure', 'YUU'],
        strokeCount: 15,
        examples: ['憂鬱 (yuuutsu) - depression', '憂慮 (yuuryo) - concern'],
        mnemonic: 'A head (頁) with a worried heart (心) underneath!',
        level: 'N1',
      ),
    ],
  };

  // Get filtered kanji list based on selected level
  List<KanjiData> get _currentKanjiList => _kanjiDatabase[_selectedLevel] ?? [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadUserProgress();
    _loadAchievementProgress(); // ADD this line
  }
  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _cardFlipController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
        begin: const Offset(0.0, -1.0),
        end: Offset.zero
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _cardFlipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardFlipController, curve: Curves.easeInOut),
    );

    _confettiAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _confettiController, curve: Curves.easeOut),
    );

    _slideController.forward();
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _loadUserProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists && mounted) {
          final data = userData.data();
          if (data != null) {
            setState(() {
              _streak = data['kanjiStreak'] ?? 0;
              _dailyProgress = data['dailyKanjiProgress'] ?? 0;
              _selectedLevel = data['jlptLevel'] ?? 'N5';
            });
          }
        }
      } catch (e) {
        debugPrint('Error loading progress: $e');
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _cardFlipController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    // Responsive breakpoints
    final isSmallScreen = size.width < 360;
    final isMediumScreen = size.width >= 360 && size.width < 768;
    final isLargeScreen = size.width >= 768;

    // Dynamic padding based on screen size
    final horizontalPadding = isSmallScreen ? 12.0 : isMediumScreen ? 16.0 : 24.0;
    final verticalPadding = isSmallScreen ? 8.0 : 12.0;

    if (_currentKanjiList.isEmpty) {
      return _buildEmptyState(size, horizontalPadding);
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildHeader(size, isSmallScreen, isMediumScreen),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding / 2,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildProgressSection(size, isSmallScreen, isMediumScreen),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildKanjiCard(size, isSmallScreen, isMediumScreen),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildActionButtons(size, isSmallScreen, isMediumScreen),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildNavigationButtons(size, isSmallScreen, isMediumScreen),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(bottom: 80 + padding.bottom),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [_accentColor, Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _accentColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: _startKanjiQuiz,
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Icon(
                  Icons.quiz_rounded,
                  color: Colors.white,
                  size: isSmallScreen ? 24 : 28,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(Size size, double horizontalPadding) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '📚',
                    style: TextStyle(fontSize: size.width * 0.15),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Kanji Available',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'No kanji found for $_selectedLevel level.\nTry selecting a different level.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: _textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_primaryColor, _secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedLevel = 'N5';
                        _currentKanjiIndex = 0;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Go to N5',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size, bool isSmallScreen, bool isMediumScreen) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Back Button
            Container(
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_rounded,
                    color: _primaryColor,
                    size: isSmallScreen ? 20 : 24),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 16),
            // Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learn Kanji',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 18 : isMediumScreen ? 22 : 26,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary,
                    ),
                  ),
                  Text(
                    'Master Japanese Characters',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 11 : isMediumScreen ? 13 : 15,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Level Selector
            _buildLevelSelector(isSmallScreen, isMediumScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelSelector(bool isSmallScreen, bool isMediumScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryColor, _secondaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLevel,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
          dropdownColor: _cardColor,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 12 : isMediumScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          items: ['N5', 'N4', 'N3', 'N2', 'N1'].map((level) {
            return DropdownMenuItem(
              value: level,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  level,
                  style: GoogleFonts.poppins(
                    color: _textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedLevel = value;
                _currentKanjiIndex = 0;
                _cardFlipController.reset();
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildProgressSection(Size size, bool isSmallScreen, bool isMediumScreen) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _accentColor.withOpacity(0.1),
            _primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildProgressItem(
            '🔥',
            'Streak',
            '$_streak days',
            const Color(0xFFEF4444),
            isSmallScreen,
            isMediumScreen,
          ),
          _buildVerticalDivider(),
          _buildProgressItem(
            '📈',
            'Today',
            '$_dailyProgress/10',
            _accentColor,
            isSmallScreen,
            isMediumScreen,
          ),
          _buildVerticalDivider(),
          _buildProgressItem(
            '🎯',
            'Level',
            _selectedLevel,
            _primaryColor,
            isSmallScreen,
            isMediumScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: _textSecondary.withOpacity(0.2),
    );
  }

  Widget _buildProgressItem(
      String emoji,
      String label,
      String value,
      Color color,
      bool isSmallScreen,
      bool isMediumScreen,
      ) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              emoji,
              style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 14 : isMediumScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 10 : isMediumScreen ? 12 : 14,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanjiCard(Size size, bool isSmallScreen, bool isMediumScreen) {
    if (_currentKanjiList.isEmpty || _currentKanjiIndex >= _currentKanjiList.length) {
      return const SizedBox.shrink();
    }

    final currentKanji = _currentKanjiList[_currentKanjiIndex];

    return AnimatedBuilder(
      animation: _cardFlipAnimation,
      builder: (context, child) {
        final isShowingFront = _cardFlipAnimation.value < 0.5;
        return GestureDetector(
          onTap: _flipCard,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_cardFlipAnimation.value * math.pi),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: isSmallScreen ? size.height * 0.35 : size.height * 0.4,
                maxHeight: isSmallScreen ? size.height * 0.5 : size.height * 0.6,
              ),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isShowingFront
                        ? _primaryColor.withOpacity(0.15)
                        : _accentColor.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: isShowingFront
                      ? _primaryColor.withOpacity(0.2)
                      : _accentColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: isShowingFront
                  ? _buildKanjiFront(currentKanji, size, isSmallScreen, isMediumScreen)
                  : Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(math.pi),
                child: _buildKanjiBack(currentKanji, size, isSmallScreen, isMediumScreen),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKanjiFront(KanjiData kanji, Size size, bool isSmallScreen, bool isMediumScreen) {
    final kanjiSize = isSmallScreen ? size.width * 0.35 : size.width * 0.4;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main Kanji Character
          Container(
            width: kanjiSize,
            height: kanjiSize,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  _primaryColor.withOpacity(0.1),
                  _secondaryColor.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: _primaryColor.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                kanji.character,
                style: GoogleFonts.notoSansJp(
                  fontSize: isSmallScreen ? 60 : isMediumScreen ? 70 : 90,
                  fontWeight: FontWeight.w500,
                  color: _textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Stroke Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor.withOpacity(0.1), _secondaryColor.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: _primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '${kanji.strokeCount} strokes',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 12 : isMediumScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tap hint with animation
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.95 + (_pulseAnimation.value - 1) * 0.5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        color: _accentColor,
                        size: isSmallScreen ? 16 : 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tap to see meaning & examples',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 11 : isMediumScreen ? 13 : 15,
                          color: _accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKanjiBack(KanjiData kanji, Size size, bool isSmallScreen, bool isMediumScreen) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meaning
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_accentColor.withOpacity(0.1), _primaryColor.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _accentColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  kanji.meaning,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 18 : isMediumScreen ? 22 : 26,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Readings
            _buildInfoSection(
              'Readings',
              kanji.readings.join(', '),
              Icons.record_voice_over_rounded,
              _secondaryColor,
              isSmallScreen,
              isMediumScreen,
            ),
            const SizedBox(height: 16),
            // Examples
            _buildInfoSection(
              'Examples',
              kanji.examples.join('\n'),
              Icons.format_list_bulleted_rounded,
              _warningColor,
              isSmallScreen,
              isMediumScreen,
            ),
            const SizedBox(height: 16),
            // Mnemonic
            _buildInfoSection(
              'Memory Tip',
              kanji.mnemonic,
              Icons.lightbulb_rounded,
              _accentColor,
              isSmallScreen,
              isMediumScreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
      String title,
      String content,
      IconData icon,
      Color color,
      bool isSmallScreen,
      bool isMediumScreen,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : isMediumScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 12 : isMediumScreen ? 14 : 16,
              color: _textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Size size, bool isSmallScreen, bool isMediumScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            label: 'Bookmark',
            color: _warningColor,
            onTap: _toggleBookmark,
            isSmallScreen: isSmallScreen,
            isMediumScreen: isMediumScreen,
          ),
          _buildActionButton(
            icon: Icons.volume_up_rounded,
            label: 'Pronounce',
            color: _primaryColor,
            onTap: _pronounceKanji,
            isSmallScreen: isSmallScreen,
            isMediumScreen: isMediumScreen,
          ),
          _buildActionButton(
            icon: Icons.edit_rounded,
            label: 'Practice',
            color: _accentColor,
            onTap: _practiceWriting,
            isSmallScreen: isSmallScreen,
            isMediumScreen: isMediumScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isSmallScreen,
    required bool isMediumScreen,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                    icon,
                    color: color,
                    size: isSmallScreen ? 20 : 24
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 10 : isMediumScreen ? 12 : 14,
                  color: _textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(Size size, bool isSmallScreen, bool isMediumScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildNavButton(
              icon: Icons.arrow_back_ios_rounded,
              label: 'Previous',
              onTap: _previousKanji,
              enabled: _currentKanjiIndex > 0,
              isSmallScreen: isSmallScreen,
              isMediumScreen: isMediumScreen,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_primaryColor, _secondaryColor],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${_currentKanjiIndex + 1} / ${_currentKanjiList.length}',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 12 : isMediumScreen ? 14 : 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildNavButton(
              icon: Icons.arrow_forward_ios_rounded,
              label: 'Next',
              onTap: _nextKanji,
              enabled: _currentKanjiIndex < _currentKanjiList.length - 1,
              isSmallScreen: isSmallScreen,
              isMediumScreen: isMediumScreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool enabled,
    required bool isSmallScreen,
    required bool isMediumScreen,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: enabled
              ? _primaryColor.withOpacity(0.1)
              : _textSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled
                ? _primaryColor.withOpacity(0.3)
                : _textSecondary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon == Icons.arrow_back_ios_rounded) ...[
              Icon(
                icon,
                color: enabled ? _primaryColor : _textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 12 : isMediumScreen ? 14 : 16,
                color: enabled ? _primaryColor : _textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (icon == Icons.arrow_forward_ios_rounded) ...[
              const SizedBox(width: 8),
              Icon(
                icon,
                color: enabled ? _primaryColor : _textSecondary,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }
  // 7. ADD method to track kanji engagement
  Future<void> _trackKanjiEngagement(KanjiData kanji) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Track engagement with this kanji
      await userRef.collection('kanji_interactions').add({
        'kanjiCharacter': kanji.character,
        'action': 'viewed_details',
        'timestamp': FieldValue.serverTimestamp(),
        'level': kanji.level,
      });

    } catch (e) {
      debugPrint('Error tracking kanji engagement: $e');
    }
  }

  void _flipCard() {
    if (_cardFlipController.isCompleted) {
      _cardFlipController.reverse();
    } else {
      _cardFlipController.forward();

      // Track that user engaged with the kanji (flipped to see details)
      if (_currentKanjiList.isNotEmpty && _currentKanjiIndex < _currentKanjiList.length) {
        final currentKanji = _currentKanjiList[_currentKanjiIndex];
        _trackKanjiEngagement(currentKanji);
      }
    }
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    _confettiController.forward().then((_) {
      _confettiController.reset();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _isBookmarked ? 'Kanji bookmarked!' : 'Bookmark removed',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: _warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _pronounceKanji() {
    if (_currentKanjiList.isNotEmpty && _currentKanjiIndex < _currentKanjiList.length) {
      final currentKanji = _currentKanjiList[_currentKanjiIndex];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pronouncing: ${currentKanji.readings.isNotEmpty ? currentKanji.readings.first : currentKanji.character}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: _primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _practiceWriting() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Writing practice coming soon!',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: _accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  // 3. ADD this method to track when a kanji is learned
  Future<void> _markKanjiAsLearned(KanjiData kanji) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Get current kanji progress to check if already learned
      final kanjiProgressDoc = await userRef.collection('kanji_progress').doc(kanji.character).get();
      final isAlreadyLearned = kanjiProgressDoc.exists && (kanjiProgressDoc.data()?['isLearned'] ?? false);

      // Only increment counters if not already learned
      Map<String, dynamic> updates = {
        'lastStudyDate': FieldValue.serverTimestamp(),
        'studyTimes': FieldValue.arrayUnion([DateTime.now().hour]),
      };

      if (!isAlreadyLearned) {
        updates.addAll({
          'learnedKanji': FieldValue.arrayUnion([kanji.character]),
          'totalKanjiLearned': FieldValue.increment(1),
          'lessonsCompleted': FieldValue.increment(1),
          'dailyKanjiProgress': FieldValue.increment(1),
        });
      }

      await userRef.update(updates);

      // Update detailed kanji progress with learning status
      final currentData = kanjiProgressDoc.data() ?? {};
      final practiceCount = currentData['reviewCount'] ?? 0;
      final correctCount = currentData['correctCount'] ?? 0;

      await userRef.collection('kanji_progress').doc(kanji.character).set({
        'character': kanji.character,
        'meaning': kanji.meaning,
        'level': kanji.level,
        'isLearned': true, // Mark as learned
        'learnedDate': isAlreadyLearned ? currentData['learnedDate'] : FieldValue.serverTimestamp(),
        'lastReviewed': FieldValue.serverTimestamp(),
        'reviewCount': practiceCount,
        'correctCount': correctCount,
        'masteryLevel': KanjiMasteryData.calculateMastery(true, practiceCount, correctCount),
        'source': 'learning', // Track where it was learned
      }, SetOptions(merge: true));

      // Update local state
      if (!isAlreadyLearned) {
        setState(() {
          _dailyProgress++;
        });
      }

      await _updateStudyStreak(user.uid);

    } catch (e) {
      debugPrint('Error marking kanji as learned: $e');
    }
  }
  // 4. ADD study streak update method
  Future<void> _updateStudyStreak(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      final lastStudyTimestamp = userData['lastStudyDate'] as Timestamp?;
      final currentStreak = userData['studyStreak'] ?? 0;

      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);

      if (lastStudyTimestamp != null) {
        final lastStudyDate = lastStudyTimestamp.toDate();
        final lastStudyDay = DateTime(lastStudyDate.year, lastStudyDate.month, lastStudyDate.day);
        final daysDifference = today.difference(lastStudyDay).inDays;

        // Only update streak if this is the first study session today
        if (daysDifference >= 1) {
          int newStreak;
          if (daysDifference == 1) {
            // Consecutive day - increment streak
            newStreak = currentStreak + 1;
          } else {
            // Missed days - reset streak to 1
            newStreak = 1;
          }

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'studyStreak': newStreak,
            'lastStudyDate': FieldValue.serverTimestamp(),
          });

          // Update local state
          setState(() {
            _streak = newStreak;
          });
        }
      } else {
        // First time studying - set streak to 1
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'studyStreak': 1,
          'lastStudyDate': FieldValue.serverTimestamp(),
        });

        setState(() {
          _streak = 1;
        });
      }
    } catch (e) {
      debugPrint('Error updating study streak: $e');
    }
  }
  // 5. ADD progress feedback method
  void _showProgressFeedback() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.school_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Kanji learned! Progress: $_dailyProgress/10 today',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: _accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _previousKanji() {
    if (_currentKanjiIndex > 0) {
      setState(() {
        _currentKanjiIndex--;
        _isBookmarked = false;
      });
      _cardFlipController.reset();
    }
  }

// 2. REPLACE the _nextKanji method with this:
  void _nextKanji() {
    if (_currentKanjiIndex < _currentKanjiList.length - 1) {
      // Mark current kanji as learned before moving to next
      if (_currentKanjiList.isNotEmpty) {
        final currentKanji = _currentKanjiList[_currentKanjiIndex];
        _markKanjiAsLearned(currentKanji);
      }

      setState(() {
        _currentKanjiIndex++;
        _isBookmarked = false;
        _dailyProgress++; // Update local progress
      });
      _cardFlipController.reset();

      // Show achievement progress feedback
      _showProgressFeedback();
    }
  }
// 9. ADD method to load real-time achievement progress
  Future<void> _loadAchievementProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.exists && mounted) {
        final data = userData.data()!;

        // Check for recent achievements
        final totalKanjiLearned = data['totalKanjiLearned'] ?? 0;
        final lessonsCompleted = data['lessonsCompleted'] ?? 0;

        // Show achievement notifications
        if (totalKanjiLearned == 1) {
          _showAchievementUnlocked('First Kanji', 'You learned your first kanji! 🈶');
        } else if (totalKanjiLearned == 50) {
          _showAchievementUnlocked('Kanji Apprentice', 'You learned 50 kanji! 📝');
        } else if (lessonsCompleted == 1) {
          _showAchievementUnlocked('First Step', 'You completed your first lesson! 👶');
        }
      }
    } catch (e) {
      debugPrint('Error loading achievement progress: $e');
    }
  }
  // 10. ADD achievement notification method
  void _showAchievementUnlocked(String title, String description) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.emoji_events, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Achievement Unlocked!',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '$title: $description',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFFFD700), // Gold color for achievements
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _startKanjiQuiz() {
    // Navigate to the practice screen using Navigator.push instead of named route
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KanjiPracticeScreen(),
      ),
    );
  }

}

class KanjiData {
  final String character;
  final String meaning;
  final List<String> readings;
  final int strokeCount;
  final List<String> examples;
  final String mnemonic;
  final String level;

  KanjiData({
    required this.character,
    required this.meaning,
    required this.readings,
    required this.strokeCount,
    required this.examples,
    required this.mnemonic,
    required this.level,
  });
}
class KanjiMasteryData {
  final String character;
  final bool isLearned;
  final bool isPracticed;
  final int practiceCount;
  final int correctCount;
  final DateTime? lastReviewed;
  final double masteryLevel; // 0.0 to 1.0

  KanjiMasteryData({
    required this.character,
    this.isLearned = false,
    this.isPracticed = false,
    this.practiceCount = 0,
    this.correctCount = 0,
    this.lastReviewed,
    this.masteryLevel = 0.0,
  });
  static double calculateMastery(bool isLearned, int practiceCount, int correctCount) {
    if (!isLearned) return 0.0;
    if (practiceCount == 0) return 0.3; // Just learned, not practiced

    double accuracy = practiceCount > 0 ? correctCount / practiceCount : 0.0;
    double practiceBonus = (practiceCount * 0.1).clamp(0.0, 0.4);

    return (0.3 + (accuracy * 0.5) + practiceBonus).clamp(0.0, 1.0);
  }
}

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:math' as math;
//
// class KanjiLearningScreen extends StatefulWidget {
//   const KanjiLearningScreen({super.key});
//
//   @override
//   State<KanjiLearningScreen> createState() => _KanjiLearningScreenState();
// }
//
// class _KanjiLearningScreenState extends State<KanjiLearningScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _slideController;
//   late AnimationController _rotationController;
//   late AnimationController _pulseController;
//   late AnimationController _cardFlipController;
//
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _rotationAnimation;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _cardFlipAnimation;
//
//   int _currentKanjiIndex = 0;
//   bool _showMeaning = false;
//   bool _isBookmarked = false;
//   String _selectedLevel = 'N5';
//   int _streak = 0;
//   int _dailyProgress = 0;
//
//   // Complete Kanji database organized by JLPT levels
//   final Map<String, List<KanjiData>> _kanjiDatabase = {
//     'N5': [
//       KanjiData(
//         character: '学',
//         meaning: 'Learn, Study',
//         readings: ['がく', 'まな', 'GAKU', 'mana'],
//         strokeCount: 8,
//         examples: ['学校 (gakkou) - school', '学ぶ (manabu) - to learn'],
//         mnemonic: 'A child (子) under a roof learning - perfect place to study!',
//         level: 'N5',
//       ),
//       KanjiData(
//         character: '友',
//         meaning: 'Friend',
//         readings: ['とも', 'ゆう', 'tomo', 'YUU'],
//         strokeCount: 4,
//         examples: ['友達 (tomodachi) - friend', '友人 (yuujin) - friend (formal)'],
//         mnemonic: 'Two hands reaching out to each other - making friends!',
//         level: 'N5',
//       ),
//       KanjiData(
//         character: '日',
//         meaning: 'Sun, Day',
//         readings: ['ひ', 'にち', 'hi', 'NICHI'],
//         strokeCount: 4,
//         examples: ['今日 (kyou) - today', '日本 (nihon) - Japan'],
//         mnemonic: 'Picture of the sun in the sky!',
//         level: 'N5',
//       ),
//       KanjiData(
//         character: '本',
//         meaning: 'Book, Origin',
//         readings: ['ほん', 'もと', 'HON', 'moto'],
//         strokeCount: 5,
//         examples: ['本 (hon) - book', '日本 (nihon) - Japan'],
//         mnemonic: 'A tree (木) with roots, the origin of all things!',
//         level: 'N5',
//       ),
//       KanjiData(
//         character: '人',
//         meaning: 'Person, Human',
//         readings: ['ひと', 'じん', 'hito', 'JIN'],
//         strokeCount: 2,
//         examples: ['人 (hito) - person', '日本人 (nihonjin) - Japanese person'],
//         mnemonic: 'Looks like a person walking with two legs!',
//         level: 'N5',
//       ),
//     ],
//     'N4': [
//       KanjiData(
//         character: '愛',
//         meaning: 'Love, Affection',
//         readings: ['あい', 'AI'],
//         strokeCount: 13,
//         examples: ['愛する (aisuru) - to love', '愛情 (aijou) - affection'],
//         mnemonic: 'A heart (心) with a hand reaching out and legs walking - showing love through action!',
//         level: 'N4',
//       ),
//       KanjiData(
//         character: '心',
//         meaning: 'Heart, Mind, Spirit',
//         readings: ['こころ', 'しん', 'kokoro', 'SHIN'],
//         strokeCount: 4,
//         examples: ['心配 (shinpai) - worry', '安心 (anshin) - peace of mind'],
//         mnemonic: 'Looks like a heart with three chambers pumping emotions!',
//         level: 'N4',
//       ),
//       KanjiData(
//         character: '思',
//         meaning: 'Think, Thought',
//         readings: ['おも', 'し', 'omo', 'SHI'],
//         strokeCount: 9,
//         examples: ['思う (omou) - to think', '思考 (shikou) - thinking'],
//         mnemonic: 'A field (田) over a heart (心) - thinking with your heart!',
//         level: 'N4',
//       ),
//     ],
//     'N3': [
//       KanjiData(
//         character: '夢',
//         meaning: 'Dream, Vision',
//         readings: ['ゆめ', 'む', 'yume', 'MU'],
//         strokeCount: 13,
//         examples: ['夢見る (yume miru) - to dream', '夢想 (musou) - reverie'],
//         mnemonic: 'Grass (艹) over eyes (目) in the evening (夕) - dreaming under the stars!',
//         level: 'N3',
//       ),
//       KanjiData(
//         character: '実',
//         meaning: 'Reality, Truth, Fruit',
//         readings: ['み', 'じつ', 'mi', 'JITSU'],
//         strokeCount: 8,
//         examples: ['実際 (jissai) - reality', '果実 (kajitsu) - fruit'],
//         mnemonic: 'A house (宀) full (八) of real things!',
//         level: 'N3',
//       ),
//     ],
//     'N2': [
//       KanjiData(
//         character: '認',
//         meaning: 'Recognize, Acknowledge',
//         readings: ['みと', 'にん', 'mito', 'NIN'],
//         strokeCount: 14,
//         examples: ['認める (mitomeru) - to recognize', '確認 (kakunin) - confirmation'],
//         mnemonic: 'Words (言) and patience (忍) to truly recognize something!',
//         level: 'N2',
//       ),
//     ],
//     'N1': [
//       KanjiData(
//         character: '憂',
//         meaning: 'Worry, Melancholy',
//         readings: ['うれ', 'ゆう', 'ure', 'YUU'],
//         strokeCount: 15,
//         examples: ['憂鬱 (yuuutsu) - depression', '憂慮 (yuuryo) - concern'],
//         mnemonic: 'A head (頁) with a worried heart (心) underneath!',
//         level: 'N1',
//       ),
//     ],
//   };
//
//   // Get filtered kanji list based on selected level
//   List<KanjiData> get _currentKanjiList => _kanjiDatabase[_selectedLevel] ?? [];
//
//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//     _loadUserProgress();
//   }
//
//   void _initAnimations() {
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//
//     _rotationController = AnimationController(
//       duration: const Duration(seconds: 20),
//       vsync: this,
//     );
//
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
//
//     _cardFlipController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//
//     // Fixed slide animation to use Offset instead of double
//     _slideAnimation = Tween<Offset>(
//         begin: const Offset(0.0, -1.0),
//         end: Offset.zero
//     ).animate(
//       CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
//     );
//
//     _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
//       CurvedAnimation(parent: _rotationController, curve: Curves.linear),
//     );
//
//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//
//     _cardFlipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _cardFlipController, curve: Curves.easeInOut),
//     );
//
//     _slideController.forward();
//     _rotationController.repeat();
//     _pulseController.repeat(reverse: true);
//   }
//
//   Future<void> _loadUserProgress() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         final userData = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();
//
//         if (userData.exists && mounted) {
//           final data = userData.data();
//           if (data != null) {
//             setState(() {
//               _streak = data['kanjiStreak'] ?? 0;
//               _dailyProgress = data['dailyKanjiProgress'] ?? 0;
//               _selectedLevel = data['jlptLevel'] ?? 'N5';
//             });
//           }
//         }
//       } catch (e) {
//         debugPrint('Error loading progress: $e');
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _slideController.dispose();
//     _rotationController.dispose();
//     _pulseController.dispose();
//     _cardFlipController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isSmallScreen = size.width < 375;
//
//     if (_currentKanjiList.isEmpty) {
//       return _buildEmptyState(size);
//     }
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1117),
//       body: SafeArea(
//         child: CustomScrollView(
//           physics: const BouncingScrollPhysics(),
//           slivers: [
//             SliverPadding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isSmallScreen ? 12 : 16,
//                 vertical: 8,
//               ),
//               sliver: SliverToBoxAdapter(
//                 child: _buildHeader(size, isSmallScreen),
//               ),
//             ),
//             SliverPadding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isSmallScreen ? 12 : 16,
//               ),
//               sliver: SliverToBoxAdapter(
//                 child: _buildProgressSection(size, isSmallScreen),
//               ),
//             ),
//             SliverPadding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isSmallScreen ? 12 : 16,
//                 vertical: 8,
//               ),
//               sliver: SliverToBoxAdapter(
//                 child: _buildKanjiCard(size, isSmallScreen),
//               ),
//             ),
//             SliverPadding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isSmallScreen ? 12 : 16,
//                 vertical: 8,
//               ),
//               sliver: SliverToBoxAdapter(
//                 child: _buildActionButtons(size, isSmallScreen),
//               ),
//             ),
//             SliverPadding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isSmallScreen ? 12 : 16,
//                 vertical: 8,
//               ),
//               sliver: SliverToBoxAdapter(
//                 child: _buildNavigationButtons(size, isSmallScreen),
//               ),
//             ),
//             const SliverPadding(
//               padding: EdgeInsets.only(bottom: 80),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: AnimatedBuilder(
//         animation: _pulseAnimation,
//         builder: (context, child) {
//           return Transform.scale(
//             scale: _pulseAnimation.value,
//             child: FloatingActionButton(
//               onPressed: _startKanjiQuiz,
//               backgroundColor: const Color(0xFF10B981),
//               child: Icon(
//                 Icons.quiz,
//                 color: Colors.white,
//                 size: isSmallScreen ? 24 : 28,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildEmptyState(Size size) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1117),
//       body: SafeArea(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   '📚',
//                   style: TextStyle(fontSize: size.width * 0.2),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   'No Kanji Available',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   'No kanji found for $_selectedLevel level.\nTry selecting a different level.',
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     color: Colors.white.withOpacity(0.7),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       _selectedLevel = 'N5';
//                       _currentKanjiIndex = 0;
//                     });
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF8B5CF6),
//                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text(
//                     'Go to N5',
//                     style: GoogleFonts.poppins(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(Size size, bool isSmallScreen) {
//     return SlideTransition(
//       position: _slideAnimation,
//       child: Row(
//         children: [
//           // Back Button
//           IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           const SizedBox(width: 12),
//           // Title
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Learn Kanji',
//                   style: GoogleFonts.poppins(
//                     fontSize: isSmallScreen ? 20 : 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Text(
//                   'Master Japanese Characters',
//                   style: GoogleFonts.poppins(
//                     fontSize: isSmallScreen ? 12 : 14,
//                     color: Colors.white.withOpacity(0.7),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Level Selector
//           _buildLevelSelector(isSmallScreen),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLevelSelector(bool isSmallScreen) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
//         ),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: _selectedLevel,
//           icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
//           dropdownColor: const Color(0xFF1C2128),
//           style: GoogleFonts.poppins(
//             fontSize: isSmallScreen ? 14 : 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//           items: ['N5', 'N4', 'N3', 'N2', 'N1'].map((level) {
//             return DropdownMenuItem(
//               value: level,
//               child: Text(level),
//             );
//           }).toList(),
//           onChanged: (value) {
//             if (value != null) {
//               setState(() {
//                 _selectedLevel = value;
//                 _currentKanjiIndex = 0;
//                 _cardFlipController.reset();
//               });
//             }
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProgressSection(Size size, bool isSmallScreen) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.1),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _buildProgressItem(
//             '🔥',
//             'Streak',
//             '$_streak days',
//             const Color(0xFFFF6B35),
//             isSmallScreen,
//           ),
//           _buildProgressItem(
//             '📈',
//             'Today',
//             '$_dailyProgress/10',
//             const Color(0xFF10B981),
//             isSmallScreen,
//           ),
//           _buildProgressItem(
//             '🎯',
//             'Level',
//             _selectedLevel,
//             const Color(0xFF8B5CF6),
//             isSmallScreen,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildProgressItem(
//       String emoji,
//       String label,
//       String value,
//       Color color,
//       bool isSmallScreen,
//       ) {
//     return Flexible(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             emoji,
//             style: const TextStyle(fontSize: 24),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: isSmallScreen ? 14 : 16,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: isSmallScreen ? 10 : 12,
//               color: Colors.white.withOpacity(0.7),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildKanjiCard(Size size, bool isSmallScreen) {
//     if (_currentKanjiList.isEmpty || _currentKanjiIndex >= _currentKanjiList.length) {
//       return const SizedBox.shrink();
//     }
//
//     final currentKanji = _currentKanjiList[_currentKanjiIndex];
//
//     return AnimatedBuilder(
//       animation: _cardFlipAnimation,
//       builder: (context, child) {
//         final isShowingFront = _cardFlipAnimation.value < 0.5;
//         return GestureDetector(
//           onTap: _flipCard,
//           child: Transform(
//             alignment: Alignment.center,
//             transform: Matrix4.identity()
//               ..setEntry(3, 2, 0.001)
//               ..rotateY(_cardFlipAnimation.value * math.pi),
//             child: Container(
//               width: double.infinity,
//               constraints: BoxConstraints(
//                 minHeight: size.height * 0.4,
//                 maxHeight: size.height * 0.6,
//               ),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: isShowingFront
//                       ? [
//                     const Color(0xFF8B5CF6).withOpacity(0.1),
//                     const Color(0xFFEC4899).withOpacity(0.1),
//                   ]
//                       : [
//                     const Color(0xFF10B981).withOpacity(0.1),
//                     const Color(0xFF06B6D4).withOpacity(0.1),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(24),
//                 border: Border.all(
//                   color: isShowingFront
//                       ? const Color(0xFF8B5CF6).withOpacity(0.3)
//                       : const Color(0xFF10B981).withOpacity(0.3),
//                   width: 2,
//                 ),
//               ),
//               child: isShowingFront
//                   ? _buildKanjiFront(currentKanji, size, isSmallScreen)
//                   : Transform(
//                 alignment: Alignment.center,
//                 transform: Matrix4.identity()..rotateY(math.pi),
//                 child: _buildKanjiBack(currentKanji, size, isSmallScreen),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildKanjiFront(KanjiData kanji, Size size, bool isSmallScreen) {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Main Kanji Character
//           Container(
//             width: size.width * 0.4,
//             height: size.width * 0.4,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: RadialGradient(
//                 colors: [
//                   Colors.white.withOpacity(0.1),
//                   Colors.transparent,
//                 ],
//               ),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.2),
//                 width: 2,
//               ),
//             ),
//             child: Center(
//               child: Text(
//                 kanji.character,
//                 style: GoogleFonts.notoSansJp(
//                   fontSize: isSmallScreen ? 60 : 80,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Stroke Count
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               color: const Color(0xFF8B5CF6).withOpacity(0.2),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               '${kanji.strokeCount} strokes',
//               style: GoogleFonts.poppins(
//                 fontSize: isSmallScreen ? 12 : 14,
//                 color: Colors.white.withOpacity(0.9),
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           // Tap hint
//           Text(
//             'Tap to see meaning & examples',
//             style: GoogleFonts.poppins(
//               fontSize: isSmallScreen ? 12 : 14,
//               color: Colors.white.withOpacity(0.6),
//               fontStyle: FontStyle.italic,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildKanjiBack(KanjiData kanji, Size size, bool isSmallScreen) {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Meaning
//             Center(
//               child: Text(
//                 kanji.meaning,
//                 style: GoogleFonts.poppins(
//                   fontSize: isSmallScreen ? 20 : 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Readings
//             _buildInfoSection(
//               'Readings',
//               kanji.readings.join(', '),
//               Icons.record_voice_over,
//               isSmallScreen,
//             ),
//             const SizedBox(height: 12),
//             // Examples
//             _buildInfoSection(
//               'Examples',
//               kanji.examples.join('\n'),
//               Icons.format_list_bulleted,
//               isSmallScreen,
//             ),
//             const SizedBox(height: 12),
//             // Mnemonic
//             _buildInfoSection(
//               'Memory Tip',
//               kanji.mnemonic,
//               Icons.lightbulb,
//               isSmallScreen,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoSection(
//       String title,
//       String content,
//       IconData icon,
//       bool isSmallScreen,
//       ) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
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
//               Icon(icon, color: const Color(0xFF10B981), size: 20),
//               const SizedBox(width: 8),
//               Text(
//                 title,
//                 style: GoogleFonts.poppins(
//                   fontSize: isSmallScreen ? 14 : 16,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFF10B981),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             content,
//             style: GoogleFonts.poppins(
//               fontSize: isSmallScreen ? 12 : 14,
//               color: Colors.white.withOpacity(0.8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButtons(Size size, bool isSmallScreen) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         _buildActionButton(
//           icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
//           label: 'Bookmark',
//           color: const Color(0xFFF59E0B),
//           onTap: _toggleBookmark,
//           isSmallScreen: isSmallScreen,
//         ),
//         _buildActionButton(
//           icon: Icons.volume_up,
//           label: 'Pronounce',
//           color: const Color(0xFF06B6D4),
//           onTap: _pronounceKanji,
//           isSmallScreen: isSmallScreen,
//         ),
//         _buildActionButton(
//           icon: Icons.edit,
//           label: 'Practice',
//           color: const Color(0xFF10B981),
//           onTap: _practiceWriting,
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
//     required bool isSmallScreen,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: color.withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: color, size: 24),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: GoogleFonts.poppins(
//                 fontSize: isSmallScreen ? 10 : 12,
//                 color: Colors.white.withOpacity(0.8),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNavigationButtons(Size size, bool isSmallScreen) {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildNavButton(
//             icon: Icons.arrow_back_ios,
//             label: 'Previous',
//             onTap: _previousKanji,
//             enabled: _currentKanjiIndex > 0,
//             isSmallScreen: isSmallScreen,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: BoxDecoration(
//             color: const Color(0xFF8B5CF6).withOpacity(0.2),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             '${_currentKanjiIndex + 1} / ${_currentKanjiList.length}',
//             style: GoogleFonts.poppins(
//               fontSize: isSmallScreen ? 14 : 16,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _buildNavButton(
//             icon: Icons.arrow_forward_ios,
//             label: 'Next',
//             onTap: _nextKanji,
//             enabled: _currentKanjiIndex < _currentKanjiList.length - 1,
//             isSmallScreen: isSmallScreen,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildNavButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     required bool enabled,
//     required bool isSmallScreen,
//   }) {
//     return GestureDetector(
//       onTap: enabled ? onTap : null,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: enabled
//               ? const Color(0xFF8B5CF6).withOpacity(0.1)
//               : Colors.grey.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: enabled
//                 ? const Color(0xFF8B5CF6).withOpacity(0.3)
//                 : Colors.grey.withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (icon == Icons.arrow_back_ios) ...[
//               Icon(
//                 icon,
//                 color: enabled ? Colors.white : Colors.grey,
//                 size: 18,
//               ),
//               const SizedBox(width: 8),
//             ],
//             Text(
//               label,
//               style: GoogleFonts.poppins(
//                 fontSize: isSmallScreen ? 12 : 14,
//                 color: enabled ? Colors.white : Colors.grey,
//               ),
//             ),
//             if (icon == Icons.arrow_forward_ios) ...[
//               const SizedBox(width: 8),
//               Icon(
//                 icon,
//                 color: enabled ? Colors.white : Colors.grey,
//                 size: 18,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _flipCard() {
//     if (_cardFlipController.isCompleted) {
//       _cardFlipController.reverse();
//     } else {
//       _cardFlipController.forward();
//     }
//   }
//
//   void _toggleBookmark() {
//     setState(() {
//       _isBookmarked = !_isBookmarked;
//     });
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(_isBookmarked ? 'Bookmarked!' : 'Removed bookmark'),
//           backgroundColor: const Color(0xFFF59E0B),
//           duration: const Duration(seconds: 1),
//         ),
//       );
//     }
//   }
//
//   void _pronounceKanji() {
//     if (_currentKanjiList.isNotEmpty && _currentKanjiIndex < _currentKanjiList.length) {
//       final currentKanji = _currentKanjiList[_currentKanjiIndex];
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Pronouncing: ${currentKanji.readings.isNotEmpty ? currentKanji.readings.first : currentKanji.character}'),
//             backgroundColor: const Color(0xFF06B6D4),
//             duration: const Duration(seconds: 1),
//           ),
//         );
//       }
//     }
//   }
//
//   void _practiceWriting() {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Writing practice coming soon!'),
//           backgroundColor: Color(0xFF10B981),
//           duration: Duration(seconds: 1),
//         ),
//       );
//     }
//   }
//
//   void _previousKanji() {
//     if (_currentKanjiIndex > 0) {
//       setState(() {
//         _currentKanjiIndex--;
//         _isBookmarked = false;
//       });
//       _cardFlipController.reset();
//     }
//   }
//
//   void _nextKanji() {
//     if (_currentKanjiIndex < _currentKanjiList.length - 1) {
//       setState(() {
//         _currentKanjiIndex++;
//         _isBookmarked = false;
//       });
//       _cardFlipController.reset();
//     }
//   }
//
//   void _startKanjiQuiz() {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Starting $_selectedLevel Kanji Quiz!'),
//           backgroundColor: const Color(0xFF10B981),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }
// }
//
// class KanjiData {
//   final String character;
//   final String meaning;
//   final List<String> readings;
//   final int strokeCount;
//   final List<String> examples;
//   final String mnemonic;
//   final String level;
//
//   KanjiData({
//     required this.character,
//     required this.meaning,
//     required this.readings,
//     required this.strokeCount,
//     required this.examples,
//     required this.mnemonic,
//     required this.level,
//   });
// }
//
