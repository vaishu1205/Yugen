import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late AnimationController _timerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _timerAnimation;

  // Quiz state
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _quizStarted = false;
  bool _quizCompleted = false;

  // Quiz settings
  String _selectedCategory = 'Grammar';
  String _selectedLevel = 'N5';
  int _questionCount = 10;
  bool _isTimedQuiz = true;
  int _timePerQuestion = 30; // seconds

  // Current question state
  String? _selectedAnswer;
  bool _isAnswered = false;
  bool _showExplanation = false;

  // Quiz tracking
  int _correctAnswers = 0;
  int _totalAnswers = 0;
  int _streak = 0;
  int _maxStreak = 0;
  List<QuizResult> _quizResults = [];
  DateTime _quizStartTime = DateTime.now();

  // Timer
  Timer? _questionTimer;
  int _remainingTime = 30;

  // Real-time data
  StreamSubscription<QuerySnapshot>? _quizSubscription;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadQuizQuestions();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _timerController = AnimationController(
      duration: Duration(seconds: _timePerQuestion),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );

    _timerAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _timerController, curve: Curves.linear),
    );

    _fadeController.forward();
  }

  void _loadQuizQuestions() {
    // Generate sample quiz questions based on category and level
    _questions = _generateSampleQuestions(_selectedCategory, _selectedLevel, _questionCount);
    setState(() {
      _isLoading = false;
    });
  }

  List<QuizQuestion> _generateSampleQuestions(String category, String level, int count) {
    final List<QuizQuestion> questions = [];

    if (category == 'Grammar') {
      final grammarQuestions = [
        QuizQuestion(
          id: '1',
          question: 'Which particle is used to mark the direct object?',
          options: ['は', 'が', 'を', 'に'],
          correctAnswer: 'を',
          explanation: 'を (wo) is the particle used to mark the direct object in Japanese sentences.',
          category: 'Grammar',
          level: level,
          difficulty: 1,
        ),
        QuizQuestion(
          id: '2',
          question: 'What does です (desu) do in a sentence?',
          options: ['Makes it polite', 'Makes it past tense', 'Makes it negative', 'Makes it a question'],
          correctAnswer: 'Makes it polite',
          explanation: 'です (desu) is a polite copula that makes sentences more formal and polite.',
          category: 'Grammar',
          level: level,
          difficulty: 1,
        ),
        QuizQuestion(
          id: '3',
          question: 'How do you say "I went" in polite form?',
          options: ['行きます', '行きました', '行く', '行った'],
          correctAnswer: '行きました',
          explanation: '行きました (ikimashita) is the polite past tense form of 行く (iku - to go).',
          category: 'Grammar',
          level: level,
          difficulty: 2,
        ),
        QuizQuestion(
          id: '4',
          question: 'Which particle indicates the location where an action takes place?',
          options: ['で', 'に', 'へ', 'から'],
          correctAnswer: 'で',
          explanation: 'で (de) indicates the location where an action takes place.',
          category: 'Grammar',
          level: level,
          difficulty: 2,
        ),
        QuizQuestion(
          id: '5',
          question: 'What is the て-form of 食べる (taberu)?',
          options: ['食べて', '食べた', '食べない', '食べます'],
          correctAnswer: '食べて',
          explanation: '食べて (tabete) is the て-form of 食べる (taberu - to eat).',
          category: 'Grammar',
          level: level,
          difficulty: 2,
        ),
      ];
      questions.addAll(grammarQuestions);
    } else if (category == 'Vocabulary') {
      final vocabQuestions = [
        QuizQuestion(
          id: '6',
          question: 'What does 水 (mizu) mean?',
          options: ['Fire', 'Water', 'Air', 'Earth'],
          correctAnswer: 'Water',
          explanation: '水 (mizu) means water in Japanese.',
          category: 'Vocabulary',
          level: level,
          difficulty: 1,
        ),
        QuizQuestion(
          id: '7',
          question: 'How do you say "thank you" in Japanese?',
          options: ['すみません', 'ありがとう', 'おはよう', 'こんにちは'],
          correctAnswer: 'ありがとう',
          explanation: 'ありがとう (arigatou) means "thank you" in Japanese.',
          category: 'Vocabulary',
          level: level,
          difficulty: 1,
        ),
        QuizQuestion(
          id: '8',
          question: 'What does 学校 (gakkou) mean?',
          options: ['Hospital', 'School', 'Library', 'Restaurant'],
          correctAnswer: 'School',
          explanation: '学校 (gakkou) means school in Japanese.',
          category: 'Vocabulary',
          level: level,
          difficulty: 1,
        ),
      ];
      questions.addAll(vocabQuestions);
    } else if (category == 'Kanji') {
      final kanjiQuestions = [
        QuizQuestion(
          id: '9',
          question: 'What is the meaning of 人?',
          options: ['Person', 'Tree', 'Water', 'Fire'],
          correctAnswer: 'Person',
          explanation: '人 means person or people in Japanese.',
          category: 'Kanji',
          level: level,
          difficulty: 1,
        ),
        QuizQuestion(
          id: '10',
          question: 'How do you read 日本?',
          options: ['にほん', 'ちゅうごく', 'かんこく', 'あめりか'],
          correctAnswer: 'にほん',
          explanation: '日本 is read as にほん (nihon) and means Japan.',
          category: 'Kanji',
          level: level,
          difficulty: 2,
        ),
      ];
      questions.addAll(kanjiQuestions);
    }

    questions.shuffle();
    return questions.take(count).toList();
  }

  void _startQuiz() {
    setState(() {
      _quizStarted = true;
      _currentQuestionIndex = 0;
      _quizStartTime = DateTime.now();
    });
    _progressController.forward();
    if (_isTimedQuiz) {
      _startQuestionTimer();
    }
  }

  void _startQuestionTimer() {
    _remainingTime = _timePerQuestion;
    _timerController.reset();
    _timerController.forward();

    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
      });

      if (_remainingTime <= 0) {
        _timeUp();
      }
    });
  }

  void _timeUp() {
    if (!_isAnswered) {
      _selectAnswer(null); // Auto-submit as wrong
    }
  }

  void _selectAnswer(String? answer) {
    if (_isAnswered) return;

    _questionTimer?.cancel();
    _timerController.stop();

    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
    });

    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = answer == currentQuestion.correctAnswer;

    _recordAnswer(isCorrect);

    // Show result for 2 seconds, then move to next
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showExplanation = true;
        });

        // Show explanation for 3 seconds, then move to next
        Timer(const Duration(seconds: 3), () {
          if (mounted) {
            _nextQuestion();
          }
        });
      }
    });
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

    final currentQuestion = _questions[_currentQuestionIndex];
    _quizResults.add(QuizResult(
      questionId: currentQuestion.id,
      question: currentQuestion.question,
      userAnswer: _selectedAnswer ?? 'No Answer',
      correctAnswer: currentQuestion.correctAnswer,
      isCorrect: isCorrect,
      timeTaken: _isTimedQuiz ? _timePerQuestion - _remainingTime : 0,
    ));
  }

  void _nextQuestion() {
    if (_currentQuestionIndex >= _questions.length - 1) {
      _finishQuiz();
      return;
    }

    setState(() {
      _currentQuestionIndex++;
      _selectedAnswer = null;
      _isAnswered = false;
      _showExplanation = false;
    });

    if (_isTimedQuiz) {
      _startQuestionTimer();
    }
  }

  void _finishQuiz() {
    _questionTimer?.cancel();
    setState(() {
      _quizCompleted = true;
    });
    _saveQuizResults();
  }

  Future<void> _saveQuizResults() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final accuracy = _totalAnswers > 0 ? (_correctAnswers / _totalAnswers * 100).round() : 0;
      final duration = DateTime.now().difference(_quizStartTime).inMinutes;
      final xpEarned = _calculateXPEarned();

      // UPDATED: Match the field names that StudyHistoryScreen expects
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('study_sessions')
          .add({
        'activity': 'Grammar Quiz', // This matches what StudyHistoryScreen looks for
        'date': FieldValue.serverTimestamp(), // This matches
        'duration': duration, // This matches
        'xpEarned': xpEarned, // This matches
        'score': accuracy, // This matches
        'topics': [_selectedCategory], // This matches
        'difficulty': _selectedLevel, // This matches

        // Additional quiz-specific data
        'quizData': {
          'category': _selectedCategory,
          'level': _selectedLevel,
          'questionCount': _questionCount,
          'correctAnswers': _correctAnswers,
          'totalAnswers': _totalAnswers,
          'accuracy': accuracy,
          'maxStreak': _maxStreak,
          'isTimedQuiz': _isTimedQuiz,
          'timePerQuestion': _timePerQuestion,
          'results': _quizResults.map((r) => r.toMap()).toList(),
        },
      });

      print("🔥 Quiz results saved successfully!"); // Add debug log

      // Update user stats
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'totalXP': FieldValue.increment(xpEarned),
        'quizzesCompleted': FieldValue.increment(1),
        if (accuracy == 100) 'perfectScores': FieldValue.increment(1),
      });

      print("🔥 User stats updated successfully!"); // Add debug log

    } catch (e) {
      print('🔥 Error saving quiz results: $e');
    }
  }

  int _calculateXPEarned() {
    int baseXP = _correctAnswers * 15;
    int streakBonus = _maxStreak > 3 ? (_maxStreak - 3) * 10 : 0;
    int speedBonus = 0;
    int accuracyBonus = 0;

    if (_isTimedQuiz) {
      // Bonus for answering quickly
      final avgTimePerQuestion = _quizResults.isNotEmpty
          ? _quizResults.map((r) => r.timeTaken).reduce((a, b) => a + b) / _quizResults.length
          : _timePerQuestion.toDouble();

      if (avgTimePerQuestion < _timePerQuestion * 0.5) {
        speedBonus = 25;
      } else if (avgTimePerQuestion < _timePerQuestion * 0.7) {
        speedBonus = 15;
      }
    }

    if (_totalAnswers > 0) {
      final accuracy = _correctAnswers / _totalAnswers;
      if (accuracy == 1.0) accuracyBonus = 100; // Perfect score
      else if (accuracy >= 0.9) accuracyBonus = 50;
      else if (accuracy >= 0.8) accuracyBonus = 25;
    }

    return baseXP + streakBonus + speedBonus + accuracyBonus;
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _quizSubscription?.cancel();
    _fadeController.dispose();
    _progressController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 375;

            if (_isLoading) {
              return _buildLoadingState();
            } else if (!_quizStarted) {
              return _buildQuizSetup(isSmallScreen);
            } else if (_quizCompleted) {
              return _buildQuizResults(isSmallScreen);
            } else {
              return _buildQuizInterface(isSmallScreen);
            }
          },
        ),
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
              gradient: const LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
              ),
              borderRadius: BorderRadius.circular(20),
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
            'Preparing your quiz...',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }


Widget _buildQuizSetup(bool isSmallScreen) {
  return FadeTransition(
    opacity: _fadeAnimation,
    child: Column(
      children: [
        _buildSetupHeader(isSmallScreen),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategorySelector(isSmallScreen),
                const SizedBox(height: 24),
                _buildLevelSelector(isSmallScreen),
                const SizedBox(height: 24),
                _buildQuestionCountSelector(isSmallScreen),
                const SizedBox(height: 24),
                _buildTimerSettings(isSmallScreen),
                const SizedBox(height: 40),
                _buildStartButton(isSmallScreen),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildSetupHeader(bool isSmallScreen) {
  return Container(
    padding: const EdgeInsets.all(20),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF9C27B0),
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
              Text(
                'Japanese Quiz',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                'Test your knowledge',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.quiz,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    ),
  );
}

Widget _buildCategorySelector(bool isSmallScreen) {
  final categories = ['Grammar', 'Vocabulary', 'Kanji', 'Reading'];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Quiz Category',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F2937),
        ),
      ),
      const SizedBox(height: 12),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isSmallScreen ? 2 : 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
              _loadQuizQuestions();
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF9C27B0) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFF9C27B0) : const Color(0xFFE5E7EB),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ],
  );
}

Widget _buildLevelSelector(bool isSmallScreen) {
  final levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'JLPT Level',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F2937),
        ),
      ),
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: levels.map((level) {
            final isSelected = _selectedLevel == level;
            return Container(
              margin: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedLevel = level;
                  });
                  _loadQuizQuestions();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF9C27B0) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF9C27B0) : const Color(0xFFE5E7EB),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    level,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

Widget _buildQuestionCountSelector(bool isSmallScreen) {
  final counts = [5, 10, 15, 20];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Number of Questions',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F2937),
        ),
      ),
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: counts.map((count) {
            final isSelected = _questionCount == count;
            return Container(
              margin: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _questionCount = count;
                  });
                  _loadQuizQuestions();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF9C27B0) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF9C27B0) : const Color(0xFFE5E7EB),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

Widget _buildTimerSettings(bool isSmallScreen) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Timed Quiz',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            Switch(
              value: _isTimedQuiz,
              onChanged: (value) {
                setState(() {
                  _isTimedQuiz = value;
                });
              },
              activeColor: const Color(0xFF9C27B0),
            ),
          ],
        ),
        if (_isTimedQuiz) ...[
          const SizedBox(height: 16),
          Text(
            'Time per question: $_timePerQuestion seconds',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _timePerQuestion.toDouble(),
            min: 15,
            max: 60,
            divisions: 9,
            activeColor: const Color(0xFF9C27B0),
            onChanged: (value) {
              setState(() {
                _timePerQuestion = value.round();
              });
            },
          ),
        ],
      ],
    ),
  );
}

Widget _buildStartButton(bool isSmallScreen) {
  return Container(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9C27B0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        elevation: 0,
      ),
      onPressed: _startQuiz,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Start Quiz',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildQuizInterface(bool isSmallScreen) {
  final currentQuestion = _questions[_currentQuestionIndex];
  final progress = (_currentQuestionIndex + 1) / _questions.length;

  return Column(
    children: [
      _buildQuizHeader(isSmallScreen, progress),
      if (_isTimedQuiz) _buildTimer(isSmallScreen),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildQuestionCard(currentQuestion, isSmallScreen),
              const SizedBox(height: 24),
              _buildAnswerOptions(currentQuestion, isSmallScreen),
              if (_showExplanation) ...[
                const SizedBox(height: 24),
                _buildExplanation(currentQuestion, isSmallScreen),
              ],
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _buildQuizHeader(bool isSmallScreen, double progress) {
  return Container(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Color(0xFF9C27B0),
                  size: 20,
                ),
                onPressed: () => _showQuitDialog(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    '$_selectedCategory Quiz • $_selectedLevel',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            if (_streak > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5722).withOpacity(0.1),
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF5722),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: progress * _progressAnimation.value,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
              minHeight: 6,
            );
          },
        ),
      ],
    ),
  );
}

Widget _buildTimer(bool isSmallScreen) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _remainingTime <= 5 ? const Color(0xFFEF4444).withOpacity(0.1) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: _remainingTime <= 5 ? const Color(0xFFEF4444) : const Color(0xFFE5E7EB),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.timer,
          color: _remainingTime <= 5 ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          '${_remainingTime}s',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _remainingTime <= 5 ? const Color(0xFFEF4444) : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AnimatedBuilder(
            animation: _timerAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _timerAnimation.value,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _remainingTime <= 5 ? const Color(0xFFEF4444) : const Color(0xFF9C27B0),
                ),
                minHeight: 4,
              );
            },
          ),
        ),
      ],
    ),
  );
}

Widget _buildQuestionCard(QuizQuestion question, bool isSmallScreen) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF9C27B0),
          Color(0xFFE1BEE7),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF9C27B0).withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            question.category,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          question.question,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        if (question.difficulty > 0) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Icon(
                index < question.difficulty ? Icons.star : Icons.star_border,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              );
            }),
          ),
        ],
      ],
    ),
  );
}

Widget _buildAnswerOptions(QuizQuestion question, bool isSmallScreen) {
  return Column(
    children: question.options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      final isCorrect = option == question.correctAnswer;
      final isSelected = _selectedAnswer == option;

      Color backgroundColor = Colors.white;
      Color borderColor = const Color(0xFFE5E7EB);
      Color textColor = const Color(0xFF1F2937);
      IconData? icon;

      if (_isAnswered) {
        if (isSelected && isCorrect) {
          backgroundColor = const Color(0xFF10B981).withOpacity(0.1);
          borderColor = const Color(0xFF10B981);
          textColor = const Color(0xFF10B981);
          icon = Icons.check_circle;
        } else if (isSelected && !isCorrect) {
          backgroundColor = const Color(0xFFEF4444).withOpacity(0.1);
          borderColor = const Color(0xFFEF4444);
          textColor = const Color(0xFFEF4444);
          icon = Icons.cancel;
        } else if (isCorrect) {
          backgroundColor = const Color(0xFF10B981).withOpacity(0.1);
          borderColor = const Color(0xFF10B981);
          textColor = const Color(0xFF10B981);
          icon = Icons.check_circle;
        }
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
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: GoogleFonts.poppins(
                        fontSize: 14,
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
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: textColor,
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }).toList(),
  );
}

Widget _buildExplanation(QuizQuestion question, bool isSmallScreen) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF3B82F6).withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFF3B82F6).withOpacity(0.3),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb,
              color: const Color(0xFF3B82F6),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Explanation',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          question.explanation,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 15,
            color: const Color(0xFF1F2937),
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

Widget _buildQuizResults(bool isSmallScreen) {
  final accuracy = _totalAnswers > 0 ? (_correctAnswers / _totalAnswers * 100).round() : 0;
  final xpEarned = _calculateXPEarned();
  final duration = DateTime.now().difference(_quizStartTime);

  return FadeTransition(
    opacity: _fadeAnimation,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: accuracy >= 80
                    ? [const Color(0xFF10B981), const Color(0xFF34D399)]
                    : accuracy >= 60
                    ? [const Color(0xFFFFC107), const Color(0xFFFCD34D)]
                    : [const Color(0xFFEF4444), const Color(0xFFF87171)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (accuracy >= 80 ? const Color(0xFF10B981) :
                  accuracy >= 60 ? const Color(0xFFFFC107) :
                  const Color(0xFFEF4444)).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              accuracy >= 80 ? Icons.emoji_events :
              accuracy >= 60 ? Icons.thumb_up : Icons.refresh,
              color: Colors.white,
              size: 60,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            accuracy >= 80 ? 'Excellent!' :
            accuracy >= 60 ? 'Good Job!' : 'Keep Practicing!',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quiz completed!',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildResultRow('Score', '$accuracy%', Icons.grade),
                _buildResultRow('Correct Answers', '$_correctAnswers/$_totalAnswers', Icons.check),
                _buildResultRow('Best Streak', '$_maxStreak', Icons.local_fire_department),
                _buildResultRow('Time Taken', '${duration.inMinutes}m ${duration.inSeconds % 60}s', Icons.timer),
                _buildResultRow('XP Earned', '+$xpEarned', Icons.star),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _restartQuiz,
                  child: Text(
                    'Take Again',
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
                    side: const BorderSide(color: Color(0xFF9C27B0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Finish',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF9C27B0),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

Widget _buildResultRow(String label, String value, IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF9C27B0),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Quit Quiz?',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F2937),
        ),
      ),
      content: Text(
        'Your progress will be saved, but you won\'t earn full XP.',
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: const Color(0xFF6B7280),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Continue Quiz',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
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
            Navigator.pop(context);
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

void _restartQuiz() {
  setState(() {
    _currentQuestionIndex = 0;
    _correctAnswers = 0;
    _totalAnswers = 0;
    _streak = 0;
    _maxStreak = 0;
    _quizResults.clear();
    _quizStarted = false;
    _quizCompleted = false;
    _selectedAnswer = null;
    _isAnswered = false;
    _showExplanation = false;
  });

  _questionTimer?.cancel();
  _loadQuizQuestions();
}
}

// Data models
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String category;
  final String level;
  final int difficulty;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.category,
    required this.level,
    required this.difficulty,
  });
}

class QuizResult {
  final String questionId;
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final int timeTaken;

  QuizResult({
    required this.questionId,
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.timeTaken,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'question': question,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'timeTaken': timeTaken,
    };
  }
}