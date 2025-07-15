import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudyHistoryScreen extends StatefulWidget {
  const StudyHistoryScreen({super.key});

  @override
  State<StudyHistoryScreen> createState() => _StudyHistoryScreenState();
}

class _StudyHistoryScreenState extends State<StudyHistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _chartController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _chartAnimation;

  List<StudySession> _sessions = [];
  bool _isLoading = true;
  StreamSubscription<QuerySnapshot>? _sessionsSubscription;

  // Filter states
  String _selectedPeriod = 'Week';
  final List<String> _periodOptions = ['Week', 'Month', '3 Months', 'All Time'];

  // Chart data
  List<ChartData> _chartData = [];

  // Statistics
  int _totalStudyTime = 0;
  int _totalXPEarned = 0;
  int _averageSessionTime = 0;
  int _longestStreak = 0;
  Map<String, int> _activityStats = {};

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

    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
  }

  void _setupRealtimeListeners() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print("🔥 Setting up study history listener for user: ${user.uid}"); // Add debug

      _sessionsSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('study_sessions')
          .orderBy('date', descending: true)
          .limit(100)
          .snapshots()
          .listen((snapshot) {
        print("🔥 Received ${snapshot.docs.length} study sessions"); // Add debug

        if (mounted) {
          setState(() {
            _sessions = snapshot.docs.map((doc) {
              final data = doc.data();
              print("🔥 Session data: $data"); // Add debug to see each session

              return StudySession(
                id: doc.id,
                date: (data['date'] as Timestamp).toDate(),
                activity: data['activity'] ?? 'Study',
                xpEarned: data['xpEarned'] ?? 0,
                duration: data['duration'] ?? 0,
                score: data['score'],
                topics: List<String>.from(data['topics'] ?? []),
                difficulty: data['difficulty'] ?? 'Beginner',
              );
            }).toList();
            _isLoading = false;
          });
          _calculateStatistics();
          _generateChartData();
          _chartController.forward();
        }
      }, onError: (error) {
        print("🔥 Error loading study sessions: $error"); // Add error debug
      });
    } else {
      print("🔥 No authenticated user found!"); // Add debug
    }
  }

  void _calculateStatistics() {
    final filteredSessions = _getFilteredSessions();

    _totalStudyTime = filteredSessions.fold(0, (sum, session) => sum + session.duration);
    _totalXPEarned = filteredSessions.fold(0, (sum, session) => sum + session.xpEarned);
    _averageSessionTime = filteredSessions.isNotEmpty
        ? (_totalStudyTime / filteredSessions.length).round()
        : 0;

    // Calculate activity statistics
    _activityStats.clear();
    for (var session in filteredSessions) {
      _activityStats[session.activity] = (_activityStats[session.activity] ?? 0) + 1;
    }

    // Calculate longest streak
    _longestStreak = _calculateLongestStreak(filteredSessions);
  }

  int _calculateLongestStreak(List<StudySession> sessions) {
    if (sessions.isEmpty) return 0;

    sessions.sort((a, b) => a.date.compareTo(b.date));

    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sessions.length; i++) {
      final prevDate = sessions[i - 1].date;
      final currentDate = sessions[i].date;
      final daysDiff = currentDate.difference(prevDate).inDays;

      if (daysDiff == 1) {
        currentStreak++;
        maxStreak = math.max(maxStreak, currentStreak);
      } else {
        currentStreak = 1;
      }
    }

    return maxStreak;
  }

  void _generateChartData() {
    final filteredSessions = _getFilteredSessions();
    _chartData.clear();

    // Group sessions by date
    Map<DateTime, int> dailyXP = {};
    Map<DateTime, int> dailyTime = {};

    for (var session in filteredSessions) {
      final date = DateTime(session.date.year, session.date.month, session.date.day);
      dailyXP[date] = (dailyXP[date] ?? 0) + session.xpEarned;
      dailyTime[date] = (dailyTime[date] ?? 0) + session.duration;
    }

    // Convert to chart data
    dailyXP.forEach((date, xp) {
      _chartData.add(ChartData(
        date: date,
        xp: xp,
        studyTime: dailyTime[date] ?? 0,
      ));
    });

    // Sort by date
    _chartData.sort((a, b) => a.date.compareTo(b.date));
  }

  List<StudySession> _getFilteredSessions() {
    final now = DateTime.now();
    DateTime filterDate;

    switch (_selectedPeriod) {
      case 'Week':
        filterDate = now.subtract(const Duration(days: 7));
        break;
      case 'Month':
        filterDate = now.subtract(const Duration(days: 30));
        break;
      case '3 Months':
        filterDate = now.subtract(const Duration(days: 90));
        break;
      default:
        return _sessions;
    }

    return _sessions.where((session) => session.date.isAfter(filterDate)).toList();
  }

  @override
  void dispose() {
    _sessionsSubscription?.cancel();
    _fadeController.dispose();
    _chartController.dispose();
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
            final isMediumScreen = constraints.maxWidth < 768;
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildHeader(isSmallScreen),
                  _buildPeriodSelector(isSmallScreen),
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingState()
                        : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildStatsOverview(isSmallScreen, isMediumScreen),
                          _buildChart(isSmallScreen, isMediumScreen),
                          _buildActivityBreakdown(isSmallScreen, isMediumScreen),
                          _buildSessionsList(isSmallScreen),
                          const SizedBox(height: 24),
                        ],
                      ),
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
                  'Study History',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  'Track your learning progress',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 12 : 14,
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
              icon: const Icon(
                Icons.refresh,
                color: Color(0xFF6366F1),
                size: 20,
              ),
              onPressed: () {
                _calculateStatistics();
                _generateChartData();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _periodOptions.map((period) {
            final isSelected = _selectedPeriod == period;
            return Container(
              margin: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPeriod = period;
                  });
                  _calculateStatistics();
                  _generateChartData();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: 12
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
                    period,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 13 : 14,
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
            'Loading study history...',
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

  Widget _buildStatsOverview(bool isSmallScreen, bool isMediumScreen) {
    final stats = [
      {
        'title': 'Total Time',
        'value': '${(_totalStudyTime / 60).toStringAsFixed(1)}h',
        'icon': Icons.access_time,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Total XP',
        'value': '$_totalXPEarned',
        'icon': Icons.star,
        'color': const Color(0xFFFFC107),
      },
      {
        'title': 'Avg Session',
        'value': '${_averageSessionTime}m',
        'icon': Icons.timer,
        'color': const Color(0xFF6366F1),
      },
      {
        'title': 'Best Streak',
        'value': '$_longestStreak days',
        'icon': Icons.local_fire_department,
        'color': const Color(0xFFFF5722),
      },
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isSmallScreen ? 2 : (isMediumScreen ? 2 : 4),
          childAspectRatio: isSmallScreen ? 1.2 : 1.4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (stat['color'] as Color).withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: isSmallScreen ? 32 : 40,
                  height: isSmallScreen ? 32 : 40,
                  decoration: BoxDecoration(
                    color: (stat['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    stat['icon'] as IconData,
                    color: stat['color'] as Color,
                    size: isSmallScreen ? 16 : 20,
                  ),
                ),
                const Spacer(),
                Text(
                  stat['value'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  stat['title'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart(bool isSmallScreen, bool isMediumScreen) {
    if (_chartData.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(40),
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
            Icon(
              Icons.bar_chart,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No data for selected period',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
            Text(
              'Start studying to see your progress chart',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Progress',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: isSmallScreen ? 150 : 200,
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ChartPainter(_chartData, _chartAnimation.value),
                  size: Size.infinite,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBreakdown(bool isSmallScreen, bool isMediumScreen) {
    if (_activityStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Breakdown',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          ..._activityStats.entries.map((entry) {
            final total = _activityStats.values.fold(0, (sum, count) => sum + count);
            final percentage = (entry.value / total * 100).round();

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: isSmallScreen ? 32 : 40,
                    height: isSmallScreen ? 32 : 40,
                    decoration: BoxDecoration(
                      color: _getActivityColor(entry.key).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _getActivityIcon(entry.key),
                        style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              '$percentage%',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.bold,
                                color: _getActivityColor(entry.key),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: entry.value / total,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(_getActivityColor(entry.key)),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSessionsList(bool isSmallScreen) {
    final filteredSessions = _getFilteredSessions();
    final displaySessions = filteredSessions.take(10).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Sessions',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  '${displaySessions.length} of ${filteredSessions.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          if (displaySessions.isEmpty)
            Padding(
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
                    'No study sessions yet',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    'Start studying to see your sessions here',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: displaySessions.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: Color(0xFFF3F4F6),
                indent: 70,
              ),
              itemBuilder: (context, index) {
                final session = displaySessions[index];
                return _buildSessionItem(session, isSmallScreen);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSessionItem(StudySession session, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 40 : 48,
            height: isSmallScreen ? 40 : 48,
            decoration: BoxDecoration(
              color: _getActivityColor(session.activity).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _getActivityIcon(session.activity),
                style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
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
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${session.duration}m',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const Text(' • '),
                    Text(
                      _formatTime(session.date),
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
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
                    fontSize: isSmallScreen ? 11 : 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
              if (session.score != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${session.score}%',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: _getScoreColor(session.score!),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Add this method to StudyHistoryScreen for testing
  Future<void> _addTestSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('study_sessions')
            .add({
          'activity': 'Test Quiz',
          'date': FieldValue.serverTimestamp(),
          'duration': 5,
          'xpEarned': 100,
          'score': 85,
          'topics': ['Grammar'],
          'difficulty': 'N5',
        });
        print("🔥 Test session added successfully!");
      } catch (e) {
        print("🔥 Error adding test session: $e");
      }
    }
  }
  Color _getActivityColor(String activity) {
    switch (activity.toLowerCase()) {
      case 'kanji practice':
        return const Color(0xFF4CAF50);
      case 'grammar quiz':
        return const Color(0xFF9C27B0);
      case 'story reading':
        return const Color(0xFF2196F3);
      case 'vocabulary':
        return const Color(0xFFFFC107);
      case 'listening':
        return const Color(0xFFFF5722);
      default:
        return const Color(0xFF6366F1);
    }
  }

  String _getActivityIcon(String activity) {
    switch (activity.toLowerCase()) {
      case 'kanji practice':
        return '🈶';
      case 'grammar quiz':
        return '📚';
      case 'story reading':
        return '📖';
      case 'vocabulary':
        return '📝';
      case 'listening':
        return '🎧';
      default:
        return '📚';
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return const Color(0xFF10B981);
    if (score >= 70) return const Color(0xFFFFC107);
    return const Color(0xFFEF4444);
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class StudySession {
  final String id;
  final DateTime date;
  final String activity;
  final int xpEarned;
  final int duration;
  final int? score;
  final List<String> topics;
  final String difficulty;

  StudySession({
    required this.id,
    required this.date,
    required this.activity,
    required this.xpEarned,
    required this.duration,
    this.score,
    required this.topics,
    required this.difficulty,
  });
}

class ChartData {
  final DateTime date;
  final int xp;
  final int studyTime;

  ChartData({
    required this.date,
    required this.xp,
    required this.studyTime,
  });
}

class ChartPainter extends CustomPainter {
  final List<ChartData> data;
  final double animationValue;

  ChartPainter(this.data, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.fill;

    final maxXP = data.map((d) => d.xp).reduce((a, b) => a > b ? a : b);
    if (maxXP == 0) return;

    final path = Path();
    final fillPath = Path();
    final points = <Offset>[];

    // Calculate points
    for (int i = 0; i < data.length; i++) {
      final x = (size.width / (data.length - 1)) * i;
      final y = size.height - (data[i].xp / maxXP * size.height * 0.8);
      points.add(Offset(x, y));
    }

    // Animate the line drawing
    final animatedPointCount = (points.length * animationValue).round();
    if (animatedPointCount < 2) return;

    // Draw line
    path.moveTo(points[0].dx, points[0].dy);
    fillPath.moveTo(points[0].dx, size.height);
    fillPath.lineTo(points[0].dx, points[0].dy);

    for (int i = 1; i < animatedPointCount; i++) {
      path.lineTo(points[i].dx, points[i].dy);
      fillPath.lineTo(points[i].dx, points[i].dy);
    }

    // Complete fill path
    if (animatedPointCount > 0) {
      fillPath.lineTo(points[animatedPointCount - 1].dx, size.height);
      fillPath.close();
    }

    // Draw fill area
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    canvas.drawPath(path, paint);

    // Draw points
    for (int i = 0; i < animatedPointCount; i++) {
      canvas.drawCircle(points[i], 4, pointPaint);
      canvas.drawCircle(points[i], 4, Paint()..color = Colors.white..style = PaintingStyle.fill);
      canvas.drawCircle(points[i], 2, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}