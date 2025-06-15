import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class ConversationLearningScreen extends StatefulWidget {
  final String level;

  const ConversationLearningScreen({super.key, required this.level});

  @override
  State<ConversationLearningScreen> createState() => _ConversationLearningScreenState();
}

class _ConversationLearningScreenState extends State<ConversationLearningScreen>
    with TickerProviderStateMixin {

  // Animation Controllers
  late AnimationController _animationController;
  late AnimationController _typingController;
  late AnimationController _bubbleController;
  late AnimationController _characterController;
  late AnimationController _responseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _typingAnimation;
  late Animation<double> _bubbleAnimation;
  late Animation<double> _characterAnimation;
  late Animation<double> _responseAnimation;

  // State Variables
  String selectedSituation = "Greetings";
  int currentPhraseIndex = 0;
  bool showTranslation = false;
  bool isTypingMode = false;
  List<String> typedText = [];
  String currentInput = "";
  int conversationStep = 0;
  bool showHint = false;
  bool showResponse = false;

  // Conversation data organized by level and situation
  Map<String, Map<String, List<Map<String, dynamic>>>> conversationData = {
    'N5': {
      'Greetings': [
        {
          'japanese': 'おはようございます。',
          'reading': 'Ohayou gozaimasu.',
          'english': 'Good morning.',
          'situation': 'Morning greeting (formal)',
          'response': 'おはようございます。',
          'responseReading': 'Ohayou gozaimasu.',
          'responseEnglish': 'Good morning.',
          'culturalNote': 'Used until about 10 AM. Very polite form.',
          'character': '👨‍💼',
          'voiceNote': 'Say this with a slight bow',
        },
        {
          'japanese': 'こんにちは。',
          'reading': 'Konnichiwa.',
          'english': 'Hello / Good afternoon.',
          'situation': 'General greeting',
          'response': 'こんにちは。',
          'responseReading': 'Konnichiwa.',
          'responseEnglish': 'Hello.',
          'culturalNote': 'Most common greeting, used from late morning to late afternoon.',
          'character': '👩',
          'voiceNote': 'Clear pronunciation with rising tone',
        },
        {
          'japanese': 'こんばんは。',
          'reading': 'Konbanwa.',
          'english': 'Good evening.',
          'situation': 'Evening greeting',
          'response': 'こんばんは。',
          'responseReading': 'Konbanwa.',
          'responseEnglish': 'Good evening.',
          'culturalNote': 'Used from around 6 PM onwards.',
          'character': '👴',
          'voiceNote': 'Slower, more relaxed tone',
        },
        {
          'japanese': 'はじめまして。',
          'reading': 'Hajimemashite.',
          'english': 'Nice to meet you.',
          'situation': 'First meeting',
          'response': 'こちらこそ、よろしくお願いします。',
          'responseReading': 'Kochira koso, yoroshiku onegaishimasu.',
          'responseEnglish': 'Nice to meet you too. Please treat me favorably.',
          'culturalNote': 'Always bow when saying this phrase.',
          'character': '🧑‍🎓',
          'voiceNote': 'Speak slowly and clearly, very polite',
        },
      ],
      'At Restaurant': [
        {
          'japanese': 'いらっしゃいませ！',
          'reading': 'Irasshaimase!',
          'english': 'Welcome!',
          'situation': 'Staff greeting customers',
          'response': 'ありがとうございます。',
          'responseReading': 'Arigatou gozaimasu.',
          'responseEnglish': 'Thank you.',
          'culturalNote': 'Standard greeting in all Japanese shops and restaurants.',
          'character': '👨‍🍳',
          'voiceNote': 'Enthusiastic and welcoming tone',
        },
        {
          'japanese': 'メニューをお願いします。',
          'reading': 'Menyuu wo onegaishimasu.',
          'english': 'Menu, please.',
          'situation': 'Asking for menu',
          'response': 'はい、どうぞ。',
          'responseReading': 'Hai, douzo.',
          'responseEnglish': 'Yes, here you go.',
          'culturalNote': 'Polite way to request the menu.',
          'character': '🍽️',
          'voiceNote': 'Polite request tone',
        },
        {
          'japanese': 'これをください。',
          'reading': 'Kore wo kudasai.',
          'english': 'This, please.',
          'situation': 'Ordering food',
          'response': 'かしこまりました。',
          'responseReading': 'Kashikomarimashita.',
          'responseEnglish': 'Understood. (formal)',
          'culturalNote': 'Point to the menu item when saying this.',
          'character': '🍜',
          'voiceNote': 'Clear and direct',
        },
        {
          'japanese': 'お会計をお願いします。',
          'reading': 'Okaikei wo onegaishimasu.',
          'english': 'Check, please.',
          'situation': 'Asking for the bill',
          'response': 'はい、少々お待ちください。',
          'responseReading': 'Hai, shoushou omachi kudasai.',
          'responseEnglish': 'Yes, please wait a moment.',
          'culturalNote': 'In Japan, you usually pay at the counter, not at the table.',
          'character': '💳',
          'voiceNote': 'Polite and patient tone',
        },
      ],
      'Shopping': [
        {
          'japanese': 'いくらですか？',
          'reading': 'Ikura desu ka?',
          'english': 'How much is it?',
          'situation': 'Asking for price',
          'response': '千円です。',
          'responseReading': 'Sen en desu.',
          'responseEnglish': 'It\'s 1000 yen.',
          'culturalNote': 'Essential phrase for shopping.',
          'character': '🏪',
          'voiceNote': 'Clear question with rising intonation',
        },
        {
          'japanese': 'これはありますか？',
          'reading': 'Kore wa arimasu ka?',
          'english': 'Do you have this?',
          'situation': 'Asking for availability',
          'response': 'はい、あります。',
          'responseReading': 'Hai, arimasu.',
          'responseEnglish': 'Yes, we have it.',
          'culturalNote': 'Useful when looking for specific items.',
          'character': '🛍️',
          'voiceNote': 'Hopeful questioning tone',
        },
      ],
      'Directions': [
        {
          'japanese': 'すみません、駅はどこですか？',
          'reading': 'Sumimasen, eki wa doko desu ka?',
          'english': 'Excuse me, where is the station?',
          'situation': 'Asking for directions',
          'response': 'まっすぐ行って、右に曲がってください。',
          'responseReading': 'Massugu itte, migi ni magatte kudasai.',
          'responseEnglish': 'Go straight and turn right.',
          'culturalNote': 'Always start with "sumimasen" when asking strangers.',
          'character': '🚉',
          'voiceNote': 'Polite and slightly urgent',
        },
      ],
    },
    'N4': {
      'Advanced Conversations': [
        {
          'japanese': 'お疲れ様でした。',
          'reading': 'Otsukaresama deshita.',
          'english': 'Thank you for your hard work.',
          'situation': 'End of work day',
          'response': 'お疲れ様でした。',
          'responseReading': 'Otsukaresama deshita.',
          'responseEnglish': 'Thank you for your hard work too.',
          'culturalNote': 'Essential workplace expression in Japan.',
          'character': '💼',
          'voiceNote': 'Respectful and appreciative',
        },
        {
          'japanese': 'すみませんが、ちょっと忙しいです。',
          'reading': 'Sumimasen ga, chotto isogashii desu.',
          'english': 'Sorry, but I\'m a bit busy.',
          'situation': 'Politely declining',
          'response': 'わかりました。また今度。',
          'responseReading': 'Wakarimashita. Mata kondo.',
          'responseEnglish': 'I understand. Another time.',
          'culturalNote': 'Soft way to say you\'re busy without being rude.',
          'character': '⏰',
          'voiceNote': 'Apologetic but firm',
        },
      ],
    },
    'N3': {
      'Business Conversations': [
        {
          'japanese': '会議の準備はいかがですか？',
          'reading': 'Kaigi no junbi wa ikaga desu ka?',
          'english': 'How are the meeting preparations?',
          'situation': 'Checking on work progress',
          'response': 'もう少し時間がかかります。',
          'responseReading': 'Mou sukoshi jikan ga kakarimasu.',
          'responseEnglish': 'It will take a little more time.',
          'culturalNote': 'Common way to check on progress politely.',
          'character': '📊',
          'voiceNote': 'Professional and concerned',
        },
      ],
    },
  };

  // Helper getters
  List<String> get situations => conversationData[widget.level]?.keys.toList() ?? [];
  List<Map<String, dynamic>> get currentPhrases =>
      conversationData[widget.level]?[selectedSituation] ?? [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    if (situations.isNotEmpty) {
      selectedSituation = situations.first;
    }
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _typingController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _characterController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _responseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeInOut),
    );

    _bubbleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.elasticOut),
    );

    _characterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _characterController, curve: Curves.easeInOut),
    );

    _responseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _responseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _characterController.repeat(reverse: true);

    // Auto-start first bubble animation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _bubbleController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _typingController.dispose();
    _bubbleController.dispose();
    _characterController.dispose();
    _responseController.dispose();
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
            child: Column(
              children: [
                // Header
                _buildHeader(size, isSmallScreen),

                // Situation Selector
                _buildSituationSelector(size, isSmallScreen),

                // Conversation Display
                Expanded(
                  child: _buildConversationDisplay(size, isSmallScreen),
                ),

                // Controls
                _buildControls(size, isSmallScreen),
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
                        'Daily Conversations',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.055,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Practice ${widget.level} speaking',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.032,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Animated chat icon
                AnimatedBuilder(
                  animation: _characterAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_characterAnimation.value * 0.1),
                      child: Container(
                        padding: EdgeInsets.all(size.width * 0.03),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF06B6D4).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          '💬',
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

  Widget _buildSituationSelector(Size size, bool isSmallScreen) {
    return Container(
      height: size.height * 0.08,
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: situations.length,
        itemBuilder: (context, index) {
          final situation = situations[index];
          final isSelected = situation == selectedSituation;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedSituation = situation;
                currentPhraseIndex = 0;
                conversationStep = 0;
                showTranslation = false;
                showResponse = false;
              });
              _bubbleController.reset();
              _responseController.reset();
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  _bubbleController.forward();
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: size.width * 0.03),
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.height * 0.015,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
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
                    color: const Color(0xFF06B6D4).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : null,
              ),
              child: Center(
                child: Text(
                  situation,
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.032,
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

  Widget _buildConversationDisplay(Size size, bool isSmallScreen) {
    if (currentPhrases.isEmpty) {
      return _buildEmptyState(size);
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          children: [
            // Conversation bubbles
            _buildConversationBubbles(size, isSmallScreen),
            SizedBox(height: size.height * 0.02),

            // Practice mode toggle
            _buildPracticeModeToggle(size, isSmallScreen),
            SizedBox(height: size.height * 0.02),

            // Cultural note
            _buildCulturalNote(size, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationBubbles(Size size, bool isSmallScreen) {
    final currentPhrase = currentPhrases[currentPhraseIndex];

    return Column(
      children: [
        // Character speaking
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(size.width * 0.03),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                currentPhrase['character'],
                style: TextStyle(fontSize: size.width * 0.08),
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: AnimatedBuilder(
                animation: _bubbleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _bubbleAnimation.value,
                    child: Container(
                      padding: EdgeInsets.all(size.width * 0.04),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF06B6D4).withOpacity(0.2),
                            const Color(0xFF8B5CF6).withOpacity(0.2),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                          bottomLeft: Radius.circular(5),
                        ),
                        border: Border.all(
                          color: const Color(0xFF06B6D4).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentPhrase['japanese'],
                            style: GoogleFonts.notoSansJp(
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: size.height * 0.005),
                          Text(
                            currentPhrase['reading'],
                            style: GoogleFonts.poppins(
                              fontSize: size.width * 0.032,
                              color: const Color(0xFF06B6D4),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          if (showTranslation) ...[
                            SizedBox(height: size.height * 0.008),
                            Text(
                              currentPhrase['english'],
                              style: GoogleFonts.poppins(
                                fontSize: size.width * 0.035,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        if (showResponse) ...[
          SizedBox(height: size.height * 0.02),

          // Response bubble (user's response)
          AnimatedBuilder(
            animation: _responseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _responseAnimation.value,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(size.width * 0.04),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF10B981).withOpacity(0.2),
                              const Color(0xFF06B6D4).withOpacity(0.2),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(5),
                          ),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentPhrase['response'],
                              style: GoogleFonts.notoSansJp(
                                fontSize: size.width * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: size.height * 0.005),
                            Text(
                              currentPhrase['responseReading'],
                              style: GoogleFonts.poppins(
                                fontSize: size.width * 0.03,
                                color: const Color(0xFF10B981),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(height: size.height * 0.008),
                            Text(
                              currentPhrase['responseEnglish'],
                              style: GoogleFonts.poppins(
                                fontSize: size.width * 0.032,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Container(
                      padding: EdgeInsets.all(size.width * 0.03),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '😊',
                        style: TextStyle(fontSize: size.width * 0.08),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],

        // Voice note hint
        if (showHint) ...[
          SizedBox(height: size.height * 0.015),
          Container(
            padding: EdgeInsets.all(size.width * 0.03),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.mic,
                  color: const Color(0xFFF59E0B),
                  size: size.width * 0.04,
                ),
                SizedBox(width: size.width * 0.02),
                Expanded(
                  child: Text(
                    currentPhrase['voiceNote'],
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.028,
                      color: Colors.white.withOpacity(0.9),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPracticeModeToggle(Size size, bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                showTranslation = !showTranslation;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
              decoration: BoxDecoration(
                color: showTranslation
                    ? const Color(0xFF8B5CF6).withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: showTranslation
                      ? const Color(0xFF8B5CF6).withOpacity(0.5)
                      : Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    showTranslation ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                    size: size.width * 0.05,
                  ),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    'Translation',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: size.width * 0.03),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                showHint = !showHint;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
              decoration: BoxDecoration(
                color: showHint
                    ? const Color(0xFFF59E0B).withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: showHint
                      ? const Color(0xFFF59E0B).withOpacity(0.5)
                      : Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: size.width * 0.05,
                  ),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    'Voice Hint',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCulturalNote(Size size, bool isSmallScreen) {
    final currentPhrase = currentPhrases[currentPhraseIndex];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFEC4899).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEC4899).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFFEC4899),
                size: size.width * 0.05,
              ),
              SizedBox(width: size.width * 0.02),
              Text(
                'Cultural Note',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFEC4899),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            currentPhrase['culturalNote'],
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.032,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Size size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '💬',
            style: TextStyle(fontSize: size.width * 0.2),
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            'No conversations available',
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Try a different situation',
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.035,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(Size size, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
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
      child: Column(
        children: [
          // Progress indicator
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
                '${currentPhraseIndex + 1} / ${currentPhrases.length}',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.035,
                  color: const Color(0xFF06B6D4),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: currentPhrases.isEmpty ? 0.0 : (currentPhraseIndex + 1) / currentPhrases.length,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
              minHeight: size.height * 0.008,
            ),
          ),
          SizedBox(height: size.height * 0.02),

          // Action buttons
          Row(
            children: [
              // Previous button
              Expanded(
                child: ElevatedButton(
                  onPressed: currentPhraseIndex > 0 ? _previousPhrase : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentPhraseIndex > 0
                        ? const Color(0xFF6B7280)
                        : Colors.grey.withOpacity(0.3),
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                        size: size.width * 0.05,
                      ),
                      SizedBox(width: size.width * 0.02),
                      Text(
                        'Previous',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: size.width * 0.03),

              // Practice response button
              Expanded(
                child: ElevatedButton(
                  onPressed: _practiceResponse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                        size: size.width * 0.05,
                      ),
                      SizedBox(width: size.width * 0.02),
                      Text(
                        'Response',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: size.width * 0.03),

              // Next button
              Expanded(
                child: ElevatedButton(
                  onPressed: currentPhraseIndex < currentPhrases.length - 1
                      ? _nextPhrase
                      : _completeConversation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06B6D4),
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentPhraseIndex < currentPhrases.length - 1 ? 'Next' : 'Finish',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: size.width * 0.02),
                      Icon(
                        currentPhraseIndex < currentPhrases.length - 1
                            ? Icons.skip_next
                            : Icons.check_circle,
                        color: Colors.white,
                        size: size.width * 0.05,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.015),

          // Audio practice button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _playAudio,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.volume_up,
                    color: Colors.white,
                    size: size.width * 0.05,
                  ),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    'Listen & Repeat',
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

  // Helper methods
  void _previousPhrase() {
    if (currentPhraseIndex > 0) {
      setState(() {
        currentPhraseIndex--;
        showResponse = false;
        conversationStep = 0;
      });
      _bubbleController.reset();
      _responseController.reset();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _bubbleController.forward();
        }
      });
    }
  }

  void _nextPhrase() {
    if (currentPhraseIndex < currentPhrases.length - 1) {
      setState(() {
        currentPhraseIndex++;
        showResponse = false;
        conversationStep = 0;
      });
      _bubbleController.reset();
      _responseController.reset();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _bubbleController.forward();
        }
      });
    }
  }

  void _practiceResponse() {
    setState(() {
      showResponse = true;
      conversationStep = 1;
    });
    _responseController.forward();
  }

  void _playAudio() {
    final currentPhrase = currentPhrases[currentPhraseIndex];

    // Simulate audio playback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up, color: Colors.white),
            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
            Expanded(
              child: Text(
                'Playing: ${currentPhrase['reading']}',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF8B5CF6),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    // Visual feedback for audio playing
    _typingController.forward().then((_) {
      _typingController.reverse();
    });
  }

  void _completeConversation() {
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
              'Conversation Complete!',
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
              'Great job practicing "$selectedSituation" conversations!',
              style: GoogleFonts.poppins(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Ready for real conversations!',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF06B6D4),
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    'Practice makes perfect - keep it up!',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: MediaQuery.of(context).size.width * 0.032,
                    ),
                    textAlign: TextAlign.center,
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
              _resetConversation();
            },
            child: Text(
              'Try Again',
              style: GoogleFonts.poppins(color: const Color(0xFF06B6D4)),
            ),
          ),
        ],
      ),
    );
  }

  void _resetConversation() {
    setState(() {
      currentPhraseIndex = 0;
      showResponse = false;
      conversationStep = 0;
      showTranslation = false;
      showHint = false;
    });
    _bubbleController.reset();
    _responseController.reset();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _bubbleController.forward();
      }
    });
  }
}