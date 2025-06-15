import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class LettersLearningScreen extends StatefulWidget {
  const LettersLearningScreen({super.key});

  @override
  State<LettersLearningScreen> createState() => _LettersLearningScreenState();
}

class _LettersLearningScreenState extends State<LettersLearningScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _cardController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _cardFlipAnimation;

  String selectedScript = "Hiragana";
  int currentLetterIndex = 0;
  bool isFlipped = false;
  bool showPronunciation = false;
  int correctAnswers = 0;
  int totalAttempts = 0;

  // Hiragana data
  final hiraganaLetters = [
    {'character': 'あ', 'romaji': 'a', 'audio': 'ah'},
    {'character': 'い', 'romaji': 'i', 'audio': 'ee'},
    {'character': 'う', 'romaji': 'u', 'audio': 'oo'},
    {'character': 'え', 'romaji': 'e', 'audio': 'eh'},
    {'character': 'お', 'romaji': 'o', 'audio': 'oh'},
    {'character': 'か', 'romaji': 'ka', 'audio': 'kah'},
    {'character': 'き', 'romaji': 'ki', 'audio': 'kee'},
    {'character': 'く', 'romaji': 'ku', 'audio': 'koo'},
    {'character': 'け', 'romaji': 'ke', 'audio': 'keh'},
    {'character': 'こ', 'romaji': 'ko', 'audio': 'koh'},
    {'character': 'さ', 'romaji': 'sa', 'audio': 'sah'},
    {'character': 'し', 'romaji': 'shi', 'audio': 'shee'},
    {'character': 'す', 'romaji': 'su', 'audio': 'soo'},
    {'character': 'せ', 'romaji': 'se', 'audio': 'seh'},
    {'character': 'そ', 'romaji': 'so', 'audio': 'soh'},
  ];

  // Katakana data
  final katakanaLetters = [
    {'character': 'ア', 'romaji': 'a', 'audio': 'ah'},
    {'character': 'イ', 'romaji': 'i', 'audio': 'ee'},
    {'character': 'ウ', 'romaji': 'u', 'audio': 'oo'},
    {'character': 'エ', 'romaji': 'e', 'audio': 'eh'},
    {'character': 'オ', 'romaji': 'o', 'audio': 'oh'},
    {'character': 'カ', 'romaji': 'ka', 'audio': 'kah'},
    {'character': 'キ', 'romaji': 'ki', 'audio': 'kee'},
    {'character': 'ク', 'romaji': 'ku', 'audio': 'koo'},
    {'character': 'ケ', 'romaji': 'ke', 'audio': 'keh'},
    {'character': 'コ', 'romaji': 'ko', 'audio': 'koh'},
    {'character': 'サ', 'romaji': 'sa', 'audio': 'sah'},
    {'character': 'シ', 'romaji': 'shi', 'audio': 'shee'},
    {'character': 'ス', 'romaji': 'su', 'audio': 'soo'},
    {'character': 'セ', 'romaji': 'se', 'audio': 'seh'},
    {'character': 'ソ', 'romaji': 'so', 'audio': 'soh'},
  ];

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

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _cardFlipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get currentLetters =>
      selectedScript == "Hiragana" ? hiraganaLetters : katakanaLetters;

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
            child: Column(
              children: [
                // Header
                _buildHeader(size, isSmallScreen),

                // Progress Bar
                _buildProgressBar(size),

                // Script Selector
                _buildScriptSelector(size, isSmallScreen),

                // Main Learning Card
                Expanded(
                  child: _buildLearningCard(size, isSmallScreen),
                ),

                // Controls
                _buildControls(size, isSmallScreen),

                // Bottom Navigation
                _buildBottomActions(size, isSmallScreen),
              ],
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
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.04),
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
                        'Japanese Letters',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Master ${selectedScript.toLowerCase()} characters',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.032,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Fun animated character
                Container(
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
                    selectedScript == "Hiragana" ? 'あ' : 'ア',
                    style: GoogleFonts.notoSansJp(
                      fontSize: size.width * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(Size size) {
    final progress = (currentLetterIndex + 1) / currentLetters.length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.035,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${currentLetterIndex + 1} / ${currentLetters.length}',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.035,
                  color: const Color(0xFF8B5CF6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.008),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              minHeight: size.height * 0.008,
            ),
          ),
          SizedBox(height: size.height * 0.015),
        ],
      ),
    );
  }

  Widget _buildScriptSelector(Size size, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedScript = "Hiragana";
                  currentLetterIndex = 0;
                  isFlipped = false;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                decoration: BoxDecoration(
                  gradient: selectedScript == "Hiragana"
                      ? const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  )
                      : null,
                  color: selectedScript == "Hiragana"
                      ? null
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: selectedScript == "Hiragana"
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Hiragana ひらがな',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedScript = "Katakana";
                  currentLetterIndex = 0;
                  isFlipped = false;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                decoration: BoxDecoration(
                  gradient: selectedScript == "Katakana"
                      ? const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                  )
                      : null,
                  color: selectedScript == "Katakana"
                      ? null
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: selectedScript == "Katakana"
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Katakana カタカナ',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningCard(Size size, bool isSmallScreen) {
    final currentLetter = currentLetters[currentLetterIndex];

    return Padding(
      padding: EdgeInsets.all(size.width * 0.04),
      child: GestureDetector(
        onTap: _flipCard,
        child: AnimatedBuilder(
          animation: _cardFlipAnimation,
          builder: (context, child) {
            final isShowingFront = _cardFlipAnimation.value < 0.5;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_cardFlipAnimation.value * math.pi),
              child: Container(
                width: double.infinity,
                height: size.height * 0.4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: selectedScript == "Hiragana"
                        ? [
                      const Color(0xFF8B5CF6).withOpacity(0.2),
                      const Color(0xFFEC4899).withOpacity(0.2),
                    ]
                        : [
                      const Color(0xFF10B981).withOpacity(0.2),
                      const Color(0xFF06B6D4).withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: selectedScript == "Hiragana"
                        ? const Color(0xFF8B5CF6).withOpacity(0.3)
                        : const Color(0xFF10B981).withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: selectedScript == "Hiragana"
                          ? const Color(0xFF8B5CF6).withOpacity(0.2)
                          : const Color(0xFF10B981).withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: isShowingFront ? _buildCardFront(currentLetter, size) : _buildCardBack(currentLetter, size),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardFront(Map<String, String> letter, Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Large character display
        Container(
          padding: EdgeInsets.all(size.width * 0.06),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            letter['character']!,
            style: GoogleFonts.notoSansJp(
              fontSize: size.width * 0.25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: size.height * 0.03),

        // Hint text
        Text(
          'Tap to see pronunciation',
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.035,
            color: Colors.white.withOpacity(0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: size.height * 0.02),

        // Fun memory aid
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.01,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            _getMemoryAid(letter['character']!),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.03,
              color: Colors.white.withOpacity(0.8),

            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardBack(Map<String, String> letter, Size size) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Romaji
          Text(
            letter['romaji']!.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: size.height * 0.02),

          // Audio pronunciation guide
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.06,
              vertical: size.height * 0.015,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Sounds like: "${letter['audio']!}"',
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.04,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.03),

          // Practice writing guide
          Text(
            'Practice writing this character!',
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.032,
              color: Colors.white.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(Size size, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Previous button
          _buildControlButton(
            icon: Icons.skip_previous,
            onTap: _previousLetter,
            enabled: currentLetterIndex > 0,
            size: size,
          ),

          // Play audio button
          _buildControlButton(
            icon: Icons.volume_up,
            onTap: _playAudio,
            enabled: true,
            size: size,
            isSpecial: true,
          ),

          // Flip card button
          _buildControlButton(
            icon: Icons.flip,
            onTap: _flipCard,
            enabled: true,
            size: size,
          ),

          // Next button
          _buildControlButton(
            icon: Icons.skip_next,
            onTap: _nextLetter,
            enabled: currentLetterIndex < currentLetters.length - 1,
            size: size,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
    required Size size,
    bool isSpecial = false,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          gradient: enabled
              ? (isSpecial
              ? const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFFF6B35)],
          )
              : LinearGradient(
            colors: selectedScript == "Hiragana"
                ? [const Color(0xFF8B5CF6), const Color(0xFFEC4899)]
                : [const Color(0xFF10B981), const Color(0xFF06B6D4)],
          ))
              : null,
          color: enabled ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: enabled
                ? Colors.transparent
                : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : Colors.white.withOpacity(0.5),
          size: size.width * 0.06,
        ),
      ),
    );
  }

  Widget _buildBottomActions(Size size, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _startQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06B6D4),
                padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Quick Quiz',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: ElevatedButton(
              onPressed: _practiceWriting,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Practice Writing',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getMemoryAid(String character) {
    final memoryAids = {
      'あ': 'Like a person saying "Ah!"',
      'い': 'Two sticks standing upright',
      'う': 'A person bowing down',
      'え': 'An elephant\'s trunk',
      'お': 'A surprised face',
      'か': 'A kite in the wind',
      'き': 'A key shape',
      'く': 'A bird\'s beak',
      'け': 'A person kneeling',
      'こ': 'Two horizontal lines',
      'さ': 'A person sitting',
      'し': 'A curved line',
      'す': 'A swan swimming',
      'せ': 'A world map',
      'そ': 'A needle and thread',
      // Katakana
      'ア': 'Sharp angles like "A"',
      'イ': 'Two straight lines',
      'ウ': 'Like a "U" shape',
      'エ': 'Elevator going up',
      'オ': 'Open mouth saying "Oh"',
      'カ': 'Sharp cutting motion',
      'キ': 'A key with teeth',
      'ク': 'A person bowing',
      'ケ': 'Ketchup bottle',
      'コ': 'Corner of a box',
      'サ': 'Samurai sword',
      'シ': 'Shooting arrow',
      'ス': 'Straight line with hook',
      'セ': 'Set of stairs',
      'ソ': 'Sewing needle',
    };

    return memoryAids[character] ?? 'Remember this character!';
  }

  void _flipCard() {
    if (_cardController.isCompleted) {
      _cardController.reverse();
    } else {
      _cardController.forward();
    }
  }

  void _nextLetter() {
    if (currentLetterIndex < currentLetters.length - 1) {
      setState(() {
        currentLetterIndex++;
      });
      _cardController.reset();
    }
  }

  void _previousLetter() {
    if (currentLetterIndex > 0) {
      setState(() {
        currentLetterIndex--;
      });
      _cardController.reset();
    }
  }

  void _playAudio() {
    // Implement audio playback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing: ${currentLetters[currentLetterIndex]['audio']}'),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _startQuiz() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2128),
        title: Text(
          'Quick Quiz',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          'Test your knowledge of the characters you\'ve learned!',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Later',
              style: GoogleFonts.poppins(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to quiz screen
            },
            child: Text(
              'Start Quiz',
              style: GoogleFonts.poppins(color: const Color(0xFF8B5CF6)),
            ),
          ),
        ],
      ),
    );
  }

  void _practiceWriting() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2128),
        title: Text(
          'Practice Writing',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          'Practice writing ${selectedScript.toLowerCase()} characters with guided strokes!',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Later',
              style: GoogleFonts.poppins(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to writing practice screen
            },
            child: Text(
              'Start Writing',
              style: GoogleFonts.poppins(color: const Color(0xFF8B5CF6)),
            ),
          ),
        ],
      ),
    );
  }
}