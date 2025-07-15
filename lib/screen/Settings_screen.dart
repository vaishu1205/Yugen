import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // User preferences
  bool _notificationsEnabled = true;
  bool _studyReminders = true;
  bool _achievementNotifications = true;
  bool _weeklyReports = true;
  bool _soundEffects = true;
  bool _hapticFeedback = true;
  bool _darkMode = false;
  bool _offlineMode = false;

  String _selectedLanguage = 'English';
  String _difficultyLevel = 'Intermediate';
  String _studyGoal = '30 minutes';
  String _jlptLevel = 'N4';

  final List<String> _languages = ['English', 'Japanese', 'Spanish', 'French'];
  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _studyGoals = ['15 minutes', '30 minutes', '45 minutes', '1 hour', '2 hours'];
  final List<String> _jlptLevels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  bool _isLoading = true;
  StreamSubscription<DocumentSnapshot>? _userSettingsSubscription;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadUserSettings();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  void _loadUserSettings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userSettingsSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && mounted) {
          final data = snapshot.data()!;
          final settings = data['settings'] as Map<String, dynamic>? ?? {};

          setState(() {
            _notificationsEnabled = settings['notifications'] ?? true;
            _studyReminders = settings['studyReminders'] ?? true;
            _achievementNotifications = settings['achievementNotifications'] ?? true;
            _weeklyReports = settings['weeklyReports'] ?? true;
            _soundEffects = settings['soundEffects'] ?? true;
            _hapticFeedback = settings['hapticFeedback'] ?? true;
            _darkMode = settings['darkMode'] ?? false;
            _offlineMode = settings['offlineMode'] ?? false;
            _selectedLanguage = settings['language'] ?? 'English';
            _difficultyLevel = settings['difficulty'] ?? 'Intermediate';
            _studyGoal = settings['studyGoal'] ?? '30 minutes';
            _jlptLevel = data['jlptLevel'] ?? 'N4';
            _isLoading = false;
          });
        }
      });
    }
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'settings.$key': value,
          if (key == 'jlptLevel') 'jlptLevel': value,
        });
      } catch (e) {
        print('Error updating setting: $e');
        _showErrorSnackBar('Failed to update setting');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _userSettingsSubscription?.cancel();
    _fadeController.dispose();
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
              child: Column(
                children: [
                  _buildHeader(isSmallScreen),
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingState()
                        : _buildSettingsList(isSmallScreen),
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
                  'Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  'Customize your learning experience',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
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
            'Loading settings...',
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

  Widget _buildSettingsList(bool isSmallScreen) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSettingsSection(
            'Study Preferences',
            [
              _buildDropdownSetting(
                'JLPT Level',
                _jlptLevel,
                _jlptLevels,
                Icons.school,
                    (value) {
                  setState(() => _jlptLevel = value);
                  _updateSetting('jlptLevel', value);
                },
              ),
              _buildDropdownSetting(
                'Difficulty Level',
                _difficultyLevel,
                _difficulties,
                Icons.tune,
                    (value) {
                  setState(() => _difficultyLevel = value);
                  _updateSetting('difficulty', value);
                },
              ),
              _buildDropdownSetting(
                'Daily Study Goal',
                _studyGoal,
                _studyGoals,
                Icons.timer,
                    (value) {
                  setState(() => _studyGoal = value);
                  _updateSetting('studyGoal', value);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSettingsSection(
            'Notifications',
            [
              _buildSwitchSetting(
                'Push Notifications',
                'Receive notifications on your device',
                _notificationsEnabled,
                Icons.notifications,
                    (value) {
                  setState(() => _notificationsEnabled = value);
                  _updateSetting('notifications', value);
                },
              ),
              _buildSwitchSetting(
                'Study Reminders',
                'Get reminded to study daily',
                _studyReminders,
                Icons.alarm,
                    (value) {
                  setState(() => _studyReminders = value);
                  _updateSetting('studyReminders', value);
                },
              ),
              _buildSwitchSetting(
                'Achievement Notifications',
                'Get notified when you unlock achievements',
                _achievementNotifications,
                Icons.emoji_events,
                    (value) {
                  setState(() => _achievementNotifications = value);
                  _updateSetting('achievementNotifications', value);
                },
              ),
              _buildSwitchSetting(
                'Weekly Reports',
                'Receive weekly progress summaries',
                _weeklyReports,
                Icons.bar_chart,
                    (value) {
                  setState(() => _weeklyReports = value);
                  _updateSetting('weeklyReports', value);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSettingsSection(
            'App Experience',
            [
              _buildSwitchSetting(
                'Sound Effects',
                'Play sounds for interactions',
                _soundEffects,
                Icons.volume_up,
                    (value) {
                  setState(() => _soundEffects = value);
                  _updateSetting('soundEffects', value);
                },
              ),
              _buildSwitchSetting(
                'Haptic Feedback',
                'Feel vibrations for interactions',
                _hapticFeedback,
                Icons.vibration,
                    (value) {
                  setState(() => _hapticFeedback = value);
                  _updateSetting('hapticFeedback', value);
                },
              ),
              _buildDropdownSetting(
                'App Language',
                _selectedLanguage,
                _languages,
                Icons.language,
                    (value) {
                  setState(() => _selectedLanguage = value);
                  _updateSetting('language', value);
                },
              ),
              _buildSwitchSetting(
                'Offline Mode',
                'Download lessons for offline study',
                _offlineMode,
                Icons.cloud_download,
                    (value) {
                  setState(() => _offlineMode = value);
                  _updateSetting('offlineMode', value);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSettingsSection(
            'Account & Data',
            [
              _buildActionSetting(
                'Export Study Data',
                'Download your learning progress',
                Icons.download,
                _exportData,
              ),
              _buildActionSetting(
                'Reset Progress',
                'Clear all learning data (cannot be undone)',
                Icons.refresh,
                _showResetDialog,
                isDestructive: true,
              ),
              _buildActionSetting(
                'Delete Account',
                'Permanently delete your account',
                Icons.delete_forever,
                _showDeleteAccountDialog,
                isDestructive: true,
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSettingsSection(
            'About',
            [
              _buildActionSetting(
                'Privacy Policy',
                'Read our privacy policy',
                Icons.privacy_tip,
                _openPrivacyPolicy,
              ),
              _buildActionSetting(
                'Terms of Service',
                'Read our terms of service',
                Icons.article,
                _openTermsOfService,
              ),
              _buildActionSetting(
                'Help & Support',
                'Get help and contact support',
                Icons.help,
                _openSupport,
              ),
              _buildActionSetting(
                'Rate the App',
                'Leave a review on the app store',
                Icons.star,
                _rateApp,
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: children.map((child) {
              final index = children.indexOf(child);
              return Column(
                children: [
                  child,
                  if (index < children.length - 1)
                    const Divider(
                      height: 1,
                      color: Color(0xFFF3F4F6),
                      indent: 60,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchSetting(
      String title,
      String subtitle,
      bool value,
      IconData icon,
      Function(bool) onChanged,
      ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF6366F1),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: const Color(0xFF6B7280),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF6366F1),
      ),
    );
  }

  Widget _buildDropdownSetting(
      String title,
      String value,
      List<String> options,
      IconData icon,
      Function(String) onChanged,
      ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF6366F1),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F2937),
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(
              option,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF1F2937),
              ),
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  Widget _buildActionSetting(
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onTap, {
        bool isDestructive = false,
      }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (isDestructive ? const Color(0xFFEF4444) : const Color(0xFF6366F1))
              .withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF6366F1),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: const Color(0xFF6B7280),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Color(0xFF9CA3AF),
        size: 16,
      ),
      onTap: onTap,
    );
  }

  // Action methods
  void _exportData() {
    _showSuccessSnackBar('Study data export started. Check your downloads folder.');
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Progress',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        content: Text(
          'This will permanently delete all your learning progress. This action cannot be undone.',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
            onPressed: () {
              Navigator.pop(context);
              _resetProgress();
            },
            child: Text(
              'Reset',
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

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Account',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        content: Text(
          'This will permanently delete your account and all associated data. This action cannot be undone.',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: Text(
              'Delete',
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

  Future<void> _resetProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Reset user progress in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'studyStreak': 0,
          'totalXP': 0,
          'totalKanjiLearned': 0,
          'storiesRead': 0,
          'quizzesCompleted': 0,
          'lessonsCompleted': 0,
          'perfectScores': 0,
        });

        _showSuccessSnackBar('Progress reset successfully');
      } catch (e) {
        _showErrorSnackBar('Failed to reset progress');
      }
    }
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Delete user data from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();

        // Delete user account
        await user.delete();

        _showSuccessSnackBar('Account deleted successfully');

        // Navigate to login screen
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      } catch (e) {
        _showErrorSnackBar('Failed to delete account');
      }
    }
  }

  void _openPrivacyPolicy() {
    _showSuccessSnackBar('Opening privacy policy...');
  }

  void _openTermsOfService() {
    _showSuccessSnackBar('Opening terms of service...');
  }

  void _openSupport() {
    _showSuccessSnackBar('Opening help & support...');
  }

  void _rateApp() {
    _showSuccessSnackBar('Opening app store...');
  }
}