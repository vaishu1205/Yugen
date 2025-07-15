import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfessionalResumeBuilder extends StatefulWidget {
  const ProfessionalResumeBuilder({Key? key}) : super(key: key);

  @override
  State<ProfessionalResumeBuilder> createState() => _ProfessionalResumeBuilderState();
}

class _ProfessionalResumeBuilderState extends State<ProfessionalResumeBuilder>
    with TickerProviderStateMixin {

  // Personal Information Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _portfolioController = TextEditingController();

  // Professional Summary
  final _summaryController = TextEditingController();

  // Education Controllers (Multiple entries)
  List<Map<String, TextEditingController>> educationList = [];

  // Experience Controllers (Multiple entries)
  List<Map<String, TextEditingController>> experienceList = [];

  // Projects Controllers (Multiple entries)
  List<Map<String, TextEditingController>> projectsList = [];

  // Skills Controllers
  final _technicalSkillsController = TextEditingController();
  final _softSkillsController = TextEditingController();
  final _languagesController = TextEditingController();

  // Certifications Controllers (Multiple entries)
  List<Map<String, TextEditingController>> certificationsList = [];

  // Additional Sections
  final _achievementsController = TextEditingController();
  final _volunteersController = TextEditingController();
  final _hobbiesController = TextEditingController();

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String selectedTemplate = 'professional';
  final List<String> templates = ['professional', 'modern', 'creative', 'ats_friendly'];

  // Auto-save functionality
  bool _isDataLoaded = false;
  static const String _storageKey = 'professional_resume_data';
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();

    _loadSavedData().then((_) {
      _addListeners();
    });
  }

  void _initializeControllers() {
    _addEducationEntry();
    _addExperienceEntry();
    _addProjectEntry();
    _addCertificationEntry();
  }

  void _addEducationEntry() {
    educationList.add({
      'institution': TextEditingController(),
      'degree': TextEditingController(),
      'major': TextEditingController(),
      'gpa': TextEditingController(),
      'startDate': TextEditingController(),
      'endDate': TextEditingController(),
      'relevant_courses': TextEditingController(),
    });
  }

  void _addExperienceEntry() {
    experienceList.add({
      'company': TextEditingController(),
      'position': TextEditingController(),
      'location': TextEditingController(),
      'startDate': TextEditingController(),
      'endDate': TextEditingController(),
      'current': TextEditingController(),
      'description': TextEditingController(),
    });
  }

  void _addProjectEntry() {
    projectsList.add({
      'title': TextEditingController(),
      'technologies': TextEditingController(),
      'startDate': TextEditingController(),
      'endDate': TextEditingController(),
      'description': TextEditingController(),
      'github': TextEditingController(),
      'demo': TextEditingController(),
    });
  }

  void _addCertificationEntry() {
    certificationsList.add({
      'name': TextEditingController(),
      'issuer': TextEditingController(),
      'date': TextEditingController(),
      'id': TextEditingController(),
    });
  }

  void _addListeners() {
    _firstNameController.addListener(_onDataChanged);
    _lastNameController.addListener(_onDataChanged);
    _emailController.addListener(_onDataChanged);
    _phoneController.addListener(_onDataChanged);
    _addressController.addListener(_onDataChanged);
    _cityController.addListener(_onDataChanged);
    _stateController.addListener(_onDataChanged);
    _zipController.addListener(_onDataChanged);
    _linkedinController.addListener(_onDataChanged);
    _githubController.addListener(_onDataChanged);
    _portfolioController.addListener(_onDataChanged);
    _summaryController.addListener(_onDataChanged);
    _technicalSkillsController.addListener(_onDataChanged);
    _softSkillsController.addListener(_onDataChanged);
    _languagesController.addListener(_onDataChanged);
    _achievementsController.addListener(_onDataChanged);
    _volunteersController.addListener(_onDataChanged);
    _hobbiesController.addListener(_onDataChanged);

    for (var education in educationList) {
      education.values.forEach((controller) => controller.addListener(_onDataChanged));
    }
    for (var experience in experienceList) {
      experience.values.forEach((controller) => controller.addListener(_onDataChanged));
    }
    for (var project in projectsList) {
      project.values.forEach((controller) => controller.addListener(_onDataChanged));
    }
    for (var cert in certificationsList) {
      cert.values.forEach((controller) => controller.addListener(_onDataChanged));
    }
  }

  void _onDataChanged() {
    setState(() {});
    if (_isDataLoaded) {
      _saveData();
    }
  }
  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_storageKey);

      if (savedData != null) {
        final Map<String, dynamic> data = json.decode(savedData);

        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';
        _cityController.text = data['city'] ?? '';
        _stateController.text = data['state'] ?? '';
        _zipController.text = data['zip'] ?? '';
        _linkedinController.text = data['linkedin'] ?? '';
        _githubController.text = data['github'] ?? '';
        _portfolioController.text = data['portfolio'] ?? '';
        _summaryController.text = data['summary'] ?? '';
        _technicalSkillsController.text = data['technicalSkills'] ?? '';
        _softSkillsController.text = data['softSkills'] ?? '';
        _languagesController.text = data['languages'] ?? '';
        _achievementsController.text = data['achievements'] ?? '';
        _volunteersController.text = data['volunteers'] ?? '';
        _hobbiesController.text = data['hobbies'] ?? '';
        selectedTemplate = data['template'] ?? 'professional';

        _loadDynamicData(data);
      }
    } catch (e) {
      debugPrint('Error loading saved data: $e');
    } finally {
      _isDataLoaded = true;
    }
  }

  void _loadDynamicData(Map<String, dynamic> data) {
    if (data['education'] != null) {
      educationList.clear();
      for (var edu in data['education']) {
        var controllers = <String, TextEditingController>{};
        edu.forEach((key, value) {
          controllers[key] = TextEditingController(text: value);
        });
        educationList.add(controllers);
      }
    }

    if (data['experience'] != null) {
      experienceList.clear();
      for (var exp in data['experience']) {
        var controllers = <String, TextEditingController>{};
        exp.forEach((key, value) {
          controllers[key] = TextEditingController(text: value);
        });
        experienceList.add(controllers);
      }
    }

    if (data['projects'] != null) {
      projectsList.clear();
      for (var proj in data['projects']) {
        var controllers = <String, TextEditingController>{};
        proj.forEach((key, value) {
          controllers[key] = TextEditingController(text: value);
        });
        projectsList.add(controllers);
      }
    }

    if (data['certifications'] != null) {
      certificationsList.clear();
      for (var cert in data['certifications']) {
        var controllers = <String, TextEditingController>{};
        cert.forEach((key, value) {
          controllers[key] = TextEditingController(text: value);
        });
        certificationsList.add(controllers);
      }
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'zip': _zipController.text,
        'linkedin': _linkedinController.text,
        'github': _githubController.text,
        'portfolio': _portfolioController.text,
        'summary': _summaryController.text,
        'technicalSkills': _technicalSkillsController.text,
        'softSkills': _softSkillsController.text,
        'languages': _languagesController.text,
        'achievements': _achievementsController.text,
        'volunteers': _volunteersController.text,
        'hobbies': _hobbiesController.text,
        'template': selectedTemplate,
        'education': educationList.map((edu) =>
            edu.map((key, controller) => MapEntry(key, controller.text))).toList(),
        'experience': experienceList.map((exp) =>
            exp.map((key, controller) => MapEntry(key, controller.text))).toList(),
        'projects': projectsList.map((proj) =>
            proj.map((key, controller) => MapEntry(key, controller.text))).toList(),
        'certifications': certificationsList.map((cert) =>
            cert.map((key, controller) => MapEntry(key, controller.text))).toList(),
        'lastModified': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_storageKey, json.encode(data));
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(size),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: isMobile ? _buildMobileLayout(size) : _buildDesktopLayout(size),
      ),
      floatingActionButton: _buildDownloadFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar(Size size) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.work, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Professional Resume Builder',
                  style: GoogleFonts.inter(
                    fontSize: size.width < 400 ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Build your career-ready resume',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _clearAllData,
          icon: const Icon(Icons.refresh, color: Colors.red),
          tooltip: 'Start Fresh',
        ),
        _buildTemplateSelector(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildTemplateSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: selectedTemplate,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4F46E5)),
        items: [
          DropdownMenuItem(value: 'professional', child: Text('PROFESSIONAL', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF4F46E5)))),
          DropdownMenuItem(value: 'modern', child: Text('MODERN', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF4F46E5)))),
          DropdownMenuItem(value: 'creative', child: Text('CREATIVE', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF4F46E5)))),
          DropdownMenuItem(value: 'ats_friendly', child: Text('ATS FRIENDLY', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF4F46E5)))),
        ],
        onChanged: (value) {
          setState(() {
            selectedTemplate = value!;
          });
          if (_isDataLoaded) {
            _saveData();
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout(Size size) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: const Color(0xFF4F46E5),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF4F46E5),
              tabs: [
                Tab(child: Text('Edit', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                Tab(child: Text('Preview', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildFormSection(size),
                _buildPreviewSection(size),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(Size size) {
    return Row(
      children: [
        Expanded(flex: 1, child: _buildFormSection(size)),
        Expanded(flex: 1, child: _buildPreviewSection(size)),
      ],
    );
  }
  Widget _buildFormSection(Size size) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPersonalInfoSection(size),
            const SizedBox(height: 24),
            _buildSummarySection(size),
            const SizedBox(height: 24),
            _buildEducationSection(size),
            const SizedBox(height: 24),
            _buildExperienceSection(size),
            const SizedBox(height: 24),
            _buildProjectsSection(size),
            const SizedBox(height: 24),
            _buildSkillsSection(size),
            const SizedBox(height: 24),
            _buildCertificationsSection(size),
            const SizedBox(height: 24),
            _buildAdditionalSections(size),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(Size size) {
    return Column(
      children: [
        _buildSectionHeader('Personal Information', Icons.person),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildTextField(_firstNameController, 'First Name*', Icons.person_outline)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_lastNameController, 'Last Name*', Icons.person_outline)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildTextField(_emailController, 'Email Address*', Icons.email_outlined, keyboardType: TextInputType.emailAddress)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_phoneController, 'Phone Number*', Icons.phone_outlined, keyboardType: TextInputType.phone)),
                ],
              ),
              _buildTextField(_addressController, 'Street Address', Icons.location_on_outlined),
              Row(
                children: [
                  Expanded(flex: 2, child: _buildTextField(_cityController, 'City', Icons.location_city_outlined)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_stateController, 'State', Icons.map_outlined)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_zipController, 'ZIP Code', Icons.local_post_office_outlined)),
                ],
              ),
              _buildTextField(_linkedinController, 'LinkedIn Profile', Icons.link_outlined, hint: 'https://linkedin.com/in/yourname'),
              _buildTextField(_githubController, 'GitHub Profile', Icons.code_outlined, hint: 'https://github.com/yourname'),
              _buildTextField(_portfolioController, 'Portfolio Website', Icons.web_outlined, hint: 'https://yourportfolio.com'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(Size size) {
    return Column(
      children: [
        _buildSectionHeader('Professional Summary', Icons.description),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: _buildTextField(
            _summaryController,
            'Professional Summary*',
            Icons.description_outlined,
            maxLines: 4,
            hint: 'Write a compelling summary of your skills, experience, and career goals (2-3 sentences)',
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        int maxLines = 1,
        String? hint,
        TextInputType? keyboardType,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E293B)),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF4F46E5), size: 20),
          labelStyle: GoogleFonts.inter(
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF94A3B8),
            fontSize: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
  Widget _buildEducationSection(Size size) {
    return Column(
      children: [
        _buildSectionHeader(
          'Education',
          Icons.school,
          trailing: IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF4F46E5)),
            onPressed: () {
              setState(() {
                _addEducationEntry();
              });
              _saveData();
            },
          ),
        ),
        ...educationList.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, TextEditingController> controllers = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Education ${index + 1}',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF4F46E5)),
                      ),
                    ),
                    if (educationList.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () {
                          setState(() {
                            controllers.values.forEach((c) => c.dispose());
                            educationList.removeAt(index);
                          });
                          _saveData();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(controllers['institution']!, 'Institution/University*', Icons.school_outlined),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controllers['degree']!, 'Degree*', Icons.school_outlined, hint: 'Bachelor of Science')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controllers['major']!, 'Major/Field of Study*', Icons.book_outlined)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controllers['gpa']!, 'GPA (Optional)', Icons.grade_outlined, hint: '3.8/4.0')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controllers['startDate']!, 'Start Date', Icons.calendar_today_outlined, hint: 'Sep 2020')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controllers['endDate']!, 'End Date', Icons.calendar_today_outlined, hint: 'May 2024')),
                  ],
                ),
                _buildTextField(controllers['relevant_courses']!, 'Relevant Courses', Icons.list_outlined,
                    hint: 'Data Structures, Algorithms, Database Systems', maxLines: 2),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildExperienceSection(Size size) {
    return Column(
      children: [
        _buildSectionHeader(
          'Work Experience',
          Icons.work,
          trailing: IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF4F46E5)),
            onPressed: () {
              setState(() {
                _addExperienceEntry();
              });
              _saveData();
            },
          ),
        ),
        ...experienceList.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, TextEditingController> controllers = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Experience ${index + 1}',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF4F46E5)),
                      ),
                    ),
                    if (experienceList.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () {
                          setState(() {
                            controllers.values.forEach((c) => c.dispose());
                            experienceList.removeAt(index);
                          });
                          _saveData();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controllers['company']!, 'Company/Organization*', Icons.business_outlined)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controllers['position']!, 'Position/Job Title*', Icons.work_outline)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controllers['location']!, 'Location', Icons.location_on_outlined, hint: 'City, State')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controllers['startDate']!, 'Start Date', Icons.calendar_today_outlined, hint: 'Jun 2023')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controllers['endDate']!, 'End Date', Icons.calendar_today_outlined, hint: 'Present')),
                  ],
                ),
                _buildTextField(controllers['description']!, 'Job Description & Achievements*', Icons.description_outlined,
                    maxLines: 4, hint: '• Achieved X% improvement in Y\n• Led team of Z people\n• Developed solutions that resulted in...'),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildProjectsSection(Size size) {
    return Column(
      children: [
        _buildSectionHeader(
          'Projects',
          Icons.code,
          trailing: IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF4F46E5)),
            onPressed: () {
              setState(() {
                _addProjectEntry();
              });
              _saveData();
            },
          ),
        ),
        ...projectsList.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, TextEditingController> controllers = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Project ${index + 1}',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF4F46E5)),
                      ),
                    ),
                    if (projectsList.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () {
                          setState(() {
                            controllers.values.forEach((c) => c.dispose());
                            projectsList.removeAt(index);
                          });
                          _saveData();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(controllers['title']!, 'Project Title*', Icons.code_outlined),
                _buildTextField(controllers['technologies']!, 'Technologies Used*', Icons.build_outlined,
                    hint: 'React, Node.js, MongoDB, AWS'),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controllers['startDate']!, 'Start Date', Icons.calendar_today_outlined, hint: 'Jan 2024')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controllers['endDate']!, 'End Date', Icons.calendar_today_outlined, hint: 'Mar 2024')),
                  ],
                ),
                _buildTextField(controllers['description']!, 'Project Description*', Icons.description_outlined,
                    maxLines: 3, hint: 'Describe what the project does, your role, and key achievements'),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controllers['github']!, 'GitHub URL', Icons.code_outlined, hint: 'https://github.com/username/project')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controllers['demo']!, 'Live Demo URL', Icons.web_outlined, hint: 'https://project-demo.com')),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
  Widget _buildSkillsSection(Size size) {
    return Column(
      children: [
        _buildSectionHeader('Skills & Languages', Icons.star),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              _buildTextField(_technicalSkillsController, 'Technical Skills*', Icons.computer_outlined,
                  maxLines: 2, hint: 'JavaScript, Python, React, Node.js, SQL, Git, AWS'),
              _buildTextField(_softSkillsController, 'Soft Skills', Icons.psychology_outlined,
                  maxLines: 2, hint: 'Leadership, Communication, Problem-solving, Teamwork'),
              _buildTextField(_languagesController, 'Languages', Icons.language_outlined,
                  hint: 'English (Native), Spanish (Fluent), French (Conversational)'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCertificationsSection(Size size) {
    return Column(
      children: [
        _buildSectionHeader(
          'Certifications',
          Icons.verified,
          trailing: IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF4F46E5)),
            onPressed: () {
              setState(() {
                _addCertificationEntry();
              });
              _saveData();
            },
          ),
        ),
        ...certificationsList.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, TextEditingController> controllers = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Certification ${index + 1}',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF4F46E5)),
                      ),
                    ),
                    if (certificationsList.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () {
                          setState(() {
                            controllers.values.forEach((c) => c.dispose());
                            certificationsList.removeAt(index);
                          });
                          _saveData();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controllers['name']!, 'Certification Name', Icons.verified_outlined)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controllers['issuer']!, 'Issuing Organization', Icons.business_outlined)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controllers['date']!, 'Date Obtained', Icons.calendar_today_outlined, hint: 'Mar 2024')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controllers['id']!, 'Credential ID (Optional)', Icons.badge_outlined)),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAdditionalSections(Size size) {
    return Column(
      children: [
        _buildSectionHeader('Additional Information', Icons.info),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              _buildTextField(_achievementsController, 'Achievements & Awards', Icons.emoji_events_outlined,
                  maxLines: 3, hint: 'Dean\'s List, Scholarship recipient, Competition winner...'),
              _buildTextField(_volunteersController, 'Volunteer Experience', Icons.volunteer_activism_outlined,
                  maxLines: 3, hint: 'Volunteer work, community service, nonprofit involvement...'),
              _buildTextField(_hobbiesController, 'Interests & Hobbies', Icons.favorite_outlined,
                  maxLines: 2, hint: 'Photography, Hiking, Chess, Reading, Cooking...'),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildPreviewSection(Size size) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          child: _buildResumePreview(size),
        ),
      ),
    );
  }

  Widget _buildResumePreview(Size size) {
    return _buildProfessionalTemplate(size);
  }

  Widget _buildProfessionalTemplate(Size size) {
    return Container(
      padding: const EdgeInsets.all(32),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResumeHeader(),
          const SizedBox(height: 24),

          if (_summaryController.text.isNotEmpty) ...[
            _buildResumeSection('PROFESSIONAL SUMMARY', _summaryController.text),
            const SizedBox(height: 20),
          ],

          if (educationList.any((edu) => edu['institution']!.text.isNotEmpty)) ...[
            _buildEducationPreview(),
            const SizedBox(height: 20),
          ],

          if (experienceList.any((exp) => exp['company']!.text.isNotEmpty)) ...[
            _buildExperiencePreview(),
            const SizedBox(height: 20),
          ],

          if (projectsList.any((proj) => proj['title']!.text.isNotEmpty)) ...[
            _buildProjectsPreview(),
            const SizedBox(height: 20),
          ],

          if (_technicalSkillsController.text.isNotEmpty) ...[
            _buildSkillsPreview(),
            const SizedBox(height: 20),
          ],

          if (certificationsList.any((cert) => cert['name']!.text.isNotEmpty)) ...[
            _buildCertificationsPreview(),
            const SizedBox(height: 20),
          ],

          _buildAdditionalPreview(),
        ],
      ),
    );
  }

  Widget _buildResumeHeader() {
    String fullName = '${_firstNameController.text} ${_lastNameController.text}'.trim();
    if (fullName.isEmpty) fullName = 'Your Name';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fullName,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            if (_emailController.text.isNotEmpty)
              _buildContactItem(Icons.email, _emailController.text),
            if (_phoneController.text.isNotEmpty)
              _buildContactItem(Icons.phone, _phoneController.text),
            if (_addressController.text.isNotEmpty || _cityController.text.isNotEmpty)
              _buildContactItem(Icons.location_on,
                  '${_addressController.text}${_addressController.text.isNotEmpty && (_cityController.text.isNotEmpty || _stateController.text.isNotEmpty) ? ', ' : ''}${_cityController.text}${_cityController.text.isNotEmpty && _stateController.text.isNotEmpty ? ', ' : ''}${_stateController.text}'),
            if (_linkedinController.text.isNotEmpty)
              _buildContactItem(Icons.link, _linkedinController.text),
            if (_githubController.text.isNotEmpty)
              _buildContactItem(Icons.code, _githubController.text),
            if (_portfolioController.text.isNotEmpty)
              _buildContactItem(Icons.web, _portfolioController.text),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 16),
          height: 2,
          width: 100,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF4F46E5)),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildResumeSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4F46E5),
            letterSpacing: 0.5,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4, bottom: 12),
          height: 1,
          width: 50,
          color: const Color(0xFF4F46E5),
        ),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF374151),
            height: 1.5,
          ),
        ),
      ],
    );
  }
  Widget _buildEducationPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EDUCATION',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4F46E5),
            letterSpacing: 0.5,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4, bottom: 12),
          height: 1,
          width: 50,
          color: const Color(0xFF4F46E5),
        ),
        ...educationList.where((edu) => edu['institution']!.text.isNotEmpty).map((edu) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        edu['institution']!.text,
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                      ),
                    ),
                    if (edu['startDate']!.text.isNotEmpty || edu['endDate']!.text.isNotEmpty)
                      Text(
                        '${edu['startDate']!.text}${edu['startDate']!.text.isNotEmpty && edu['endDate']!.text.isNotEmpty ? ' - ' : ''}${edu['endDate']!.text}',
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                      ),
                  ],
                ),
                if (edu['degree']!.text.isNotEmpty || edu['major']!.text.isNotEmpty)
                  Text(
                    '${edu['degree']!.text}${edu['degree']!.text.isNotEmpty && edu['major']!.text.isNotEmpty ? ' in ' : ''}${edu['major']!.text}',
                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF374151)),
                  ),
                if (edu['gpa']!.text.isNotEmpty)
                  Text(
                    'GPA: ${edu['gpa']!.text}',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                if (edu['relevant_courses']!.text.isNotEmpty)
                  Text(
                    'Relevant Courses: ${edu['relevant_courses']!.text}',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildExperiencePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WORK EXPERIENCE',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4F46E5),
            letterSpacing: 0.5,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4, bottom: 12),
          height: 1,
          width: 50,
          color: const Color(0xFF4F46E5),
        ),
        ...experienceList.where((exp) => exp['company']!.text.isNotEmpty).map((exp) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exp['position']!.text.isNotEmpty ? exp['position']!.text : 'Position',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                      ),
                    ),
                    if (exp['startDate']!.text.isNotEmpty || exp['endDate']!.text.isNotEmpty)
                      Text(
                        '${exp['startDate']!.text}${exp['startDate']!.text.isNotEmpty && exp['endDate']!.text.isNotEmpty ? ' - ' : ''}${exp['endDate']!.text}',
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                      ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exp['company']!.text,
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF374151)),
                      ),
                    ),
                    if (exp['location']!.text.isNotEmpty)
                      Text(
                        exp['location']!.text,
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                      ),
                  ],
                ),
                if (exp['description']!.text.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    exp['description']!.text,
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF374151), height: 1.4),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildProjectsPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROJECTS',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4F46E5),
            letterSpacing: 0.5,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4, bottom: 12),
          height: 1,
          width: 50,
          color: const Color(0xFF4F46E5),
        ),
        ...projectsList.where((proj) => proj['title']!.text.isNotEmpty).map((proj) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        proj['title']!.text,
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                      ),
                    ),
                    if (proj['startDate']!.text.isNotEmpty || proj['endDate']!.text.isNotEmpty)
                      Text(
                        '${proj['startDate']!.text}${proj['startDate']!.text.isNotEmpty && proj['endDate']!.text.isNotEmpty ? ' - ' : ''}${proj['endDate']!.text}',
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                      ),
                  ],
                ),
                if (proj['technologies']!.text.isNotEmpty)
                  Text(
                    'Technologies: ${proj['technologies']!.text}',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF4F46E5)),
                  ),
                if (proj['description']!.text.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    proj['description']!.text,
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF374151), height: 1.4),
                  ),
                ],
                if (proj['github']!.text.isNotEmpty || proj['demo']!.text.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (proj['github']!.text.isNotEmpty) ...[
                        const Icon(Icons.code, size: 12, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          'GitHub',
                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (proj['demo']!.text.isNotEmpty) ...[
                        const Icon(Icons.web, size: 12, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          'Live Demo',
                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSkillsPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SKILLS',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4F46E5),
            letterSpacing: 0.5,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4, bottom: 12),
          height: 1,
          width: 50,
          color: const Color(0xFF4F46E5),
        ),
        if (_technicalSkillsController.text.isNotEmpty) ...[
          Text(
            'Technical Skills: ${_technicalSkillsController.text}',
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF374151), height: 1.4),
          ),
          const SizedBox(height: 8),
        ],
        if (_softSkillsController.text.isNotEmpty) ...[
          Text(
            'Soft Skills: ${_softSkillsController.text}',
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF374151), height: 1.4),
          ),
          const SizedBox(height: 8),
        ],
        if (_languagesController.text.isNotEmpty) ...[
          Text(
            'Languages: ${_languagesController.text}',
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF374151), height: 1.4),
          ),
        ],
      ],
    );
  }

  Widget _buildCertificationsPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CERTIFICATIONS',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4F46E5),
            letterSpacing: 0.5,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4, bottom: 12),
          height: 1,
          width: 50,
          color: const Color(0xFF4F46E5),
        ),
        ...certificationsList.where((cert) => cert['name']!.text.isNotEmpty).map((cert) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cert['name']!.text,
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                      ),
                      if (cert['issuer']!.text.isNotEmpty)
                        Text(
                          cert['issuer']!.text,
                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                        ),
                    ],
                  ),
                ),
                if (cert['date']!.text.isNotEmpty)
                  Text(
                    cert['date']!.text,
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAdditionalPreview() {
    return Column(
      children: [
        if (_achievementsController.text.isNotEmpty) ...[
          _buildResumeSection('ACHIEVEMENTS & AWARDS', _achievementsController.text),
          const SizedBox(height: 20),
        ],
        if (_volunteersController.text.isNotEmpty) ...[
          _buildResumeSection('VOLUNTEER EXPERIENCE', _volunteersController.text),
          const SizedBox(height: 20),
        ],
        if (_hobbiesController.text.isNotEmpty) ...[
          _buildResumeSection('INTERESTS', _hobbiesController.text),
        ],
      ],
    );
  }

  Widget _buildDownloadFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_done, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                'Auto-saved',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.extended(
          onPressed: _generatePDF,
          backgroundColor: const Color(0xFF4F46E5),
          icon: const Icon(Icons.download, color: Colors.white),
          label: Text(
            'Download PDF',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    String fullName = '${_firstNameController.text} ${_lastNameController.text}'.trim();
    if (fullName.isEmpty) fullName = 'Your Name';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Complete Header with ALL contact information
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    fullName,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 12),

                  // Contact Information - Show ALL fields
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (_emailController.text.isNotEmpty)
                        pw.Row(children: [
                          pw.Text('Email: ', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                          pw.Text(_emailController.text, style: const pw.TextStyle(fontSize: 11)),
                        ]),
                      if (_phoneController.text.isNotEmpty)
                        pw.Row(children: [
                          pw.Text('Phone: ', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                          pw.Text(_phoneController.text, style: const pw.TextStyle(fontSize: 11)),
                        ]),

                      // Complete Address
                      if (_addressController.text.isNotEmpty || _cityController.text.isNotEmpty || _stateController.text.isNotEmpty || _zipController.text.isNotEmpty)
                        pw.Row(children: [
                          pw.Text('Address: ', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                          pw.Text(
                            '${_addressController.text}${_addressController.text.isNotEmpty && (_cityController.text.isNotEmpty || _stateController.text.isNotEmpty || _zipController.text.isNotEmpty) ? ', ' : ''}${_cityController.text}${_cityController.text.isNotEmpty && (_stateController.text.isNotEmpty || _zipController.text.isNotEmpty) ? ', ' : ''}${_stateController.text}${_stateController.text.isNotEmpty && _zipController.text.isNotEmpty ? ' ' : ''}${_zipController.text}',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                        ]),

                      // Professional Links
                      if (_linkedinController.text.isNotEmpty)
                        pw.Row(children: [
                          pw.Text('LinkedIn: ', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                          pw.Text(_linkedinController.text, style: const pw.TextStyle(fontSize: 11)),
                        ]),
                      if (_githubController.text.isNotEmpty)
                        pw.Row(children: [
                          pw.Text('GitHub: ', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                          pw.Text(_githubController.text, style: const pw.TextStyle(fontSize: 11)),
                        ]),
                      if (_portfolioController.text.isNotEmpty)
                        pw.Row(children: [
                          pw.Text('Portfolio: ', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                          pw.Text(_portfolioController.text, style: const pw.TextStyle(fontSize: 11)),
                        ]),
                    ],
                  ),

                  pw.Container(
                    margin: const pw.EdgeInsets.only(top: 16, bottom: 20),
                    height: 2,
                    width: 100,
                    color: PdfColors.blue,
                  ),
                ],
              ),

              // Professional Summary
              if (_summaryController.text.isNotEmpty) ...[
                _buildPDFSection('PROFESSIONAL SUMMARY', _summaryController.text),
                pw.SizedBox(height: 16),
              ],

              // Complete Education Section
              if (educationList.any((edu) => edu['institution']!.text.isNotEmpty)) ...[
                _buildPDFEducationSection(),
                pw.SizedBox(height: 16),
              ],

              // Complete Experience Section
              if (experienceList.any((exp) => exp['company']!.text.isNotEmpty)) ...[
                _buildPDFExperienceSection(),
                pw.SizedBox(height: 16),
              ],

              // Complete Projects Section
              if (projectsList.any((proj) => proj['title']!.text.isNotEmpty)) ...[
                _buildPDFProjectsSection(),
                pw.SizedBox(height: 16),
              ],

              // Complete Skills Section
              if (_technicalSkillsController.text.isNotEmpty || _softSkillsController.text.isNotEmpty || _languagesController.text.isNotEmpty) ...[
                _buildPDFSkillsSection(),
                pw.SizedBox(height: 16),
              ],

              // Complete Certifications Section
              if (certificationsList.any((cert) => cert['name']!.text.isNotEmpty)) ...[
                _buildPDFCertificationsSection(),
                pw.SizedBox(height: 16),
              ],

              // All Additional Sections
              if (_achievementsController.text.isNotEmpty) ...[
                _buildPDFSection('ACHIEVEMENTS & AWARDS', _achievementsController.text),
                pw.SizedBox(height: 12),
              ],
              if (_volunteersController.text.isNotEmpty) ...[
                _buildPDFSection('VOLUNTEER EXPERIENCE', _volunteersController.text),
                pw.SizedBox(height: 12),
              ],
              if (_hobbiesController.text.isNotEmpty) ...[
                _buildPDFSection('INTERESTS & HOBBIES', _hobbiesController.text),
              ],
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPDFSection(String title, String content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 4, bottom: 8),
          height: 1,
          width: 50,
          color: PdfColors.blue,
        ),
        pw.Text(
          content,
          style: const pw.TextStyle(fontSize: 11, height: 1.4),
        ),
      ],
    );
  }

  pw.Widget _buildPDFEducationSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'EDUCATION',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 4, bottom: 8),
          height: 1,
          width: 50,
          color: PdfColors.blue,
        ),
        ...educationList.where((edu) => edu['institution']!.text.isNotEmpty).map((edu) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Institution and Dates
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        edu['institution']!.text,
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    if (edu['startDate']!.text.isNotEmpty || edu['endDate']!.text.isNotEmpty)
                      pw.Text(
                        '${edu['startDate']!.text}${edu['startDate']!.text.isNotEmpty && edu['endDate']!.text.isNotEmpty ? ' - ' : ''}${edu['endDate']!.text}',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                  ],
                ),

                // Degree and Major
                if (edu['degree']!.text.isNotEmpty || edu['major']!.text.isNotEmpty)
                  pw.Text(
                    '${edu['degree']!.text}${edu['degree']!.text.isNotEmpty && edu['major']!.text.isNotEmpty ? ' in ' : ''}${edu['major']!.text}',
                    style: const pw.TextStyle(fontSize: 11),
                  ),

                // GPA
                if (edu['gpa']!.text.isNotEmpty)
                  pw.Text(
                    'GPA: ${edu['gpa']!.text}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),

                // Relevant Courses
                if (edu['relevant_courses']!.text.isNotEmpty)
                  pw.Text(
                    'Relevant Coursework: ${edu['relevant_courses']!.text}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildPDFExperienceSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'WORK EXPERIENCE',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 4, bottom: 8),
          height: 1,
          width: 50,
          color: PdfColors.blue,
        ),
        ...experienceList.where((exp) => exp['company']!.text.isNotEmpty).map((exp) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Position and Dates
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        exp['position']!.text.isNotEmpty ? exp['position']!.text : 'Position',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    if (exp['startDate']!.text.isNotEmpty || exp['endDate']!.text.isNotEmpty)
                      pw.Text(
                        '${exp['startDate']!.text}${exp['startDate']!.text.isNotEmpty && exp['endDate']!.text.isNotEmpty ? ' - ' : ''}${exp['endDate']!.text}',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                  ],
                ),

                // Company and Location
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        exp['company']!.text,
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ),
                    if (exp['location']!.text.isNotEmpty)
                      pw.Text(
                        exp['location']!.text,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                  ],
                ),

                // Job Description
                if (exp['description']!.text.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    exp['description']!.text,
                    style: const pw.TextStyle(fontSize: 10, height: 1.3),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildPDFProjectsSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PROJECTS',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 4, bottom: 8),
          height: 1,
          width: 50,
          color: PdfColors.blue,
        ),
        ...projectsList.where((proj) => proj['title']!.text.isNotEmpty).map((proj) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Project Title and Dates
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        proj['title']!.text,
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    if (proj['startDate']!.text.isNotEmpty || proj['endDate']!.text.isNotEmpty)
                      pw.Text(
                        '${proj['startDate']!.text}${proj['startDate']!.text.isNotEmpty && proj['endDate']!.text.isNotEmpty ? ' - ' : ''}${proj['endDate']!.text}',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                  ],
                ),

                // Technologies Used
                if (proj['technologies']!.text.isNotEmpty)
                  pw.Text(
                    'Technologies: ${proj['technologies']!.text}',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),

                // Project Description
                if (proj['description']!.text.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    proj['description']!.text,
                    style: const pw.TextStyle(fontSize: 10, height: 1.3),
                  ),
                ],

                // Project Links
                if (proj['github']!.text.isNotEmpty || proj['demo']!.text.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Row(
                    children: [
                      if (proj['github']!.text.isNotEmpty) ...[
                        pw.Text('GitHub: ', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        pw.Text(proj['github']!.text, style: const pw.TextStyle(fontSize: 9)),
                        if (proj['demo']!.text.isNotEmpty) pw.SizedBox(width: 10),
                      ],
                      if (proj['demo']!.text.isNotEmpty) ...[
                        pw.Text('Demo: ', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        pw.Text(proj['demo']!.text, style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildPDFSkillsSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'SKILLS',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 4, bottom: 8),
          height: 1,
          width: 50,
          color: PdfColors.blue,
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (_technicalSkillsController.text.isNotEmpty) ...[
              pw.Text(
                'Technical Skills: ${_technicalSkillsController.text}',
                style: const pw.TextStyle(fontSize: 11, height: 1.3),
              ),
              pw.SizedBox(height: 4),
            ],
            if (_softSkillsController.text.isNotEmpty) ...[
              pw.Text(
                'Soft Skills: ${_softSkillsController.text}',
                style: const pw.TextStyle(fontSize: 11, height: 1.3),
              ),
              pw.SizedBox(height: 4),
            ],
            if (_languagesController.text.isNotEmpty) ...[
              pw.Text(
                'Languages: ${_languagesController.text}',
                style: const pw.TextStyle(fontSize: 11, height: 1.3),
              ),
            ],
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPDFCertificationsSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'CERTIFICATIONS',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 4, bottom: 8),
          height: 1,
          width: 50,
          color: PdfColors.blue,
        ),
        ...certificationsList.where((cert) => cert['name']!.text.isNotEmpty).map((cert) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Certification Name and Date
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        cert['name']!.text,
                        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    if (cert['date']!.text.isNotEmpty)
                      pw.Text(
                        cert['date']!.text,
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                  ],
                ),

                // Issuing Organization
                if (cert['issuer']!.text.isNotEmpty)
                  pw.Text(
                    cert['issuer']!.text,
                    style: const pw.TextStyle(fontSize: 10),
                  ),

                // Credential ID
                if (cert['id']!.text.isNotEmpty)
                  pw.Text(
                    'Credential ID: ${cert['id']!.text}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Future<void> _clearAllData() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Start Fresh?',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'This will clear all your resume information and start over. Are you sure?',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performClearData();
              },
              child: Text(
                'Clear All',
                style: GoogleFonts.inter(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performClearData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);

      setState(() {
        _firstNameController.clear();
        _lastNameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _addressController.clear();
        _cityController.clear();
        _stateController.clear();
        _zipController.clear();
        _linkedinController.clear();
        _githubController.clear();
        _portfolioController.clear();
        _summaryController.clear();
        _technicalSkillsController.clear();
        _softSkillsController.clear();
        _languagesController.clear();
        _achievementsController.clear();
        _volunteersController.clear();
        _hobbiesController.clear();

        for (var education in educationList) {
          education.values.forEach((controller) => controller.dispose());
        }
        for (var experience in experienceList) {
          experience.values.forEach((controller) => controller.dispose());
        }
        for (var project in projectsList) {
          project.values.forEach((controller) => controller.dispose());
        }
        for (var cert in certificationsList) {
          cert.values.forEach((controller) => controller.dispose());
        }

        educationList.clear();
        experienceList.clear();
        projectsList.clear();
        certificationsList.clear();

        _initializeControllers();
        selectedTemplate = 'professional';
      });

      _showSnackBar('All data cleared successfully! Starting fresh.', Colors.green);
      _addListeners();
    } catch (e) {
      _showSnackBar('Error clearing data', Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    _summaryController.dispose();
    _technicalSkillsController.dispose();
    _softSkillsController.dispose();
    _languagesController.dispose();
    _achievementsController.dispose();
    _volunteersController.dispose();
    _hobbiesController.dispose();

    for (var education in educationList) {
      education.values.forEach((controller) => controller.dispose());
    }
    for (var experience in experienceList) {
      experience.values.forEach((controller) => controller.dispose());
    }
    for (var project in projectsList) {
      project.values.forEach((controller) => controller.dispose());
    }
    for (var cert in certificationsList) {
      cert.values.forEach((controller) => controller.dispose());
    }

    super.dispose();
  }
}





// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:math' as math;
//
// class ResumeBuilderScreen extends StatefulWidget {
//   const ResumeBuilderScreen({super.key});
//
//   @override
//   State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
// }
//
// class _ResumeBuilderScreenState extends State<ResumeBuilderScreen>
//     with TickerProviderStateMixin {
//   // Animation Controllers
//   late AnimationController _slideController;
//   late AnimationController _pulseController;
//   late Animation<double> _slideAnimation;
//   late Animation<double> _pulseAnimation;
//
//   // Form Controllers
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _objectiveController = TextEditingController();
//   final _experienceController = TextEditingController();
//   final _educationController = TextEditingController();
//   final _skillsController = TextEditingController();
//
//   final _formKey = GlobalKey<FormState>();
//
//   // State Variables
//   int _currentStep = 0;
//   bool _isGenerating = false;
//   bool _resumeGenerated = false;
//   String _selectedTemplate = 'modern';
//   String _selectedLanguage = 'english'; // english, japanese, both
//   ResumeData? _generatedResume;
//
//   // Form Data
//   Map<String, dynamic> _formData = {};
//
//   final List<String> _templates = ['modern', 'classic', 'creative', 'minimal'];
//   final List<String> _languages = ['english', 'japanese', 'both'];
//
//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//     _loadUserData();
//   }
//
//   void _initAnimations() {
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );
//
//     _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
//       CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
//     );
//
//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//
//     _slideController.forward();
//     _pulseController.repeat(reverse: true);
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
//             _nameController.text = data['name'] ?? '';
//             _emailController.text = data['email'] ?? '';
//           });
//         }
//       } catch (e) {
//         print('Error loading user data: $e');
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _slideController.dispose();
//     _pulseController.dispose();
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     _objectiveController.dispose();
//     _experienceController.dispose();
//     _educationController.dispose();
//     _skillsController.dispose();
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final padding = MediaQuery.of(context).padding;
//     final isSmallScreen = size.width < 360;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1117),
//       body: SafeArea(
//         child: Container(
//           width: size.width,
//           height: size.height,
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Color(0xFF0D1117),
//                 Color(0xFF1C2128),
//                 Color(0xFF2D1B69),
//                 Color(0xFFF59E0B),
//               ],
//             ),
//           ),
//           child: Column(
//             children: [
//               // Header with constrained height
//               Container(
//                 constraints: BoxConstraints(
//                   maxHeight: size.height * 0.12,
//                   minHeight: kToolbarHeight,
//                 ),
//                 padding: EdgeInsets.symmetric(
//                   horizontal: size.width * 0.04,
//                   vertical: size.height * 0.01,
//                 ),
//                 child: _buildHeader(size, isSmallScreen),
//               ),
//
//               // Content with flexible space
//               Expanded(
//                 child: _resumeGenerated
//                     ? _buildResumePreview(size, isSmallScreen)
//                     : _buildFormContent(size, isSmallScreen),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(Size size, bool isSmallScreen) {
//     return Container(
//       width: size.width,
//       padding: EdgeInsets.symmetric(
//         horizontal: size.width * 0.04,
//         vertical: size.height * 0.01,
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Back Button
//           GestureDetector(
//             onTap: () {
//               Navigator.pop(context); // Add navigation logic if needed
//             },
//             child: Container(
//               width: size.width * 0.1,
//               height: size.width * 0.1,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.2),
//                   width: 1,
//                 ),
//               ),
//               child: Icon(
//                 Icons.arrow_back_ios_new,
//                 color: Colors.white,
//                 size: size.width * 0.04,
//               ),
//             ),
//           ),
//
//           SizedBox(width: size.width * 0.03),
//
//           // Title Section
//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Resume Builder',
//                   style: GoogleFonts.poppins(
//                     fontSize: isSmallScreen ? 18 : 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 Text(
//                   'Create professional Japanese resumes',
//                   style: GoogleFonts.poppins(
//                     fontSize: isSmallScreen ? 12 : 14,
//                     color: Colors.white.withOpacity(0.7),
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//
//           // Progress Indicator
//           if (!_resumeGenerated)
//             Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: size.width * 0.02,
//                 vertical: size.height * 0.008,
//               ),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 'Step ${_currentStep + 1}/4',
//                 style: GoogleFonts.poppins(
//                   fontSize: isSmallScreen ? 10 : 12,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//   Widget _buildFormContent(Size size, bool isSmallScreen) {
//     return Column(
//       children: [
//         // Progress Steps
//         _buildProgressSteps(size, isSmallScreen),
//
//         // Form Content
//         Expanded(
//           child: _buildCurrentStep(size, isSmallScreen),
//         ),
//
//         // Navigation Buttons
//         _buildNavigationButtons(size, isSmallScreen),
//       ],
//     );
//   }
//
//   Widget _buildProgressSteps(Size size, bool isSmallScreen) {
//     final steps = ['Personal', 'Experience', 'Template', 'Generate'];
//
//     return Container(
//       height: size.height * 0.1,
//       padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
//       child: Row(
//         children: steps.asMap().entries.map((entry) {
//           final index = entry.key;
//           final step = entry.value;
//           final isActive = index == _currentStep;
//           final isCompleted = index < _currentStep;
//
//           return Expanded(
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         width: size.width * 0.08,
//                         height: size.width * 0.08,
//                         decoration: BoxDecoration(
//                           color: isCompleted
//                               ? const Color(0xFF10B981)
//                               : isActive
//                               ? const Color(0xFFF59E0B)
//                               : Colors.white.withOpacity(0.2),
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: isActive
//                                 ? const Color(0xFFF59E0B)
//                                 : Colors.white.withOpacity(0.3),
//                             width: 2,
//                           ),
//                         ),
//                         child: Center(
//                           child: isCompleted
//                               ? Icon(
//                             Icons.check,
//                             color: Colors.white,
//                             size: size.width * 0.04,
//                           )
//                               : Text(
//                             '${index + 1}',
//                             style: GoogleFonts.poppins(
//                               fontSize: size.width * 0.03,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: size.height * 0.005),
//                       FittedBox(
//                         fit: BoxFit.scaleDown,
//                         child: Text(
//                           step,
//                           style: GoogleFonts.poppins(
//                             fontSize: size.width * 0.025,
//                             color: isActive
//                                 ? const Color(0xFFF59E0B)
//                                 : Colors.white.withOpacity(0.7),
//                             fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (index < steps.length - 1)
//                   Container(
//                     width: size.width * 0.02,
//                     height: 2,
//                     color: isCompleted
//                         ? const Color(0xFF10B981)
//                         : Colors.white.withOpacity(0.2),
//                   ),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _buildCurrentStep(Size size, bool isSmallScreen) {
//     switch (_currentStep) {
//       case 0:
//         return _buildPersonalInfoStep(size, isSmallScreen);
//       case 1:
//         return _buildExperienceStep(size, isSmallScreen);
//       case 2:
//         return _buildTemplateStep(size, isSmallScreen);
//       case 3:
//         return _buildGenerateStep(size, isSmallScreen);
//       default:
//         return _buildPersonalInfoStep(size, isSmallScreen);
//     }
//   }
//
//   Widget _buildPersonalInfoStep(Size size, bool isSmallScreen) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(size.width * 0.04),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Step Title
//             _buildStepHeader(
//               'Personal Information',
//               'Let\'s start with your basic details',
//               '👤',
//               size,
//               isSmallScreen,
//             ),
//
//             SizedBox(height: size.height * 0.03),
//
//             // Form Fields
//             _buildTextField(
//               controller: _nameController,
//               label: 'Full Name',
//               hint: 'Enter your full name',
//               icon: Icons.person,
//               size: size,
//               validator: (value) => value?.isEmpty == true ? 'Required field' : null,
//             ),
//
//             SizedBox(height: size.height * 0.02),
//
//             _buildTextField(
//               controller: _emailController,
//               label: 'Email Address',
//               hint: 'your.email@example.com',
//               icon: Icons.email,
//               keyboardType: TextInputType.emailAddress,
//               size: size,
//               validator: (value) {
//                 if (value?.isEmpty == true) return 'Required field';
//                 if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
//                   return 'Invalid email format';
//                 }
//                 return null;
//               },
//             ),
//
//             SizedBox(height: size.height * 0.02),
//
//             _buildTextField(
//               controller: _phoneController,
//               label: 'Phone Number',
//               hint: '+81 90-1234-5678',
//               icon: Icons.phone,
//               keyboardType: TextInputType.phone,
//               size: size,
//             ),
//
//             SizedBox(height: size.height * 0.02),
//
//             _buildTextField(
//               controller: _addressController,
//               label: 'Address',
//               hint: 'Your current address',
//               icon: Icons.location_on,
//               maxLines: 2,
//               size: size,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildExperienceStep(Size size, bool isSmallScreen) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(size.width * 0.04),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildStepHeader(
//             'Experience & Skills',
//             'Tell us about your background',
//             '💼',
//             size,
//             isSmallScreen,
//           ),
//
//           SizedBox(height: size.height * 0.03),
//
//           _buildTextField(
//             controller: _objectiveController,
//             label: 'Career Objective',
//             hint: 'Describe your career goals and aspirations...',
//             icon: Icons.flag,
//             maxLines: 3,
//             size: size,
//           ),
//
//           SizedBox(height: size.height * 0.02),
//
//           _buildTextField(
//             controller: _experienceController,
//             label: 'Work Experience',
//             hint: 'List your work experience, internships, projects...',
//             icon: Icons.work,
//             maxLines: 5,
//             size: size,
//           ),
//
//           SizedBox(height: size.height * 0.02),
//
//           _buildTextField(
//             controller: _educationController,
//             label: 'Education',
//             hint: 'Your educational background...',
//             icon: Icons.school,
//             maxLines: 3,
//             size: size,
//           ),
//
//           SizedBox(height: size.height * 0.02),
//
//           _buildTextField(
//             controller: _skillsController,
//             label: 'Skills & Languages',
//             hint: 'Technical skills, soft skills, languages...',
//             icon: Icons.star,
//             maxLines: 3,
//             size: size,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTemplateStep(Size size, bool isSmallScreen) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(size.width * 0.04),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildStepHeader(
//             'Choose Template',
//             'Select your preferred style',
//             '🎨',
//             size,
//             isSmallScreen,
//           ),
//
//           SizedBox(height: size.height * 0.03),
//
//           // Template Selection
//           Text(
//             'Resume Template',
//             style: GoogleFonts.poppins(
//               fontSize: size.width * 0.04,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//
//           SizedBox(height: size.height * 0.015),
//
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: isSmallScreen ? 2 : 2,
//               childAspectRatio: 1.2,
//               crossAxisSpacing: size.width * 0.03,
//               mainAxisSpacing: size.width * 0.03,
//             ),
//             itemCount: _templates.length,
//             itemBuilder: (context, index) {
//               final template = _templates[index];
//               final isSelected = _selectedTemplate == template;
//
//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _selectedTemplate = template;
//                   });
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: isSelected
//                         ? const Color(0xFFF59E0B).withOpacity(0.2)
//                         : Colors.white.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: isSelected
//                           ? const Color(0xFFF59E0B)
//                           : Colors.white.withOpacity(0.2),
//                       width: isSelected ? 2 : 1,
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         width: size.width * 0.12,
//                         height: size.width * 0.15,
//                         decoration: BoxDecoration(
//                           color: _getTemplateColor(template).withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Icon(
//                           _getTemplateIcon(template),
//                           color: _getTemplateColor(template),
//                           size: size.width * 0.06,
//                         ),
//                       ),
//                       SizedBox(height: size.height * 0.01),
//                       FittedBox(
//                         fit: BoxFit.scaleDown,
//                         child: Text(
//                           template.toUpperCase(),
//                           style: GoogleFonts.poppins(
//                             fontSize: size.width * 0.03,
//                             fontWeight: FontWeight.bold,
//                             color: isSelected
//                                 ? const Color(0xFFF59E0B)
//                                 : Colors.white.withOpacity(0.8),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//
//           SizedBox(height: size.height * 0.03),
//
//           // Language Selection
//           Text(
//             'Resume Language',
//             style: GoogleFonts.poppins(
//               fontSize: size.width * 0.04,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//
//           SizedBox(height: size.height * 0.015),
//
//           ..._languages.map((language) {
//             final isSelected = _selectedLanguage == language;
//             return Container(
//               margin: EdgeInsets.only(bottom: size.height * 0.01),
//               child: GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _selectedLanguage = language;
//                   });
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.all(size.width * 0.04),
//                   decoration: BoxDecoration(
//                     color: isSelected
//                         ? const Color(0xFFF59E0B).withOpacity(0.1)
//                         : Colors.white.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: isSelected
//                           ? const Color(0xFFF59E0B)
//                           : Colors.white.withOpacity(0.2),
//                       width: isSelected ? 2 : 1,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: size.width * 0.08,
//                         height: size.width * 0.08,
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? const Color(0xFFF59E0B).withOpacity(0.2)
//                               : Colors.white.withOpacity(0.1),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Center(
//                           child: Text(
//                             _getLanguageEmoji(language),
//                             style: TextStyle(fontSize: size.width * 0.04),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: size.width * 0.03),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             _getLanguageTitle(language),
//                             style: GoogleFonts.poppins(
//                               fontSize: size.width * 0.035,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                           Text(
//                             _getLanguageDescription(language),
//                             style: GoogleFonts.poppins(
//                               fontSize: size.width * 0.028,
//                               color: Colors.white.withOpacity(0.7),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildGenerateStep(Size size, bool isSmallScreen) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(size.width * 0.04),
//       child: Column(
//         children: [
//           _buildStepHeader(
//             'Generate Resume',
//             'Review and create your resume',
//             '🚀',
//             size,
//             isSmallScreen,
//           ),
//
//           SizedBox(height: size.height * 0.03),
//
//           // Summary Card
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(size.width * 0.04),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   const Color(0xFFF59E0B).withOpacity(0.1),
//                   const Color(0xFFEC4899).withOpacity(0.1),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: const Color(0xFFF59E0B).withOpacity(0.3),
//                 width: 1,
//               ),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   'Resume Summary',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.045,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.02),
//
//                 ...[
//                   {'label': 'Name', 'value': _nameController.text},
//                   {'label': 'Email', 'value': _emailController.text},
//                   {'label': 'Template', 'value': _selectedTemplate.toUpperCase()},
//                   {'label': 'Language', 'value': _getLanguageTitle(_selectedLanguage)},
//                 ].map((item) => Padding(
//                   padding: EdgeInsets.only(bottom: size.height * 0.01),
//                   child: Row(
//                     children: [
//                       SizedBox(
//                         width: size.width * 0.2,
//                         child: Text(
//                           '${item['label']}:',
//                           style: GoogleFonts.poppins(
//                             fontSize: size.width * 0.03,
//                             color: Colors.white.withOpacity(0.7),
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Text(
//                           item['value']!,
//                           style: GoogleFonts.poppins(
//                             fontSize: size.width * 0.03,
//                             color: Colors.white,
//                             fontWeight: FontWeight.w500,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )).toList(),
//               ],
//             ),
//           ),
//
//           SizedBox(height: size.height * 0.04),
//
//           // Generate Button
//           if (_isGenerating)
//             Column(
//               children: [
//                 SizedBox(
//                   width: size.width * 0.15,
//                   height: size.width * 0.15,
//                   child: CircularProgressIndicator(
//                     valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
//                     strokeWidth: 4,
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.02),
//                 Text(
//                   'AI is creating your resume...',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.04,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.01),
//                 Text(
//                   'This may take a few moments',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.032,
//                     color: Colors.white.withOpacity(0.7),
//                   ),
//                 ),
//               ],
//             )
//           else
//             AnimatedBuilder(
//               animation: _pulseAnimation,
//               builder: (context, child) {
//                 return Transform.scale(
//                   scale: _pulseAnimation.value,
//                   child: SizedBox(
//                     width: double.infinity,
//                     height: size.height * 0.06,
//                     child: ElevatedButton(
//                       onPressed: _generateResume,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFF59E0B),
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         elevation: 5,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.auto_awesome,
//                             size: size.width * 0.05,
//                           ),
//                           SizedBox(width: size.width * 0.02),
//                           FittedBox(
//                             fit: BoxFit.scaleDown,
//                             child: Text(
//                               'Generate AI Resume',
//                               style: GoogleFonts.poppins(
//                                 fontSize: size.width * 0.04,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildResumePreview(Size size, bool isSmallScreen) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(size.width * 0.04),
//       child: Column(
//         children: [
//           // Header
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(size.width * 0.04),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   const Color(0xFF10B981).withOpacity(0.1),
//                   const Color(0xFF06B6D4).withOpacity(0.1),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: const Color(0xFF10B981).withOpacity(0.3),
//                 width: 1,
//               ),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   '✅',
//                   style: TextStyle(fontSize: size.width * 0.12),
//                 ),
//                 SizedBox(height: size.height * 0.02),
//                 FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Text(
//                     'Resume Generated!',
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.06,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.01),
//                 FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Text(
//                     'Your professional resume is ready',
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.035,
//                       color: Colors.white.withOpacity(0.8),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           SizedBox(height: size.height * 0.03),
//
//           // Preview Card
//           Container(
//             width: double.infinity,
//             constraints: BoxConstraints(
//               minHeight: size.height * 0.3,
//             ),
//             padding: EdgeInsets.all(size.width * 0.04),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Name
//                 Text(
//                   _nameController.text,
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.05,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.005),
//                 Text(
//                   _emailController.text,
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.032,
//                     color: Colors.black54,
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.02),
//
//                 // Sample content
//                 Text(
//                   'OBJECTIVE',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.035,
//                     fontWeight: FontWeight.bold,
//                     color: const Color(0xFFF59E0B),
//                   ),
//                 ),
//                 Text(
//                   _objectiveController.text.isNotEmpty
//                       ? _objectiveController.text
//                       : 'Seeking opportunities to apply my skills in a dynamic environment...',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.03,
//                     color: Colors.black87,
//                   ),
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//
//                 SizedBox(height: size.height * 0.015),
//
//                 Text(
//                   'EXPERIENCE',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.035,
//                     fontWeight: FontWeight.bold,
//                     color: const Color(0xFFF59E0B),
//                   ),
//                 ),
//                 Text(
//                   _experienceController.text.isNotEmpty
//                       ? _experienceController.text
//                       : 'Previous experience and achievements...',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.03,
//                     color: Colors.black87,
//                   ),
//                   maxLines: 4,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//
//           SizedBox(height: size.height * 0.03),
//
//           // Action Buttons
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: _downloadResume,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF10B981),
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.download, size: size.width * 0.04),
//                       SizedBox(width: size.width * 0.02),
//                       FittedBox(
//                         fit: BoxFit.scaleDown,
//                         child: Text(
//                           'Download PDF',
//                           style: GoogleFonts.poppins(
//                             fontSize: size.width * 0.032,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(width: size.width * 0.03),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: _shareResume,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF06B6D4),
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.share, size: size.width * 0.04),
//                       SizedBox(width: size.width * 0.02),
//                       FittedBox(
//                         fit: BoxFit.scaleDown,
//                         child: Text(
//                           'Share',
//                           style: GoogleFonts.poppins(
//                             fontSize: size.width * 0.032,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           SizedBox(height: size.height * 0.02),
//
//           // Create New Button
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: _createNewResume,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white.withOpacity(0.1),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   side: BorderSide(color: Colors.white.withOpacity(0.3)),
//                 ),
//                 padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
//               ),
//               child: FittedBox(
//                 fit: BoxFit.scaleDown,
//                 child: Text(
//                   'Create New Resume',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.035,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStepHeader(String title, String subtitle, String emoji, Size size, bool isSmallScreen) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(size.width * 0.04),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: size.width * 0.12,
//             height: size.width * 0.12,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF59E0B).withOpacity(0.2),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Center(
//               child: Text(
//                 emoji,
//                 style: TextStyle(fontSize: size.width * 0.06),
//               ),
//             ),
//           ),
//           SizedBox(width: size.width * 0.03),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Text(
//                     title,
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.045,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 Text(
//                   subtitle,
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.032,
//                     color: Colors.white.withOpacity(0.7),
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required IconData icon,
//     required Size size,
//     TextInputType? keyboardType,
//     int? maxLines,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       maxLines: maxLines ?? 1,
//       validator: validator,
//       style: GoogleFonts.poppins(
//         color: Colors.white,
//         fontSize: size.width * 0.035,
//       ),
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         labelStyle: GoogleFonts.poppins(
//           color: Colors.white.withOpacity(0.7),
//           fontSize: size.width * 0.032,
//         ),
//         hintStyle: GoogleFonts.poppins(
//           color: Colors.white.withOpacity(0.5),
//           fontSize: size.width * 0.03,
//         ),
//         prefixIcon: Icon(
//           icon,
//           color: const Color(0xFFF59E0B),
//           size: size.width * 0.05,
//         ),
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.05),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
//         ),
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: size.width * 0.04,
//           vertical: size.height * 0.015,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNavigationButtons(Size size, bool isSmallScreen) {
//     return Container(
//       padding: EdgeInsets.all(size.width * 0.04),
//       child: Row(
//         children: [
//           // Back Button
//           if (_currentStep > 0)
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: _previousStep,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white.withOpacity(0.1),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     side: BorderSide(color: Colors.white.withOpacity(0.3)),
//                   ),
//                   padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
//                 ),
//                 child: FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Text(
//                     'Back',
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.035,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//           if (_currentStep > 0) SizedBox(width: size.width * 0.03),
//
//           // Next Button
//           if (_currentStep < 3)
//             Expanded(
//               flex: _currentStep == 0 ? 1 : 1,
//               child: ElevatedButton(
//                 onPressed: _nextStep,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFF59E0B),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
//                 ),
//                 child: FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Text(
//                     'Next',
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.035,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   // Helper Methods
//   Color _getTemplateColor(String template) {
//     switch (template) {
//       case 'modern': return const Color(0xFF10B981);
//       case 'classic': return const Color(0xFF06B6D4);
//       case 'creative': return const Color(0xFFEC4899);
//       case 'minimal': return const Color(0xFF8B5CF6);
//       default: return const Color(0xFF10B981);
//     }
//   }
//
//   IconData _getTemplateIcon(String template) {
//     switch (template) {
//       case 'modern': return Icons.laptop;
//       case 'classic': return Icons.business;
//       case 'creative': return Icons.palette;
//       case 'minimal': return Icons.panorama_fish_eye;
//       default: return Icons.description;
//     }
//   }
//
//   String _getLanguageEmoji(String language) {
//     switch (language) {
//       case 'english': return '🇺🇸';
//       case 'japanese': return '🇯🇵';
//       case 'both': return '🌍';
//       default: return '🇺🇸';
//     }
//   }
//
//   String _getLanguageTitle(String language) {
//     switch (language) {
//       case 'english': return 'English Only';
//       case 'japanese': return 'Japanese Only';
//       case 'both': return 'Bilingual';
//       default: return 'English Only';
//     }
//   }
//
//   String _getLanguageDescription(String language) {
//     switch (language) {
//       case 'english': return 'Standard international format';
//       case 'japanese': return 'Japanese 履歴書 format';
//       case 'both': return 'Both languages included';
//       default: return 'Standard format';
//     }
//   }
//
//   // Action Methods
//   void _nextStep() {
//     if (_currentStep == 0 && !_formKey.currentState!.validate()) {
//       return;
//     }
//
//     if (_currentStep < 3) {
//       setState(() {
//         _currentStep++;
//       });
//     }
//   }
//
//   void _previousStep() {
//     if (_currentStep > 0) {
//       setState(() {
//         _currentStep--;
//       });
//     }
//   }
//
//   Future<void> _generateResume() async {
//     setState(() {
//       _isGenerating = true;
//     });
//
//     // Simulate AI processing
//     await Future.delayed(const Duration(seconds: 3));
//
//     setState(() {
//       _isGenerating = false;
//       _resumeGenerated = true;
//       _generatedResume = ResumeData(
//         name: _nameController.text,
//         email: _emailController.text,
//         phone: _phoneController.text,
//         address: _addressController.text,
//         objective: _objectiveController.text,
//         experience: _experienceController.text,
//         education: _educationController.text,
//         skills: _skillsController.text,
//         template: _selectedTemplate,
//         language: _selectedLanguage,
//       );
//     });
//
//     _showMessage('Resume generated successfully! 🎉');
//   }
//
//   void _downloadResume() {
//     // TODO: Implement PDF generation and download
//     _showMessage('Download functionality coming soon! 📄');
//   }
//
//   void _shareResume() {
//     // TODO: Implement sharing functionality
//     _showMessage('Share functionality coming soon! 📤');
//   }
//
//   void _createNewResume() {
//     setState(() {
//       _resumeGenerated = false;
//       _currentStep = 0;
//       _selectedTemplate = 'modern';
//       _selectedLanguage = 'english';
//     });
//
//     // Clear form controllers
//     _nameController.clear();
//     _emailController.clear();
//     _phoneController.clear();
//     _addressController.clear();
//     _objectiveController.clear();
//     _experienceController.clear();
//     _educationController.clear();
//     _skillsController.clear();
//
//     _loadUserData();
//   }
//
//   void _showMessage(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: const Color(0xFFF59E0B),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
// }
//
// // Resume Data Model
// class ResumeData {
//   final String name;
//   final String email;
//   final String phone;
//   final String address;
//   final String objective;
//   final String experience;
//   final String education;
//   final String skills;
//   final String template;
//   final String language;
//
//   ResumeData({
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.address,
//     required this.objective,
//     required this.experience,
//     required this.education,
//     required this.skills,
//     required this.template,
//     required this.language,
//   });
// }