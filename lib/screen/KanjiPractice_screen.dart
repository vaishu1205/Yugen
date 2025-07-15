import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KanjiPracticeScreen extends StatefulWidget {
  const KanjiPracticeScreen({super.key});

  @override
  State<KanjiPracticeScreen> createState() => _KanjiPracticeScreenState();
}

class _KanjiPracticeScreenState extends State<KanjiPracticeScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _progressController;
  late AnimationController _bounceController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _bounceAnimation;

  // Current practice state
  List<KanjiData> _learnedKanjiCards = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  // Practice settings
  String _practiceMode = 'Recognition';
  int _sessionLength = 10;
  String _selectedLevel = 'N5';

  // Session tracking
  int _correctAnswers = 0;
  int _totalAnswers = 0;
  int _streak = 0;
  int _maxStreak = 0;
  List<KanjiResult> _sessionResults = [];
  DateTime _sessionStartTime = DateTime.now();

  // Current question data
  KanjiData? _currentKanji;
  List<String> _multipleChoiceOptions = [];
  String? _selectedAnswer;
  bool _isAnswered = false;

  // Real-time data
  StreamSubscription<DocumentSnapshot>? _userDataSubscription;

  // Complete Kanji database
  final Map<String, List<KanjiData>> _kanjiDatabase = {
    'N5': [
      KanjiData(
        character: '学',
        meaning: 'Learn, Study',
        readings: ['がく', 'まな'],
        strokeCount: 8,
        examples: ['学校 (gakkou) - school'],
        mnemonic: 'A child under a roof learning!',
        level: 'N5',
      ),
      KanjiData(
        character: '友',
        meaning: 'Friend',
        readings: ['とも', 'ゆう'],
        strokeCount: 4,
        examples: ['友達 (tomodachi) - friend'],
        mnemonic: 'Two hands reaching out!',
        level: 'N5',
      ),
      KanjiData(
        character: '日',
        meaning: 'Sun, Day',
        readings: ['ひ', 'にち'],
        strokeCount: 4,
        examples: ['今日 (kyou) - today'],
        mnemonic: 'Picture of the sun!',
        level: 'N5',
      ),
      KanjiData(
        character: '本',
        meaning: 'Book, Origin',
        readings: ['ほん', 'もと'],
        strokeCount: 5,
        examples: ['本 (hon) - book'],
        mnemonic: 'A tree with roots!',
        level: 'N5',
      ),
      KanjiData(
        character: '人',
        meaning: 'Person, Human',
        readings: ['ひと', 'じん'],
        strokeCount: 2,
        examples: ['人 (hito) - person'],
        mnemonic: 'Person walking with legs!',
        level: 'N5',
      ),
      KanjiData(
        character: '水',
        meaning: 'Water',
        readings: ['みず', 'すい'],
        strokeCount: 4,
        examples: ['水 (mizu) - water'],
        mnemonic: 'Flowing water stream!',
        level: 'N5',
      ),
      KanjiData(
        character: '火',
        meaning: 'Fire',
        readings: ['ひ', 'か'],
        strokeCount: 4,
        examples: ['火 (hi) - fire'],
        mnemonic: 'Flames rising up!',
        level: 'N5',
      ),
      KanjiData(
        character: '木',
        meaning: 'Tree, Wood',
        readings: ['き', 'もく'],
        strokeCount: 4,
        examples: ['木 (ki) - tree'],
        mnemonic: 'A tree with branches!',
        level: 'N5',
      ),
    ],
  };

  // Theme colors
  static const Color _primaryColor = Color(0xFF6366F1);
  static const Color _secondaryColor = Color(0xFFEC4899);
  static const Color _accentColor = Color(0xFF10B981);
  static const Color _warningColor = Color(0xFFF59E0B);
  static const Color _backgroundColor = Color(0xFFF8FAFC);
  static const Color _cardColor = Colors.white;
  static const Color _textPrimary = Color(0xFF1E293B);
  static const Color _textSecondary = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadUserProgress();
    _sessionStartTime = DateTime.now();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticInOut),
    );

    _slideController.forward();
    _bounceController.repeat(reverse: true);
  }

  void _loadUserProgress() {
    print('=== LOADING USER PROGRESS ===');
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userDataSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && mounted) {
          final data = snapshot.data()!;
          print('User data loaded: ${data.keys}');

          setState(() {
            _selectedLevel = data['jlptLevel'] ?? 'N5';
            final learnedKanjiIds = List<String>.from(data['learnedKanji'] ?? []);
            print('Learned kanji IDs: $learnedKanjiIds');
            _loadLearnedKanji(learnedKanjiIds);
          });
        }
      });
    } else {
      // No user - load all N5 kanji for demo
      print('No user - loading demo kanji');
      _loadDemoKanji();
    }
  }

  void _loadLearnedKanji(List<String> learnedKanjiIds) {
    print('=== LOADING LEARNED KANJI ===');
    print('Learned IDs: $learnedKanjiIds');

    _learnedKanjiCards = [];

    // Get kanji that user has learned
    for (String level in _kanjiDatabase.keys) {
      final levelKanji = _kanjiDatabase[level] ?? [];
      for (var kanji in levelKanji) {
        if (learnedKanjiIds.contains(kanji.character)) {
          _learnedKanjiCards.add(kanji);
          print('Added learned kanji: ${kanji.character} - ${kanji.meaning}');
        }
      }
    }

    // If no learned kanji, load demo
    if (_learnedKanjiCards.isEmpty) {
      print('No learned kanji found - loading demo');
      _loadDemoKanji();
      return;
    }

    print('Total learned kanji: ${_learnedKanjiCards.length}');
    _learnedKanjiCards.shuffle();
    _startQuizSession();
  }

  void _loadDemoKanji() {
    print('=== LOADING DEMO KANJI ===');
    _learnedKanjiCards = _kanjiDatabase['N5'] ?? [];
    print('Demo kanji loaded: ${_learnedKanjiCards.length}');
    _learnedKanjiCards.shuffle();
    _startQuizSession();
  }

  void _startQuizSession() {
    print('=== STARTING QUIZ SESSION ===');
    setState(() {
      _currentIndex = 0;
      _correctAnswers = 0;
      _totalAnswers = 0;
      _streak = 0;
      _maxStreak = 0;
      _sessionResults.clear();
      _isLoading = false;
    });

    if (_learnedKanjiCards.isNotEmpty) {
      _generateNextQuestion();
    }
    _progressController.forward();
  }

  void _generateNextQuestion() {
    print('=== GENERATING QUESTION ${_currentIndex + 1} ===');

    if (_currentIndex >= _sessionLength || _learnedKanjiCards.isEmpty) {
      print('Quiz complete - finishing session');
      _finishSession();
      return;
    }

    final kanjiIndex = _currentIndex % _learnedKanjiCards.length;
    final selectedKanji = _learnedKanjiCards[kanjiIndex];

    print('Selected kanji: ${selectedKanji.character} - ${selectedKanji.meaning}');

    setState(() {
      _currentKanji = selectedKanji;
      _isAnswered = false;
      _selectedAnswer = null;
    });

    _generateMultipleChoice();
    _slideController.reset();
    _slideController.forward();
  }

  void _generateMultipleChoice() {
    if (_currentKanji == null) return;

    print('=== GENERATING MULTIPLE CHOICE ===');
    final correctAnswer = _getCorrectAnswer();
    final wrongAnswers = _getWrongAnswers(correctAnswer);

    setState(() {
      _multipleChoiceOptions = [correctAnswer, ...wrongAnswers];
      _multipleChoiceOptions.shuffle();
    });

    print('Options: $_multipleChoiceOptions');
    print('Correct answer: $correctAnswer');
  }

  String _getCorrectAnswer() {
    if (_currentKanji == null) return '';

    switch (_practiceMode) {
      case 'Reading':
        return _currentKanji!.readings.isNotEmpty ? _currentKanji!.readings.first : _currentKanji!.character;
      case 'Meaning':
        return _currentKanji!.meaning;
      default: // Recognition
        return _currentKanji!.character;
    }
  }

  List<String> _getWrongAnswers(String correctAnswer) {
    List<String> wrongAnswers = [];
    final otherKanji = _learnedKanjiCards.where((k) => k.character != _currentKanji!.character).toList();
    otherKanji.shuffle();

    for (var kanji in otherKanji.take(6)) {
      String option;
      switch (_practiceMode) {
        case 'Reading':
          option = kanji.readings.isNotEmpty ? kanji.readings.first : kanji.character;
          break;
        case 'Meaning':
          option = kanji.meaning;
          break;
        default: // Recognition
          option = kanji.character;
          break;
      }

      if (option != correctAnswer && !wrongAnswers.contains(option)) {
        wrongAnswers.add(option);
        if (wrongAnswers.length >= 3) break;
      }
    }

    // Fill with fallbacks if needed
    final fallbacks = _getFallbackOptions();
    for (var option in fallbacks) {
      if (wrongAnswers.length >= 3) break;
      if (option != correctAnswer && !wrongAnswers.contains(option)) {
        wrongAnswers.add(option);
      }
    }

    return wrongAnswers.take(3).toList();
  }

  List<String> _getFallbackOptions() {
    switch (_practiceMode) {
      case 'Reading':
        return ['よみ', 'かん', 'じ', 'かな'];
      case 'Meaning':
        return ['Water', 'Fire', 'Earth', 'Wind'];
      default:
        return ['漢', '字', '文', '語'];
    }
  }

  void _selectAnswer(String answer) {
    if (_isAnswered) return;

    print('=== ANSWER SELECTED: $answer ===');
    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
    });

    final isCorrect = answer == _getCorrectAnswer();
    _recordAnswer(isCorrect);

    print('Answer is correct: $isCorrect');
  }

  void _recordAnswer(bool isCorrect) {
    setState(() {
      _totalAnswers++;
      if (isCorrect) {
        _correctAnswers++;
        _streak++;
        _maxStreak = math.max(_maxStreak, _streak);
      } else {
        _streak = 0;
      }
    });

    if (_currentKanji != null) {
      _sessionResults.add(KanjiResult(
        kanjiId: _currentKanji!.character,
        kanji: _currentKanji!.character,
        isCorrect: isCorrect,
        timeTaken: DateTime.now().difference(_sessionStartTime),
        practiceMode: _practiceMode,
      ));
    }

    _updateKanjiProgress(isCorrect);
  }

  Future<void> _updateKanjiProgress(bool isCorrect) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _currentKanji == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'kanjiPracticeCount': FieldValue.increment(1),
        'kanjiCorrectAnswers': isCorrect ? FieldValue.increment(1) : FieldValue.increment(0),
        'totalKanjiPracticed': FieldValue.increment(1),
        'lastPracticeDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating progress: $e');
    }
  }

  void _nextQuestion() {
    if (!_isAnswered) return;

    print('=== MOVING TO NEXT QUESTION ===');
    setState(() {
      _currentIndex++;
    });
    _generateNextQuestion();
  }

  void _finishSession() {
    print('=== FINISHING SESSION ===');
    _saveSessionToFirebase();
    _showResultsDialog();
  }

  Future<void> _saveSessionToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final accuracy = _totalAnswers > 0 ? (_correctAnswers / _totalAnswers) : 0.0;
      final sessionDuration = DateTime.now().difference(_sessionStartTime);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('study_sessions')
          .add({
        'type': 'kanji_practice',
        'mode': _practiceMode,
        'level': _selectedLevel,
        'totalQuestions': _sessionLength,
        'answeredQuestions': _totalAnswers,
        'correctAnswers': _correctAnswers,
        'accuracy': (accuracy * 100).round(),
        'maxStreak': _maxStreak,
        'duration': sessionDuration.inMinutes,
        'xpEarned': _calculateXPEarned(),
        'date': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'totalXP': FieldValue.increment(_calculateXPEarned()),
        'quizzesCompleted': FieldValue.increment(1),
        'lastStudyDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  int _calculateXPEarned() {
    int baseXP = _correctAnswers * 10;
    int streakBonus = _maxStreak > 3 ? (_maxStreak - 3) * 5 : 0;
    int accuracyBonus = 0;

    if (_totalAnswers > 0) {
      final accuracy = _correctAnswers / _totalAnswers;
      if (accuracy >= 0.9) accuracyBonus = 50;
      else if (accuracy >= 0.8) accuracyBonus = 30;
      else if (accuracy >= 0.7) accuracyBonus = 15;
    }

    return baseXP + streakBonus + accuracyBonus;
  }

  void _showResultsDialog() {
    final accuracy = _totalAnswers > 0 ? (_correctAnswers / _totalAnswers * 100).round() : 0;
    final xpEarned = _calculateXPEarned();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: accuracy >= 80
                        ? [_accentColor, const Color(0xFF34D399)]
                        : accuracy >= 60
                        ? [_warningColor, const Color(0xFFFCD34D)]
                        : [const Color(0xFFEF4444), const Color(0xFFF87171)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  accuracy >= 80 ? Icons.emoji_events :
                  accuracy >= 60 ? Icons.thumb_up : Icons.refresh,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Practice Complete!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildResultRow('Accuracy', '$accuracy%'),
                    _buildResultRow('Correct', '$_correctAnswers/$_totalAnswers'),
                    _buildResultRow('Best Streak', '$_maxStreak'),
                    _buildResultRow('XP Earned', '+$xpEarned'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _restartPractice();
                      },
                      child: Text(
                        'Practice Again',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Finish',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: _primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: _textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _restartPractice() {
    _learnedKanjiCards.shuffle();
    _startQuizSession();
  }

  @override
  void dispose() {
    _userDataSubscription?.cancel();
    _slideController.dispose();
    _progressController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 375;
            return Column(
              children: [
                _buildHeader(isSmallScreen),
                if (_isLoading)
                  Expanded(child: _buildLoadingState())
                else if (_learnedKanjiCards.isEmpty)
                  Expanded(child: _buildEmptyState())
                else ...[
                    _buildProgressBar(isSmallScreen),
                    _buildModeSelector(isSmallScreen),
                    Expanded(child: _buildPracticeCard(isSmallScreen)),
                    _buildAnswerOptions(isSmallScreen),
                    _buildNavigationButtons(isSmallScreen),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor, _secondaryColor],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Kanji Practice',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('🎯', style: TextStyle(fontSize: isSmallScreen ? 16 : 20)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_accentColor, const Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Level $_selectedLevel • $_practiceMode Mode',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _bounceAnimation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_warningColor, const Color(0xFFFCD34D)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_correctAnswers/$_totalAnswers',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
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
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_accentColor, const Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your kanji...',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.school_rounded,
                size: 60,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Kanji to Practice',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start learning kanji from the learning section\nto practice them here!',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: _textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_stories, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Start Learning Kanji',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(bool isSmallScreen) {
    final progress = _sessionLength > 0 ? (_currentIndex + 1) / _sessionLength : 0.0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentIndex + 1} of $_sessionLength',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              if (_streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF5722), Color(0xFFFF8A65)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        '$_streak',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress * _progressAnimation.value,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                    minHeight: 8,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(bool isSmallScreen) {
    final modes = ['Recognition', 'Reading', 'Meaning'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: modes.map((mode) {
          final isSelected = _practiceMode == mode;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: GestureDetector(
                onTap: () {
                  if (!_isAnswered) {
                    setState(() {
                      _practiceMode = mode;
                    });
                    _generateMultipleChoice();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                      colors: [_primaryColor, _secondaryColor],
                    )
                        : null,
                    color: isSelected ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : null,
                  ),
                  child: Text(
                    mode,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : _textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // FIXED PRACTICE CARD - Shows question content clearly
  Widget _buildPracticeCard(bool isSmallScreen) {
    print('=== BUILDING PRACTICE CARD ===');
    print('Current kanji: ${_currentKanji?.character}');
    print('Practice mode: $_practiceMode');

    if (_currentKanji == null) {
      return Container(
        margin: const EdgeInsets.all(20),
        height: 200,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'NO KANJI LOADED!',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // Determine what to show based on mode
    String questionTitle = '';
    String displayContent = '';

    switch (_practiceMode) {
      case 'Recognition':
        questionTitle = 'Which kanji has this meaning?';
        displayContent = _currentKanji!.meaning;
        break;
      case 'Reading':
        questionTitle = 'What is the reading?';
        displayContent = _currentKanji!.character;
        break;
      case 'Meaning':
        questionTitle = 'What does this mean?';
        displayContent = _currentKanji!.character;
        break;
    }

    print('Question: $questionTitle');
    print('Display: $displayContent');

    return Container(
      margin: const EdgeInsets.all(20),
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _accentColor,
                const Color(0xFF059669),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _accentColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Question instruction
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    questionTitle,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 20),

                // Main question content
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: isSmallScreen ? 120 : 140,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      displayContent,
                      style: GoogleFonts.poppins(
                        fontSize: _practiceMode == 'Recognition'
                            ? (isSmallScreen ? 18 : 22)  // Text size for meanings
                            : (isSmallScreen ? 48 : 64), // Large size for kanji
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: _practiceMode == 'Recognition' ? 3 : 1,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Level and info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Level ${_currentKanji!.level} • ${_currentKanji!.strokeCount} strokes',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
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

  Widget _buildAnswerOptions(bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _multipleChoiceOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isCorrect = option == _getCorrectAnswer();
          final isSelected = _selectedAnswer == option;

          Color backgroundColor = _cardColor;
          Color borderColor = const Color(0xFFE5E7EB);
          Color textColor = _textPrimary;

          if (_isAnswered && isSelected) {
            if (isCorrect) {
              backgroundColor = _accentColor.withOpacity(0.1);
              borderColor = _accentColor;
              textColor = _accentColor;
            } else {
              backgroundColor = const Color(0xFFEF4444).withOpacity(0.1);
              borderColor = const Color(0xFFEF4444);
              textColor = const Color(0xFFEF4444);
            }
          } else if (_isAnswered && isCorrect) {
            backgroundColor = _accentColor.withOpacity(0.1);
            borderColor = _accentColor;
            textColor = _accentColor;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => _selectAnswer(option),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index), // A, B, C, D
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        option,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (_isAnswered && isSelected) ...[
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? _accentColor : const Color(0xFFEF4444),
                        size: 28,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavigationButtons(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => _showQuitDialog(),
              child: Text(
                'Quit Practice',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAnswered ? _accentColor : _textSecondary.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isAnswered ? _nextQuestion : null,
              child: Text(
                _currentIndex >= _sessionLength - 1 ? 'Finish' : 'Next Question',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Quit Practice? 🤔',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
        content: Text(
          'Your progress will be saved, but you won\'t earn the full XP bonus.',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: _textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Continue',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: _primaryColor,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _finishSession();
            },
            child: Text(
              'Quit',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Data models
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

class KanjiResult {
  final String kanjiId;
  final String kanji;
  final bool isCorrect;
  final Duration timeTaken;
  final String practiceMode;

  KanjiResult({
    required this.kanjiId,
    required this.kanji,
    required this.isCorrect,
    required this.timeTaken,
    required this.practiceMode,
  });

  Map<String, dynamic> toMap() {
    return {
      'kanjiId': kanjiId,
      'kanji': kanji,
      'isCorrect': isCorrect,
      'timeTakenSeconds': timeTaken.inSeconds,
      'practiceMode': practiceMode,
    };
  }
}