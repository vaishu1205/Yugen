import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class VocabularyLearningScreen extends StatefulWidget {
  final String level;

  const VocabularyLearningScreen({super.key, required this.level});

  @override
  State<VocabularyLearningScreen> createState() => _VocabularyLearningScreenState();
}

class _VocabularyLearningScreenState extends State<VocabularyLearningScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _animationController;
  late AnimationController _cardController;
  late AnimationController _confettiController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _cardFlipAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _confettiAnimation;

  // State Variables
  String selectedCategory = "Basic";
  int currentWordIndex = 0;
  bool isFlipped = false;
  int score = 0;
  int streak = 0;
  bool showMeaning = false;
  List<String> learnedWords = [];

  // Vocabulary data organized by level and category
  Map<String, Map<String, List<Map<String, dynamic>>>> vocabularyData = {
    'N5': {
      'Basic': [
        {
          'word': '学校',
          'reading': 'がっこう',
          'meaning': 'school',
          'category': '🏫',
          'example': '学校に行きます。',
          'exampleTranslation': 'I go to school.',
          'mnemonic': 'Think of "school" as a place where you learn (学) and work (校)',
        },
        {
          'word': '友達',
          'reading': 'ともだち',
          'meaning': 'friend',
          'category': '👫',
          'example': '友達と遊びます。',
          'exampleTranslation': 'I play with friends.',
          'mnemonic': 'Friends (友) reach out (達) to each other',
        },
        {
          'word': '本',
          'reading': 'ほん',
          'meaning': 'book',
          'category': '📚',
          'example': '本を読みます。',
          'exampleTranslation': 'I read a book.',
          'mnemonic': 'A book (本) looks like a tree trunk with roots',
        },
        {
          'word': '水',
          'reading': 'みず',
          'meaning': 'water',
          'category': '💧',
          'example': '水を飲みます。',
          'exampleTranslation': 'I drink water.',
          'mnemonic': 'Water (水) flows like a river between mountains',
        },
        {
          'word': '車',
          'reading': 'くるま',
          'meaning': 'car',
          'category': '🚗',
          'example': '車で行きます。',
          'exampleTranslation': 'I go by car.',
          'mnemonic': 'A car (車) has wheels that go round and round',
        },
      ],
      'Food': [
        {
          'word': 'ご飯',
          'reading': 'ごはん',
          'meaning': 'rice/meal',
          'category': '🍚',
          'example': 'ご飯を食べます。',
          'exampleTranslation': 'I eat rice/meal.',
          'mnemonic': 'Rice (飯) is the foundation of every meal',
        },
        {
          'word': '肉',
          'reading': 'にく',
          'meaning': 'meat',
          'category': '🥩',
          'example': '肉が好きです。',
          'exampleTranslation': 'I like meat.',
          'mnemonic': 'Meat (肉) comes from inside (内) an animal',
        },
        {
          'word': '魚',
          'reading': 'さかな',
          'meaning': 'fish',
          'category': '🐟',
          'example': '魚を食べます。',
          'exampleTranslation': 'I eat fish.',
          'mnemonic': 'Fish (魚) swim in the sea',
        },
        {
          'word': '野菜',
          'reading': 'やさい',
          'meaning': 'vegetables',
          'category': '🥬',
          'example': '野菜は体にいいです。',
          'exampleTranslation': 'Vegetables are good for the body.',
          'mnemonic': 'Vegetables (野菜) grow wild (野) in the fields',
        },
      ],
      'Family': [
        {
          'word': '家族',
          'reading': 'かぞく',
          'meaning': 'family',
          'category': '👨‍👩‍👧‍👦',
          'example': '家族と旅行します。',
          'exampleTranslation': 'I travel with family.',
          'mnemonic': 'Family (家族) lives together in a house (家)',
        },
        {
          'word': '母',
          'reading': 'はは',
          'meaning': 'mother',
          'category': '👩',
          'example': '母は優しいです。',
          'exampleTranslation': 'My mother is kind.',
          'mnemonic': 'Mother (母) nurtures like a hen with her chicks',
        },
        {
          'word': '父',
          'reading': 'ちち',
          'meaning': 'father',
          'category': '👨',
          'example': '父は会社員です。',
          'exampleTranslation': 'My father is a company employee.',
          'mnemonic': 'Father (父) works hard with his hands',
        },
      ],
    },
    'N4': {
      'Advanced': [
        {
          'word': '経験',
          'reading': 'けいけん',
          'meaning': 'experience',
          'category': '🎯',
          'example': 'いい経験でした。',
          'exampleTranslation': 'It was a good experience.',
          'mnemonic': 'Experience (経験) comes through (経) testing (験)',
        },
        {
          'word': '機会',
          'reading': 'きかい',
          'meaning': 'opportunity',
          'category': '🚪',
          'example': 'いい機会です。',
          'exampleTranslation': 'It\'s a good opportunity.',
          'mnemonic': 'Opportunity (機会) is like a machine (機) meeting (会)',
        },
      ],
    },
    'N3': {
      'Business': [
        {
          'word': '会議',
          'reading': 'かいぎ',
          'meaning': 'meeting',
          'category': '💼',
          'example': '会議に参加します。',
          'exampleTranslation': 'I will participate in the meeting.',
          'mnemonic': 'A meeting (会議) is where people gather (会) to discuss (議)',
        },
      ],
    },
  };

  // Helper getters
  List<String> get categories => vocabularyData[widget.level]?.keys.toList() ?? [];
  List<Map<String, dynamic>> get currentWords =>
      vocabularyData[widget.level]?[selectedCategory] ?? [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    if (categories.isNotEmpty) {
      selectedCategory = categories.first;
    }
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

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _confettiAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _confettiController, curve: Curves.easeOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardController.dispose();
    _confettiController.dispose();
    _pulseController.dispose();
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
          child: Stack(
            children: [
              // Main content
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Header
                    _buildHeader(size, isSmallScreen),

                    // Score and Stats
                    _buildStatsBar(size, isSmallScreen),

                    // Category Selector
                    _buildCategorySelector(size, isSmallScreen),

                    // Main Learning Card
                    Expanded(
                      child: _buildVocabularyCard(size, isSmallScreen),
                    ),

                    // Action Buttons
                    _buildActionButtons(size, isSmallScreen),

                    // Progress Indicator
                    _buildProgressIndicator(size, isSmallScreen),
                  ],
                ),
              ),

              // Confetti animation
              _buildConfettiAnimation(size),
            ],
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
                        'Vocabulary Master',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.055,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${widget.level} Level Words',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.032,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Animated mascot
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: EdgeInsets.all(size.width * 0.03),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          '📚',
                          style: TextStyle(fontSize: size.width * 0.06),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsBar(Size size, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(size.width * 0.03),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10B981).withOpacity(0.2),
                    const Color(0xFF06B6D4).withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '$score',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  Text(
                    'Score',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.025,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(size.width * 0.03),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF6B35).withOpacity(0.2),
                    const Color(0xFFF59E0B).withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF6B35).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$streak',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF6B35),
                        ),
                      ),
                      SizedBox(width: size.width * 0.01),
                      Text(
                        '🔥',
                        style: TextStyle(fontSize: size.width * 0.035),
                      ),
                    ],
                  ),
                  Text(
                    'Streak',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.025,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(size.width * 0.03),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withOpacity(0.2),
                    const Color(0xFFEC4899).withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '${learnedWords.length}',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                  Text(
                    'Learned',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.025,
                      color: Colors.white.withOpacity(0.8),
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

  Widget _buildCategorySelector(Size size, bool isSmallScreen) {
    return Container(
      height: size.height * 0.08,
      margin: EdgeInsets.all(size.width * 0.04),
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
                currentWordIndex = 0;
                isFlipped = false;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: size.width * 0.03),
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.015,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                )
                    : null,
                color: isSelected ? null : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : null,
              ),
              child: Center(
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.035,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVocabularyCard(Size size, bool isSmallScreen) {
    if (currentWords.isEmpty) {
      return _buildEmptyState(size);
    }

    final currentWord = currentWords[currentWordIndex];

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
                height: size.height * 0.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF10B981).withOpacity(0.2),
                      const Color(0xFF06B6D4).withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: isShowingFront
                    ? _buildCardFront(currentWord, size)
                    : _buildCardBack(currentWord, size),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardFront(Map<String, dynamic> word, Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Category emoji
        Container(
          padding: EdgeInsets.all(size.width * 0.04),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            word['category'],
            style: TextStyle(fontSize: size.width * 0.15),
          ),
        ),
        SizedBox(height: size.height * 0.03),

        // Japanese word
        Text(
          word['word'],
          style: GoogleFonts.notoSansJp(
            fontSize: size.width * 0.12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: size.height * 0.02),

        // Reading
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: size.height * 0.015,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            word['reading'],
            style: GoogleFonts.notoSansJp(
              fontSize: size.width * 0.06,
              color: const Color(0xFF10B981),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: size.height * 0.03),

        // Hint
        Text(
          'Tap to see meaning',
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.032,
            color: Colors.white.withOpacity(0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildCardBack(Map<String, dynamic> word, Size size) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.06),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // English meaning
            Text(
              word['meaning'].toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.08,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.03),

            // Example sentence
            Container(
              padding: EdgeInsets.all(size.width * 0.04),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    word['example'],
                    style: GoogleFonts.notoSansJp(
                      fontSize: size.width * 0.04,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    word['exampleTranslation'],
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.032,
                      color: const Color(0xFF06B6D4),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.02),

            // Mnemonic
            Container(
              padding: EdgeInsets.all(size.width * 0.04),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: const Color(0xFFF59E0B),
                        size: size.width * 0.05,
                      ),
                      SizedBox(width: size.width * 0.02),
                      Text(
                        'Memory Tip',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.032,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    word['mnemonic'],
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.028,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Size size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '📚',
            style: TextStyle(fontSize: size.width * 0.2),
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            'No words available',
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Try a different category',
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.035,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Size size, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Row(
        children: [
          // Know it button
          Expanded(
            child: ElevatedButton(
              onPressed: _markAsKnown,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: size.width * 0.05,
                  ),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    'Know It!',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: size.width * 0.03),

          // Need practice button
          Expanded(
            child: ElevatedButton(
              onPressed: _needMorePractice,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: size.width * 0.05,
                  ),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    'Practice',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildProgressIndicator(Size size, bool isSmallScreen) {
    final progress = currentWords.isEmpty ? 0.0 : (currentWordIndex + 1) / currentWords.length;

    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
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
                '${currentWordIndex + 1} / ${currentWords.length}',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.035,
                  color: const Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              minHeight: size.height * 0.008,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfettiAnimation(Size size) {
    return AnimatedBuilder(
      animation: _confettiAnimation,
      builder: (context, child) {
        if (_confettiAnimation.value == 0.0) return const SizedBox.shrink();

        return Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: ConfettiPainter(_confettiAnimation.value),
            ),
          ),
        );
      },
    );
  }

  // Helper methods
  void _flipCard() {
    if (_cardController.isCompleted) {
      _cardController.reverse();
    } else {
      _cardController.forward();
    }
  }

  void _markAsKnown() {
    final currentWord = currentWords[currentWordIndex];

    setState(() {
      score += 10;
      streak++;
      if (!learnedWords.contains(currentWord['word'])) {
        learnedWords.add(currentWord['word']);
      }
    });

    _confettiController.forward().then((_) {
      _confettiController.reset();
    });

    _nextWord();
  }

  void _needMorePractice() {
    setState(() {
      if (streak > 0) streak--;
    });
    _nextWord();
  }

  void _nextWord() {
    if (currentWordIndex < currentWords.length - 1) {
      setState(() {
        currentWordIndex++;
      });
    } else {
      _showCompletionDialog();
    }
    _cardController.reset();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2128),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Text(
              '🎉',
              style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.1),
            ),
            Text(
              'Category Complete!',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You\'ve finished all words in "$selectedCategory"!',
              style: GoogleFonts.poppins(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Final Score: $score',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                    ),
                  ),
                  Text(
                    'Words Learned: ${learnedWords.length}',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: MediaQuery.of(context).size.width * 0.032,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Back to Learn',
              style: GoogleFonts.poppins(color: Colors.white60),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetProgress();
            },
            child: Text(
              'Try Again',
              style: GoogleFonts.poppins(color: const Color(0xFF10B981)),
            ),
          ),
        ],
      ),
    );
  }

  void _resetProgress() {
    setState(() {
      currentWordIndex = 0;
      isFlipped = false;
    });
    _cardController.reset();
  }
}

// Custom painter for confetti animation
class ConfettiPainter extends CustomPainter {
  final double animationValue;

  ConfettiPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = math.Random(42); // Fixed seed for consistent animation

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = size.height * (1 - animationValue) + random.nextDouble() * 100;
      final color = [
        const Color(0xFF10B981),
        const Color(0xFF06B6D4),
        const Color(0xFF8B5CF6),
        const Color(0xFFEC4899),
        const Color(0xFFF59E0B),
        const Color(0xFFFF6B35),
      ][i % 6];

      paint.color = color.withOpacity(1 - animationValue);

      if (i % 3 == 0) {
        // Draw circles
        canvas.drawCircle(Offset(x, y), 4, paint);
      } else if (i % 3 == 1) {
        // Draw squares
        canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: 8, height: 8), paint);
      } else {
        // Draw triangles
        final path = Path();
        path.moveTo(x, y - 4);
        path.lineTo(x - 4, y + 4);
        path.lineTo(x + 4, y + 4);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}