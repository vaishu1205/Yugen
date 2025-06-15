import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

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

  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _cardFlipAnimation;

  int _currentKanjiIndex = 0;
  bool _showMeaning = false;
  bool _isBookmarked = false;
  String _selectedLevel = 'N5';
  int _streak = 0;
  int _dailyProgress = 0;

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
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _cardFlipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Fixed slide animation to use Offset instead of double
    _slideAnimation = Tween<Offset>(
        begin: const Offset(0.0, -1.0),
        end: Offset.zero
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _cardFlipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardFlipController, curve: Curves.easeInOut),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;

    if (_currentKanjiList.isEmpty) {
      return _buildEmptyState(size);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: 8,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildHeader(size, isSmallScreen),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildProgressSection(size, isSmallScreen),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: 8,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildKanjiCard(size, isSmallScreen),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: 8,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildActionButtons(size, isSmallScreen),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: 8,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildNavigationButtons(size, isSmallScreen),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: FloatingActionButton(
              onPressed: _startKanjiQuiz,
              backgroundColor: const Color(0xFF10B981),
              child: Icon(
                Icons.quiz,
                color: Colors.white,
                size: isSmallScreen ? 24 : 28,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(Size size) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '📚',
                  style: TextStyle(fontSize: size.width * 0.2),
                ),
                const SizedBox(height: 20),
                Text(
                  'No Kanji Available',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'No kanji found for $_selectedLevel level.\nTry selecting a different level.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedLevel = 'N5';
                      _currentKanjiIndex = 0;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size, bool isSmallScreen) {
    return SlideTransition(
      position: _slideAnimation,
      child: Row(
        children: [
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learn Kanji',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Master Japanese Characters',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Level Selector
          _buildLevelSelector(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildLevelSelector(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLevel,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          dropdownColor: const Color(0xFF1C2128),
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          items: ['N5', 'N4', 'N3', 'N2', 'N1'].map((level) {
            return DropdownMenuItem(
              value: level,
              child: Text(level),
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

  Widget _buildProgressSection(Size size, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
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
            const Color(0xFFFF6B35),
            isSmallScreen,
          ),
          _buildProgressItem(
            '📈',
            'Today',
            '$_dailyProgress/10',
            const Color(0xFF10B981),
            isSmallScreen,
          ),
          _buildProgressItem(
            '🎯',
            'Level',
            _selectedLevel,
            const Color(0xFF8B5CF6),
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
      String emoji,
      String label,
      String value,
      Color color,
      bool isSmallScreen,
      ) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 10 : 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanjiCard(Size size, bool isSmallScreen) {
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
                minHeight: size.height * 0.4,
                maxHeight: size.height * 0.6,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isShowingFront
                      ? [
                    const Color(0xFF8B5CF6).withOpacity(0.1),
                    const Color(0xFFEC4899).withOpacity(0.1),
                  ]
                      : [
                    const Color(0xFF10B981).withOpacity(0.1),
                    const Color(0xFF06B6D4).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isShowingFront
                      ? const Color(0xFF8B5CF6).withOpacity(0.3)
                      : const Color(0xFF10B981).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: isShowingFront
                  ? _buildKanjiFront(currentKanji, size, isSmallScreen)
                  : Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(math.pi),
                child: _buildKanjiBack(currentKanji, size, isSmallScreen),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKanjiFront(KanjiData kanji, Size size, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main Kanji Character
          Container(
            width: size.width * 0.4,
            height: size.width * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                kanji.character,
                style: GoogleFonts.notoSansJp(
                  fontSize: isSmallScreen ? 60 : 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Stroke Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${kanji.strokeCount} strokes',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Tap hint
          Text(
            'Tap to see meaning & examples',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.white.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanjiBack(KanjiData kanji, Size size, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meaning
            Center(
              child: Text(
                kanji.meaning,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Readings
            _buildInfoSection(
              'Readings',
              kanji.readings.join(', '),
              Icons.record_voice_over,
              isSmallScreen,
            ),
            const SizedBox(height: 12),
            // Examples
            _buildInfoSection(
              'Examples',
              kanji.examples.join('\n'),
              Icons.format_list_bulleted,
              isSmallScreen,
            ),
            const SizedBox(height: 12),
            // Mnemonic
            _buildInfoSection(
              'Memory Tip',
              kanji.mnemonic,
              Icons.lightbulb,
              isSmallScreen,
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
      bool isSmallScreen,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
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
              Icon(icon, color: const Color(0xFF10B981), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Size size, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          label: 'Bookmark',
          color: const Color(0xFFF59E0B),
          onTap: _toggleBookmark,
          isSmallScreen: isSmallScreen,
        ),
        _buildActionButton(
          icon: Icons.volume_up,
          label: 'Pronounce',
          color: const Color(0xFF06B6D4),
          onTap: _pronounceKanji,
          isSmallScreen: isSmallScreen,
        ),
        _buildActionButton(
          icon: Icons.edit,
          label: 'Practice',
          color: const Color(0xFF10B981),
          onTap: _practiceWriting,
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
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 10 : 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(Size size, bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: _buildNavButton(
            icon: Icons.arrow_back_ios,
            label: 'Previous',
            onTap: _previousKanji,
            enabled: _currentKanjiIndex > 0,
            isSmallScreen: isSmallScreen,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_currentKanjiIndex + 1} / ${_currentKanjiList.length}',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNavButton(
            icon: Icons.arrow_forward_ios,
            label: 'Next',
            onTap: _nextKanji,
            enabled: _currentKanjiIndex < _currentKanjiList.length - 1,
            isSmallScreen: isSmallScreen,
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool enabled,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF8B5CF6).withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled
                ? const Color(0xFF8B5CF6).withOpacity(0.3)
                : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon == Icons.arrow_back_ios) ...[
              Icon(
                icon,
                color: enabled ? Colors.white : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 12 : 14,
                color: enabled ? Colors.white : Colors.grey,
              ),
            ),
            if (icon == Icons.arrow_forward_ios) ...[
              const SizedBox(width: 8),
              Icon(
                icon,
                color: enabled ? Colors.white : Colors.grey,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _flipCard() {
    if (_cardFlipController.isCompleted) {
      _cardFlipController.reverse();
    } else {
      _cardFlipController.forward();
    }
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBookmarked ? 'Bookmarked!' : 'Removed bookmark'),
          backgroundColor: const Color(0xFFF59E0B),
          duration: const Duration(seconds: 1),
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
            content: Text('Pronouncing: ${currentKanji.readings.isNotEmpty ? currentKanji.readings.first : currentKanji.character}'),
            backgroundColor: const Color(0xFF06B6D4),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _practiceWriting() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Writing practice coming soon!'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 1),
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

  void _nextKanji() {
    if (_currentKanjiIndex < _currentKanjiList.length - 1) {
      setState(() {
        _currentKanjiIndex++;
        _isBookmarked = false;
      });
      _cardFlipController.reset();
    }
  }

  void _startKanjiQuiz() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Starting $_selectedLevel Kanji Quiz!'),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
//   late Animation<double> _slideAnimation;
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
//   final List<KanjiData> _kanjiList = [
//     KanjiData(
//       character: '愛',
//       meaning: 'Love, Affection',
//       readings: ['あい', 'AI'],
//       strokeCount: 13,
//       examples: ['愛する (aisuru) - to love', '愛情 (aijou) - affection'],
//       mnemonic: 'A heart (心) with a hand reaching out and legs walking - showing love through action!',
//       level: 'N4',
//     ),
//     KanjiData(
//       character: '学',
//       meaning: 'Learn, Study',
//       readings: ['がく', 'まな', 'GAKU', 'mana'],
//       strokeCount: 8,
//       examples: ['学校 (gakkou) - school', '学ぶ (manabu) - to learn'],
//       mnemonic: 'A child (子) under a roof learning - perfect place to study!',
//       level: 'N5',
//     ),
//     KanjiData(
//       character: '友',
//       meaning: 'Friend',
//       readings: ['とも', 'ゆう', 'tomo', 'YUU'],
//       strokeCount: 4,
//       examples: ['友達 (tomodachi) - friend', '友人 (yuujin) - friend (formal)'],
//       mnemonic: 'Two hands reaching out to each other - making friends!',
//       level: 'N5',
//     ),
//     KanjiData(
//       character: '夢',
//       meaning: 'Dream, Vision',
//       readings: ['ゆめ', 'む', 'yume', 'MU'],
//       strokeCount: 13,
//       examples: ['夢見る (yume miru) - to dream', '夢想 (musou) - reverie'],
//       mnemonic: 'Grass (艹) over eyes (目) in the evening (夕) - dreaming under the stars!',
//       level: 'N3',
//     ),
//     KanjiData(
//       character: '心',
//       meaning: 'Heart, Mind, Spirit',
//       readings: ['こころ', 'しん', 'kokoro', 'SHIN'],
//       strokeCount: 4,
//       examples: ['心配 (shinpai) - worry', '安心 (anshin) - peace of mind'],
//       mnemonic: 'Looks like a heart with three chambers pumping emotions!',
//       level: 'N4',
//     ),
//   ];
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
//     _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
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
//           setState(() {
//             _streak = userData.data()?['kanjiStreak'] ?? 0;
//             _dailyProgress = userData.data()?['dailyKanjiProgress'] ?? 0;
//             _selectedLevel = userData.data()?['jlptLevel'] ?? 'N5';
//           });
//         }
//       } catch (e) {
//         print('Error loading progress: $e');
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
//     final isSmallScreen = size.width < 360;
//     final currentKanji = _kanjiList[_currentKanjiIndex];
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
//               Color(0xFFEC4899),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header
//               _buildHeader(size, isSmallScreen),
//
//               // Progress Section
//               _buildProgressSection(size, isSmallScreen),
//
//               // Main Kanji Card
//               Expanded(
//                 child: SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   child: Padding(
//                     padding: EdgeInsets.all(size.width * 0.04),
//                     child: Column(
//                       children: [
//                         // Kanji Display Card
//                         _buildKanjiCard(currentKanji, size, isSmallScreen),
//
//                         SizedBox(height: size.height * 0.03),
//
//                         // Action Buttons
//                         _buildActionButtons(size, isSmallScreen),
//
//                         SizedBox(height: size.height * 0.02),
//
//                         // Navigation Buttons
//                         _buildNavigationButtons(size, isSmallScreen),
//
//                         SizedBox(height: size.height * 0.02),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
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
//               child: const Icon(Icons.quiz, color: Colors.white),
//             ),
//           );
//         },
//       ),
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
//                     'Learn Kanji',
//                     style: GoogleFonts.poppins(
//                       fontSize: isSmallScreen ? size.width * 0.055 : size.width * 0.06,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   Text(
//                     'Master Japanese Characters',
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.03,
//                       color: Colors.white.withOpacity(0.7),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Level Selector
//             _buildLevelSelector(size, isSmallScreen),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLevelSelector(Size size, bool isSmallScreen) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: size.width * 0.03,
//         vertical: size.height * 0.01,
//       ),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF8B5CF6).withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: _selectedLevel,
//           icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
//           dropdownColor: const Color(0xFF1C2128),
//           style: GoogleFonts.poppins(
//             fontSize: size.width * 0.035,
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
//       margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
//       padding: EdgeInsets.all(size.width * 0.04),
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
//             size,
//             isSmallScreen,
//           ),
//           _buildProgressItem(
//             '📈',
//             'Today',
//             '$_dailyProgress/10',
//             const Color(0xFF10B981),
//             size,
//             isSmallScreen,
//           ),
//           _buildProgressItem(
//             '🎯',
//             'Level',
//             _selectedLevel,
//             const Color(0xFF8B5CF6),
//             size,
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
//       Size size,
//       bool isSmallScreen,
//       ) {
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
//             fontSize: isSmallScreen ? size.width * 0.035 : size.width * 0.04,
//             fontWeight: FontWeight.bold,
//             color: color,
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
//   Widget _buildKanjiCard(KanjiData kanji, Size size, bool isSmallScreen) {
//     return AnimatedBuilder(
//       animation: _cardFlipAnimation,
//       builder: (context, child) {
//         final isShowingFront = _cardFlipAnimation.value < 0.5;
//         return Transform(
//           alignment: Alignment.center,
//           transform: Matrix4.identity()
//             ..setEntry(3, 2, 0.001)
//             ..rotateY(_cardFlipAnimation.value * math.pi),
//           child: GestureDetector(
//             onTap: _flipCard,
//             child: Container(
//               width: size.width * 0.85,
//               height: size.height * 0.5,
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
//                 boxShadow: [
//                   BoxShadow(
//                     color: (isShowingFront
//                         ? const Color(0xFF8B5CF6)
//                         : const Color(0xFF10B981))
//                         .withOpacity(0.2),
//                     blurRadius: 20,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: isShowingFront
//                   ? _buildKanjiFront(kanji, size, isSmallScreen)
//                   : Transform(
//                 alignment: Alignment.center,
//                 transform: Matrix4.identity()..rotateY(math.pi),
//                 child: _buildKanjiBack(kanji, size, isSmallScreen),
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
//       padding: EdgeInsets.all(size.width * 0.06),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Main Kanji Character
//           AnimatedBuilder(
//             animation: _rotationAnimation,
//             builder: (context, child) {
//               return Container(
//                 width: size.width * 0.35,
//                 height: size.width * 0.35,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: RadialGradient(
//                     colors: [
//                       Colors.white.withOpacity(0.1),
//                       Colors.transparent,
//                     ],
//                   ),
//                   border: Border.all(
//                     color: Colors.white.withOpacity(0.2),
//                     width: 2,
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     kanji.character,
//                     style: GoogleFonts.notoSansJp(
//                       fontSize: isSmallScreen ? size.width * 0.15 : size.width * 0.18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                       shadows: [
//                         Shadow(
//                           color: const Color(0xFF8B5CF6).withOpacity(0.5),
//                           blurRadius: 10,
//                           offset: const Offset(0, 0),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//
//           SizedBox(height: size.height * 0.04),
//
//           // Stroke Count
//           Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: size.width * 0.04,
//               vertical: size.height * 0.01,
//             ),
//             decoration: BoxDecoration(
//               color: const Color(0xFF8B5CF6).withOpacity(0.2),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               '${kanji.strokeCount} strokes',
//               style: GoogleFonts.poppins(
//                 fontSize: size.width * 0.03,
//                 color: Colors.white.withOpacity(0.9),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//
//           SizedBox(height: size.height * 0.02),
//
//           // Tap hint
//           Text(
//             'Tap to see meaning & examples',
//             style: GoogleFonts.poppins(
//               fontSize: size.width * 0.03,
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
//       padding: EdgeInsets.all(size.width * 0.06),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Meaning
//             Center(
//               child: Text(
//                 kanji.meaning,
//                 style: GoogleFonts.poppins(
//                   fontSize: isSmallScreen ? size.width * 0.05 : size.width * 0.055,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//
//             SizedBox(height: size.height * 0.02),
//
//             // Readings
//             _buildInfoSection(
//               'Readings',
//               kanji.readings.join(', '),
//               Icons.record_voice_over,
//               size,
//               isSmallScreen,
//             ),
//
//             SizedBox(height: size.height * 0.015),
//
//             // Examples
//             _buildInfoSection(
//               'Examples',
//               kanji.examples.join('\n'),
//               Icons.format_list_bulleted,
//               size,
//               isSmallScreen,
//             ),
//
//             SizedBox(height: size.height * 0.015),
//
//             // Mnemonic
//             _buildInfoSection(
//               'Memory Tip',
//               kanji.mnemonic,
//               Icons.lightbulb,
//               size,
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
//       Size size,
//       bool isSmallScreen,
//       ) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(size.width * 0.03),
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
//               Icon(
//                 icon,
//                 color: const Color(0xFF10B981),
//                 size: size.width * 0.04,
//               ),
//               SizedBox(width: size.width * 0.02),
//               Text(
//                 title,
//                 style: GoogleFonts.poppins(
//                   fontSize: size.width * 0.035,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFF10B981),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: size.height * 0.008),
//           Text(
//             content,
//             style: GoogleFonts.poppins(
//               fontSize: size.width * 0.03,
//               color: Colors.white.withOpacity(0.8),
//               height: 1.4,
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
//           size: size,
//           isSmallScreen: isSmallScreen,
//         ),
//         _buildActionButton(
//           icon: Icons.volume_up,
//           label: 'Pronounce',
//           color: const Color(0xFF06B6D4),
//           onTap: _pronounceKanji,
//           size: size,
//           isSmallScreen: isSmallScreen,
//         ),
//         _buildActionButton(
//           icon: Icons.edit,
//           label: 'Practice',
//           color: const Color(0xFF10B981),
//           onTap: _practiceWriting,
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
//   Widget _buildNavigationButtons(Size size, bool isSmallScreen) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         _buildNavButton(
//           icon: Icons.arrow_back_ios,
//           label: 'Previous',
//           onTap: _previousKanji,
//           enabled: _currentKanjiIndex > 0,
//           size: size,
//           isSmallScreen: isSmallScreen,
//         ),
//         Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: size.width * 0.04,
//             vertical: size.height * 0.01,
//           ),
//           decoration: BoxDecoration(
//             color: const Color(0xFF8B5CF6).withOpacity(0.2),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             '${_currentKanjiIndex + 1} / ${_kanjiList.length}',
//             style: GoogleFonts.poppins(
//               fontSize: size.width * 0.035,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         _buildNavButton(
//           icon: Icons.arrow_forward_ios,
//           label: 'Next',
//           onTap: _nextKanji,
//           enabled: _currentKanjiIndex < _kanjiList.length - 1,
//           size: size,
//           isSmallScreen: isSmallScreen,
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
//     required Size size,
//     required bool isSmallScreen,
//   }) {
//     return GestureDetector(
//       onTap: enabled ? onTap : null,
//       child: Container(
//         padding: EdgeInsets.symmetric(
//           horizontal: size.width * 0.05,
//           vertical: size.height * 0.015,
//         ),
//         decoration: BoxDecoration(
//           color: enabled
//               ? const Color(0xFF8B5CF6).withOpacity(0.1)
//               : Colors.grey.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: enabled
//                 ? const Color(0xFF8B5CF6).withOpacity(0.3)
//                 : Colors.grey.withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (icon == Icons.arrow_back_ios) ...[
//               Icon(
//                 icon,
//                 color: enabled ? Colors.white : Colors.grey,
//                 size: size.width * 0.04,
//               ),
//               SizedBox(width: size.width * 0.02),
//             ],
//             Text(
//               label,
//               style: GoogleFonts.poppins(
//                 fontSize: size.width * 0.035,
//                 color: enabled ? Colors.white : Colors.grey,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             if (icon == Icons.arrow_forward_ios) ...[
//               SizedBox(width: size.width * 0.02),
//               Icon(
//                 icon,
//                 color: enabled ? Colors.white : Colors.grey,
//                 size: size.width * 0.04,
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
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           _isBookmarked ? 'Kanji bookmarked!' : 'Bookmark removed',
//         ),
//         backgroundColor: const Color(0xFFF59E0B),
//         duration: const Duration(seconds: 1),
//       ),
//     );
//   }
//
//   void _pronounceKanji() {
//     // TODO: Implement TTS for kanji pronunciation
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Pronunciation feature coming soon!'),
//         backgroundColor: Color(0xFF06B6D4),
//         duration: Duration(seconds: 1),
//       ),
//     );
//   }
//
//   void _practiceWriting() {
//     // TODO: Navigate to writing practice screen
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Writing practice coming soon!'),
//         backgroundColor: Color(0xFF10B981),
//         duration: Duration(seconds: 1),
//       ),
//     );
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
//     if (_currentKanjiIndex < _kanjiList.length - 1) {
//       setState(() {
//         _currentKanjiIndex++;
//         _isBookmarked = false;
//       });
//       _cardFlipController.reset();
//     }
//   }
//
//   void _startKanjiQuiz() {
//     // TODO: Navigate to kanji quiz screen
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Kanji Quiz coming soon!'),
//         backgroundColor: Color(0xFF10B981),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }
// }
//
// // Kanji Data Model
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