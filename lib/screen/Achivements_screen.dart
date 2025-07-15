import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Achievement> _achievements = [];
  bool _isLoading = true;
  StreamSubscription<DocumentSnapshot>? _userDataSubscription;

  // User stats for calculating achievements
  int _studyStreak = 0;
  int _totalXP = 0;
  int _kanjiLearned = 0;
  int _storiesRead = 0;
  int _quizzesCompleted = 0;
  int _lessonsCompleted = 0;
  int _perfectScores = 0;
// NEW VARIABLES FOR TIME-BASED ACHIEVEMENTS:
  List<int> _studyTimes = [];
  int _fastestSessionTime = 0;
  int _maxStreakInSession = 0;
  // Filter states
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Unlocked', 'Locked', 'In Progress'];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _setupRealtimeListeners();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }
  void _setupRealtimeListeners() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userDataSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && mounted) {
          final data = snapshot.data()!;
          setState(() {
            _studyStreak = data['studyStreak'] ?? 0;
            _totalXP = data['totalXP'] ?? 0;
            _kanjiLearned = data['totalKanjiLearned'] ?? 0; // Fixed field name
            _storiesRead = data['storiesRead'] ?? 0;
            _quizzesCompleted = data['quizzesCompleted'] ?? 0;
            _lessonsCompleted = data['lessonsCompleted'] ?? 0;
            _perfectScores = data['perfectScores'] ?? 0;

            // NEW FIELDS:
            _studyTimes = List<int>.from(data['studyTimes'] ?? []);
            _fastestSessionTime = data['fastestSessionTime'] ?? 999999;
            _maxStreakInSession = data['maxStreakInSession'] ?? 0;

            _isLoading = false;
          });
          _updateAchievements();
        }
      });
    }
  }
  // void _setupRealtimeListeners() {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     _userDataSubscription = FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(user.uid)
  //         .snapshots()
  //         .listen((snapshot) {
  //       if (snapshot.exists && mounted) {
  //         final data = snapshot.data()!;
  //         setState(() {
  //           _studyStreak = data['studyStreak'] ?? 0;
  //           _totalXP = data['totalXP'] ?? 0;
  //           _kanjiLearned = data['totalKanjiLearned'] ?? 0;
  //           _storiesRead = data['storiesRead'] ?? 0;
  //           _quizzesCompleted = data['quizzesCompleted'] ?? 0;
  //           _lessonsCompleted = data['lessonsCompleted'] ?? 0;
  //           _perfectScores = data['perfectScores'] ?? 0;
  //           _isLoading = false;
  //         });
  //         _updateAchievements();
  //       }
  //     });
  //   }
  // }
  void _updateAchievements() {
    // Count early morning studies (before 8 AM)
    final earlyBirdCount = _studyTimes.where((hour) => hour < 8).length;

    // Count late night studies (after 10 PM)
    final nightOwlCount = _studyTimes.where((hour) => hour >= 22).length;

    // Check if user has a fast session (under 30 seconds per question on average)
    final hasSpeedDemon = _fastestSessionTime > 0 && _fastestSessionTime <= 30;

    _achievements = [
      // Beginner Achievements
      Achievement(
        id: 'first_step',
        title: 'First Step',
        description: 'Complete your first lesson',
        icon: '👶',
        isUnlocked: _lessonsCompleted > 0,
        color: const Color(0xFF10B981),
        progress: _lessonsCompleted > 0 ? 1.0 : 0.0,
        target: 1,
        category: 'Beginner',
        rarity: 'Common',
        unlockedDate: _lessonsCompleted > 0 ? DateTime.now() : null,
      ),
      Achievement(
        id: 'first_kanji',
        title: 'First Kanji',
        description: 'Learn your first Kanji character',
        icon: '🈶',
        isUnlocked: _kanjiLearned > 0,
        color: const Color(0xFF4CAF50),
        progress: _kanjiLearned > 0 ? 1.0 : 0.0,
        target: 1,
        category: 'Learning',
        rarity: 'Common',
        unlockedDate: _kanjiLearned > 0 ? DateTime.now() : null,
      ),
      Achievement(
        id: 'first_story',
        title: 'Story Explorer',
        description: 'Read your first Japanese story',
        icon: '📖',
        isUnlocked: _storiesRead > 0,
        color: const Color(0xFF2196F3),
        progress: _storiesRead > 0 ? 1.0 : 0.0,
        target: 1,
        category: 'Reading',
        rarity: 'Common',
        unlockedDate: _storiesRead > 0 ? DateTime.now() : null,
      ),

      // Study Streak Achievements
      Achievement(
        id: 'week_streak',
        title: 'Week Warrior',
        description: 'Study for 7 days in a row',
        icon: '🔥',
        isUnlocked: _studyStreak >= 7,
        color: const Color(0xFFFF5722),
        progress: _studyStreak / 7,
        target: 7,
        category: 'Streak',
        rarity: 'Uncommon',
        unlockedDate: _studyStreak >= 7 ? DateTime.now() : null,
      ),
      Achievement(
        id: 'month_streak',
        title: 'Monthly Master',
        description: 'Study for 30 days in a row',
        icon: '🏆',
        isUnlocked: _studyStreak >= 30,
        color: const Color(0xFFFF9800),
        progress: _studyStreak / 30,
        target: 30,
        category: 'Streak',
        rarity: 'Rare',
        unlockedDate: _studyStreak >= 30 ? DateTime.now() : null,
      ),
      Achievement(
        id: 'hundred_streak',
        title: 'Centurion',
        description: 'Study for 100 days in a row',
        icon: '💯',
        isUnlocked: _studyStreak >= 100,
        color: const Color(0xFF9C27B0),
        progress: _studyStreak / 100,
        target: 100,
        category: 'Streak',
        rarity: 'Epic',
        unlockedDate: _studyStreak >= 100 ? DateTime.now() : null,
      ),

      // In-Session Streak Achievement
      Achievement(
        id: 'combo_master',
        title: 'Combo Master',
        description: 'Get 10 correct answers in a row',
        icon: '⚡',
        isUnlocked: _maxStreakInSession >= 10,
        color: const Color(0xFFFFEB3B),
        progress: _maxStreakInSession / 10,
        target: 10,
        category: 'Streak',
        rarity: 'Rare',
        unlockedDate: _maxStreakInSession >= 10 ? DateTime.now() : null,
      ),

      // Knowledge Achievements
      Achievement(
        id: 'kanji_apprentice',
        title: 'Kanji Apprentice',
        description: 'Learn 50 Kanji characters',
        icon: '📝',
        isUnlocked: _kanjiLearned >= 50,
        color: const Color(0xFF607D8B),
        progress: _kanjiLearned / 50,
        target: 50,
        category: 'Learning',
        rarity: 'Uncommon',
        unlockedDate: _kanjiLearned >= 50 ? DateTime.now() : null,
      ),
      Achievement(
        id: 'kanji_master',
        title: 'Kanji Master',
        description: 'Learn 100 Kanji characters',
        icon: '🎓',
        isUnlocked: _kanjiLearned >= 100,
        color: const Color(0xFFE91E63),
        progress: _kanjiLearned / 100,
        target: 100,
        category: 'Learning',
        rarity: 'Rare',
        unlockedDate: _kanjiLearned >= 100 ? DateTime.now() : null,
      ),
      Achievement(
        id: 'kanji_legend',
        title: 'Kanji Legend',
        description: 'Learn 500 Kanji characters',
        icon: '⚡',
        isUnlocked: _kanjiLearned >= 500,
        color: const Color(0xFF673AB7),
        progress: _kanjiLearned / 500,
        target: 500,
        category: 'Learning',
        rarity: 'Legendary',
        unlockedDate: _kanjiLearned >= 500 ? DateTime.now() : null,
      ),

      // Quiz Achievements
      Achievement(
        id: 'quiz_starter',
        title: 'Quiz Starter',
        description: 'Complete 5 quizzes',
        icon: '🧠',
        isUnlocked: _quizzesCompleted >= 5,
        color: const Color(0xFF9C27B0),
        progress: _quizzesCompleted / 5,
        target: 5,
        category: 'Quiz',
        rarity: 'Common',
        unlockedDate: _quizzesCompleted >= 5 ? DateTime.now() : null,
      ),
      Achievement(
        id: 'quiz_master',
        title: 'Quiz Master',
        description: 'Complete 25 quizzes',
        icon: '🎯',
        isUnlocked: _quizzesCompleted >= 25,
        color: const Color(0xFF3F51B5),
        progress: _quizzesCompleted / 25,
        target: 25,
        category: 'Quiz',
        rarity: 'Rare',
        unlockedDate: _quizzesCompleted >= 25 ? DateTime.now() : null,
      ),
      Achievement(
        id: 'perfectionist',
        title: 'Perfectionist',
        description: 'Get 10 perfect quiz scores',
        icon: '💎',
        isUnlocked: _perfectScores >= 10,
        color: const Color(0xFF00BCD4),
        progress: _perfectScores / 10,
        target: 10,
        category: 'Quiz',
        rarity: 'Epic',
        unlockedDate: _perfectScores >= 10 ? DateTime.now() : null,
      ),

      // XP Achievements
      Achievement(
        id: 'xp_collector',
        title: 'XP Collector',
        description: 'Earn 1000 experience points',
        icon: '⭐',
        isUnlocked: _totalXP >= 1000,
        color: const Color(0xFFFFC107),
        progress: _totalXP / 1000,
        target: 1000,
        category: 'Experience',
        rarity: 'Uncommon',
        unlockedDate: _totalXP >= 1000 ? DateTime.now() : null,
      ),
      Achievement(
        id: 'xp_legend',
        title: 'XP Legend',
        description: 'Earn 10000 experience points',
        icon: '👑',
        isUnlocked: _totalXP >= 10000,
        color: const Color(0xFFE91E63),
        progress: _totalXP / 10000,
        target: 10000,
        category: 'Experience',
        rarity: 'Legendary',
        unlockedDate: _totalXP >= 10000 ? DateTime.now() : null,
      ),

      // Reading Achievements
      Achievement(
        id: 'story_reader',
        title: 'Story Reader',
        description: 'Read 5 Japanese stories',
        icon: '📚',
        isUnlocked: _storiesRead >= 5,
        color: const Color(0xFF2196F3),
        progress: _storiesRead / 5,
        target: 5,
        category: 'Reading',
        rarity: 'Common',
        unlockedDate: _storiesRead >= 5 ? DateTime.now() : null,
      ),
      Achievement(
        id: 'bookworm',
        title: 'Bookworm',
        description: 'Read 20 Japanese stories',
        icon: '🐛',
        isUnlocked: _storiesRead >= 20,
        color: const Color(0xFF4CAF50),
        progress: _storiesRead / 20,
        target: 20,
        category: 'Reading',
        rarity: 'Uncommon',
        unlockedDate: _storiesRead >= 20 ? DateTime.now() : null,
      ),
      Achievement(
        id: 'literature_lover',
        title: 'Literature Lover',
        description: 'Read 50 Japanese stories',
        icon: '💝',
        isUnlocked: _storiesRead >= 50,
        color: const Color(0xFFE91E63),
        progress: _storiesRead / 50,
        target: 50,
        category: 'Reading',
        rarity: 'Epic',
        unlockedDate: _storiesRead >= 50 ? DateTime.now() : null,
      ),

      // UPDATED Special Achievements with working logic
      Achievement(
        id: 'early_bird',
        title: 'Early Bird',
        description: 'Study before 8 AM for 7 sessions',
        icon: '🌅',
        isUnlocked: earlyBirdCount >= 7,
        color: const Color(0xFFFF9800),
        progress: earlyBirdCount / 7,
        target: 7,
        category: 'Special',
        rarity: 'Rare',
        unlockedDate: earlyBirdCount >= 7 ? DateTime.now() : null,
      ),
      Achievement(
        id: 'night_owl',
        title: 'Night Owl',
        description: 'Study after 10 PM for 7 sessions',
        icon: '🦉',
        isUnlocked: nightOwlCount >= 7,
        color: const Color(0xFF673AB7),
        progress: nightOwlCount / 7,
        target: 7,
        category: 'Special',
        rarity: 'Rare',
        unlockedDate: nightOwlCount >= 7 ? DateTime.now() : null,
      ),
      Achievement(
        id: 'speed_demon',
        title: 'Speed Demon',
        description: 'Complete a practice session in under 30 seconds per question',
        icon: '⚡',
        isUnlocked: hasSpeedDemon,
        color: const Color(0xFFFFEB3B),
        progress: hasSpeedDemon ? 1.0 : 0.0,
        target: 1,
        category: 'Special',
        rarity: 'Epic',
        unlockedDate: hasSpeedDemon ? DateTime.now() : null,
      ),
    ];
  }
  // void _updateAchievements() {
  //   _achievements = [
  //     // Beginner Achievements
  //     Achievement(
  //       id: 'first_step',
  //       title: 'First Step',
  //       description: 'Complete your first lesson',
  //       icon: '👶',
  //       isUnlocked: _lessonsCompleted > 0,
  //       color: const Color(0xFF10B981),
  //       progress: _lessonsCompleted > 0 ? 1.0 : 0.0,
  //       target: 1,
  //       category: 'Beginner',
  //       rarity: 'Common',
  //       unlockedDate: _lessonsCompleted > 0 ? DateTime.now() : null,
  //     ),
  //     Achievement(
  //       id: 'first_kanji',
  //       title: 'First Kanji',
  //       description: 'Learn your first Kanji character',
  //       icon: '🈶',
  //       isUnlocked: _kanjiLearned > 0,
  //       color: const Color(0xFF4CAF50),
  //       progress: _kanjiLearned > 0 ? 1.0 : 0.0,
  //       target: 1,
  //       category: 'Learning',
  //       rarity: 'Common',
  //       unlockedDate: _kanjiLearned > 0 ? DateTime.now() : null,
  //     ),
  //     Achievement(
  //       id: 'first_story',
  //       title: 'Story Explorer',
  //       description: 'Read your first Japanese story',
  //       icon: '📖',
  //       isUnlocked: _storiesRead > 0,
  //       color: const Color(0xFF2196F3),
  //       progress: _storiesRead > 0 ? 1.0 : 0.0,
  //       target: 1,
  //       category: 'Reading',
  //       rarity: 'Common',
  //       unlockedDate: _storiesRead > 0 ? DateTime.now() : null,
  //     ),
  //
  //     // Study Streak Achievements
  //     Achievement(
  //       id: 'week_streak',
  //       title: 'Week Warrior',
  //       description: 'Study for 7 days in a row',
  //       icon: '🔥',
  //       isUnlocked: _studyStreak >= 7,
  //       color: const Color(0xFFFF5722),
  //       progress: _studyStreak / 7,
  //       target: 7,
  //       category: 'Streak',
  //       rarity: 'Uncommon',
  //       unlockedDate: _studyStreak >= 7 ? DateTime.now() : null,
  //     ),
  //     Achievement(
  //       id: 'month_streak',
  //       title: 'Monthly Master',
  //       description: 'Study for 30 days in a row',
  //       icon: '🏆',
  //       isUnlocked: _studyStreak >= 30,
  //       color: const Color(0xFFFF9800),
  //       progress: _studyStreak / 30,
  //       target: 30,
  //       category: 'Streak',
  //       rarity: 'Rare',
  //       unlockedDate: _studyStreak >= 30 ? DateTime.now() : null,
  //     ),
  //     Achievement(
  //       id: 'hundred_streak',
  //       title: 'Centurion',
  //       description: 'Study for 100 days in a row',
  //       icon: '💯',
  //       isUnlocked: _studyStreak >= 100,
  //       color: const Color(0xFF9C27B0),
  //       progress: _studyStreak / 100,
  //       target: 100,
  //       category: 'Streak',
  //       rarity: 'Epic',
  //       unlockedDate: _studyStreak >= 100 ? DateTime.now() : null,
  //     ),
  //
  //     // Knowledge Achievements
  //     Achievement(
  //       id: 'kanji_apprentice',
  //       title: 'Kanji Apprentice',
  //       description: 'Learn 50 Kanji characters',
  //       icon: '📝',
  //       isUnlocked: _kanjiLearned >= 50,
  //       color: const Color(0xFF607D8B),
  //       progress: _kanjiLearned / 50,
  //       target: 50,
  //       category: 'Learning',
  //       rarity: 'Uncommon',
  //       unlockedDate: _kanjiLearned >= 50 ? DateTime.now() : null,
  //     ),
  //     Achievement(
  //       id: 'kanji_master',
  //       title: 'Kanji Master',
  //       description: 'Learn 100 Kanji characters',
  //       icon: '🎓',
  //       isUnlocked: _kanjiLearned >= 100,
  //       color: const Color(0xFFE91E63),
  //       progress: _kanjiLearned / 100,
  //       target: 100,
  //       category: 'Learning',
  //       rarity: 'Rare',
  //       unlockedDate: _kanjiLearned >= 100 ? DateTime.now() : null,
  //     ),
  //     Achievement(
  //       id: 'kanji_legend',
  //       title: 'Kanji Legend',
  //       description: 'Learn 500 Kanji characters',
  //       icon: '⚡',
  //       isUnlocked: _kanjiLearned >= 500,
  //       color: const Color(0xFF673AB7),
  //       progress: _kanjiLearned / 500,
  //       target: 500,
  //       category: 'Learning',
  //       rarity: 'Legendary',
  //       unlockedDate: _kanjiLearned >= 500 ? DateTime.now() : null,
  //     ),
  //
  //     // Quiz Achievements
  //     Achievement(
  //       id: 'quiz_starter',
  //       title: 'Quiz Starter',
  //       description: 'Complete 5 quizzes',
  //       icon: '🧠',
  //       isUnlocked: _quizzesCompleted >= 5,
  //       color: const Color(0xFF9C27B0),
  //       progress: _quizzesCompleted / 5,
  //       target: 5,
  //       category: 'Quiz',
  //       rarity: 'Common',
  //       unlockedDate: _quizzesCompleted >= 5 ? DateTime.now() : null,
  //     ),
  //     Achievement(
  //       id: 'quiz_master',
  //       title: 'Quiz Master',
  //       description: 'Complete 25 quizzes',
  //       icon: '🎯',
  //       isUnlocked: _quizzesCompleted >= 25,
  //       color: const Color(0xFF3F51B5),
  //       progress: _quizzesCompleted / 25,
  //       target: 25,
  //       category: 'Quiz',
  //       rarity: 'Rare',
  //       unlockedDate: _quizzesCompleted >= 25 ? DateTime.now() : null,
  //     ),
  //     Achievement(
  //       id: 'perfectionist',
  //       title: 'Perfectionist',
  //       description: 'Get 10 perfect quiz scores',
  //       icon: '💎',
  //       isUnlocked: _perfectScores >= 10,
  //       color: const Color(0xFF00BCD4),
  //       progress: _perfectScores / 10,
  //       target: 10,
  //       category: 'Quiz',
  //       rarity: 'Epic',
  //       unlockedDate: _perfectScores >= 10 ? DateTime.now() : null,
  //     ),
  //
  //     // XP Achievements
  //     Achievement(
  //       id: 'xp_collector',
  //       title: 'XP Collector',
  //       description: 'Earn 1000 experience points',
  //       icon: '⭐',
  //       isUnlocked: _totalXP >= 1000,
  //       color: const Color(0xFFFFC107),
  //       progress: _totalXP / 1000,
  //       target: 1000,
  //       category: 'Experience',
  //       rarity: 'Uncommon',
  //       unlockedDate: _totalXP >= 1000 ? DateTime.now() : null,
  //     ),
  //     Achievement(
  //       id: 'xp_legend',
  //       title: 'XP Legend',
  //       description: 'Earn 10000 experience points',
  //       icon: '👑',
  //       isUnlocked: _totalXP >= 10000,
  //       color: const Color(0xFFE91E63),
  //       progress: _totalXP / 10000,
  //       target: 10000,
  //       category: 'Experience',
  //       rarity: 'Legendary',
  //       unlockedDate: _totalXP >= 10000 ? DateTime.now() : null,
  //     ),
  //
  //     // Reading Achievements
  //     Achievement(
  //       id: 'story_reader',
  //       title: 'Story Reader',
  //       description: 'Read 5 Japanese stories',
  //       icon: '📚',
  //       isUnlocked: _storiesRead >= 5,
  //       color: const Color(0xFF2196F3),
  //       progress: _storiesRead / 5,
  //       target: 5,
  //       category: 'Reading',
  //       rarity: 'Common',
  //       unlockedDate: _storiesRead >= 5 ? DateTime.now() : null,
  //     ),
  //     Achievement(
  //       id: 'bookworm',
  //       title: 'Bookworm',
  //       description: 'Read 20 Japanese stories',
  //       icon: '🐛',
  //       isUnlocked: _storiesRead >= 20,
  //       color: const Color(0xFF4CAF50),
  //       progress: _storiesRead / 20,
  //       target: 20,
  //       category: 'Reading',
  //       rarity: 'Uncommon',
  //       unlockedDate: _storiesRead >= 20 ? DateTime.now() : null,
  //     ),
  //     Achievement(
  //       id: 'literature_lover',
  //       title: 'Literature Lover',
  //       description: 'Read 50 Japanese stories',
  //       icon: '💝',
  //       isUnlocked: _storiesRead >= 50,
  //       color: const Color(0xFFE91E63),
  //       progress: _storiesRead / 50,
  //       target: 50,
  //       category: 'Reading',
  //       rarity: 'Epic',
  //       unlockedDate: _storiesRead >= 50 ? DateTime.now() : null,
  //     ),
  //
  //     // Special Achievements
  //     Achievement(
  //       id: 'early_bird',
  //       title: 'Early Bird',
  //       description: 'Study before 8 AM for 7 days',
  //       icon: '🌅',
  //       isUnlocked: false, // This would need special tracking
  //       color: const Color(0xFFFF9800),
  //       progress: 0.0,
  //       target: 7,
  //       category: 'Special',
  //       rarity: 'Rare',
  //       unlockedDate: null,
  //     ),
  //     Achievement(
  //       id: 'night_owl',
  //       title: 'Night Owl',
  //       description: 'Study after 10 PM for 7 days',
  //       icon: '🦉',
  //       isUnlocked: false, // This would need special tracking
  //       color: const Color(0xFF673AB7),
  //       progress: 0.0,
  //       target: 7,
  //       category: 'Special',
  //       rarity: 'Rare',
  //       unlockedDate: null,
  //     ),
  //     Achievement(
  //       id: 'speed_demon',
  //       title: 'Speed Demon',
  //       description: 'Complete a quiz in under 30 seconds',
  //       icon: '⚡',
  //       isUnlocked: false, // This would need special tracking
  //       color: const Color(0xFFFFEB3B),
  //       progress: 0.0,
  //       target: 1,
  //       category: 'Special',
  //       rarity: 'Epic',
  //       unlockedDate: null,
  //     ),
  //   ];
  // }

  List<Achievement> get _filteredAchievements {
    switch (_selectedFilter) {
      case 'Unlocked':
        return _achievements.where((a) => a.isUnlocked).toList();
      case 'Locked':
        return _achievements.where((a) => !a.isUnlocked && a.progress == 0.0).toList();
      case 'In Progress':
        return _achievements.where((a) => !a.isUnlocked && a.progress > 0.0).toList();
      default:
        return _achievements;
    }
  }

  @override
  void dispose() {
    _userDataSubscription?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
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
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildHeader(isSmallScreen),
                    _buildStatsOverview(isSmallScreen),
                    _buildFilterTabs(isSmallScreen),
                    Expanded(
                      child: _isLoading
                          ? _buildLoadingState()
                          : _buildAchievementsList(isSmallScreen),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    final unlockedCount = _achievements.where((a) => a.isUnlocked).length;
    final totalCount = _achievements.length;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: isSmallScreen ? 12 : 20,
      ),
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
                color: Color(0xFF6366F1),
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
                  'Achievements',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$unlockedCount/$totalCount unlocked',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: const Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 6 : 8,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${((unlockedCount / totalCount) * 100).round()}%',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: isSmallScreen ? 8 : 0,
      ),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
            Color(0xFFEC4899),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your Progress',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          // Fixed stats layout to prevent overflow
          LayoutBuilder(
            builder: (context, constraints) {
              return IntrinsicHeight(
                child: Row(
                  children: [
                    _buildStatItem('Streak', '$_studyStreak days', '🔥', isSmallScreen, constraints.maxWidth / 4),
                    _buildStatItem('Kanji', '$_kanjiLearned', '🈶', isSmallScreen, constraints.maxWidth / 4),
                    _buildStatItem('Stories', '$_storiesRead', '📚', isSmallScreen, constraints.maxWidth / 4),
                    _buildStatItem('Quizzes', '$_quizzesCompleted', '🧠', isSmallScreen, constraints.maxWidth / 4),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String emoji, bool isSmallScreen, double maxWidth) {
    return SizedBox(
      width: maxWidth - 8, // Subtract small margin to prevent overflow
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: isSmallScreen ? 18 : 22),
          ),
          SizedBox(height: isSmallScreen ? 3 : 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 9 : 11,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: isSmallScreen ? 12 : 20,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filterOptions.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Container(
              margin: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 20,
                    vertical: isSmallScreen ? 10 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    filter,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
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
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
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
            'Loading achievements...',
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

  Widget _buildAchievementsList(bool isSmallScreen) {
    final filteredAchievements = _filteredAchievements;

    if (filteredAchievements.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: isSmallScreen ? 8 : 16,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmallScreen ? 1 : 2,
        childAspectRatio: isSmallScreen ? 2.8 : 2.2,
        crossAxisSpacing: isSmallScreen ? 8 : 12,
        mainAxisSpacing: isSmallScreen ? 8 : 12,
      ),
      itemCount: filteredAchievements.length,
      itemBuilder: (context, index) {
        final achievement = filteredAchievements[index];
        return _buildAchievementCard(achievement, isSmallScreen);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 60,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No achievements found',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Keep studying to unlock more achievements!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isSmallScreen) {
    final progressPercent = (achievement.progress * 100).clamp(0, 100).round();

    return Container(
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? Colors.white
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: achievement.isUnlocked
              ? achievement.color.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: achievement.isUnlocked
                ? achievement.color.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Rarity indicator
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 4 : 6,
                vertical: isSmallScreen ? 2 : 3,
              ),
              decoration: BoxDecoration(
                color: _getRarityColor(achievement.rarity).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                achievement.rarity,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 8 : 9,
                  fontWeight: FontWeight.bold,
                  color: _getRarityColor(achievement.rarity),
                ),
              ),
            ),
          ),

          // Main content
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top section with icon and title
                    SizedBox(
                      height: isSmallScreen ? 50 : 60,
                      child: Row(
                        children: [
                          Container(
                            width: isSmallScreen ? 40 : 50,
                            height: isSmallScreen ? 40 : 50,
                            decoration: BoxDecoration(
                              color: achievement.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                achievement.icon,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 20 : 24,
                                  color: achievement.isUnlocked
                                      ? null
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  achievement.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    fontWeight: FontWeight.bold,
                                    color: achievement.isUnlocked
                                        ? const Color(0xFF1F2937)
                                        : const Color(0xFF6B7280),
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  achievement.description,
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 9 : 10,
                                    color: achievement.isUnlocked
                                        ? const Color(0xFF6B7280)
                                        : const Color(0xFF9CA3AF),
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Spacer
                    SizedBox(height: isSmallScreen ? 8 : 12),

                    // Progress section
                    if (!achievement.isUnlocked) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Progress: $progressPercent%',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 9 : 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(achievement.progress * achievement.target).round()}/${achievement.target}',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 9 : 10,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: achievement.progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
                          minHeight: 4,
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 8 : 10,
                                vertical: isSmallScreen ? 3 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: const Color(0xFF10B981),
                                    size: isSmallScreen ? 12 : 14,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Unlocked',
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 9 : 10,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (achievement.unlockedDate != null) ...[
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                _formatDate(achievement.unlockedDate!),
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 8 : 9,
                                  color: const Color(0xFF9CA3AF),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return const Color(0xFF6B7280);
      case 'uncommon':
        return const Color(0xFF10B981);
      case 'rare':
        return const Color(0xFF3B82F6);
      case 'epic':
        return const Color(0xFF8B5CF6);
      case 'legendary':
        return const Color(0xFFEAB308);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final Color color;
  final double progress;
  final int target;
  final String category;
  final String rarity;
  final DateTime? unlockedDate;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.color,
    required this.progress,
    required this.target,
    this.category = 'General',
    this.rarity = 'Common',
    this.unlockedDate,
  });
}


// import 'dart:async';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class AchievementsScreen extends StatefulWidget {
//   const AchievementsScreen({super.key});
//
//   @override
//   State<AchievementsScreen> createState() => _AchievementsScreenState();
// }
//
// class _AchievementsScreenState extends State<AchievementsScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//
//   List<Achievement> _achievements = [];
//   bool _isLoading = true;
//   StreamSubscription<DocumentSnapshot>? _userDataSubscription;
//
//   // User stats for calculating achievements
//   int _studyStreak = 0;
//   int _totalXP = 0;
//   int _kanjiLearned = 0;
//   int _storiesRead = 0;
//   int _quizzesCompleted = 0;
//   int _lessonsCompleted = 0;
//   int _perfectScores = 0;
//
//   // Filter states
//   String _selectedFilter = 'All';
//   final List<String> _filterOptions = ['All', 'Unlocked', 'Locked', 'In Progress'];
//
//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//     _setupRealtimeListeners();
//   }
//
//   void _initAnimations() {
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
//     );
//
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
//
//     _fadeController.forward();
//     _slideController.forward();
//   }
//
//   void _setupRealtimeListeners() {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       _userDataSubscription = FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .snapshots()
//           .listen((snapshot) {
//         if (snapshot.exists && mounted) {
//           final data = snapshot.data()!;
//           setState(() {
//             _studyStreak = data['studyStreak'] ?? 0;
//             _totalXP = data['totalXP'] ?? 0;
//             _kanjiLearned = data['totalKanjiLearned'] ?? 0;
//             _storiesRead = data['storiesRead'] ?? 0;
//             _quizzesCompleted = data['quizzesCompleted'] ?? 0;
//             _lessonsCompleted = data['lessonsCompleted'] ?? 0;
//             _perfectScores = data['perfectScores'] ?? 0;
//             _isLoading = false;
//           });
//           _updateAchievements();
//         }
//       });
//     }
//   }
//
//   void _updateAchievements() {
//     _achievements = [
//       // Beginner Achievements
//       Achievement(
//         id: 'first_step',
//         title: 'First Step',
//         description: 'Complete your first lesson',
//         icon: '👶',
//         isUnlocked: _lessonsCompleted > 0,
//         color: const Color(0xFF10B981),
//         progress: _lessonsCompleted > 0 ? 1.0 : 0.0,
//         target: 1,
//         category: 'Beginner',
//         rarity: 'Common',
//         unlockedDate: _lessonsCompleted > 0 ? DateTime.now() : null,
//       ),
//       Achievement(
//         id: 'first_kanji',
//         title: 'First Kanji',
//         description: 'Learn your first Kanji character',
//         icon: '🈶',
//         isUnlocked: _kanjiLearned > 0,
//         color: const Color(0xFF4CAF50),
//         progress: _kanjiLearned > 0 ? 1.0 : 0.0,
//         target: 1,
//         category: 'Learning',
//         rarity: 'Common',
//         unlockedDate: _kanjiLearned > 0 ? DateTime.now() : null,
//       ),
//       Achievement(
//         id: 'first_story',
//         title: 'Story Explorer',
//         description: 'Read your first Japanese story',
//         icon: '📖',
//         isUnlocked: _storiesRead > 0,
//         color: const Color(0xFF2196F3),
//         progress: _storiesRead > 0 ? 1.0 : 0.0,
//         target: 1,
//         category: 'Reading',
//         rarity: 'Common',
//         unlockedDate: _storiesRead > 0 ? DateTime.now() : null,
//       ),
//
//       // Study Streak Achievements
//       Achievement(
//         id: 'week_streak',
//         title: 'Week Warrior',
//         description: 'Study for 7 days in a row',
//         icon: '🔥',
//         isUnlocked: _studyStreak >= 7,
//         color: const Color(0xFFFF5722),
//         progress: _studyStreak / 7,
//         target: 7,
//         category: 'Streak',
//         rarity: 'Uncommon',
//         unlockedDate: _studyStreak >= 7 ? DateTime.now() : null,
//       ),
//       Achievement(
//         id: 'month_streak',
//         title: 'Monthly Master',
//         description: 'Study for 30 days in a row',
//         icon: '🏆',
//         isUnlocked: _studyStreak >= 30,
//         color: const Color(0xFFFF9800),
//         progress: _studyStreak / 30,
//         target: 30,
//         category: 'Streak',
//         rarity: 'Rare',
//         unlockedDate: _studyStreak >= 30 ? DateTime.now() : null,
//       ),
//       Achievement(
//         id: 'hundred_streak',
//         title: 'Centurion',
//         description: 'Study for 100 days in a row',
//         icon: '💯',
//         isUnlocked: _studyStreak >= 100,
//         color: const Color(0xFF9C27B0),
//         progress: _studyStreak / 100,
//         target: 100,
//         category: 'Streak',
//         rarity: 'Epic',
//         unlockedDate: _studyStreak >= 100 ? DateTime.now() : null,
//       ),
//
//       // Knowledge Achievements
//       Achievement(
//         id: 'kanji_apprentice',
//         title: 'Kanji Apprentice',
//         description: 'Learn 50 Kanji characters',
//         icon: '📝',
//         isUnlocked: _kanjiLearned >= 50,
//         color: const Color(0xFF607D8B),
//         progress: _kanjiLearned / 50,
//         target: 50,
//         category: 'Learning',
//         rarity: 'Uncommon',
//         unlockedDate: _kanjiLearned >= 50 ? DateTime.now() : null,
//       ),
//       Achievement(
//         id: 'kanji_master',
//         title: 'Kanji Master',
//         description: 'Learn 100 Kanji characters',
//         icon: '🎓',
//         isUnlocked: _kanjiLearned >= 100,
//         color: const Color(0xFFE91E63),
//         progress: _kanjiLearned / 100,
//         target: 100,
//         category: 'Learning',
//         rarity: 'Rare',
//         unlockedDate: _kanjiLearned >= 100 ? DateTime.now() : null,
//       ),
//       Achievement(
//         id: 'kanji_legend',
//         title: 'Kanji Legend',
//         description: 'Learn 500 Kanji characters',
//         icon: '⚡',
//         isUnlocked: _kanjiLearned >= 500,
//         color: const Color(0xFF673AB7),
//         progress: _kanjiLearned / 500,
//         target: 500,
//         category: 'Learning',
//         rarity: 'Legendary',
//         unlockedDate: _kanjiLearned >= 500 ? DateTime.now() : null,
//       ),
//
//       // Quiz Achievements
//       Achievement(
//         id: 'quiz_starter',
//         title: 'Quiz Starter',
//         description: 'Complete 5 quizzes',
//         icon: '🧠',
//         isUnlocked: _quizzesCompleted >= 5,
//         color: const Color(0xFF9C27B0),
//         progress: _quizzesCompleted / 5,
//         target: 5,
//         category: 'Quiz',
//         rarity: 'Common',
//         unlockedDate: _quizzesCompleted >= 5 ? DateTime.now() : null,
//       ),
//       Achievement(
//         id: 'quiz_master',
//         title: 'Quiz Master',
//         description: 'Complete 25 quizzes',
//         icon: '🎯',
//         isUnlocked: _quizzesCompleted >= 25,
//         color: const Color(0xFF3F51B5),
//         progress: _quizzesCompleted / 25,
//         target: 25,
//         category: 'Quiz',
//         rarity: 'Rare',
//         unlockedDate: _quizzesCompleted >= 25 ? DateTime.now() : null,
//       ),
//       Achievement(
//         id: 'perfectionist',
//         title: 'Perfectionist',
//         description: 'Get 10 perfect quiz scores',
//         icon: '💎',
//         isUnlocked: _perfectScores >= 10,
//         color: const Color(0xFF00BCD4),
//         progress: _perfectScores / 10,
//         target: 10,
//         category: 'Quiz',
//         rarity: 'Epic',
//         unlockedDate: _perfectScores >= 10 ? DateTime.now() : null,
//       ),
//
//       // XP Achievements
//       Achievement(
//         id: 'xp_collector',
//         title: 'XP Collector',
//         description: 'Earn 1000 experience points',
//         icon: '⭐',
//         isUnlocked: _totalXP >= 1000,
//         color: const Color(0xFFFFC107),
//         progress: _totalXP / 1000,
//         target: 1000,
//         category: 'Experience',
//         rarity: 'Uncommon',
//         unlockedDate: _totalXP >= 1000 ? DateTime.now() : null,
//       ),
//       Achievement(
//         id: 'xp_legend',
//         title: 'XP Legend',
//         description: 'Earn 10000 experience points',
//         icon: '👑',
//         isUnlocked: _totalXP >= 10000,
//         color: const Color(0xFFE91E63),
//         progress: _totalXP / 10000,
//         target: 10000,
//         category: 'Experience',
//         rarity: 'Legendary',
//         unlockedDate: _totalXP >= 10000 ? DateTime.now() : null,
//       ),
//
//       // Reading Achievements
//       Achievement(
//         id: 'story_reader',
//         title: 'Story Reader',
//         description: 'Read 5 Japanese stories',
//         icon: '📚',
//         isUnlocked: _storiesRead >= 5,
//         color: const Color(0xFF2196F3),
//         progress: _storiesRead / 5,
//         target: 5,
//         category: 'Reading',
//         rarity: 'Common',
//         unlockedDate: _storiesRead >= 5 ? DateTime.now() : null,
//       ),
//       Achievement(
//         id: 'bookworm',
//         title: 'Bookworm',
//         description: 'Read 20 Japanese stories',
//         icon: '🐛',
//         isUnlocked: _storiesRead >= 20,
//         color: const Color(0xFF4CAF50),
//         progress: _storiesRead / 20,
//         target: 20,
//         category: 'Reading',
//         rarity: 'Uncommon',
//         unlockedDate: _storiesRead >= 20 ? DateTime.now() : null,
//       ),
//       Achievement(
//         id: 'literature_lover',
//         title: 'Literature Lover',
//         description: 'Read 50 Japanese stories',
//         icon: '💝',
//         isUnlocked: _storiesRead >= 50,
//         color: const Color(0xFFE91E63),
//         progress: _storiesRead / 50,
//         target: 50,
//         category: 'Reading',
//         rarity: 'Epic',
//         unlockedDate: _storiesRead >= 50 ? DateTime.now() : null,
//       ),
//
//       // Special Achievements
//       Achievement(
//         id: 'early_bird',
//         title: 'Early Bird',
//         description: 'Study before 8 AM for 7 days',
//         icon: '🌅',
//         isUnlocked: false, // This would need special tracking
//         color: const Color(0xFFFF9800),
//         progress: 0.0,
//         target: 7,
//         category: 'Special',
//         rarity: 'Rare',
//         unlockedDate: null,
//       ),
//       Achievement(
//         id: 'night_owl',
//         title: 'Night Owl',
//         description: 'Study after 10 PM for 7 days',
//         icon: '🦉',
//         isUnlocked: false, // This would need special tracking
//         color: const Color(0xFF673AB7),
//         progress: 0.0,
//         target: 7,
//         category: 'Special',
//         rarity: 'Rare',
//         unlockedDate: null,
//       ),
//       Achievement(
//         id: 'speed_demon',
//         title: 'Speed Demon',
//         description: 'Complete a quiz in under 30 seconds',
//         icon: '⚡',
//         isUnlocked: false, // This would need special tracking
//         color: const Color(0xFFFFEB3B),
//         progress: 0.0,
//         target: 1,
//         category: 'Special',
//         rarity: 'Epic',
//         unlockedDate: null,
//       ),
//     ];
//   }
//
//   List<Achievement> get _filteredAchievements {
//     switch (_selectedFilter) {
//       case 'Unlocked':
//         return _achievements.where((a) => a.isUnlocked).toList();
//       case 'Locked':
//         return _achievements.where((a) => !a.isUnlocked && a.progress == 0.0).toList();
//       case 'In Progress':
//         return _achievements.where((a) => !a.isUnlocked && a.progress > 0.0).toList();
//       default:
//         return _achievements;
//     }
//   }
//
//   @override
//   void dispose() {
//     _userDataSubscription?.cancel();
//     _fadeController.dispose();
//     _slideController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FF),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final isSmallScreen = constraints.maxWidth < 375;
//             return FadeTransition(
//               opacity: _fadeAnimation,
//               child: SlideTransition(
//                 position: _slideAnimation,
//                 child: Column(
//                   children: [
//                     _buildHeader(isSmallScreen),
//                     _buildStatsOverview(isSmallScreen),
//                     _buildFilterTabs(isSmallScreen),
//                     Expanded(
//                       child: _isLoading
//                           ? _buildLoadingState()
//                           : _buildAchievementsList(isSmallScreen),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(bool isSmallScreen) {
//     final unlockedCount = _achievements.where((a) => a.isUnlocked).length;
//     final totalCount = _achievements.length;
//
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: isSmallScreen ? 16 : 20,
//         vertical: isSmallScreen ? 12 : 20,
//       ),
//       child: Row(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: IconButton(
//               icon: const Icon(
//                 Icons.arrow_back_ios_new,
//                 color: Color(0xFF6366F1),
//                 size: 20,
//               ),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Achievements',
//                   style: GoogleFonts.poppins(
//                     fontSize: isSmallScreen ? 20 : 24,
//                     fontWeight: FontWeight.bold,
//                     color: const Color(0xFF1F2937),
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 Text(
//                   '$unlockedCount/$totalCount unlocked',
//                   style: GoogleFonts.poppins(
//                     fontSize: isSmallScreen ? 12 : 14,
//                     color: const Color(0xFF6B7280),
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: isSmallScreen ? 12 : 16,
//               vertical: isSmallScreen ? 6 : 8,
//             ),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//               ),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               '${((unlockedCount / totalCount) * 100).round()}%',
//               style: GoogleFonts.poppins(
//                 fontSize: isSmallScreen ? 12 : 14,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatsOverview(bool isSmallScreen) {
//     return Container(
//       margin: EdgeInsets.symmetric(
//         horizontal: isSmallScreen ? 16 : 20,
//         vertical: isSmallScreen ? 8 : 0,
//       ),
//       padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFF6366F1),
//             Color(0xFF8B5CF6),
//             Color(0xFFEC4899),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF6366F1).withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Text(
//             'Your Progress',
//             style: GoogleFonts.poppins(
//               fontSize: isSmallScreen ? 16 : 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           SizedBox(height: isSmallScreen ? 12 : 16),
//           // Fixed stats layout to prevent overflow
//           LayoutBuilder(
//             builder: (context, constraints) {
//               return Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildStatItem('Streak', '$_studyStreak days', '🔥', isSmallScreen),
//                   _buildStatItem('Kanji', '$_kanjiLearned', '🈶', isSmallScreen),
//                   _buildStatItem('Stories', '$_storiesRead', '📚', isSmallScreen),
//                   _buildStatItem('Quizzes', '$_quizzesCompleted', '🧠', isSmallScreen),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatItem(String label, String value, String emoji, bool isSmallScreen) {
//     return Flexible(
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               emoji,
//               style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
//             ),
//             SizedBox(height: isSmallScreen ? 4 : 8),
//             Text(
//               value,
//               style: GoogleFonts.poppins(
//                 fontSize: isSmallScreen ? 14 : 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//               textAlign: TextAlign.center,
//               overflow: TextOverflow.ellipsis,
//             ),
//             Text(
//               label,
//               style: GoogleFonts.poppins(
//                 fontSize: isSmallScreen ? 10 : 12,
//                 color: Colors.white.withOpacity(0.8),
//               ),
//               textAlign: TextAlign.center,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFilterTabs(bool isSmallScreen) {
//     return Container(
//       margin: EdgeInsets.symmetric(
//         horizontal: isSmallScreen ? 16 : 20,
//         vertical: isSmallScreen ? 12 : 20,
//       ),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: _filterOptions.map((filter) {
//             final isSelected = _selectedFilter == filter;
//             return Container(
//               margin: const EdgeInsets.only(right: 12),
//               child: GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _selectedFilter = filter;
//                   });
//                 },
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: isSmallScreen ? 16 : 20,
//                     vertical: isSmallScreen ? 10 : 12,
//                   ),
//                   decoration: BoxDecoration(
//                     color: isSelected ? const Color(0xFF6366F1) : Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Text(
//                     filter,
//                     style: GoogleFonts.poppins(
//                       fontSize: isSmallScreen ? 12 : 14,
//                       fontWeight: FontWeight.w600,
//                       color: isSelected ? Colors.white : const Color(0xFF6B7280),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//               ),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: const Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 strokeWidth: 3,
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'Loading achievements...',
//             style: GoogleFonts.poppins(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: const Color(0xFF1F2937),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAchievementsList(bool isSmallScreen) {
//     final filteredAchievements = _filteredAchievements;
//
//     if (filteredAchievements.isEmpty) {
//       return _buildEmptyState();
//     }
//
//     return GridView.builder(
//       padding: EdgeInsets.symmetric(
//         horizontal: isSmallScreen ? 16 : 20,
//         vertical: isSmallScreen ? 8 : 16,
//       ),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: isSmallScreen ? 1 : 2,
//         childAspectRatio: isSmallScreen ? 3.0 : 2.5,
//         crossAxisSpacing: isSmallScreen ? 12 : 16,
//         mainAxisSpacing: isSmallScreen ? 12 : 16,
//       ),
//       itemCount: filteredAchievements.length,
//       itemBuilder: (context, index) {
//         final achievement = filteredAchievements[index];
//         return _buildAchievementCard(achievement, isSmallScreen);
//       },
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 color: const Color(0xFF6366F1).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(60),
//               ),
//               child: const Icon(
//                 Icons.emoji_events,
//                 size: 60,
//                 color: Color(0xFF6366F1),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'No achievements found',
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFF1F2937),
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Keep studying to unlock more achievements!',
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 color: const Color(0xFF6B7280),
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAchievementCard(Achievement achievement, bool isSmallScreen) {
//     final progressPercent = (achievement.progress * 100).clamp(0, 100).round();
//
//     return Container(
//       decoration: BoxDecoration(
//         color: achievement.isUnlocked
//             ? Colors.white
//             : Colors.white.withOpacity(0.7),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: achievement.isUnlocked
//               ? achievement.color.withOpacity(0.3)
//               : Colors.grey.withOpacity(0.2),
//           width: 2,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: achievement.isUnlocked
//                 ? achievement.color.withOpacity(0.1)
//                 : Colors.black.withOpacity(0.05),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           // Rarity indicator
//           Positioned(
//             top: 12,
//             right: 12,
//             child: Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isSmallScreen ? 6 : 8,
//                 vertical: isSmallScreen ? 3 : 4,
//               ),
//               decoration: BoxDecoration(
//                 color: _getRarityColor(achievement.rarity).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 achievement.rarity,
//                 style: GoogleFonts.poppins(
//                   fontSize: isSmallScreen ? 9 : 10,
//                   fontWeight: FontWeight.bold,
//                   color: _getRarityColor(achievement.rarity),
//                 ),
//               ),
//             ),
//           ),
//
//           // Main content
//           Padding(
//             padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Top section with icon and title
//                 Row(
//                   children: [
//                     Container(
//                       width: isSmallScreen ? 50 : 60,
//                       height: isSmallScreen ? 50 : 60,
//                       decoration: BoxDecoration(
//                         color: achievement.color.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Center(
//                         child: Text(
//                           achievement.icon,
//                           style: TextStyle(
//                             fontSize: isSmallScreen ? 24 : 28,
//                             color: achievement.isUnlocked
//                                 ? null
//                                 : Colors.grey,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             achievement.title,
//                             style: GoogleFonts.poppins(
//                               fontSize: isSmallScreen ? 14 : 16,
//                               fontWeight: FontWeight.bold,
//                               color: achievement.isUnlocked
//                                   ? const Color(0xFF1F2937)
//                                   : const Color(0xFF6B7280),
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             achievement.description,
//                             style: GoogleFonts.poppins(
//                               fontSize: isSmallScreen ? 11 : 12,
//                               color: achievement.isUnlocked
//                                   ? const Color(0xFF6B7280)
//                                   : const Color(0xFF9CA3AF),
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 const Spacer(),
//
//                 // Progress section
//                 if (!achievement.isUnlocked) ...[
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           'Progress: $progressPercent%',
//                           style: GoogleFonts.poppins(
//                             fontSize: isSmallScreen ? 11 : 12,
//                             fontWeight: FontWeight.w600,
//                             color: const Color(0xFF6B7280),
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         '${(achievement.progress * achievement.target).round()}/${achievement.target}',
//                         style: GoogleFonts.poppins(
//                           fontSize: isSmallScreen ? 11 : 12,
//                           color: const Color(0xFF9CA3AF),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: isSmallScreen ? 6 : 8),
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(3),
//                     child: LinearProgressIndicator(
//                       value: achievement.progress.clamp(0.0, 1.0),
//                       backgroundColor: Colors.grey[200],
//                       valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
//                       minHeight: 6,
//                     ),
//                   ),
//                 ] else ...[
//                   Row(
//                     children: [
//                       Flexible(
//                         child: Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: isSmallScreen ? 10 : 12,
//                             vertical: isSmallScreen ? 4 : 6,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF10B981).withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.check_circle,
//                                 color: const Color(0xFF10B981),
//                                 size: isSmallScreen ? 14 : 16,
//                               ),
//                               const SizedBox(width: 4),
//                               Flexible(
//                                 child: Text(
//                                   'Unlocked',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: isSmallScreen ? 11 : 12,
//                                     fontWeight: FontWeight.bold,
//                                     color: const Color(0xFF10B981),
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       if (achievement.unlockedDate != null)
//                         Flexible(
//                           child: Text(
//                             _formatDate(achievement.unlockedDate!),
//                             style: GoogleFonts.poppins(
//                               fontSize: isSmallScreen ? 9 : 10,
//                               color: const Color(0xFF9CA3AF),
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Color _getRarityColor(String rarity) {
//     switch (rarity.toLowerCase()) {
//       case 'common':
//         return const Color(0xFF6B7280);
//       case 'uncommon':
//         return const Color(0xFF10B981);
//       case 'rare':
//         return const Color(0xFF3B82F6);
//       case 'epic':
//         return const Color(0xFF8B5CF6);
//       case 'legendary':
//         return const Color(0xFFEAB308);
//       default:
//         return const Color(0xFF6B7280);
//     }
//   }
//
//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
//
//     if (difference.inDays > 0) {
//       return '${difference.inDays}d ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours}h ago';
//     } else {
//       return 'Just now';
//     }
//   }
// }
//
// class Achievement {
//   final String id;
//   final String title;
//   final String description;
//   final String icon;
//   final bool isUnlocked;
//   final Color color;
//   final double progress;
//   final int target;
//   final String category;
//   final String rarity;
//   final DateTime? unlockedDate;
//
//   Achievement({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.icon,
//     required this.isUnlocked,
//     required this.color,
//     required this.progress,
//     required this.target,
//     this.category = 'General',
//     this.rarity = 'Common',
//     this.unlockedDate,
//   });
// }
//
//
// // import 'dart:async';
// // import 'dart:math' as math;
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// //
// // class AchievementsScreen extends StatefulWidget {
// //   const AchievementsScreen({super.key});
// //
// //   @override
// //   State<AchievementsScreen> createState() => _AchievementsScreenState();
// // }
// //
// // class _AchievementsScreenState extends State<AchievementsScreen>
// //     with TickerProviderStateMixin {
// //   late AnimationController _fadeController;
// //   late AnimationController _slideController;
// //   late Animation<double> _fadeAnimation;
// //   late Animation<Offset> _slideAnimation;
// //
// //   List<Achievement> _achievements = [];
// //   bool _isLoading = true;
// //   StreamSubscription<DocumentSnapshot>? _userDataSubscription;
// //
// //   // User stats for calculating achievements
// //   int _studyStreak = 0;
// //   int _totalXP = 0;
// //   int _kanjiLearned = 0;
// //   int _storiesRead = 0;
// //   int _quizzesCompleted = 0;
// //   int _lessonsCompleted = 0;
// //   int _perfectScores = 0;
// //
// //   // Filter states
// //   String _selectedFilter = 'All';
// //   final List<String> _filterOptions = ['All', 'Unlocked', 'Locked', 'In Progress'];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initAnimations();
// //     _setupRealtimeListeners();
// //   }
// //
// //   void _initAnimations() {
// //     _fadeController = AnimationController(
// //       duration: const Duration(milliseconds: 800),
// //       vsync: this,
// //     );
// //
// //     _slideController = AnimationController(
// //       duration: const Duration(milliseconds: 600),
// //       vsync: this,
// //     );
// //
// //     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
// //       CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
// //     );
// //
// //     _slideAnimation = Tween<Offset>(
// //       begin: const Offset(0, 0.3),
// //       end: Offset.zero,
// //     ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
// //
// //     _fadeController.forward();
// //     _slideController.forward();
// //   }
// //
// //   void _setupRealtimeListeners() {
// //     final user = FirebaseAuth.instance.currentUser;
// //     if (user != null) {
// //       _userDataSubscription = FirebaseFirestore.instance
// //           .collection('users')
// //           .doc(user.uid)
// //           .snapshots()
// //           .listen((snapshot) {
// //         if (snapshot.exists && mounted) {
// //           final data = snapshot.data()!;
// //           setState(() {
// //             _studyStreak = data['studyStreak'] ?? 0;
// //             _totalXP = data['totalXP'] ?? 0;
// //             _kanjiLearned = data['totalKanjiLearned'] ?? 0;
// //             _storiesRead = data['storiesRead'] ?? 0;
// //             _quizzesCompleted = data['quizzesCompleted'] ?? 0;
// //             _lessonsCompleted = data['lessonsCompleted'] ?? 0;
// //             _perfectScores = data['perfectScores'] ?? 0;
// //             _isLoading = false;
// //           });
// //           _updateAchievements();
// //         }
// //       });
// //     }
// //   }
// //
// //   void _updateAchievements() {
// //     _achievements = [
// //       // Beginner Achievements
// //       Achievement(
// //         id: 'first_step',
// //         title: 'First Step',
// //         description: 'Complete your first lesson',
// //         icon: '👶',
// //         isUnlocked: _lessonsCompleted > 0,
// //         color: const Color(0xFF10B981),
// //         progress: _lessonsCompleted > 0 ? 1.0 : 0.0,
// //         target: 1,
// //         category: 'Beginner',
// //         rarity: 'Common',
// //         unlockedDate: _lessonsCompleted > 0 ? DateTime.now() : null,
// //       ),
// //       Achievement(
// //         id: 'first_kanji',
// //         title: 'First Kanji',
// //         description: 'Learn your first Kanji character',
// //         icon: '🈶',
// //         isUnlocked: _kanjiLearned > 0,
// //         color: const Color(0xFF4CAF50),
// //         progress: _kanjiLearned > 0 ? 1.0 : 0.0,
// //         target: 1,
// //         category: 'Learning',
// //         rarity: 'Common',
// //         unlockedDate: _kanjiLearned > 0 ? DateTime.now() : null,
// //       ),
// //       Achievement(
// //         id: 'first_story',
// //         title: 'Story Explorer',
// //         description: 'Read your first Japanese story',
// //         icon: '📖',
// //         isUnlocked: _storiesRead > 0,
// //         color: const Color(0xFF2196F3),
// //         progress: _storiesRead > 0 ? 1.0 : 0.0,
// //         target: 1,
// //         category: 'Reading',
// //         rarity: 'Common',
// //         unlockedDate: _storiesRead > 0 ? DateTime.now() : null,
// //       ),
// //
// //       // Study Streak Achievements
// //       Achievement(
// //         id: 'week_streak',
// //         title: 'Week Warrior',
// //         description: 'Study for 7 days in a row',
// //         icon: '🔥',
// //         isUnlocked: _studyStreak >= 7,
// //         color: const Color(0xFFFF5722),
// //         progress: _studyStreak / 7,
// //         target: 7,
// //         category: 'Streak',
// //         rarity: 'Uncommon',
// //         unlockedDate: _studyStreak >= 7 ? DateTime.now() : null,
// //       ),
// //       Achievement(
// //         id: 'month_streak',
// //         title: 'Monthly Master',
// //         description: 'Study for 30 days in a row',
// //         icon: '🏆',
// //         isUnlocked: _studyStreak >= 30,
// //         color: const Color(0xFFFF9800),
// //         progress: _studyStreak / 30,
// //         target: 30,
// //         category: 'Streak',
// //         rarity: 'Rare',
// //         unlockedDate: _studyStreak >= 30 ? DateTime.now() : null,
// //       ),
// //       Achievement(
// //         id: 'hundred_streak',
// //         title: 'Centurion',
// //         description: 'Study for 100 days in a row',
// //         icon: '💯',
// //         isUnlocked: _studyStreak >= 100,
// //         color: const Color(0xFF9C27B0),
// //         progress: _studyStreak / 100,
// //         target: 100,
// //         category: 'Streak',
// //         rarity: 'Epic',
// //         unlockedDate: _studyStreak >= 100 ? DateTime.now() : null,
// //       ),
// //
// //       // Knowledge Achievements
// //       Achievement(
// //         id: 'kanji_apprentice',
// //         title: 'Kanji Apprentice',
// //         description: 'Learn 50 Kanji characters',
// //         icon: '📝',
// //         isUnlocked: _kanjiLearned >= 50,
// //         color: const Color(0xFF607D8B),
// //         progress: _kanjiLearned / 50,
// //         target: 50,
// //         category: 'Learning',
// //         rarity: 'Uncommon',
// //         unlockedDate: _kanjiLearned >= 50 ? DateTime.now() : null,
// //       ),
// //       Achievement(
// //         id: 'kanji_master',
// //         title: 'Kanji Master',
// //         description: 'Learn 100 Kanji characters',
// //         icon: '🎓',
// //         isUnlocked: _kanjiLearned >= 100,
// //         color: const Color(0xFFE91E63),
// //         progress: _kanjiLearned / 100,
// //         target: 100,
// //         category: 'Learning',
// //         rarity: 'Rare',
// //         unlockedDate: _kanjiLearned >= 100 ? DateTime.now() : null,
// //       ),
// //       Achievement(
// //         id: 'kanji_legend',
// //         title: 'Kanji Legend',
// //         description: 'Learn 500 Kanji characters',
// //         icon: '⚡',
// //         isUnlocked: _kanjiLearned >= 500,
// //         color: const Color(0xFF673AB7),
// //         progress: _kanjiLearned / 500,
// //         target: 500,
// //         category: 'Learning',
// //         rarity: 'Legendary',
// //         unlockedDate: _kanjiLearned >= 500 ? DateTime.now() : null,
// //       ),
// //
// //       // Quiz Achievements
// //       Achievement(
// //         id: 'quiz_starter',
// //         title: 'Quiz Starter',
// //         description: 'Complete 5 quizzes',
// //         icon: '🧠',
// //         isUnlocked: _quizzesCompleted >= 5,
// //         color: const Color(0xFF9C27B0),
// //         progress: _quizzesCompleted / 5,
// //         target: 5,
// //         category: 'Quiz',
// //         rarity: 'Common',
// //         unlockedDate: _quizzesCompleted >= 5 ? DateTime.now() : null,
// //       ),
// //       Achievement(
// //         id: 'quiz_master',
// //         title: 'Quiz Master',
// //         description: 'Complete 25 quizzes',
// //         icon: '🎯',
// //         isUnlocked: _quizzesCompleted >= 25,
// //         color: const Color(0xFF3F51B5),
// //         progress: _quizzesCompleted / 25,
// //         target: 25,
// //         category: 'Quiz',
// //         rarity: 'Rare',
// //         unlockedDate: _quizzesCompleted >= 25 ? DateTime.now() : null,
// //       ),
// //       Achievement(
// //         id: 'perfectionist',
// //         title: 'Perfectionist',
// //         description: 'Get 10 perfect quiz scores',
// //         icon: '💎',
// //         isUnlocked: _perfectScores >= 10,
// //         color: const Color(0xFF00BCD4),
// //         progress: _perfectScores / 10,
// //         target: 10,
// //         category: 'Quiz',
// //         rarity: 'Epic',
// //         unlockedDate: _perfectScores >= 10 ? DateTime.now() : null,
// //       ),
// //
// //       // XP Achievements
// //       Achievement(
// //         id: 'xp_collector',
// //         title: 'XP Collector',
// //         description: 'Earn 1000 experience points',
// //         icon: '⭐',
// //         isUnlocked: _totalXP >= 1000,
// //         color: const Color(0xFFFFC107),
// //         progress: _totalXP / 1000,
// //         target: 1000,
// //         category: 'Experience',
// //         rarity: 'Uncommon',
// //         unlockedDate: _totalXP >= 5000 ? DateTime.now() : null,
// //       ),
// //       Achievement(
// //         id: 'xp_legend',
// //         title: 'XP Legend',
// //         description: 'Earn 10000 experience points',
// //         icon: '👑',
// //         isUnlocked: _totalXP >= 10000,
// //         color: const Color(0xFFE91E63),
// //         progress: _totalXP / 10000,
// //         target: 10000,
// //         category: 'Experience',
// //         rarity: 'Legendary',
// //         unlockedDate: _totalXP >= 10000 ? DateTime.now() : null,
// //       ),
// //
// //       // Reading Achievements
// //       Achievement(
// //         id: 'story_reader',
// //         title: 'Story Reader',
// //         description: 'Read 5 Japanese stories',
// //         icon: '📚',
// //         isUnlocked: _storiesRead >= 5,
// //         color: const Color(0xFF2196F3),
// //         progress: _storiesRead / 5,
// //         target: 5,
// //         category: 'Reading',
// //         rarity: 'Common',
// //         unlockedDate: _storiesRead >= 5 ? DateTime.now() : null,
// //       ),
// //       Achievement(
// //         id: 'bookworm',
// //         title: 'Bookworm',
// //         description: 'Read 20 Japanese stories',
// //         icon: '🐛',
// //         isUnlocked: _storiesRead >= 20,
// //         color: const Color(0xFF4CAF50),
// //         progress: _storiesRead / 20,
// //         target: 20,
// //         category: 'Reading',
// //         rarity: 'Uncommon',
// //         unlockedDate: _storiesRead >= 20 ? DateTime.now() : null,
// //       ),
// //       Achievement(
// //         id: 'literature_lover',
// //         title: 'Literature Lover',
// //         description: 'Read 50 Japanese stories',
// //         icon: '💝',
// //         isUnlocked: _storiesRead >= 50,
// //         color: const Color(0xFFE91E63),
// //         progress: _storiesRead / 50,
// //         target: 50,
// //         category: 'Reading',
// //         rarity: 'Epic',
// //         unlockedDate: _storiesRead >= 50 ? DateTime.now() : null,
// //       ),
// //
// //       // Special Achievements
// //       Achievement(
// //         id: 'early_bird',
// //         title: 'Early Bird',
// //         description: 'Study before 8 AM for 7 days',
// //         icon: '🌅',
// //         isUnlocked: false, // This would need special tracking
// //         color: const Color(0xFFFF9800),
// //         progress: 0.0,
// //         target: 7,
// //         category: 'Special',
// //         rarity: 'Rare',
// //         unlockedDate: null,
// //       ),
// //       Achievement(
// //         id: 'night_owl',
// //         title: 'Night Owl',
// //         description: 'Study after 10 PM for 7 days',
// //         icon: '🦉',
// //         isUnlocked: false, // This would need special tracking
// //         color: const Color(0xFF673AB7),
// //         progress: 0.0,
// //         target: 7,
// //         category: 'Special',
// //         rarity: 'Rare',
// //         unlockedDate: null,
// //       ),
// //       Achievement(
// //         id: 'speed_demon',
// //         title: 'Speed Demon',
// //         description: 'Complete a quiz in under 30 seconds',
// //         icon: '⚡',
// //         isUnlocked: false, // This would need special tracking
// //         color: const Color(0xFFFFEB3B),
// //         progress: 0.0,
// //         target: 1,
// //         category: 'Special',
// //         rarity: 'Epic',
// //         unlockedDate: null,
// //       ),
// //     ];
// //   }
// //
// //   List<Achievement> get _filteredAchievements {
// //     switch (_selectedFilter) {
// //       case 'Unlocked':
// //         return _achievements.where((a) => a.isUnlocked).toList();
// //       case 'Locked':
// //         return _achievements.where((a) => !a.isUnlocked && a.progress == 0.0).toList();
// //       case 'In Progress':
// //         return _achievements.where((a) => !a.isUnlocked && a.progress > 0.0).toList();
// //       default:
// //         return _achievements;
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     _userDataSubscription?.cancel();
// //     _fadeController.dispose();
// //     _slideController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8F9FF),
// //       body: SafeArea(
// //         child: LayoutBuilder(
// //           builder: (context, constraints) {
// //             final isSmallScreen = constraints.maxWidth < 375;
// //             return FadeTransition(
// //               opacity: _fadeAnimation,
// //               child: SlideTransition(
// //                 position: _slideAnimation,
// //                 child: Column(
// //                   children: [
// //                     _buildHeader(isSmallScreen),
// //                     _buildStatsOverview(isSmallScreen),
// //                     _buildFilterTabs(isSmallScreen),
// //                     Expanded(
// //                       child: _isLoading
// //                           ? _buildLoadingState()
// //                           : _buildAchievementsList(isSmallScreen),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildHeader(bool isSmallScreen) {
// //     final unlockedCount = _achievements.where((a) => a.isUnlocked).length;
// //     final totalCount = _achievements.length;
// //
// //     return Container(
// //       padding: const EdgeInsets.all(20),
// //       child: Row(
// //         children: [
// //           Container(
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(12),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withOpacity(0.05),
// //                   blurRadius: 10,
// //                   offset: const Offset(0, 2),
// //                 ),
// //               ],
// //             ),
// //             child: IconButton(
// //               icon: const Icon(
// //                 Icons.arrow_back_ios_new,
// //                 color: Color(0xFF6366F1),
// //                 size: 20,
// //               ),
// //               onPressed: () => Navigator.of(context).pop(),
// //             ),
// //           ),
// //           const SizedBox(width: 16),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   'Achievements',
// //                   style: GoogleFonts.poppins(
// //                     fontSize: 24,
// //                     fontWeight: FontWeight.bold,
// //                     color: const Color(0xFF1F2937),
// //                   ),
// //                 ),
// //                 Text(
// //                   '$unlockedCount/$totalCount unlocked',
// //                   style: GoogleFonts.poppins(
// //                     fontSize: 14,
// //                     color: const Color(0xFF6B7280),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //             decoration: BoxDecoration(
// //               gradient: const LinearGradient(
// //                 colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
// //               ),
// //               borderRadius: BorderRadius.circular(20),
// //             ),
// //             child: Text(
// //               '${((unlockedCount / totalCount) * 100).round()}%',
// //               style: GoogleFonts.poppins(
// //                 fontSize: 14,
// //                 fontWeight: FontWeight.bold,
// //                 color: Colors.white,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildStatsOverview(bool isSmallScreen) {
// //     return Container(
// //       margin: const EdgeInsets.symmetric(horizontal: 20),
// //       padding: const EdgeInsets.all(20),
// //       decoration: BoxDecoration(
// //         gradient: const LinearGradient(
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //           colors: [
// //             Color(0xFF6366F1),
// //             Color(0xFF8B5CF6),
// //             Color(0xFFEC4899),
// //           ],
// //         ),
// //         borderRadius: BorderRadius.circular(20),
// //         boxShadow: [
// //           BoxShadow(
// //             color: const Color(0xFF6366F1).withOpacity(0.3),
// //             blurRadius: 20,
// //             offset: const Offset(0, 10),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         children: [
// //           Text(
// //             'Your Progress',
// //             style: GoogleFonts.poppins(
// //               fontSize: 18,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.white,
// //             ),
// //           ),
// //           const SizedBox(height: 16),
// //           Row(
// //             children: [
// //               _buildStatItem('Streak', '$_studyStreak days', '🔥'),
// //               _buildStatItem('Kanji', '$_kanjiLearned', '🈶'),
// //               _buildStatItem('Stories', '$_storiesRead', '📚'),
// //               _buildStatItem('Quizzes', '$_quizzesCompleted', '🧠'),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildStatItem(String label, String value, String emoji) {
// //     return Expanded(
// //       child: Column(
// //         children: [
// //           Text(
// //             emoji,
// //             style: const TextStyle(fontSize: 24),
// //           ),
// //           const SizedBox(height: 8),
// //           Text(
// //             value,
// //             style: GoogleFonts.poppins(
// //               fontSize: 16,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.white,
// //             ),
// //           ),
// //           Text(
// //             label,
// //             style: GoogleFonts.poppins(
// //               fontSize: 12,
// //               color: Colors.white.withOpacity(0.8),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildFilterTabs(bool isSmallScreen) {
// //     return Container(
// //       margin: const EdgeInsets.all(20),
// //       child: SingleChildScrollView(
// //         scrollDirection: Axis.horizontal,
// //         child: Row(
// //           children: _filterOptions.map((filter) {
// //             final isSelected = _selectedFilter == filter;
// //             return Container(
// //               margin: const EdgeInsets.only(right: 12),
// //               child: GestureDetector(
// //                 onTap: () {
// //                   setState(() {
// //                     _selectedFilter = filter;
// //                   });
// //                 },
// //                 child: Container(
// //                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
// //                   decoration: BoxDecoration(
// //                     color: isSelected ? const Color(0xFF6366F1) : Colors.white,
// //                     borderRadius: BorderRadius.circular(20),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Colors.black.withOpacity(0.05),
// //                         blurRadius: 10,
// //                         offset: const Offset(0, 2),
// //                       ),
// //                     ],
// //                   ),
// //                   child: Text(
// //                     filter,
// //                     style: GoogleFonts.poppins(
// //                       fontSize: 14,
// //                       fontWeight: FontWeight.w600,
// //                       color: isSelected ? Colors.white : const Color(0xFF6B7280),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             );
// //           }).toList(),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildLoadingState() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Container(
// //             width: 80,
// //             height: 80,
// //             decoration: BoxDecoration(
// //               gradient: const LinearGradient(
// //                 colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
// //               ),
// //               borderRadius: BorderRadius.circular(20),
// //             ),
// //             child: const Center(
// //               child: CircularProgressIndicator(
// //                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
// //                 strokeWidth: 3,
// //               ),
// //             ),
// //           ),
// //           const SizedBox(height: 24),
// //           Text(
// //             'Loading achievements...',
// //             style: GoogleFonts.poppins(
// //               fontSize: 18,
// //               fontWeight: FontWeight.w600,
// //               color: const Color(0xFF1F2937),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildAchievementsList(bool isSmallScreen) {
// //     final filteredAchievements = _filteredAchievements;
// //
// //     if (filteredAchievements.isEmpty) {
// //       return _buildEmptyState();
// //     }
// //
// //     return GridView.builder(
// //       padding: const EdgeInsets.symmetric(horizontal: 20),
// //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //         crossAxisCount: isSmallScreen ? 1 : 2,
// //         childAspectRatio: isSmallScreen ? 3.5 : 2.8,
// //         crossAxisSpacing: 16,
// //         mainAxisSpacing: 16,
// //       ),
// //       itemCount: filteredAchievements.length,
// //       itemBuilder: (context, index) {
// //         final achievement = filteredAchievements[index];
// //         return _buildAchievementCard(achievement, isSmallScreen);
// //       },
// //     );
// //   }
// //
// //   Widget _buildEmptyState() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Container(
// //             width: 120,
// //             height: 120,
// //             decoration: BoxDecoration(
// //               color: const Color(0xFF6366F1).withOpacity(0.1),
// //               borderRadius: BorderRadius.circular(60),
// //             ),
// //             child: const Icon(
// //               Icons.emoji_events,
// //               size: 60,
// //               color: Color(0xFF6366F1),
// //             ),
// //           ),
// //           const SizedBox(height: 24),
// //           Text(
// //             'No achievements found',
// //             style: GoogleFonts.poppins(
// //               fontSize: 20,
// //               fontWeight: FontWeight.bold,
// //               color: const Color(0xFF1F2937),
// //             ),
// //           ),
// //           const SizedBox(height: 8),
// //           Text(
// //             'Keep studying to unlock more achievements!',
// //             style: GoogleFonts.poppins(
// //               fontSize: 14,
// //               color: const Color(0xFF6B7280),
// //             ),
// //             textAlign: TextAlign.center,
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildAchievementCard(Achievement achievement, bool isSmallScreen) {
// //     final progressPercent = (achievement.progress * 100).clamp(0, 100).round();
// //
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: achievement.isUnlocked
// //             ? Colors.white
// //             : Colors.white.withOpacity(0.7),
// //         borderRadius: BorderRadius.circular(20),
// //         border: Border.all(
// //           color: achievement.isUnlocked
// //               ? achievement.color.withOpacity(0.3)
// //               : Colors.grey.withOpacity(0.2),
// //           width: 2,
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: achievement.isUnlocked
// //                 ? achievement.color.withOpacity(0.1)
// //                 : Colors.black.withOpacity(0.05),
// //             blurRadius: 15,
// //             offset: const Offset(0, 5),
// //           ),
// //         ],
// //       ),
// //       child: Stack(
// //         children: [
// //           // Rarity indicator
// //           Positioned(
// //             top: 12,
// //             right: 12,
// //             child: Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //               decoration: BoxDecoration(
// //                 color: _getRarityColor(achievement.rarity).withOpacity(0.1),
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: Text(
// //                 achievement.rarity,
// //                 style: GoogleFonts.poppins(
// //                   fontSize: 10,
// //                   fontWeight: FontWeight.bold,
// //                   color: _getRarityColor(achievement.rarity),
// //                 ),
// //               ),
// //             ),
// //           ),
// //
// //           // Main content
// //           Padding(
// //             padding: const EdgeInsets.all(20),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   children: [
// //                     Container(
// //                       width: 60,
// //                       height: 60,
// //                       decoration: BoxDecoration(
// //                         color: achievement.color.withOpacity(0.1),
// //                         borderRadius: BorderRadius.circular(16),
// //                       ),
// //                       child: Center(
// //                         child: Text(
// //                           achievement.icon,
// //                           style: TextStyle(
// //                             fontSize: 28,
// //                             color: achievement.isUnlocked
// //                                 ? null
// //                                 : Colors.grey,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 16),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             achievement.title,
// //                             style: GoogleFonts.poppins(
// //                               fontSize: 16,
// //                               fontWeight: FontWeight.bold,
// //                               color: achievement.isUnlocked
// //                                   ? const Color(0xFF1F2937)
// //                                   : const Color(0xFF6B7280),
// //                             ),
// //                           ),
// //                           const SizedBox(height: 4),
// //                           Text(
// //                             achievement.description,
// //                             style: GoogleFonts.poppins(
// //                               fontSize: 12,
// //                               color: achievement.isUnlocked
// //                                   ? const Color(0xFF6B7280)
// //                                   : const Color(0xFF9CA3AF),
// //                             ),
// //                             maxLines: 2,
// //                             overflow: TextOverflow.ellipsis,
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //
// //                 const Spacer(),
// //
// //                 // Progress section
// //                 if (!achievement.isUnlocked) ...[
// //                   Row(
// //                     children: [
// //                       Text(
// //                         'Progress: $progressPercent%',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: 12,
// //                           fontWeight: FontWeight.w600,
// //                           color: const Color(0xFF6B7280),
// //                         ),
// //                       ),
// //                       const Spacer(),
// //                       Text(
// //                         '${(achievement.progress * achievement.target).round()}/${achievement.target}',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: 12,
// //                           color: const Color(0xFF9CA3AF),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 8),
// //                   LinearProgressIndicator(
// //                     value: achievement.progress.clamp(0.0, 1.0),
// //                     backgroundColor: Colors.grey[200],
// //                     valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
// //                     minHeight: 6,
// //                   ),
// //                 ] else ...[
// //                   Row(
// //                     children: [
// //                       Container(
// //                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //                         decoration: BoxDecoration(
// //                           color: const Color(0xFF10B981).withOpacity(0.1),
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                         child: Row(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             const Icon(
// //                               Icons.check_circle,
// //                               color: Color(0xFF10B981),
// //                               size: 16,
// //                             ),
// //                             const SizedBox(width: 4),
// //                             Text(
// //                               'Unlocked',
// //                               style: GoogleFonts.poppins(
// //                                 fontSize: 12,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: const Color(0xFF10B981),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       const Spacer(),
// //                       if (achievement.unlockedDate != null)
// //                         Text(
// //                           _formatDate(achievement.unlockedDate!),
// //                           style: GoogleFonts.poppins(
// //                             fontSize: 10,
// //                             color: const Color(0xFF9CA3AF),
// //                           ),
// //                         ),
// //                     ],
// //                   ),
// //                 ],
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Color _getRarityColor(String rarity) {
// //     switch (rarity.toLowerCase()) {
// //       case 'common':
// //         return const Color(0xFF6B7280);
// //       case 'uncommon':
// //         return const Color(0xFF10B981);
// //       case 'rare':
// //         return const Color(0xFF3B82F6);
// //       case 'epic':
// //         return const Color(0xFF8B5CF6);
// //       case 'legendary':
// //         return const Color(0xFFEAB308);
// //       default:
// //         return const Color(0xFF6B7280);
// //     }
// //   }
// //
// //   String _formatDate(DateTime date) {
// //     final now = DateTime.now();
// //     final difference = now.difference(date);
// //
// //     if (difference.inDays > 0) {
// //       return '${difference.inDays}d ago';
// //     } else if (difference.inHours > 0) {
// //       return '${difference.inHours}h ago';
// //     } else {
// //       return 'Just now';
// //     }
// //   }
// // }
// //
// // class Achievement {
// //   final String id;
// //   final String title;
// //   final String description;
// //   final String icon;
// //   final bool isUnlocked;
// //   final Color color;
// //   final double progress;
// //   final int target;
// //   final String category;
// //   final String rarity;
// //   final DateTime? unlockedDate;
// //
// //   Achievement({
// //     required this.id,
// //     required this.title,
// //     required this.description,
// //     required this.icon,
// //     required this.isUnlocked,
// //     required this.color,
// //     required this.progress,
// //     required this.target,
// //     this.category = 'General',
// //     this.rarity = 'Common',
// //     this.unlockedDate,
// //   });
// // }