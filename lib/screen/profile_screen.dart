import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

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
  late Animation<double> _slideAnimation;
  late Animation<double> _rotationAnimation;

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

  // Achievements
  List<Achievement> _achievements = [];
  List<StudySession> _recentSessions = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadUserData();
    _loadAchievements();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _slideController.forward();
    _rotationController.repeat();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists && mounted) {
          final data = userData.data()!;
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
            _isLoading = false;
          });
          _loadAchievements();
        }
      } catch (e) {
        print('Error loading user data: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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
        color: const Color(0xFF10B981),
      ),
      Achievement(
        id: 'week_streak',
        title: 'Week Warrior',
        description: 'Study for 7 days in a row',
        icon: '🔥',
        isUnlocked: _studyStreak >= 7,
        color: const Color(0xFFFF6B35),
      ),
      Achievement(
        id: 'story_reader',
        title: 'Story Reader',
        description: 'Read 5 Japanese stories',
        icon: '📚',
        isUnlocked: _storiesRead >= 5,
        color: const Color(0xFF06B6D4),
      ),
      Achievement(
        id: 'quiz_master',
        title: 'Quiz Master',
        description: 'Complete 10 grammar quizzes',
        icon: '🧠',
        isUnlocked: _quizzesCompleted >= 10,
        color: const Color(0xFF8B5CF6),
      ),
      Achievement(
        id: 'xp_collector',
        title: 'XP Collector',
        description: 'Earn 1000 experience points',
        icon: '⭐',
        isUnlocked: _totalXP >= 1000,
        color: const Color(0xFFF59E0B),
      ),
      Achievement(
        id: 'kanji_master',
        title: 'Kanji Master',
        description: 'Learn 100 Kanji characters',
        icon: '🎓',
        isUnlocked: _kanjiLearned >= 100,
        color: const Color(0xFFEC4899),
      ),
    ];

    _recentSessions = [
      StudySession(
        date: DateTime.now().subtract(const Duration(hours: 2)),
        activity: 'Kanji Practice',
        xpEarned: 50,
        duration: 15,
      ),
      StudySession(
        date: DateTime.now().subtract(const Duration(days: 1)),
        activity: 'Grammar Quiz',
        xpEarned: 30,
        duration: 10,
      ),
      StudySession(
        date: DateTime.now().subtract(const Duration(days: 2)),
        activity: 'Story Reading',
        xpEarned: 40,
        duration: 20,
      ),
    ];
  }

  @override
  void dispose() {
    _slideController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 375;
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  sliver: SliverToBoxAdapter(
                    child: _buildHeader(isSmallScreen),
                  ),
                ),
                _isLoading
                    ? SliverFillRemaining(
                  child: _buildLoadingState(),
                )
                    : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildProfileHeader(isSmallScreen),
                      const SizedBox(height: 16),
                      _buildStatsGrid(isSmallScreen),
                      const SizedBox(height: 16),
                      _buildAchievements(isSmallScreen),
                      const SizedBox(height: 16),
                      _buildRecentActivity(isSmallScreen),
                      const SizedBox(height: 16),
                      _buildActionButtons(isSmallScreen),
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          // Back Button
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Your learning journey',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Settings Button
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _openSettings,
            ),
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
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              strokeWidth: 4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your profile...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.1),
            const Color(0xFFEC4899).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
          width: 1,
        ),
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
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF8B5CF6).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'S',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            style: GoogleFonts.poppins(
              fontSize: 20,
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
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'JLPT $_userLevel',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (_joinDate != null) ...[
            const SizedBox(height: 8),
            Text(
              'Member since ${_formatDate(_joinDate!)}',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isSmallScreen) {
    final stats = [
      {'label': 'Study Streak', 'value': '$_studyStreak', 'unit': 'days', 'icon': '🔥', 'color': const Color(0xFFFF6B35)},
      {'label': 'Total XP', 'value': '$_totalXP', 'unit': 'points', 'icon': '⭐', 'color': const Color(0xFFF59E0B)},
      {'label': 'Kanji Learned', 'value': '$_kanjiLearned', 'unit': 'chars', 'icon': '🈶', 'color': const Color(0xFF10B981)},
      {'label': 'Stories Read', 'value': '$_storiesRead', 'unit': 'stories', 'icon': '📚', 'color': const Color(0xFF06B6D4)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: isSmallScreen ? 0.9 : 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (stat['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (stat['color'] as Color).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    stat['icon'] as String,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    stat['value'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    stat['label'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    stat['unit'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildAchievements(bool isSmallScreen) {
    final unlockedAchievements = _achievements.where((a) => a.isUnlocked).toList();
    final lockedAchievements = _achievements.where((a) => !a.isUnlocked).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Achievements',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.2),
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
        if (unlockedAchievements.isNotEmpty) ...[
          SizedBox(
            height: isSmallScreen ? 100 : 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: unlockedAchievements.length,
              itemBuilder: (context, index) {
                final achievement = unlockedAchievements[index];
                return Container(
                  width: isSmallScreen ? 90 : 100,
                  margin: EdgeInsets.only(right: index == unlockedAchievements.length - 1 ? 0 : 12),
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
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          achievement.title,
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 11 : 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
        if (lockedAchievements.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Coming Next',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: isSmallScreen ? 90 : 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: math.min(3, lockedAchievements.length),
              itemBuilder: (context, index) {
                final achievement = lockedAchievements[index];
                return Container(
                  width: isSmallScreen ? 85 : 90,
                  margin: EdgeInsets.only(right: index == math.min(2, lockedAchievements.length - 1) ? 0 : 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: 0.5,
                        child: Text(
                          achievement.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          achievement.title,
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 10 : 11,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRecentActivity(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: _recentSessions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final session = _recentSessions[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getActivityColor(session.activity).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          _getActivityIcon(session.activity),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.activity,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _formatActivityTime(session.date),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+${session.xpEarned} XP',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        Text(
                          '${session.duration}m',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.6),
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
                const Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Share Progress',
                Icons.share,
                const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Study Reminder',
                Icons.notifications,
                const Color(0xFF06B6D4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Logout',
                Icons.logout,
                const Color(0xFFEC4899),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        onPressed: () {
          switch (text) {
            case 'Edit Profile':
              _editProfile();
              break;
            case 'Share Progress':
              _shareProgress();
              break;
            case 'Study Reminder':
              _setReminder();
              break;
            case 'Logout':
              _logout();
              break;
          }
        },
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
    } else {
      return '${difference.inMinutes} min ago';
    }
  }

  Color _getActivityColor(String activity) {
    switch (activity.toLowerCase()) {
      case 'kanji practice': return const Color(0xFF10B981);
      case 'grammar quiz': return const Color(0xFF8B5CF6);
      case 'story reading': return const Color(0xFF06B6D4);
      default: return const Color(0xFFF59E0B);
    }
  }

  String _getActivityIcon(String activity) {
    switch (activity.toLowerCase()) {
      case 'kanji practice': return '🈶';
      case 'grammar quiz': return '📚';
      case 'story reading': return '📖';
      default: return '📝';
    }
  }

  // Action Methods
  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2128),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildSettingsSheet(),
    );
  }

  Widget _buildSettingsSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Settings',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ...[
            {'title': 'Notifications', 'icon': Icons.notifications, 'onTap': () {}},
            {'title': 'Language', 'icon': Icons.language, 'onTap': () {}},
            {'title': 'Privacy', 'icon': Icons.privacy_tip, 'onTap': () {}},
            {'title': 'Help & Support', 'icon': Icons.help, 'onTap': () {}},
            {'title': 'About', 'icon': Icons.info, 'onTap': () {}},
          ].map((item) => ListTile(
            leading: Icon(
              item['icon'] as IconData,
              color: const Color(0xFF8B5CF6),
            ),
            title: Text(
              item['title'] as String,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
            onTap: item['onTap'] as VoidCallback,
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit Profile coming soon! ✏️'),
        backgroundColor: Color(0xFF8B5CF6),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareProgress() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share Progress coming soon! 📤'),
        backgroundColor: Color(0xFF8B5CF6),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _setReminder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Study Reminder set! 🔔'),
        backgroundColor: Color(0xFF8B5CF6),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/welcome',
              (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout failed. Please try again.'),
          backgroundColor: Color(0xFFEC4899),
          duration: Duration(seconds: 2),
        ),
      );
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

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.color,
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
//     final size = MediaQuery.of(context).size;
//     final isSmallScreen = size.width < 400;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1117),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               minHeight: size.height - MediaQuery.of(context).padding.top,
//             ),
//             child: Container(
//               width: size.width,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Color(0xFF0D1117),
//                     Color(0xFF1C2128),
//                     Color(0xFF2D1B69),
//                     Color(0xFF8B5CF6),
//                   ],
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   // Header
//                   _buildHeader(size, isSmallScreen),
//
//                   // Content
//                   _isLoading
//                       ? _buildLoadingState(size)
//                       : _buildProfileContent(size, isSmallScreen),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(Size size, bool isSmallScreen) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: 16,
//         vertical: 12, // Reduced vertical padding
//       ),
//       child: SlideTransition(
//         position: Tween<Offset>(
//           begin: const Offset(0, -1),
//           end: Offset.zero,
//         ).animate(_slideAnimation),
//         child: SizedBox( // Added SizedBox to constrain height
//           height: 60, // Fixed height for header
//           child: Row(
//             children: [
//               // Back Button
//               GestureDetector(
//                 onTap: () => Navigator.of(context).pop(),
//                 child: Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: Colors.white.withOpacity(0.2),
//                       width: 1,
//                     ),
//                   ),
//                   child: Icon(
//                     Icons.arrow_back_ios_new,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//               ),
//
//               const SizedBox(width: 12),
//
//               // Title
//               Expanded(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Profile',
//                       style: GoogleFonts.poppins(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       'Your learning journey',
//                       style: GoogleFonts.poppins(
//                         fontSize: 12,
//                         color: Colors.white.withOpacity(0.7),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Settings Button
//               GestureDetector(
//                 onTap: _openSettings,
//                 child: Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: Colors.white.withOpacity(0.2),
//                       width: 1,
//                     ),
//                   ),
//                   child: Icon(
//                     Icons.settings,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//   Widget _buildLoadingState(Size size) {
//     return Expanded(
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: size.width * 0.15,
//               height: size.width * 0.15,
//               child: CircularProgressIndicator(
//                 valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
//                 strokeWidth: 4,
//               ),
//             ),
//             SizedBox(height: size.height * 0.02),
//             Text(
//               'Loading your profile...',
//               style: GoogleFonts.poppins(
//                 fontSize: size.width * 0.04,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProfileContent(Size size, bool isSmallScreen) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         children: [
//           // Profile Header
//           _buildProfileHeader(size, isSmallScreen),
//
//           const SizedBox(height: 16),
//
//           // Stats Grid
//           _buildStatsGrid(size, isSmallScreen),
//
//           const SizedBox(height: 16),
//
//           // Achievements
//           _buildAchievements(size, isSmallScreen),
//
//           const SizedBox(height: 16),
//
//           // Recent Activity
//           _buildRecentActivity(size, isSmallScreen),
//
//           const SizedBox(height: 16),
//
//           // Action Buttons
//           _buildActionButtons(size, isSmallScreen),
//
//           const SizedBox(height: 16),
//         ],
//       ),
//     );
//   }
//   Widget _buildProfileHeader(Size size, bool isSmallScreen) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       margin: const EdgeInsets.only(top: 8), // Added top margin
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
//           // Profile Avatar
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
//
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
//
//           const SizedBox(height: 12),
//
//           // User Info
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
//
//           const SizedBox(height: 4),
//
//           Text(
//             _userEmail,
//             style: GoogleFonts.poppins(
//               fontSize: 13,
//               color: Colors.white.withOpacity(0.7),
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//
//           const SizedBox(height: 12),
//
//           // Level Badge
//           Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 8,
//             ),
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
//                 const SizedBox(width: 6),
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
//
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
//   Widget _buildStatsGrid(Size size, bool isSmallScreen) {
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
//         childAspectRatio: 1.1, // Adjusted aspect ratio
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
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 stat['icon'] as String,
//                 style: const TextStyle(fontSize: 28),
//               ),
//               const SizedBox(height: 8),
//               FittedBox(
//                 fit: BoxFit.scaleDown,
//                 child: Text(
//                   stat['value'] as String,
//                   style: GoogleFonts.poppins(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               FittedBox(
//                 fit: BoxFit.scaleDown,
//                 child: Text(
//                   stat['label'] as String,
//                   style: GoogleFonts.poppins(
//                     fontSize: 13,
//                     color: Colors.white.withOpacity(0.8),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               FittedBox(
//                 fit: BoxFit.scaleDown,
//                 child: Text(
//                   stat['unit'] as String,
//                   style: GoogleFonts.poppins(
//                     fontSize: 11,
//                     color: Colors.white.withOpacity(0.6),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildAchievements(Size size, bool isSmallScreen) {
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
//                 fontSize: isSmallScreen ? 18 : 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const Spacer(),
//             Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isSmallScreen ? 8 : 10,
//                 vertical: isSmallScreen ? 4 : 6,
//               ),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF10B981).withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 '${unlockedAchievements.length}/${_achievements.length}',
//                 style: GoogleFonts.poppins(
//                   fontSize: isSmallScreen ? 12 : 13,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFF10B981),
//                 ),
//               ),
//             ),
//           ],
//         ),
//
//         SizedBox(height: size.height * 0.015),
//
//         // Unlocked Achievements
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
//                   margin: EdgeInsets.only(right: isSmallScreen ? 8 : 12),
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
//                         style: TextStyle(fontSize: isSmallScreen ? 32 : 36),
//                       ),
//                       SizedBox(height: isSmallScreen ? 4 : 8),
//                       Text(
//                         achievement.title,
//                         style: GoogleFonts.poppins(
//                           fontSize: isSmallScreen ? 10 : 12,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//
//         // Locked Achievements (first 3)
//         if (lockedAchievements.isNotEmpty) ...[
//           SizedBox(height: size.height * 0.015),
//           Text(
//             'Coming Next',
//             style: GoogleFonts.poppins(
//               fontSize: isSmallScreen ? 14 : 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.white.withOpacity(0.8),
//             ),
//           ),
//           SizedBox(height: size.height * 0.01),
//
//           SizedBox(
//             height: isSmallScreen ? 80 : 90,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: math.min(3, lockedAchievements.length),
//               itemBuilder: (context, index) {
//                 final achievement = lockedAchievements[index];
//                 return Container(
//                   width: isSmallScreen ? 80 : 90,
//                   margin: EdgeInsets.only(right: isSmallScreen ? 8 : 12),
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
//                           style: TextStyle(fontSize: isSmallScreen ? 24 : 28),
//                         ),
//                       ),
//                       SizedBox(height: isSmallScreen ? 4 : 8),
//                       Text(
//                         achievement.title,
//                         style: GoogleFonts.poppins(
//                           fontSize: isSmallScreen ? 10 : 11,
//                           color: Colors.white.withOpacity(0.6),
//                         ),
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
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
//   Widget _buildRecentActivity(Size size, bool isSmallScreen) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Recent Activity',
//           style: GoogleFonts.poppins(
//             fontSize: isSmallScreen ? 18 : 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//
//         SizedBox(height: size.height * 0.015),
//
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
//           child: ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
//             itemCount: _recentSessions.length,
//             itemBuilder: (context, index) {
//               final session = _recentSessions[index];
//               return Container(
//                 margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
//                 padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.05),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: isSmallScreen ? 36 : 40,
//                       height: isSmallScreen ? 36 : 40,
//                       decoration: BoxDecoration(
//                         color: _getActivityColor(session.activity).withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Center(
//                         child: Text(
//                           _getActivityIcon(session.activity),
//                           style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
//                         ),
//                       ),
//                     ),
//
//                     SizedBox(width: isSmallScreen ? 8 : 12),
//
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             session.activity,
//                             style: GoogleFonts.poppins(
//                               fontSize: isSmallScreen ? 12 : 14,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           Text(
//                             _formatActivityTime(session.date),
//                             style: GoogleFonts.poppins(
//                               fontSize: isSmallScreen ? 10 : 11,
//                               color: Colors.white.withOpacity(0.6),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           '+${session.xpEarned} XP',
//                           style: GoogleFonts.poppins(
//                             fontSize: isSmallScreen ? 12 : 13,
//                             fontWeight: FontWeight.bold,
//                             color: const Color(0xFF10B981),
//                           ),
//                         ),
//                         Text(
//                           '${session.duration}m',
//                           style: GoogleFonts.poppins(
//                             fontSize: isSmallScreen ? 10 : 11,
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
//   Widget _buildActionButtons(Size size, bool isSmallScreen) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: _buildActionButton(
//                 'Edit Profile',
//                 Icons.edit,
//                 const Color(0xFF8B5CF6),
//                 _editProfile,
//                 size,
//                 isSmallScreen,
//               ),
//             ),
//             SizedBox(width: isSmallScreen ? 8 : 12),
//             Expanded(
//               child: _buildActionButton(
//                 'Share Progress',
//                 Icons.share,
//                 const Color(0xFF10B981),
//                 _shareProgress,
//                 size,
//                 isSmallScreen,
//               ),
//             ),
//           ],
//         ),
//
//         SizedBox(height: isSmallScreen ? 8 : 12),
//
//         Row(
//           children: [
//             Expanded(
//               child: _buildActionButton(
//                 'Study Reminder',
//                 Icons.notifications,
//                 const Color(0xFF06B6D4),
//                 _setReminder,
//                 size,
//                 isSmallScreen,
//               ),
//             ),
//             SizedBox(width: isSmallScreen ? 8 : 12),
//             Expanded(
//               child: _buildActionButton(
//                 'Logout',
//                 Icons.logout,
//                 const Color(0xFFEC4899),
//                 _logout,
//                 size,
//                 isSmallScreen,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildActionButton(
//       String text,
//       IconData icon,
//       Color color,
//       VoidCallback onTap,
//       Size size,
//       bool isSmallScreen,
//       ) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: color.withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               color: color,
//               size: isSmallScreen ? 16 : 18,
//             ),
//             SizedBox(width: isSmallScreen ? 4 : 6),
//             Text(
//               text,
//               style: GoogleFonts.poppins(
//                 fontSize: isSmallScreen ? 12 : 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
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
//     final size = MediaQuery.of(context).size;
//     final isSmallScreen = size.width < 400;
//
//     return Container(
//       padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: size.width * 0.15,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.3),
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//
//           SizedBox(height: size.height * 0.02),
//
//           Text(
//             'Settings',
//             style: GoogleFonts.poppins(
//               fontSize: isSmallScreen ? 20 : 22,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//
//           SizedBox(height: size.height * 0.03),
//
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
//               style: GoogleFonts.poppins(
//                 fontSize: isSmallScreen ? 14 : 16,
//                 color: Colors.white,
//               ),
//             ),
//             trailing: const Icon(
//               Icons.arrow_forward_ios,
//               color: Colors.white54,
//               size: 16,
//             ),
//             onTap: item['onTap'] as VoidCallback,
//           )),
//
//           SizedBox(height: size.height * 0.02),
//         ],
//       ),
//     );
//   }
//
//   void _editProfile() {
//     _showMessage('Edit Profile coming soon! ✏️');
//   }
//
//   void _shareProgress() {
//     _showMessage('Share Progress coming soon! 📤');
//   }
//
//   void _setReminder() {
//     _showMessage('Study Reminder set! 🔔');
//   }
//
//   Future<void> _logout() async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       if (mounted) {
//         Navigator.of(context).pushNamedAndRemoveUntil(
//           '/welcome',
//               (route) => false,
//         );
//       }
//     } catch (e) {
//       _showMessage('Logout failed. Please try again.');
//     }
//   }
//
//   void _showMessage(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: const Color(0xFF8B5CF6),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
// }
//
// // Data Models
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
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'dart:math' as math;
// //
// // class ProfileScreen extends StatefulWidget {
// //   const ProfileScreen({super.key});
// //
// //   @override
// //   State<ProfileScreen> createState() => _ProfileScreenState();
// // }
// //
// // class _ProfileScreenState extends State<ProfileScreen>
// //     with TickerProviderStateMixin {
// //   // Animation Controllers
// //   late AnimationController _slideController;
// //   late AnimationController _rotationController;
// //   late Animation<double> _slideAnimation;
// //   late Animation<double> _rotationAnimation;
// //
// //   // User Data
// //   String _userName = "Student";
// //   String _userEmail = "";
// //   String _userLevel = "N5";
// //   int _studyStreak = 0;
// //   int _totalXP = 0;
// //   int _kanjiLearned = 0;
// //   int _storiesRead = 0;
// //   int _quizzesCompleted = 0;
// //   DateTime? _joinDate;
// //   bool _isLoading = true;
// //
// //   // Achievements
// //   List<Achievement> _achievements = [];
// //   List<StudySession> _recentSessions = [];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initAnimations();
// //     _loadUserData();
// //     _loadAchievements();
// //   }
// //
// //   void _initAnimations() {
// //     _slideController = AnimationController(
// //       duration: const Duration(milliseconds: 600),
// //       vsync: this,
// //     );
// //
// //     _rotationController = AnimationController(
// //       duration: const Duration(seconds: 10),
// //       vsync: this,
// //     );
// //
// //     _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
// //       CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
// //     );
// //
// //     _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
// //       CurvedAnimation(parent: _rotationController, curve: Curves.linear),
// //     );
// //
// //     _slideController.forward();
// //     _rotationController.repeat();
// //   }
// //
// //   Future<void> _loadUserData() async {
// //     final user = FirebaseAuth.instance.currentUser;
// //     if (user != null) {
// //       try {
// //         final userData = await FirebaseFirestore.instance
// //             .collection('users')
// //             .doc(user.uid)
// //             .get();
// //
// //         if (userData.exists && mounted) {
// //           final data = userData.data()!;
// //           setState(() {
// //             _userName = data['name'] ?? "Student";
// //             _userEmail = data['email'] ?? "";
// //             _userLevel = data['jlptLevel'] ?? "N5";
// //             _studyStreak = data['studyStreak'] ?? 0;
// //             _totalXP = data['totalXP'] ?? 0;
// //             _kanjiLearned = data['totalKanjiLearned'] ?? 0;
// //             _storiesRead = data['storiesRead'] ?? 0;
// //             _quizzesCompleted = data['quizzesCompleted'] ?? 0;
// //             _joinDate = (data['createdAt'] as Timestamp?)?.toDate();
// //             _isLoading = false;
// //           });
// //         }
// //       } catch (e) {
// //         print('Error loading user data: $e');
// //         if (mounted) {
// //           setState(() {
// //             _isLoading = false;
// //           });
// //         }
// //       }
// //     }
// //   }
// //
// //   void _loadAchievements() {
// //     _achievements = [
// //       Achievement(
// //         id: 'first_kanji',
// //         title: 'First Kanji',
// //         description: 'Learned your first Kanji character',
// //         icon: '🈶',
// //         isUnlocked: _kanjiLearned > 0,
// //         color: const Color(0xFF10B981),
// //       ),
// //       Achievement(
// //         id: 'week_streak',
// //         title: 'Week Warrior',
// //         description: 'Study for 7 days in a row',
// //         icon: '🔥',
// //         isUnlocked: _studyStreak >= 7,
// //         color: const Color(0xFFFF6B35),
// //       ),
// //       Achievement(
// //         id: 'story_reader',
// //         title: 'Story Reader',
// //         description: 'Read 5 Japanese stories',
// //         icon: '📚',
// //         isUnlocked: _storiesRead >= 5,
// //         color: const Color(0xFF06B6D4),
// //       ),
// //       Achievement(
// //         id: 'quiz_master',
// //         title: 'Quiz Master',
// //         description: 'Complete 10 grammar quizzes',
// //         icon: '🧠',
// //         isUnlocked: _quizzesCompleted >= 10,
// //         color: const Color(0xFF8B5CF6),
// //       ),
// //       Achievement(
// //         id: 'xp_collector',
// //         title: 'XP Collector',
// //         description: 'Earn 1000 experience points',
// //         icon: '⭐',
// //         isUnlocked: _totalXP >= 1000,
// //         color: const Color(0xFFF59E0B),
// //       ),
// //       Achievement(
// //         id: 'kanji_master',
// //         title: 'Kanji Master',
// //         description: 'Learn 100 Kanji characters',
// //         icon: '🎓',
// //         isUnlocked: _kanjiLearned >= 100,
// //         color: const Color(0xFFEC4899),
// //       ),
// //     ];
// //
// //     _recentSessions = [
// //       StudySession(
// //         date: DateTime.now().subtract(const Duration(hours: 2)),
// //         activity: 'Kanji Practice',
// //         xpEarned: 50,
// //         duration: 15,
// //       ),
// //       StudySession(
// //         date: DateTime.now().subtract(const Duration(days: 1)),
// //         activity: 'Grammar Quiz',
// //         xpEarned: 30,
// //         duration: 10,
// //       ),
// //       StudySession(
// //         date: DateTime.now().subtract(const Duration(days: 2)),
// //         activity: 'Story Reading',
// //         xpEarned: 40,
// //         duration: 20,
// //       ),
// //     ];
// //   }
// //
// //   @override
// //   void dispose() {
// //     _slideController.dispose();
// //     _rotationController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final size = MediaQuery.of(context).size;
// //     final isSmallScreen = size.width < 360;
// //
// //     return Scaffold(
// //       backgroundColor: const Color(0xFF0D1117),
// //       body: Container(
// //         width: size.width,
// //         height: size.height,
// //         decoration: const BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topLeft,
// //             end: Alignment.bottomRight,
// //             colors: [
// //               Color(0xFF0D1117),
// //               Color(0xFF1C2128),
// //               Color(0xFF2D1B69),
// //               Color(0xFF8B5CF6),
// //             ],
// //           ),
// //         ),
// //         child: SafeArea(
// //           child: Column(
// //             children: [
// //               // Header
// //               _buildHeader(size, isSmallScreen),
// //
// //               // Content
// //               Expanded(
// //                 child: _isLoading
// //                     ? _buildLoadingState(size)
// //                     : _buildProfileContent(size, isSmallScreen),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildHeader(Size size, bool isSmallScreen) {
// //     return Container(
// //       height: size.height * 0.12,
// //       padding: EdgeInsets.symmetric(
// //         horizontal: size.width * 0.04,
// //         vertical: size.height * 0.01,
// //       ),
// //       child: SlideTransition(
// //         position: Tween<Offset>(
// //           begin: const Offset(0, -1),
// //           end: Offset.zero,
// //         ).animate(_slideAnimation),
// //         child: Row(
// //           children: [
// //             // Back Button
// //             GestureDetector(
// //               onTap: () => Navigator.of(context).pop(),
// //               child: Container(
// //                 width: size.width * 0.1,
// //                 height: size.width * 0.1,
// //                 decoration: BoxDecoration(
// //                   color: Colors.white.withOpacity(0.1),
// //                   borderRadius: BorderRadius.circular(8),
// //                   border: Border.all(
// //                     color: Colors.white.withOpacity(0.2),
// //                     width: 1,
// //                   ),
// //                 ),
// //                 child: Icon(
// //                   Icons.arrow_back_ios_new,
// //                   color: Colors.white,
// //                   size: size.width * 0.04,
// //                 ),
// //               ),
// //             ),
// //
// //             SizedBox(width: size.width * 0.03),
// //
// //             // Title
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   FittedBox(
// //                     fit: BoxFit.scaleDown,
// //                     child: Text(
// //                       'Profile',
// //                       style: GoogleFonts.poppins(
// //                         fontSize: size.width * 0.055,
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.white,
// //                       ),
// //                     ),
// //                   ),
// //                   FittedBox(
// //                     fit: BoxFit.scaleDown,
// //                     child: Text(
// //                       'Your learning journey',
// //                       style: GoogleFonts.poppins(
// //                         fontSize: size.width * 0.028,
// //                         color: Colors.white.withOpacity(0.7),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //
// //             // Settings Button
// //             GestureDetector(
// //               onTap: _openSettings,
// //               child: Container(
// //                 width: size.width * 0.1,
// //                 height: size.width * 0.1,
// //                 decoration: BoxDecoration(
// //                   color: Colors.white.withOpacity(0.1),
// //                   borderRadius: BorderRadius.circular(8),
// //                   border: Border.all(
// //                     color: Colors.white.withOpacity(0.2),
// //                     width: 1,
// //                   ),
// //                 ),
// //                 child: Icon(
// //                   Icons.settings,
// //                   color: Colors.white,
// //                   size: size.width * 0.04,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildLoadingState(Size size) {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           SizedBox(
// //             width: size.width * 0.15,
// //             height: size.width * 0.15,
// //             child: CircularProgressIndicator(
// //               valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
// //               strokeWidth: 4,
// //             ),
// //           ),
// //           SizedBox(height: size.height * 0.02),
// //           Text(
// //             'Loading your profile...',
// //             style: GoogleFonts.poppins(
// //               fontSize: size.width * 0.04,
// //               color: Colors.white,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildProfileContent(Size size, bool isSmallScreen) {
// //     return SingleChildScrollView(
// //       physics: const BouncingScrollPhysics(),
// //       padding: EdgeInsets.all(size.width * 0.04),
// //       child: Column(
// //         children: [
// //           // Profile Header
// //           _buildProfileHeader(size, isSmallScreen),
// //
// //           SizedBox(height: size.height * 0.03),
// //
// //           // Stats Grid
// //           _buildStatsGrid(size, isSmallScreen),
// //
// //           SizedBox(height: size.height * 0.03),
// //
// //           // Achievements
// //           _buildAchievements(size, isSmallScreen),
// //
// //           SizedBox(height: size.height * 0.03),
// //
// //           // Recent Activity
// //           _buildRecentActivity(size, isSmallScreen),
// //
// //           SizedBox(height: size.height * 0.03),
// //
// //           // Action Buttons
// //           _buildActionButtons(size, isSmallScreen),
// //
// //           SizedBox(height: size.height * 0.02),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildProfileHeader(Size size, bool isSmallScreen) {
// //     return Container(
// //       width: double.infinity,
// //       padding: EdgeInsets.all(size.width * 0.05),
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           colors: [
// //             const Color(0xFF8B5CF6).withOpacity(0.1),
// //             const Color(0xFFEC4899).withOpacity(0.1),
// //           ],
// //         ),
// //         borderRadius: BorderRadius.circular(20),
// //         border: Border.all(
// //           color: const Color(0xFF8B5CF6).withOpacity(0.3),
// //           width: 1,
// //         ),
// //       ),
// //       child: Column(
// //         children: [
// //           // Profile Avatar
// //           Stack(
// //             alignment: Alignment.center,
// //             children: [
// //               // Rotating Ring
// //               AnimatedBuilder(
// //                 animation: _rotationAnimation,
// //                 builder: (context, child) {
// //                   return Transform.rotate(
// //                     angle: _rotationAnimation.value,
// //                     child: Container(
// //                       width: size.width * 0.25,
// //                       height: size.width * 0.25,
// //                       decoration: BoxDecoration(
// //                         shape: BoxShape.circle,
// //                         border: Border.all(
// //                           color: const Color(0xFF8B5CF6).withOpacity(0.3),
// //                           width: 2,
// //                         ),
// //                       ),
// //                     ),
// //                   );
// //                 },
// //               ),
// //
// //               // Avatar
// //               Container(
// //                 width: size.width * 0.2,
// //                 height: size.width * 0.2,
// //                 decoration: BoxDecoration(
// //                   gradient: const LinearGradient(
// //                     colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
// //                   ),
// //                   shape: BoxShape.circle,
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: const Color(0xFF8B5CF6).withOpacity(0.3),
// //                       blurRadius: 15,
// //                       offset: const Offset(0, 5),
// //                     ),
// //                   ],
// //                 ),
// //                 child: Center(
// //                   child: Text(
// //                     _userName.isNotEmpty ? _userName[0].toUpperCase() : 'S',
// //                     style: GoogleFonts.poppins(
// //                       fontSize: size.width * 0.08,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //
// //           SizedBox(height: size.height * 0.02),
// //
// //           // User Info
// //           FittedBox(
// //             fit: BoxFit.scaleDown,
// //             child: Text(
// //               _userName,
// //               style: GoogleFonts.poppins(
// //                 fontSize: size.width * 0.06,
// //                 fontWeight: FontWeight.bold,
// //                 color: Colors.white,
// //               ),
// //             ),
// //           ),
// //
// //           SizedBox(height: size.height * 0.005),
// //
// //           FittedBox(
// //             fit: BoxFit.scaleDown,
// //             child: Text(
// //               _userEmail,
// //               style: GoogleFonts.poppins(
// //                 fontSize: size.width * 0.032,
// //                 color: Colors.white.withOpacity(0.7),
// //               ),
// //             ),
// //           ),
// //
// //           SizedBox(height: size.height * 0.015),
// //
// //           // Level Badge
// //           Container(
// //             padding: EdgeInsets.symmetric(
// //               horizontal: size.width * 0.04,
// //               vertical: size.height * 0.008,
// //             ),
// //             decoration: BoxDecoration(
// //               gradient: const LinearGradient(
// //                 colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
// //               ),
// //               borderRadius: BorderRadius.circular(15),
// //             ),
// //             child: Row(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Icon(
// //                   Icons.school,
// //                   color: Colors.white,
// //                   size: size.width * 0.04,
// //                 ),
// //                 SizedBox(width: size.width * 0.01),
// //                 Text(
// //                   'JLPT $_userLevel',
// //                   style: GoogleFonts.poppins(
// //                     fontSize: size.width * 0.03,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.white,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //
// //           if (_joinDate != null) ...[
// //             SizedBox(height: size.height * 0.01),
// //             Text(
// //               'Member since ${_formatDate(_joinDate!)}',
// //               style: GoogleFonts.poppins(
// //                 fontSize: size.width * 0.025,
// //                 color: Colors.white.withOpacity(0.6),
// //               ),
// //             ),
// //           ],
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildStatsGrid(Size size, bool isSmallScreen) {
// //     final stats = [
// //       {'label': 'Study Streak', 'value': '$_studyStreak', 'unit': 'days', 'icon': '🔥', 'color': const Color(0xFFFF6B35)},
// //       {'label': 'Total XP', 'value': '$_totalXP', 'unit': 'points', 'icon': '⭐', 'color': const Color(0xFFF59E0B)},
// //       {'label': 'Kanji Learned', 'value': '$_kanjiLearned', 'unit': 'chars', 'icon': '🈶', 'color': const Color(0xFF10B981)},
// //       {'label': 'Stories Read', 'value': '$_storiesRead', 'unit': 'stories', 'icon': '📚', 'color': const Color(0xFF06B6D4)},
// //     ];
// //
// //     return GridView.builder(
// //       shrinkWrap: true,
// //       physics: const NeverScrollableScrollPhysics(),
// //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //         crossAxisCount: 2,
// //         childAspectRatio: isSmallScreen ? 1.3 : 1.4,
// //         crossAxisSpacing: size.width * 0.03,
// //         mainAxisSpacing: size.width * 0.03,
// //       ),
// //       itemCount: stats.length,
// //       itemBuilder: (context, index) {
// //         final stat = stats[index];
// //         return Container(
// //           padding: EdgeInsets.all(size.width * 0.04),
// //           decoration: BoxDecoration(
// //             color: (stat['color'] as Color).withOpacity(0.1),
// //             borderRadius: BorderRadius.circular(16),
// //             border: Border.all(
// //               color: (stat['color'] as Color).withOpacity(0.3),
// //               width: 1,
// //             ),
// //           ),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Text(
// //                 stat['icon'] as String,
// //                 style: TextStyle(fontSize: size.width * 0.08),
// //               ),
// //               SizedBox(height: size.height * 0.01),
// //               FittedBox(
// //                 fit: BoxFit.scaleDown,
// //                 child: Text(
// //                   stat['value'] as String,
// //                   style: GoogleFonts.poppins(
// //                     fontSize: size.width * 0.05,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.white,
// //                   ),
// //                 ),
// //               ),
// //               FittedBox(
// //                 fit: BoxFit.scaleDown,
// //                 child: Text(
// //                   stat['label'] as String,
// //                   style: GoogleFonts.poppins(
// //                     fontSize: size.width * 0.028,
// //                     color: Colors.white.withOpacity(0.8),
// //                   ),
// //                   textAlign: TextAlign.center,
// //                 ),
// //               ),
// //               FittedBox(
// //                 fit: BoxFit.scaleDown,
// //                 child: Text(
// //                   stat['unit'] as String,
// //                   style: GoogleFonts.poppins(
// //                     fontSize: size.width * 0.024,
// //                     color: Colors.white.withOpacity(0.6),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   Widget _buildAchievements(Size size, bool isSmallScreen) {
// //     final unlockedAchievements = _achievements.where((a) => a.isUnlocked).toList();
// //     final lockedAchievements = _achievements.where((a) => !a.isUnlocked).toList();
// //
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Row(
// //           children: [
// //             Text(
// //               'Achievements',
// //               style: GoogleFonts.poppins(
// //                 fontSize: size.width * 0.045,
// //                 fontWeight: FontWeight.bold,
// //                 color: Colors.white,
// //               ),
// //             ),
// //             const Spacer(),
// //             Container(
// //               padding: EdgeInsets.symmetric(
// //                 horizontal: size.width * 0.02,
// //                 vertical: size.height * 0.005,
// //               ),
// //               decoration: BoxDecoration(
// //                 color: const Color(0xFF10B981).withOpacity(0.2),
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //               child: Text(
// //                 '${unlockedAchievements.length}/${_achievements.length}',
// //                 style: GoogleFonts.poppins(
// //                   fontSize: size.width * 0.025,
// //                   fontWeight: FontWeight.bold,
// //                   color: const Color(0xFF10B981),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //
// //         SizedBox(height: size.height * 0.015),
// //
// //         // Unlocked Achievements
// //         if (unlockedAchievements.isNotEmpty) ...[
// //           SizedBox(
// //             height: size.height * 0.12,
// //             child: ListView.builder(
// //               scrollDirection: Axis.horizontal,
// //               itemCount: unlockedAchievements.length,
// //               itemBuilder: (context, index) {
// //                 final achievement = unlockedAchievements[index];
// //                 return Container(
// //                   width: size.width * 0.25,
// //                   margin: EdgeInsets.only(right: size.width * 0.03),
// //                   decoration: BoxDecoration(
// //                     color: achievement.color.withOpacity(0.1),
// //                     borderRadius: BorderRadius.circular(16),
// //                     border: Border.all(
// //                       color: achievement.color.withOpacity(0.3),
// //                       width: 1,
// //                     ),
// //                   ),
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Text(
// //                         achievement.icon,
// //                         style: TextStyle(fontSize: size.width * 0.08),
// //                       ),
// //                       SizedBox(height: size.height * 0.005),
// //                       FittedBox(
// //                         fit: BoxFit.scaleDown,
// //                         child: Text(
// //                           achievement.title,
// //                           style: GoogleFonts.poppins(
// //                             fontSize: size.width * 0.025,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.white,
// //                           ),
// //                           textAlign: TextAlign.center,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //         ],
// //
// //         // Locked Achievements (first 3)
// //         if (lockedAchievements.isNotEmpty) ...[
// //           SizedBox(height: size.height * 0.015),
// //           Text(
// //             'Coming Next',
// //             style: GoogleFonts.poppins(
// //               fontSize: size.width * 0.035,
// //               fontWeight: FontWeight.w600,
// //               color: Colors.white.withOpacity(0.8),
// //             ),
// //           ),
// //           SizedBox(height: size.height * 0.01),
// //
// //           SizedBox(
// //             height: size.height * 0.1,
// //             child: ListView.builder(
// //               scrollDirection: Axis.horizontal,
// //               itemCount: math.min(3, lockedAchievements.length),
// //               itemBuilder: (context, index) {
// //                 final achievement = lockedAchievements[index];
// //                 return Container(
// //                   width: size.width * 0.22,
// //                   margin: EdgeInsets.only(right: size.width * 0.03),
// //                   decoration: BoxDecoration(
// //                     color: Colors.white.withOpacity(0.05),
// //                     borderRadius: BorderRadius.circular(16),
// //                     border: Border.all(
// //                       color: Colors.white.withOpacity(0.2),
// //                       width: 1,
// //                     ),
// //                   ),
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Opacity(
// //                         opacity: 0.5,
// //                         child: Text(
// //                           achievement.icon,
// //                           style: TextStyle(fontSize: size.width * 0.06),
// //                         ),
// //                       ),
// //                       SizedBox(height: size.height * 0.005),
// //                       FittedBox(
// //                         fit: BoxFit.scaleDown,
// //                         child: Text(
// //                           achievement.title,
// //                           style: GoogleFonts.poppins(
// //                             fontSize: size.width * 0.022,
// //                             color: Colors.white.withOpacity(0.6),
// //                           ),
// //                           textAlign: TextAlign.center,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //         ],
// //       ],
// //     );
// //   }
// //
// //   Widget _buildRecentActivity(Size size, bool isSmallScreen) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'Recent Activity',
// //           style: GoogleFonts.poppins(
// //             fontSize: size.width * 0.045,
// //             fontWeight: FontWeight.bold,
// //             color: Colors.white,
// //           ),
// //         ),
// //
// //         SizedBox(height: size.height * 0.015),
// //
// //         Container(
// //           width: double.infinity,
// //           constraints: BoxConstraints(
// //             maxHeight: size.height * 0.25,
// //           ),
// //           decoration: BoxDecoration(
// //             color: Colors.white.withOpacity(0.05),
// //             borderRadius: BorderRadius.circular(16),
// //             border: Border.all(
// //               color: Colors.white.withOpacity(0.1),
// //               width: 1,
// //             ),
// //           ),
// //           child: ListView.builder(
// //             shrinkWrap: true,
// //             physics: const BouncingScrollPhysics(),
// //             padding: EdgeInsets.all(size.width * 0.04),
// //             itemCount: _recentSessions.length,
// //             itemBuilder: (context, index) {
// //               final session = _recentSessions[index];
// //               return Container(
// //                 margin: EdgeInsets.only(bottom: size.height * 0.015),
// //                 padding: EdgeInsets.all(size.width * 0.03),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white.withOpacity(0.05),
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     Container(
// //                       width: size.width * 0.1,
// //                       height: size.width * 0.1,
// //                       decoration: BoxDecoration(
// //                         color: _getActivityColor(session.activity).withOpacity(0.2),
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       child: Center(
// //                         child: Text(
// //                           _getActivityIcon(session.activity),
// //                           style: TextStyle(fontSize: size.width * 0.04),
// //                         ),
// //                       ),
// //                     ),
// //
// //                     SizedBox(width: size.width * 0.03),
// //
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             session.activity,
// //                             style: GoogleFonts.poppins(
// //                               fontSize: size.width * 0.032,
// //                               fontWeight: FontWeight.w600,
// //                               color: Colors.white,
// //                             ),
// //                           ),
// //                           Text(
// //                             _formatActivityTime(session.date),
// //                             style: GoogleFonts.poppins(
// //                               fontSize: size.width * 0.025,
// //                               color: Colors.white.withOpacity(0.6),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //
// //                     Column(
// //                       crossAxisAlignment: CrossAxisAlignment.end,
// //                       children: [
// //                         Text(
// //                           '+${session.xpEarned} XP',
// //                           style: GoogleFonts.poppins(
// //                             fontSize: size.width * 0.03,
// //                             fontWeight: FontWeight.bold,
// //                             color: const Color(0xFF10B981),
// //                           ),
// //                         ),
// //                         Text(
// //                           '${session.duration}m',
// //                           style: GoogleFonts.poppins(
// //                             fontSize: size.width * 0.025,
// //                             color: Colors.white.withOpacity(0.6),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               );
// //             },
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildActionButtons(Size size, bool isSmallScreen) {
// //     return Column(
// //       children: [
// //         Row(
// //           children: [
// //             Expanded(
// //               child: _buildActionButton(
// //                 'Edit Profile',
// //                 Icons.edit,
// //                 const Color(0xFF8B5CF6),
// //                 _editProfile,
// //                 size,
// //               ),
// //             ),
// //             SizedBox(width: size.width * 0.03),
// //             Expanded(
// //               child: _buildActionButton(
// //                 'Share Progress',
// //                 Icons.share,
// //                 const Color(0xFF10B981),
// //                 _shareProgress,
// //                 size,
// //               ),
// //             ),
// //           ],
// //         ),
// //
// //         SizedBox(height: size.height * 0.015),
// //
// //         Row(
// //           children: [
// //             Expanded(
// //               child: _buildActionButton(
// //                 'Study Reminder',
// //                 Icons.notifications,
// //                 const Color(0xFF06B6D4),
// //                 _setReminder,
// //                 size,
// //               ),
// //             ),
// //             SizedBox(width: size.width * 0.03),
// //             Expanded(
// //               child: _buildActionButton(
// //                 'Logout',
// //                 Icons.logout,
// //                 const Color(0xFFEC4899),
// //                 _logout,
// //                 size,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildActionButton(
// //       String text,
// //       IconData icon,
// //       Color color,
// //       VoidCallback onTap,
// //       Size size,
// //       ) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
// //         decoration: BoxDecoration(
// //           color: color.withOpacity(0.1),
// //           borderRadius: BorderRadius.circular(12),
// //           border: Border.all(
// //             color: color.withOpacity(0.3),
// //             width: 1,
// //           ),
// //         ),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(
// //               icon,
// //               color: color,
// //               size: size.width * 0.04,
// //             ),
// //             SizedBox(width: size.width * 0.02),
// //             FittedBox(
// //               fit: BoxFit.scaleDown,
// //               child: Text(
// //                 text,
// //                 style: GoogleFonts.poppins(
// //                   fontSize: size.width * 0.032,
// //                   fontWeight: FontWeight.w600,
// //                   color: Colors.white,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // Helper Methods
// //   String _formatDate(DateTime date) {
// //     const months = [
// //       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
// //       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
// //     ];
// //     return '${months[date.month - 1]} ${date.year}';
// //   }
// //
// //   String _formatActivityTime(DateTime date) {
// //     final now = DateTime.now();
// //     final difference = now.difference(date);
// //
// //     if (difference.inDays > 0) {
// //       return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
// //     } else if (difference.inHours > 0) {
// //       return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
// //     } else {
// //       return '${difference.inMinutes} min ago';
// //     }
// //   }
// //
// //   Color _getActivityColor(String activity) {
// //     switch (activity.toLowerCase()) {
// //       case 'kanji practice': return const Color(0xFF10B981);
// //       case 'grammar quiz': return const Color(0xFF8B5CF6);
// //       case 'story reading': return const Color(0xFF06B6D4);
// //       default: return const Color(0xFFF59E0B);
// //     }
// //   }
// //
// //   String _getActivityIcon(String activity) {
// //     switch (activity.toLowerCase()) {
// //       case 'kanji practice': return '🈶';
// //       case 'grammar quiz': return '📚';
// //       case 'story reading': return '📖';
// //       default: return '📝';
// //     }
// //   }
// //
// //   // Action Methods
// //   void _openSettings() {
// //     showModalBottomSheet(
// //       context: context,
// //       backgroundColor: const Color(0xFF1C2128),
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       builder: (context) => _buildSettingsSheet(),
// //     );
// //   }
// //
// //   Widget _buildSettingsSheet() {
// //     final size = MediaQuery.of(context).size;
// //
// //     return Container(
// //       padding: EdgeInsets.all(size.width * 0.04),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Container(
// //             width: size.width * 0.1,
// //             height: 4,
// //             decoration: BoxDecoration(
// //               color: Colors.white.withOpacity(0.3),
// //               borderRadius: BorderRadius.circular(2),
// //             ),
// //           ),
// //
// //           SizedBox(height: size.height * 0.02),
// //
// //           Text(
// //             'Settings',
// //             style: GoogleFonts.poppins(
// //               fontSize: size.width * 0.05,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.white,
// //             ),
// //           ),
// //
// //           SizedBox(height: size.height * 0.03),
// //
// //           ...[
// //             {'title': 'Notifications', 'icon': Icons.notifications, 'onTap': () {}},
// //             {'title': 'Language', 'icon': Icons.language, 'onTap': () {}},
// //             {'title': 'Privacy', 'icon': Icons.privacy_tip, 'onTap': () {}},
// //             {'title': 'Help & Support', 'icon': Icons.help, 'onTap': () {}},
// //             {'title': 'About', 'icon': Icons.info, 'onTap': () {}},
// //           ].map((item) => ListTile(
// //             leading: Icon(
// //               item['icon'] as IconData,
// //               color: const Color(0xFF8B5CF6),
// //             ),
// //             title: Text(
// //               item['title'] as String,
// //               style: GoogleFonts.poppins(color: Colors.white),
// //             ),
// //             trailing: const Icon(
// //               Icons.arrow_forward_ios,
// //               color: Colors.white54,
// //               size: 16,
// //             ),
// //             onTap: item['onTap'] as VoidCallback,
// //           )),
// //
// //           SizedBox(height: size.height * 0.02),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   void _editProfile() {
// //     _showMessage('Edit Profile coming soon! ✏️');
// //   }
// //
// //   void _shareProgress() {
// //     _showMessage('Share Progress coming soon! 📤');
// //   }
// //
// //   void _setReminder() {
// //     _showMessage('Study Reminder set! 🔔');
// //   }
// //
// //   Future<void> _logout() async {
// //     try {
// //       await FirebaseAuth.instance.signOut();
// //       if (mounted) {
// //         Navigator.of(context).pushNamedAndRemoveUntil(
// //           '/welcome',
// //               (route) => false,
// //         );
// //       }
// //     } catch (e) {
// //       _showMessage('Logout failed. Please try again.');
// //     }
// //   }
// //
// //   void _showMessage(String message) {
// //     if (!mounted) return;
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: const Color(0xFF8B5CF6),
// //         duration: const Duration(seconds: 2),
// //       ),
// //     );
// //   }
// // }
// //
// // // Data Models
// // class Achievement {
// //   final String id;
// //   final String title;
// //   final String description;
// //   final String icon;
// //   final bool isUnlocked;
// //   final Color color;
// //
// //   Achievement({
// //     required this.id,
// //     required this.title,
// //     required this.description,
// //     required this.icon,
// //     required this.isUnlocked,
// //     required this.color,
// //   });
// // }
// //
// // class StudySession {
// //   final DateTime date;
// //   final String activity;
// //   final int xpEarned;
// //   final int duration;
// //
// //   StudySession({
// //     required this.date,
// //     required this.activity,
// //     required this.xpEarned,
// //     required this.duration,
// //   });
// // }