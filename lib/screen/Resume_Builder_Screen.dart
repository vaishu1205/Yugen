import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // Form Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationController = TextEditingController();
  final _skillsController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // State Variables
  int _currentStep = 0;
  bool _isGenerating = false;
  bool _resumeGenerated = false;
  String _selectedTemplate = 'modern';
  String _selectedLanguage = 'english'; // english, japanese, both
  ResumeData? _generatedResume;

  // Form Data
  Map<String, dynamic> _formData = {};

  final List<String> _templates = ['modern', 'classic', 'creative', 'minimal'];
  final List<String> _languages = ['english', 'japanese', 'both'];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadUserData();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _pulseController.repeat(reverse: true);
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
            _nameController.text = data['name'] ?? '';
            _emailController.text = data['email'] ?? '';
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _objectiveController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    _skillsController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Container(
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
                Color(0xFFF59E0B),
              ],
            ),
          ),
          child: Column(
            children: [
              // Header with constrained height
              Container(
                constraints: BoxConstraints(
                  maxHeight: size.height * 0.12,
                  minHeight: kToolbarHeight,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.01,
                ),
                child: _buildHeader(size, isSmallScreen),
              ),

              // Content with flexible space
              Expanded(
                child: _resumeGenerated
                    ? _buildResumePreview(size, isSmallScreen)
                    : _buildFormContent(size, isSmallScreen),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size, bool isSmallScreen) {
    return Container(
      width: size.width,
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.01,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back Button
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // Add navigation logic if needed
            },
            child: Container(
              width: size.width * 0.1,
              height: size.width * 0.1,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: size.width * 0.04,
              ),
            ),
          ),

          SizedBox(width: size.width * 0.03),

          // Title Section
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resume Builder',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Create professional Japanese resumes',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Progress Indicator
          if (!_resumeGenerated)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.02,
                vertical: size.height * 0.008,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Step ${_currentStep + 1}/4',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 10 : 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildFormContent(Size size, bool isSmallScreen) {
    return Column(
      children: [
        // Progress Steps
        _buildProgressSteps(size, isSmallScreen),

        // Form Content
        Expanded(
          child: _buildCurrentStep(size, isSmallScreen),
        ),

        // Navigation Buttons
        _buildNavigationButtons(size, isSmallScreen),
      ],
    );
  }

  Widget _buildProgressSteps(Size size, bool isSmallScreen) {
    final steps = ['Personal', 'Experience', 'Template', 'Generate'];

    return Container(
      height: size.height * 0.1,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Row(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: size.width * 0.08,
                        height: size.width * 0.08,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? const Color(0xFF10B981)
                              : isActive
                              ? const Color(0xFFF59E0B)
                              : Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFFF59E0B)
                                : Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: isCompleted
                              ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: size.width * 0.04,
                          )
                              : Text(
                            '${index + 1}',
                            style: GoogleFonts.poppins(
                              fontSize: size.width * 0.03,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.005),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          step,
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.025,
                            color: isActive
                                ? const Color(0xFFF59E0B)
                                : Colors.white.withOpacity(0.7),
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    width: size.width * 0.02,
                    height: 2,
                    color: isCompleted
                        ? const Color(0xFF10B981)
                        : Colors.white.withOpacity(0.2),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrentStep(Size size, bool isSmallScreen) {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep(size, isSmallScreen);
      case 1:
        return _buildExperienceStep(size, isSmallScreen);
      case 2:
        return _buildTemplateStep(size, isSmallScreen);
      case 3:
        return _buildGenerateStep(size, isSmallScreen);
      default:
        return _buildPersonalInfoStep(size, isSmallScreen);
    }
  }

  Widget _buildPersonalInfoStep(Size size, bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Title
            _buildStepHeader(
              'Personal Information',
              'Let\'s start with your basic details',
              '👤',
              size,
              isSmallScreen,
            ),

            SizedBox(height: size.height * 0.03),

            // Form Fields
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.person,
              size: size,
              validator: (value) => value?.isEmpty == true ? 'Required field' : null,
            ),

            SizedBox(height: size.height * 0.02),

            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'your.email@example.com',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              size: size,
              validator: (value) {
                if (value?.isEmpty == true) return 'Required field';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                  return 'Invalid email format';
                }
                return null;
              },
            ),

            SizedBox(height: size.height * 0.02),

            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: '+81 90-1234-5678',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              size: size,
            ),

            SizedBox(height: size.height * 0.02),

            _buildTextField(
              controller: _addressController,
              label: 'Address',
              hint: 'Your current address',
              icon: Icons.location_on,
              maxLines: 2,
              size: size,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceStep(Size size, bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Experience & Skills',
            'Tell us about your background',
            '💼',
            size,
            isSmallScreen,
          ),

          SizedBox(height: size.height * 0.03),

          _buildTextField(
            controller: _objectiveController,
            label: 'Career Objective',
            hint: 'Describe your career goals and aspirations...',
            icon: Icons.flag,
            maxLines: 3,
            size: size,
          ),

          SizedBox(height: size.height * 0.02),

          _buildTextField(
            controller: _experienceController,
            label: 'Work Experience',
            hint: 'List your work experience, internships, projects...',
            icon: Icons.work,
            maxLines: 5,
            size: size,
          ),

          SizedBox(height: size.height * 0.02),

          _buildTextField(
            controller: _educationController,
            label: 'Education',
            hint: 'Your educational background...',
            icon: Icons.school,
            maxLines: 3,
            size: size,
          ),

          SizedBox(height: size.height * 0.02),

          _buildTextField(
            controller: _skillsController,
            label: 'Skills & Languages',
            hint: 'Technical skills, soft skills, languages...',
            icon: Icons.star,
            maxLines: 3,
            size: size,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateStep(Size size, bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Choose Template',
            'Select your preferred style',
            '🎨',
            size,
            isSmallScreen,
          ),

          SizedBox(height: size.height * 0.03),

          // Template Selection
          Text(
            'Resume Template',
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(height: size.height * 0.015),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isSmallScreen ? 2 : 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: size.width * 0.03,
              mainAxisSpacing: size.width * 0.03,
            ),
            itemCount: _templates.length,
            itemBuilder: (context, index) {
              final template = _templates[index];
              final isSelected = _selectedTemplate == template;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTemplate = template;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF59E0B).withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFF59E0B)
                          : Colors.white.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: size.width * 0.12,
                        height: size.width * 0.15,
                        decoration: BoxDecoration(
                          color: _getTemplateColor(template).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getTemplateIcon(template),
                          color: _getTemplateColor(template),
                          size: size.width * 0.06,
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          template.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.03,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? const Color(0xFFF59E0B)
                                : Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          SizedBox(height: size.height * 0.03),

          // Language Selection
          Text(
            'Resume Language',
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(height: size.height * 0.015),

          ..._languages.map((language) {
            final isSelected = _selectedLanguage == language;
            return Container(
              margin: EdgeInsets.only(bottom: size.height * 0.01),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedLanguage = language;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(size.width * 0.04),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF59E0B).withOpacity(0.1)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFF59E0B)
                          : Colors.white.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: size.width * 0.08,
                        height: size.width * 0.08,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF59E0B).withOpacity(0.2)
                              : Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _getLanguageEmoji(language),
                            style: TextStyle(fontSize: size.width * 0.04),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.03),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getLanguageTitle(language),
                            style: GoogleFonts.poppins(
                              fontSize: size.width * 0.035,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _getLanguageDescription(language),
                            style: GoogleFonts.poppins(
                              fontSize: size.width * 0.028,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildGenerateStep(Size size, bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        children: [
          _buildStepHeader(
            'Generate Resume',
            'Review and create your resume',
            '🚀',
            size,
            isSmallScreen,
          ),

          SizedBox(height: size.height * 0.03),

          // Summary Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF59E0B).withOpacity(0.1),
                  const Color(0xFFEC4899).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Resume Summary',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: size.height * 0.02),

                ...[
                  {'label': 'Name', 'value': _nameController.text},
                  {'label': 'Email', 'value': _emailController.text},
                  {'label': 'Template', 'value': _selectedTemplate.toUpperCase()},
                  {'label': 'Language', 'value': _getLanguageTitle(_selectedLanguage)},
                ].map((item) => Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.01),
                  child: Row(
                    children: [
                      SizedBox(
                        width: size.width * 0.2,
                        child: Text(
                          '${item['label']}:',
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.03,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item['value']!,
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.03,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),

          SizedBox(height: size.height * 0.04),

          // Generate Button
          if (_isGenerating)
            Column(
              children: [
                SizedBox(
                  width: size.width * 0.15,
                  height: size.width * 0.15,
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                    strokeWidth: 4,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  'AI is creating your resume...',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  'This may take a few moments',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.032,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            )
          else
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: SizedBox(
                    width: double.infinity,
                    height: size.height * 0.06,
                    child: ElevatedButton(
                      onPressed: _generateResume,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: size.width * 0.05,
                          ),
                          SizedBox(width: size.width * 0.02),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Generate AI Resume',
                              style: GoogleFonts.poppins(
                                fontSize: size.width * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildResumePreview(Size size, bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        children: [
          // Header
          Container(
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
              children: [
                Text(
                  '✅',
                  style: TextStyle(fontSize: size.width * 0.12),
                ),
                SizedBox(height: size.height * 0.02),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Resume Generated!',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Your professional resume is ready',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.035,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: size.height * 0.03),

          // Preview Card
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: size.height * 0.3,
            ),
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  _nameController.text,
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: size.height * 0.005),
                Text(
                  _emailController.text,
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.032,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: size.height * 0.02),

                // Sample content
                Text(
                  'OBJECTIVE',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.035,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                Text(
                  _objectiveController.text.isNotEmpty
                      ? _objectiveController.text
                      : 'Seeking opportunities to apply my skills in a dynamic environment...',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.03,
                    color: Colors.black87,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: size.height * 0.015),

                Text(
                  'EXPERIENCE',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.035,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                Text(
                  _experienceController.text.isNotEmpty
                      ? _experienceController.text
                      : 'Previous experience and achievements...',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.03,
                    color: Colors.black87,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          SizedBox(height: size.height * 0.03),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _downloadResume,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download, size: size.width * 0.04),
                      SizedBox(width: size.width * 0.02),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Download PDF',
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.032,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: ElevatedButton(
                  onPressed: _shareResume,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06B6D4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.share, size: size.width * 0.04),
                      SizedBox(width: size.width * 0.02),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Share',
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.032,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.02),

          // Create New Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createNewResume,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Create New Resume',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.035,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle, String emoji, Size size, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: size.width * 0.12,
            height: size.width * 0.12,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(fontSize: size.width * 0.06),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.032,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Size size,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      validator: validator,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: size.width * 0.035,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.7),
          fontSize: size.width * 0.032,
        ),
        hintStyle: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.5),
          fontSize: size.width * 0.03,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFFF59E0B),
          size: size.width * 0.05,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.015,
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(Size size, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Row(
        children: [
          // Back Button
          if (_currentStep > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: _previousStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          if (_currentStep > 0) SizedBox(width: size.width * 0.03),

          // Next Button
          if (_currentStep < 3)
            Expanded(
              flex: _currentStep == 0 ? 1 : 1,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Next',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper Methods
  Color _getTemplateColor(String template) {
    switch (template) {
      case 'modern': return const Color(0xFF10B981);
      case 'classic': return const Color(0xFF06B6D4);
      case 'creative': return const Color(0xFFEC4899);
      case 'minimal': return const Color(0xFF8B5CF6);
      default: return const Color(0xFF10B981);
    }
  }

  IconData _getTemplateIcon(String template) {
    switch (template) {
      case 'modern': return Icons.laptop;
      case 'classic': return Icons.business;
      case 'creative': return Icons.palette;
      case 'minimal': return Icons.panorama_fish_eye;
      default: return Icons.description;
    }
  }

  String _getLanguageEmoji(String language) {
    switch (language) {
      case 'english': return '🇺🇸';
      case 'japanese': return '🇯🇵';
      case 'both': return '🌍';
      default: return '🇺🇸';
    }
  }

  String _getLanguageTitle(String language) {
    switch (language) {
      case 'english': return 'English Only';
      case 'japanese': return 'Japanese Only';
      case 'both': return 'Bilingual';
      default: return 'English Only';
    }
  }

  String _getLanguageDescription(String language) {
    switch (language) {
      case 'english': return 'Standard international format';
      case 'japanese': return 'Japanese 履歴書 format';
      case 'both': return 'Both languages included';
      default: return 'Standard format';
    }
  }

  // Action Methods
  void _nextStep() {
    if (_currentStep == 0 && !_formKey.currentState!.validate()) {
      return;
    }

    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _generateResume() async {
    setState(() {
      _isGenerating = true;
    });

    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isGenerating = false;
      _resumeGenerated = true;
      _generatedResume = ResumeData(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        objective: _objectiveController.text,
        experience: _experienceController.text,
        education: _educationController.text,
        skills: _skillsController.text,
        template: _selectedTemplate,
        language: _selectedLanguage,
      );
    });

    _showMessage('Resume generated successfully! 🎉');
  }

  void _downloadResume() {
    // TODO: Implement PDF generation and download
    _showMessage('Download functionality coming soon! 📄');
  }

  void _shareResume() {
    // TODO: Implement sharing functionality
    _showMessage('Share functionality coming soon! 📤');
  }

  void _createNewResume() {
    setState(() {
      _resumeGenerated = false;
      _currentStep = 0;
      _selectedTemplate = 'modern';
      _selectedLanguage = 'english';
    });

    // Clear form controllers
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    _objectiveController.clear();
    _experienceController.clear();
    _educationController.clear();
    _skillsController.clear();

    _loadUserData();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFF59E0B),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Resume Data Model
class ResumeData {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String objective;
  final String experience;
  final String education;
  final String skills;
  final String template;
  final String language;

  ResumeData({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.objective,
    required this.experience,
    required this.education,
    required this.skills,
    required this.template,
    required this.language,
  });
}