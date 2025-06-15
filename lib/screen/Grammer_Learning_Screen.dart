import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class GrammarLearningScreen extends StatefulWidget {
  final String level;

  const GrammarLearningScreen({super.key, required this.level});

  @override
  State<GrammarLearningScreen> createState() => _GrammarLearningScreenState();
}

class _GrammarLearningScreenState extends State<GrammarLearningScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  int currentLessonIndex = 0;
  int completedLessons = 0;
  bool showExplanation = true;

  // Grammar lessons based on level
  Map<String, List<Map<String, dynamic>>> grammarLessons = {
    'N5': [
      {
        'title': 'Basic Particles: は (wa)',
        'explanation': 'は marks the topic of the sentence. It tells us what we are talking about.',
        'example': '私は学生です。',
        'translation': 'I am a student.',
        'breakdown': '私 (watashi) = I\nは (wa) = topic marker\n学生 (gakusei) = student\nです (desu) = polite "to be"',
        'practice': [
          {'japanese': '彼は先生です。', 'english': 'He is a teacher.'},
          {'japanese': '猫は可愛いです。', 'english': 'The cat is cute.'},
        ],
      },
      {
        'title': 'Basic Particles: を (wo/o)',
        'explanation': 'を marks the direct object of a sentence. It shows what action is being done to.',
        'example': '本を読みます。',
        'translation': 'I read a book.',
        'breakdown': '本 (hon) = book\nを (wo/o) = object marker\n読みます (yomimasu) = to read (polite)',
        'practice': [
          {'japanese': '水を飲みます。', 'english': 'I drink water.'},
          {'japanese': '映画を見ます。', 'english': 'I watch a movie.'},
        ],
      },
      {
        'title': 'Present Tense: です/だ',
        'explanation': 'です is the polite form of "to be". だ is the casual form. Use です in formal situations.',
        'example': '今日は暑いです。',
        'translation': 'Today is hot.',
        'breakdown': '今日 (kyou) = today\nは (wa) = topic marker\n暑い (atsui) = hot\nです (desu) = polite "to be"',
        'practice': [
          {'japanese': '明日は寒いです。', 'english': 'Tomorrow is cold.'},
          {'japanese': 'この本は面白いです。', 'english': 'This book is interesting.'},
        ],
      },
    ],
    'N4': [
      {
        'title': 'Past Tense: でした',
        'explanation': 'でした is the past tense of です. Use it to describe completed actions or past states.',
        'example': '昨日は雨でした。',
        'translation': 'Yesterday was rainy.',
        'breakdown': '昨日 (kinou) = yesterday\nは (wa) = topic marker\n雨 (ame) = rain\nでした (deshita) = was/were (polite past)',
        'practice': [
          {'japanese': '映画は面白かったです。', 'english': 'The movie was interesting.'},
          {'japanese': '昨日は忙しかったです。', 'english': 'Yesterday was busy.'},
        ],
      },
      {
        'title': 'て-form: Connecting Actions',
        'explanation': 'The て-form connects verbs and adjectives. It can show sequence or add descriptions.',
        'example': '朝ごはんを食べて、学校に行きます。',
        'translation': 'I eat breakfast and go to school.',
        'breakdown': '朝ごはん (asagohan) = breakfast\nを (wo) = object marker\n食べて (tabete) = eat (て-form)\n学校 (gakkou) = school\nに (ni) = direction marker\n行きます (ikimasu) = go',
        'practice': [
          {'japanese': '宿題をして、寝ます。', 'english': 'I do homework and sleep.'},
          {'japanese': '友達に会って、映画を見ました。', 'english': 'I met a friend and watched a movie.'},
        ],
      },
    ],
    'N3': [
      {
        'title': 'Conditional: たら',
        'explanation': 'たら expresses "if" or "when". Use past tense + たら to show conditions.',
        'example': '時間があったら、映画を見ます。',
        'translation': 'If I have time, I will watch a movie.',
        'breakdown': '時間 (jikan) = time\nが (ga) = subject marker\nあったら (attara) = if there is\n映画 (eiga) = movie\nを (wo) = object marker\n見ます (mimasu) = watch',
        'practice': [
          {'japanese': '雨が降ったら、家にいます。', 'english': 'If it rains, I will stay home.'},
          {'japanese': 'お金があったら、旅行します。', 'english': 'If I have money, I will travel.'},
        ],
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get currentLessons => grammarLessons[widget.level] ?? [];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    if (currentLessons.isEmpty) {
      return _buildEmptyState(size);
    }

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

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.all(size.width * 0.04),
                      child: Column(
                        children: [
                          // Lesson Content
                          _buildLessonContent(size, isSmallScreen),

                          SizedBox(height: size.height * 0.02),

                          // Practice Section
                          _buildPracticeSection(size, isSmallScreen),
                        ],
                      ),
                    ),
                  ),
                ),

                // Navigation Controls
                _buildNavigationControls(size, isSmallScreen),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Size size) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Coming Soon!',
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              '${widget.level} grammar lessons are being prepared.',
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.04,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.03),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.08,
                  vertical: size.height * 0.015,
                ),
              ),
              child: Text(
                'Go Back',
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
                        'Grammar Learning',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.055,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${widget.level} Level',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.032,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.03,
                    vertical: size.height * 0.008,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.level,
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.03,
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
    final progress = currentLessons.isEmpty ? 0.0 : (currentLessonIndex + 1) / currentLessons.length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lesson Progress',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.035,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${currentLessonIndex + 1} / ${currentLessons.length}',
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

  Widget _buildLessonContent(Size size, bool isSmallScreen) {
    final lesson = currentLessons[currentLessonIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lesson Title
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(size.width * 0.04),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF8B5CF6).withOpacity(0.2),
                const Color(0xFFEC4899).withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            lesson['title'],
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: size.height * 0.02),

        // Toggle between explanation and example
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => showExplanation = true),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                  decoration: BoxDecoration(
                    color: showExplanation
                        ? const Color(0xFF8B5CF6).withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Explanation',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(width: size.width * 0.02),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => showExplanation = false),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                  decoration: BoxDecoration(
                    color: !showExplanation
                        ? const Color(0xFF8B5CF6).withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Example',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: size.height * 0.02),

        // Content based on toggle
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: showExplanation
              ? _buildExplanation(lesson, size)
              : _buildExample(lesson, size),
        ),
      ],
    );
  }

  Widget _buildExplanation(Map<String, dynamic> lesson, Size size) {
    return Container(
      key: const ValueKey('explanation'),
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
      child: Text(
        lesson['explanation'],
        style: GoogleFonts.poppins(
          fontSize: size.width * 0.037,
          color: Colors.white.withOpacity(0.9),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildExample(Map<String, dynamic> lesson, Size size) {
    return Container(
      key: const ValueKey('example'),
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
          // Japanese Example
          Text(
            lesson['example'],
            style: GoogleFonts.notoSansJp(
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: size.height * 0.01),

          // English Translation
          Text(
            lesson['translation'],
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.035,
              color: const Color(0xFF10B981),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: size.height * 0.015),

          // Breakdown
          Container(
            padding: EdgeInsets.all(size.width * 0.03),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              lesson['breakdown'],
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.03,
                color: Colors.white.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeSection(Size size, bool isSmallScreen) {
    final lesson = currentLessons[currentLessonIndex];
    final practiceItems = lesson['practice'] as List<Map<String, String>>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Practice Examples',
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.045,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: size.height * 0.015),

        ...practiceItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Container(
            margin: EdgeInsets.only(bottom: size.height * 0.015),
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
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
                    Container(
                      padding: EdgeInsets.all(size.width * 0.02),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.03,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: Text(
                        item['japanese']!,
                        style: GoogleFonts.notoSansJp(
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.008),
                Padding(
                  padding: EdgeInsets.only(left: size.width * 0.1),
                  child: Text(
                    item['english']!,
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.032,
                      color: const Color(0xFFF59E0B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildNavigationControls(Size size, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Previous Button
          Expanded(
            child: ElevatedButton(
              onPressed: currentLessonIndex > 0 ? _previousLesson : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: currentLessonIndex > 0
                    ? const Color(0xFF06B6D4)
                    : Colors.grey.withOpacity(0.3),
                padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Previous',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(width: size.width * 0.03),

          // Next Button
          Expanded(
            child: ElevatedButton(
              onPressed: currentLessonIndex < currentLessons.length - 1
                  ? _nextLesson
                  : _completeLesson,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                currentLessonIndex < currentLessons.length - 1 ? 'Next' : 'Complete',
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

  void _previousLesson() {
    if (currentLessonIndex > 0) {
      setState(() {
        currentLessonIndex--;
        showExplanation = true;
      });
    }
  }

  void _nextLesson() {
    if (currentLessonIndex < currentLessons.length - 1) {
      setState(() {
        currentLessonIndex++;
        showExplanation = true;
      });
    }
  }

  void _completeLesson() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2128),
        title: Text(
          'Congratulations! 🎉',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          'You\'ve completed all ${widget.level} grammar lessons!\n\nReady to practice with some exercises?',
          style: GoogleFonts.poppins(color: Colors.white70),
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
              // Navigate to practice exercises
            },
            child: Text(
              'Practice Now',
              style: GoogleFonts.poppins(color: const Color(0xFF8B5CF6)),
            ),
          ),
        ],
      ),
    );
  }
}