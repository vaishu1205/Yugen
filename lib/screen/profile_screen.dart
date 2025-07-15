import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_programs/screen/Achivements_screen.dart';
import 'package:flutter_programs/screen/KanjiPractice_screen.dart';
import 'package:flutter_programs/screen/Notification_screen.dart';
import 'package:flutter_programs/screen/Quiz_screen.dart';
import 'package:flutter_programs/screen/RecentActivity_screen.dart';
import 'package:flutter_programs/screen/Settings_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

import 'EditProfile.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _slideController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  // User Data
  String _userName = "Student";
  String _userEmail = "";
  String _userLevel = "N5";
  int _studyStreak = 0;
  int _totalXP = 0;
  int _kanjiLearned = 0;
  int _storiesRead = 0;
  int _quizzesCompleted = 0;
  DateTime? _joinDate;
  bool _isLoading = true;
  bool _isOnline = true;

  // Achievements
  List<Achievement> _achievements = [];
  List<StudySession> _recentSessions = [];

  // Real-time listeners
  StreamSubscription<DocumentSnapshot>? _userDataSubscription;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _setupRealtimeListeners();
    _loadAchievements();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  void _setupRealtimeListeners() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Real-time user data listener
      _userDataSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && mounted) {
          final data = snapshot.data()!;
          setState(() {
            _userName = data['name'] ?? "Student";
            _userEmail = data['email'] ?? "";
            _userLevel = data['jlptLevel'] ?? "N5";
            _studyStreak = data['studyStreak'] ?? 0;
            _totalXP = data['totalXP'] ?? 0;
            _kanjiLearned = data['totalKanjiLearned'] ?? 0;
            _storiesRead = data['storiesRead'] ?? 0;
            _quizzesCompleted = data['quizzesCompleted'] ?? 0;
            _joinDate = (data['createdAt'] as Timestamp?)?.toDate();
            _isOnline = data['isOnline'] ?? true;
            _isLoading = false;
          });
          _loadAchievements();
          _loadRecentSessions();
        }
      }, onError: (error) {
        print('Error listening to user data: $error');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });

      // Update user's online status
      _updateOnlineStatus(true);
    }
  }

  Future<void> _updateOnlineStatus(bool isOnline) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'isOnline': isOnline,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Error updating online status: $e');
      }
    }
  }

  void _loadRecentSessions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final sessions = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('study_sessions')
            .orderBy('date', descending: true)
            .limit(5)
            .get();

        if (mounted) {
          setState(() {
            _recentSessions = sessions.docs.map((doc) {
              final data = doc.data();
              return StudySession(
                date: (data['date'] as Timestamp).toDate(),
                activity: data['activity'] ?? 'Study',
                xpEarned: data['xpEarned'] ?? 0,
                duration: data['duration'] ?? 0,
              );
            }).toList();
          });
        }
      } catch (e) {
        print('Error loading recent sessions: $e');
      }
    }
  }

  void _loadAchievements() {
    _achievements = [
      Achievement(
        id: 'first_kanji',
        title: 'First Kanji',
        description: 'Learned your first Kanji character',
        icon: '🈶',
        isUnlocked: _kanjiLearned > 0,
        color: const Color(0xFF4CAF50),
        progress: _kanjiLearned > 0 ? 1.0 : 0.0,
        target: 1,
      ),
      Achievement(
        id: 'week_streak',
        title: 'Week Warrior',
        description: 'Study for 7 days in a row',
        icon: '🔥',
        isUnlocked: _studyStreak >= 7,
        color: const Color(0xFFFF5722),
        progress: _studyStreak / 7,
        target: 7,
      ),
      Achievement(
        id: 'story_reader',
        title: 'Story Reader',
        description: 'Read 5 Japanese stories',
        icon: '📚',
        isUnlocked: _storiesRead >= 5,
        color: const Color(0xFF2196F3),
        progress: _storiesRead / 5,
        target: 5,
      ),
      Achievement(
        id: 'quiz_master',
        title: 'Quiz Master',
        description: 'Complete 10 grammar quizzes',
        icon: '🧠',
        isUnlocked: _quizzesCompleted >= 10,
        color: const Color(0xFF9C27B0),
        progress: _quizzesCompleted / 10,
        target: 10,
      ),
      Achievement(
        id: 'xp_collector',
        title: 'XP Collector',
        description: 'Earn 1000 experience points',
        icon: '⭐',
        isUnlocked: _totalXP >= 1000,
        color: const Color(0xFFFFC107),
        progress: _totalXP / 1000,
        target: 1000,
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
      ),
    ];
  }

  @override
  void dispose() {
    _updateOnlineStatus(false);
    _userDataSubscription?.cancel();
    _slideController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
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
            return RefreshIndicator(
              onRefresh: () async {
                _loadRecentSessions();
              },
              color: const Color(0xFF6366F1),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    sliver: SliverToBoxAdapter(
                      child: _buildHeader(isSmallScreen),
                    ),
                  ),
                  _isLoading
                      ? SliverFillRemaining(
                    child: _buildLoadingState(),
                  )
                      : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildProfileHeader(isSmallScreen),
                        const SizedBox(height: 24),
                        _buildStatsGrid(isSmallScreen),
                        const SizedBox(height: 24),
                        _buildQuickActions(isSmallScreen),
                        const SizedBox(height: 24),
                        _buildAchievements(isSmallScreen),
                        const SizedBox(height: 24),
                        _buildRecentActivity(isSmallScreen),
                        const SizedBox(height: 24),
                        _buildActionButtons(isSmallScreen),
                        const SizedBox(height: 40),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Row(
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
                'My Profile',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                'Track your learning journey',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
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
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF6366F1),
                  size: 24,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
           },
          ),
        ),
      ],
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
            'Loading your profile...',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we fetch your data',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        borderRadius: BorderRadius.circular(24),
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
          Stack(
            alignment: Alignment.center,
            children: [
              // Rotating Ring
              AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Pulsing Avatar
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              _userName.isNotEmpty ? _userName[0].toUpperCase() : 'S',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6366F1),
                              ),
                            ),
                          ),
                          if (_isOnline)
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
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
          const SizedBox(height: 20),
          Text(
            _userName,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _userEmail,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'JLPT $_userLevel',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isOnline)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Online',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (_joinDate != null) ...[
            const SizedBox(height: 12),
            Text(
              'Member since ${_formatDate(_joinDate!)}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isSmallScreen) {
    final stats = [
      {
        'label': 'Study Streak',
        'value': '$_studyStreak',
        'unit': 'days',
        'icon': Icons.local_fire_department,
        'color': const Color(0xFFFF5722),
        'change': '+2',
      },
      {
        'label': 'Total XP',
        'value': '$_totalXP',
        'unit': 'points',
        'icon': Icons.star,
        'color': const Color(0xFFFFC107),
        'change': '+150',
      },
      {
        'label': 'Kanji Learned',
        'value': '$_kanjiLearned',
        'unit': 'characters',
        'icon': Icons.translate,
        'color': const Color(0xFF4CAF50),
        'change': '+5',
      },
      {
        'label': 'Stories Read',
        'value': '$_storiesRead',
        'unit': 'stories',
        'icon': Icons.menu_book,
        'color': const Color(0xFF2196F3),
        'change': '+1',
      },
    ];

    // return GridView.builder(
    //   shrinkWrap: true,
    //   physics: const NeverScrollableScrollPhysics(),
    //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //     crossAxisCount: 2,
    //     childAspectRatio: isSmallScreen ? 1.0 : 1.2,
    //     crossAxisSpacing: 16,
    //     mainAxisSpacing: 16,
    //   ),
    //   itemCount: stats.length,
    //   itemBuilder: (context, index) {
    //     final stat = stats[index];
    //     return Container(
    //       padding: const EdgeInsets.all(20),
    //       decoration: BoxDecoration(
    //         color: Colors.white,
    //         borderRadius: BorderRadius.circular(20),
    //         boxShadow: [
    //           BoxShadow(
    //             color: (stat['color'] as Color).withOpacity(0.1),
    //             blurRadius: 20,
    //             offset: const Offset(0, 8),
    //           ),
    //         ],
    //       ),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               Container(
    //                 padding: const EdgeInsets.all(12),
    //                 decoration: BoxDecoration(
    //                   color: (stat['color'] as Color).withOpacity(0.1),
    //                   borderRadius: BorderRadius.circular(12),
    //                 ),
    //                 child: Icon(
    //                   stat['icon'] as IconData,
    //                   color: stat['color'] as Color,
    //                   size: 24,
    //                 ),
    //               ),
    //               Container(
    //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    //                 decoration: BoxDecoration(
    //                   color: const Color(0xFF10B981).withOpacity(0.1),
    //                   borderRadius: BorderRadius.circular(8),
    //                 ),
    //                 child: Text(
    //                   stat['change'] as String,
    //                   style: GoogleFonts.poppins(
    //                     fontSize: 12,
    //                     fontWeight: FontWeight.w600,
    //                     color: const Color(0xFF10B981),
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //           const Spacer(),
    //           Text(
    //             stat['value'] as String,
    //             style: GoogleFonts.poppins(
    //               fontSize: 24,
    //               fontWeight: FontWeight.bold,
    //               color: const Color(0xFF1F2937),
    //             ),
    //           ),
    //           const SizedBox(height: 4),
    //           Text(
    //             stat['label'] as String,
    //             style: GoogleFonts.poppins(
    //               fontSize: 14,
    //               fontWeight: FontWeight.w500,
    //               color: const Color(0xFF6B7280),
    //             ),
    //           ),
    //           Text(
    //             stat['unit'] as String,
    //             style: GoogleFonts.poppins(
    //               fontSize: 12,
    //               color: const Color(0xFF9CA3AF),
    //             ),
    //           ),
    //         ],
    //       ),
    //     );
    //   },
    // );
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: isSmallScreen ? 0.85 : 1.1, // Adjusted ratios
        crossAxisSpacing: 12, // Reduced spacing
        mainAxisSpacing: 12,  // Reduced spacing
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16), // Responsive padding
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16), // Slightly reduced
            boxShadow: [
              BoxShadow(
                color: (stat['color'] as Color).withOpacity(0.1),
                blurRadius: 15, // Reduced blur
                offset: const Offset(0, 4), // Reduced offset
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with icon and change indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 10), // Responsive padding
                    decoration: BoxDecoration(
                      color: (stat['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      stat['icon'] as IconData,
                      color: stat['color'] as Color,
                      size: isSmallScreen ? 18 : 20, // Responsive icon size
                    ),
                  ),
                  if (stat.containsKey('change')) // Only show if change exists
                    Flexible( // Use Flexible to prevent overflow
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          stat['change'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 10 : 11, // Responsive font
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF10B981),
                          ),
                          overflow: TextOverflow.ellipsis, // Prevent overflow
                        ),
                      ),
                    ),
                ],
              ),

              // Spacer that adapts to available space
              const Expanded(child: SizedBox()), // Use Expanded instead of Spacer

              // Value text
              Text(
                stat['value'] as String,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 18 : 22, // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
                overflow: TextOverflow.ellipsis, // Prevent overflow
                maxLines: 1,
              ),

              SizedBox(height: isSmallScreen ? 2 : 4), // Responsive spacing

              // Label text
              Text(
                stat['label'] as String,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 12 : 13, // Responsive font size
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
                overflow: TextOverflow.ellipsis, // Prevent overflow
                maxLines: 1,
              ),

              // Unit text (only show if exists)
              if (stat.containsKey('unit'))
                Text(
                  stat['unit'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 10 : 11, // Responsive font size
                    color: const Color(0xFF9CA3AF),
                  ),
                  overflow: TextOverflow.ellipsis, // Prevent overflow
                  maxLines: 1,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(bool isSmallScreen) {
    final actions = [
      {
        'title': 'Practice Kanji',
        'icon': Icons.translate,
        'color': const Color(0xFF4CAF50),
        'onTap': () => _navigateToKanjiPractice(),
      },
      {
        'title': 'Take Quiz',
        'icon': Icons.quiz,
        'color': const Color(0xFF9C27B0),
        'onTap': () => _navigateToQuiz(),
      },
      {
        'title': 'Read Story',
        'icon': Icons.menu_book,
        'color': const Color(0xFF2196F3),
        'onTap': () => _navigateToStories(),
      },
      {
        'title': 'Study Stats',
        'icon': Icons.analytics,
        'color': const Color(0xFFFFC107),
        'onTap': () => _navigateToStats(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return InkWell(
              onTap: action['onTap'] as VoidCallback,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (action['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (action['color'] as Color).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        action['title'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAchievements(bool isSmallScreen) {
    final unlockedAchievements = _achievements.where((a) => a.isUnlocked).toList();
    final nextAchievements = _achievements.where((a) => !a.isUnlocked).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievements',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AchievementsScreen(),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF6366F1),
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
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
              Row(
                children: [
                  Text(
                    'Progress',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${unlockedAchievements.length}/${_achievements.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (unlockedAchievements.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: unlockedAchievements.length,
                    itemBuilder: (context, index) {
                      final achievement = unlockedAchievements[index];
                      return Container(
                        width: 80,
                        margin: EdgeInsets.only(
                          right: index == unlockedAchievements.length - 1 ? 0 : 12,
                        ),
                        decoration: BoxDecoration(
                          color: achievement.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: achievement.color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              achievement.icon,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              achievement.title,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              if (nextAchievements.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Next Goals',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 12),
                ...nextAchievements.map((achievement) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        achievement.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achievement.title,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: achievement.progress.clamp(0.0, 1.0),
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(achievement.progress * achievement.target).round()}/${achievement.target}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudyHistoryScreen(),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF6366F1),
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
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
          child: _recentSessions.isEmpty
              ? Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No recent activity',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start studying to see your progress here',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF9CA3AF),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
              : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: math.min(3, _recentSessions.length),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final session = _recentSessions[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getActivityColor(session.activity).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          _getActivityIconData(session.activity),
                          color: _getActivityColor(session.activity),
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.activity,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatActivityTime(session.date),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+${session.xpEarned} XP',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${session.duration}m',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isSmallScreen) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Edit Profile',
                Icons.edit,
                const Color(0xFF6366F1),
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                        userName: _userName,
                        userEmail: _userEmail,
                        userLevel: _userLevel,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                'Share Progress',
                Icons.share,
                const Color(0xFF10B981),
                _shareProgress,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Settings',
                Icons.settings,
                const Color(0xFF8B5CF6),
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                'Logout',
                Icons.logout,
                const Color(0xFFEF4444),
                _logout,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatActivityTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min ago';
    } else {
      return 'Just now';
    }
  }

  Color _getActivityColor(String activity) {
    switch (activity.toLowerCase()) {
      case 'kanji practice': return const Color(0xFF4CAF50);
      case 'grammar quiz': return const Color(0xFF9C27B0);
      case 'story reading': return const Color(0xFF2196F3);
      case 'vocabulary': return const Color(0xFFFFC107);
      default: return const Color(0xFF6366F1);
    }
  }

  IconData _getActivityIconData(String activity) {
    switch (activity.toLowerCase()) {
      case 'kanji practice': return Icons.translate;
      case 'grammar quiz': return Icons.quiz;
      case 'story reading': return Icons.menu_book;
      case 'vocabulary': return Icons.library_books;
      default: return Icons.school;
    }
  }

  String _getActivityIcon(String activity) {
    switch (activity.toLowerCase()) {
      case 'kanji practice': return '🈶';
      case 'grammar quiz': return '📚';
      case 'story reading': return '📖';
      case 'vocabulary': return '📝';
      default: return '📚';
    }
  }

  // Navigation Methods
  void _navigateToKanjiPractice() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KanjiPracticeScreen(),
      ),
    );
  }

  void _navigateToQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QuizScreen(),
      ),
    );
  }

  void _navigateToStories() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Story library opening...',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF2196F3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _navigateToStats() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Study statistics loading...',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFFFFC107),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Action Methods
  void _shareProgress() async {
    try {
      final message = '''
🎓 My Japanese Learning Progress 🎓

📚 JLPT Level: $_userLevel
🔥 Study Streak: $_studyStreak days
⭐ Total XP: $_totalXP points
🈶 Kanji Learned: $_kanjiLearned characters
📖 Stories Read: $_storiesRead stories

Join me in learning Japanese! 🇯🇵
''';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Progress shared successfully! 📤',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to share progress',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
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
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _updateOnlineStatus(false);
        await FirebaseAuth.instance.signOut();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Logged out successfully',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Logout failed. Please try again.',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
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

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.color,
    required this.progress,
    required this.target,
  });
}

class StudySession {
  final DateTime date;
  final String activity;
  final int xpEarned;
  final int duration;

  StudySession({
    required this.date,
    required this.activity,
    required this.xpEarned,
    required this.duration,
  });
}


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:math' as math;
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen>
//     with TickerProviderStateMixin {
//   // Animation Controllers
//   late AnimationController _slideController;
//   late AnimationController _rotationController;
//   late Animation<double> _slideAnimation;
//   late Animation<double> _rotationAnimation;
//
//   // User Data
//   String _userName = "Student";
//   String _userEmail = "";
//   String _userLevel = "N5";
//   int _studyStreak = 0;
//   int _totalXP = 0;
//   int _kanjiLearned = 0;
//   int _storiesRead = 0;
//   int _quizzesCompleted = 0;
//   DateTime? _joinDate;
//   bool _isLoading = true;
//
//   // Achievements
//   List<Achievement> _achievements = [];
//   List<StudySession> _recentSessions = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//     _loadUserData();
//     _loadAchievements();
//   }
//
//   void _initAnimations() {
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//
//     _rotationController = AnimationController(
//       duration: const Duration(seconds: 10),
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
//     _slideController.forward();
//     _rotationController.repeat();
//   }
//
//   Future<void> _loadUserData() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         final userData = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();
//
//         if (userData.exists && mounted) {
//           final data = userData.data()!;
//           setState(() {
//             _userName = data['name'] ?? "Student";
//             _userEmail = data['email'] ?? "";
//             _userLevel = data['jlptLevel'] ?? "N5";
//             _studyStreak = data['studyStreak'] ?? 0;
//             _totalXP = data['totalXP'] ?? 0;
//             _kanjiLearned = data['totalKanjiLearned'] ?? 0;
//             _storiesRead = data['storiesRead'] ?? 0;
//             _quizzesCompleted = data['quizzesCompleted'] ?? 0;
//             _joinDate = (data['createdAt'] as Timestamp?)?.toDate();
//             _isLoading = false;
//           });
//           _loadAchievements();
//         }
//       } catch (e) {
//         print('Error loading user data: $e');
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       }
//     }
//   }
//
//   void _loadAchievements() {
//     _achievements = [
//       Achievement(
//         id: 'first_kanji',
//         title: 'First Kanji',
//         description: 'Learned your first Kanji character',
//         icon: '🈶',
//         isUnlocked: _kanjiLearned > 0,
//         color: const Color(0xFF10B981),
//       ),
//       Achievement(
//         id: 'week_streak',
//         title: 'Week Warrior',
//         description: 'Study for 7 days in a row',
//         icon: '🔥',
//         isUnlocked: _studyStreak >= 7,
//         color: const Color(0xFFFF6B35),
//       ),
//       Achievement(
//         id: 'story_reader',
//         title: 'Story Reader',
//         description: 'Read 5 Japanese stories',
//         icon: '📚',
//         isUnlocked: _storiesRead >= 5,
//         color: const Color(0xFF06B6D4),
//       ),
//       Achievement(
//         id: 'quiz_master',
//         title: 'Quiz Master',
//         description: 'Complete 10 grammar quizzes',
//         icon: '🧠',
//         isUnlocked: _quizzesCompleted >= 10,
//         color: const Color(0xFF8B5CF6),
//       ),
//       Achievement(
//         id: 'xp_collector',
//         title: 'XP Collector',
//         description: 'Earn 1000 experience points',
//         icon: '⭐',
//         isUnlocked: _totalXP >= 1000,
//         color: const Color(0xFFF59E0B),
//       ),
//       Achievement(
//         id: 'kanji_master',
//         title: 'Kanji Master',
//         description: 'Learn 100 Kanji characters',
//         icon: '🎓',
//         isUnlocked: _kanjiLearned >= 100,
//         color: const Color(0xFFEC4899),
//       ),
//     ];
//
//     _recentSessions = [
//       StudySession(
//         date: DateTime.now().subtract(const Duration(hours: 2)),
//         activity: 'Kanji Practice',
//         xpEarned: 50,
//         duration: 15,
//       ),
//       StudySession(
//         date: DateTime.now().subtract(const Duration(days: 1)),
//         activity: 'Grammar Quiz',
//         xpEarned: 30,
//         duration: 10,
//       ),
//       StudySession(
//         date: DateTime.now().subtract(const Duration(days: 2)),
//         activity: 'Story Reading',
//         xpEarned: 40,
//         duration: 20,
//       ),
//     ];
//   }
//
//   @override
//   void dispose() {
//     _slideController.dispose();
//     _rotationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1117),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final isSmallScreen = constraints.maxWidth < 375;
//             return CustomScrollView(
//               physics: const BouncingScrollPhysics(),
//               slivers: [
//                 SliverPadding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   sliver: SliverToBoxAdapter(
//                     child: _buildHeader(isSmallScreen),
//                   ),
//                 ),
//                 _isLoading
//                     ? SliverFillRemaining(
//                   child: _buildLoadingState(),
//                 )
//                     : SliverPadding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   sliver: SliverList(
//                     delegate: SliverChildListDelegate([
//                       _buildProfileHeader(isSmallScreen),
//                       const SizedBox(height: 16),
//                       _buildStatsGrid(isSmallScreen),
//                       const SizedBox(height: 16),
//                       _buildAchievements(isSmallScreen),
//                       const SizedBox(height: 16),
//                       _buildRecentActivity(isSmallScreen),
//                       const SizedBox(height: 16),
//                       _buildActionButtons(isSmallScreen),
//                       const SizedBox(height: 32),
//                     ]),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(bool isSmallScreen) {
//     return SizedBox(
//       height: 60,
//       child: Row(
//         children: [
//           // Back Button
//           SizedBox(
//             width: 40,
//             height: 40,
//             child: IconButton(
//               padding: EdgeInsets.zero,
//               icon: const Icon(
//                 Icons.arrow_back_ios_new,
//                 color: Colors.white,
//                 size: 20,
//               ),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//           ),
//           const SizedBox(width: 12),
//           // Title
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Profile',
//                   style: GoogleFonts.poppins(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Text(
//                   'Your learning journey',
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     color: Colors.white.withOpacity(0.7),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Settings Button
//           SizedBox(
//             width: 40,
//             height: 40,
//             child: IconButton(
//               padding: EdgeInsets.zero,
//               icon: const Icon(
//                 Icons.settings,
//                 color: Colors.white,
//                 size: 20,
//               ),
//               onPressed: _openSettings,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 60,
//             height: 60,
//             child: CircularProgressIndicator(
//               valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
//               strokeWidth: 4,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Loading your profile...',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildProfileHeader(bool isSmallScreen) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             const Color(0xFF8B5CF6).withOpacity(0.1),
//             const Color(0xFFEC4899).withOpacity(0.1),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: const Color(0xFF8B5CF6).withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         children: [
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               // Rotating Ring
//               AnimatedBuilder(
//                 animation: _rotationAnimation,
//                 builder: (context, child) {
//                   return Transform.rotate(
//                     angle: _rotationAnimation.value,
//                     child: Container(
//                       width: 100,
//                       height: 100,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: const Color(0xFF8B5CF6).withOpacity(0.3),
//                           width: 2,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               // Avatar
//               Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
//                   ),
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFF8B5CF6).withOpacity(0.3),
//                       blurRadius: 15,
//                       offset: const Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: Center(
//                   child: Text(
//                     _userName.isNotEmpty ? _userName[0].toUpperCase() : 'S',
//                     style: GoogleFonts.poppins(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             _userName,
//             style: GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             _userEmail,
//             style: GoogleFonts.poppins(
//               fontSize: 13,
//               color: Colors.white.withOpacity(0.7),
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
//               ),
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(
//                   Icons.school,
//                   color: Colors.white,
//                   size: 16,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'JLPT $_userLevel',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (_joinDate != null) ...[
//             const SizedBox(height: 8),
//             Text(
//               'Member since ${_formatDate(_joinDate!)}',
//               style: GoogleFonts.poppins(
//                 fontSize: 11,
//                 color: Colors.white.withOpacity(0.6),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatsGrid(bool isSmallScreen) {
//     final stats = [
//       {'label': 'Study Streak', 'value': '$_studyStreak', 'unit': 'days', 'icon': '🔥', 'color': const Color(0xFFFF6B35)},
//       {'label': 'Total XP', 'value': '$_totalXP', 'unit': 'points', 'icon': '⭐', 'color': const Color(0xFFF59E0B)},
//       {'label': 'Kanji Learned', 'value': '$_kanjiLearned', 'unit': 'chars', 'icon': '🈶', 'color': const Color(0xFF10B981)},
//       {'label': 'Stories Read', 'value': '$_storiesRead', 'unit': 'stories', 'icon': '📚', 'color': const Color(0xFF06B6D4)},
//     ];
//
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: isSmallScreen ? 0.9 : 1.1,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//       ),
//       itemCount: stats.length,
//       itemBuilder: (context, index) {
//         final stat = stats[index];
//         return Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: (stat['color'] as Color).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: (stat['color'] as Color).withOpacity(0.3),
//               width: 1,
//             ),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Flexible(
//                 child: FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Text(
//                     stat['icon'] as String,
//                     style: const TextStyle(fontSize: 28),
//                   ),
//                 ),
//               ),
//               Flexible(
//                 child: FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Text(
//                     stat['value'] as String,
//                     style: GoogleFonts.poppins(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//               Flexible(
//                 child: FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Text(
//                     stat['label'] as String,
//                     style: GoogleFonts.poppins(
//                       fontSize: 13,
//                       color: Colors.white.withOpacity(0.8),
//                     ),
//                   ),
//                 ),
//               ),
//               Flexible(
//                 child: FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Text(
//                     stat['unit'] as String,
//                     style: GoogleFonts.poppins(
//                       fontSize: 11,
//                       color: Colors.white.withOpacity(0.6),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//   Widget _buildAchievements(bool isSmallScreen) {
//     final unlockedAchievements = _achievements.where((a) => a.isUnlocked).toList();
//     final lockedAchievements = _achievements.where((a) => !a.isUnlocked).toList();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               'Achievements',
//               style: GoogleFonts.poppins(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const Spacer(),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF10B981).withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 '${unlockedAchievements.length}/${_achievements.length}',
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFF10B981),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         if (unlockedAchievements.isNotEmpty) ...[
//           SizedBox(
//             height: isSmallScreen ? 100 : 120,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: unlockedAchievements.length,
//               itemBuilder: (context, index) {
//                 final achievement = unlockedAchievements[index];
//                 return Container(
//                   width: isSmallScreen ? 90 : 100,
//                   margin: EdgeInsets.only(right: index == unlockedAchievements.length - 1 ? 0 : 12),
//                   decoration: BoxDecoration(
//                     color: achievement.color.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: achievement.color.withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         achievement.icon,
//                         style: const TextStyle(fontSize: 28),
//                       ),
//                       const SizedBox(height: 8),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 4),
//                         child: Text(
//                           achievement.title,
//                           style: GoogleFonts.poppins(
//                             fontSize: isSmallScreen ? 11 : 12,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                           textAlign: TextAlign.center,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//         if (lockedAchievements.isNotEmpty) ...[
//           const SizedBox(height: 16),
//           Text(
//             'Coming Next',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.white.withOpacity(0.8),
//             ),
//           ),
//           const SizedBox(height: 8),
//           SizedBox(
//             height: isSmallScreen ? 90 : 100,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: math.min(3, lockedAchievements.length),
//               itemBuilder: (context, index) {
//                 final achievement = lockedAchievements[index];
//                 return Container(
//                   width: isSmallScreen ? 85 : 90,
//                   margin: EdgeInsets.only(right: index == math.min(2, lockedAchievements.length - 1) ? 0 : 12),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: Colors.white.withOpacity(0.2),
//                       width: 1,
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Opacity(
//                         opacity: 0.5,
//                         child: Text(
//                           achievement.icon,
//                           style: const TextStyle(fontSize: 24),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 4),
//                         child: Text(
//                           achievement.title,
//                           style: GoogleFonts.poppins(
//                             fontSize: isSmallScreen ? 10 : 11,
//                             color: Colors.white.withOpacity(0.6),
//                           ),
//                           textAlign: TextAlign.center,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ],
//     );
//   }
//
//   Widget _buildRecentActivity(bool isSmallScreen) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Recent Activity',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         const SizedBox(height: 16),
//         Container(
//           width: double.infinity,
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.05),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: Colors.white.withOpacity(0.1),
//               width: 1,
//             ),
//           ),
//           child: ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             padding: const EdgeInsets.all(16),
//             itemCount: _recentSessions.length,
//             separatorBuilder: (context, index) => const SizedBox(height: 12),
//             itemBuilder: (context, index) {
//               final session = _recentSessions[index];
//               return Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.05),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: _getActivityColor(session.activity).withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Center(
//                         child: Text(
//                           _getActivityIcon(session.activity),
//                           style: const TextStyle(fontSize: 18),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             session.activity,
//                             style: GoogleFonts.poppins(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           Text(
//                             _formatActivityTime(session.date),
//                             style: GoogleFonts.poppins(
//                               fontSize: 11,
//                               color: Colors.white.withOpacity(0.6),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           '+${session.xpEarned} XP',
//                           style: GoogleFonts.poppins(
//                             fontSize: 13,
//                             fontWeight: FontWeight.bold,
//                             color: const Color(0xFF10B981),
//                           ),
//                         ),
//                         Text(
//                           '${session.duration}m',
//                           style: GoogleFonts.poppins(
//                             fontSize: 11,
//                             color: Colors.white.withOpacity(0.6),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildActionButtons(bool isSmallScreen) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: _buildActionButton(
//                 'Edit Profile',
//                 Icons.edit,
//                 const Color(0xFF8B5CF6),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _buildActionButton(
//                 'Share Progress',
//                 Icons.share,
//                 const Color(0xFF10B981),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: _buildActionButton(
//                 'Study Reminder',
//                 Icons.notifications,
//                 const Color(0xFF06B6D4),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _buildActionButton(
//                 'Logout',
//                 Icons.logout,
//                 const Color(0xFFEC4899),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildActionButton(String text, IconData icon, Color color) {
//     return SizedBox(
//       height: 50,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color.withOpacity(0.1),
//           foregroundColor: color,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//             side: BorderSide(
//               color: color.withOpacity(0.3),
//               width: 1,
//             ),
//           ),
//           elevation: 0,
//           padding: const EdgeInsets.symmetric(horizontal: 8),
//         ),
//         onPressed: () {
//           switch (text) {
//             case 'Edit Profile':
//               _editProfile();
//               break;
//             case 'Share Progress':
//               _shareProgress();
//               break;
//             case 'Study Reminder':
//               _setReminder();
//               break;
//             case 'Logout':
//               _logout();
//               break;
//           }
//         },
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 20),
//             const SizedBox(width: 8),
//             Flexible(
//               child: Text(
//                 text,
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Helper Methods
//   String _formatDate(DateTime date) {
//     const months = [
//       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//     ];
//     return '${months[date.month - 1]} ${date.year}';
//   }
//
//   String _formatActivityTime(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
//
//     if (difference.inDays > 0) {
//       return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
//     } else {
//       return '${difference.inMinutes} min ago';
//     }
//   }
//
//   Color _getActivityColor(String activity) {
//     switch (activity.toLowerCase()) {
//       case 'kanji practice': return const Color(0xFF10B981);
//       case 'grammar quiz': return const Color(0xFF8B5CF6);
//       case 'story reading': return const Color(0xFF06B6D4);
//       default: return const Color(0xFFF59E0B);
//     }
//   }
//
//   String _getActivityIcon(String activity) {
//     switch (activity.toLowerCase()) {
//       case 'kanji practice': return '🈶';
//       case 'grammar quiz': return '📚';
//       case 'story reading': return '📖';
//       default: return '📝';
//     }
//   }
//
//   // Action Methods
//   void _openSettings() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: const Color(0xFF1C2128),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => _buildSettingsSheet(),
//     );
//   }
//
//   Widget _buildSettingsSheet() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Settings',
//             style: GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 24),
//           ...[
//             {'title': 'Notifications', 'icon': Icons.notifications, 'onTap': () {}},
//             {'title': 'Language', 'icon': Icons.language, 'onTap': () {}},
//             {'title': 'Privacy', 'icon': Icons.privacy_tip, 'onTap': () {}},
//             {'title': 'Help & Support', 'icon': Icons.help, 'onTap': () {}},
//             {'title': 'About', 'icon': Icons.info, 'onTap': () {}},
//           ].map((item) => ListTile(
//             leading: Icon(
//               item['icon'] as IconData,
//               color: const Color(0xFF8B5CF6),
//             ),
//             title: Text(
//               item['title'] as String,
//               style: GoogleFonts.poppins(color: Colors.white),
//             ),
//             trailing: const Icon(
//               Icons.arrow_forward_ios,
//               color: Colors.white54,
//               size: 16,
//             ),
//             onTap: item['onTap'] as VoidCallback,
//           )),
//           const SizedBox(height: 16),
//         ],
//       ),
//     );
//   }
//
//   void _editProfile() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Edit Profile coming soon! ✏️'),
//         backgroundColor: Color(0xFF8B5CF6),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }
//
//   void _shareProgress() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Share Progress coming soon! 📤'),
//         backgroundColor: Color(0xFF8B5CF6),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }
//
//   void _setReminder() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Study Reminder set! 🔔'),
//         backgroundColor: Color(0xFF8B5CF6),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }
//
//   // In your ProfileScreen, update the _logout method:
//
//   Future<void> _logout() async {
//     try {
//       await FirebaseAuth.instance.signOut();
//
//       // Don't navigate manually - AuthChecker will handle it automatically
//       // The AuthChecker will detect the auth state change and show LoginScreen
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Logged out successfully'),
//             backgroundColor: Color(0xFF10B981),
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Logout failed. Please try again.'),
//             backgroundColor: Color(0xFFEC4899),
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
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
//
//   Achievement({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.icon,
//     required this.isUnlocked,
//     required this.color,
//   });
// }
//
// class StudySession {
//   final DateTime date;
//   final String activity;
//   final int xpEarned;
//   final int duration;
//
//   StudySession({
//     required this.date,
//     required this.activity,
//     required this.xpEarned,
//     required this.duration,
//   });
// }
//
//
//
//
//
