// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:math' as math;
//
// class GrammarQuizScreen extends StatefulWidget {
//   const GrammarQuizScreen({super.key});
//
//   @override
//   State<GrammarQuizScreen> createState() => _GrammarQuizScreenState();
// }
//
// class _GrammarQuizScreenState extends State<GrammarQuizScreen>
//     with TickerProviderStateMixin {
//   // Animation Controllers
//   late AnimationController _slideController;
//   late AnimationController _pulseController;
//   late AnimationController _progressController;
//
//   late Animation<double> _slideAnimation;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _progressAnimation;
//
//   // Quiz State
//   String _selectedLevel = 'N5';
//   bool _quizStarted = false;
//   bool _isLoading = false;
//   int _currentQuestionIndex = 0;
//   int _correctAnswers = 0;
//   int _selectedAnswerIndex = -1;
//   bool _showResult = false;
//   bool _quizCompleted = false;
//
//   // Quiz Data
//   List<QuizQuestion> _questions = [];
//   QuizQuestion? get _currentQuestion =>
//       _questions.isNotEmpty && _currentQuestionIndex < _questions.length
//           ? _questions[_currentQuestionIndex]
//           : null;
//
//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//     _loadQuizData();
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
//     _progressController = AnimationController(
//       duration: const Duration(milliseconds: 800),
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
//     _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
//     );
//
//     _slideController.forward();
//     _pulseController.repeat(reverse: true);
//   }
//
//   void _loadQuizData() {
//     _questions = _getSampleQuestions(_selectedLevel);
//   }
//
//   @override
//   void dispose() {
//     _slideController.dispose();
//     _pulseController.dispose();
//     _progressController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isSmallScreen = size.width < 360;
//     final safePadding = MediaQuery.of(context).padding;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1117),
//       body: Container(
//         width: size.width,
//         height: size.height,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF0D1117),
//               Color(0xFF1C2128),
//               Color(0xFF2D1B69),
//               Color(0xFF06B6D4),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header - Fixed height
//               _buildHeader(size, isSmallScreen),
//
//               // Content - Takes remaining space
//               Expanded(
//                 child: _buildContent(size, isSmallScreen),
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
//       height: size.height * 0.12,
//       padding: EdgeInsets.symmetric(
//         horizontal: size.width * 0.04,
//         vertical: size.height * 0.01,
//       ),
//       child: SlideTransition(
//         position: Tween<Offset>(
//           begin: const Offset(0, -1),
//           end: Offset.zero,
//         ).animate(_slideAnimation),
//         child: Row(
//           children: [
//             // Back Button
//             GestureDetector(
//               onTap: () => Navigator.of(context).pop(),
//               child: Container(
//                 width: size.width * 0.1,
//                 height: size.width * 0.1,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: Colors.white.withOpacity(0.2),
//                     width: 1,
//                   ),
//                 ),
//                 child: Icon(
//                   Icons.arrow_back_ios_new,
//                   color: Colors.white,
//                   size: size.width * 0.04,
//                 ),
//               ),
//             ),
//
//             SizedBox(width: size.width * 0.03),
//
//             // Title Section
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: Text(
//                       'Grammar Quiz',
//                       style: GoogleFonts.poppins(
//                         fontSize: size.width * 0.055,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: Text(
//                       'Test your Japanese grammar skills',
//                       style: GoogleFonts.poppins(
//                         fontSize: size.width * 0.028,
//                         color: Colors.white.withOpacity(0.7),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Level Badge
//             Container(
//               constraints: BoxConstraints(
//                 minWidth: size.width * 0.12,
//                 maxWidth: size.width * 0.15,
//               ),
//               padding: EdgeInsets.symmetric(
//                 horizontal: size.width * 0.02,
//                 vertical: size.height * 0.008,
//               ),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Center(
//                 child: FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Text(
//                     _selectedLevel,
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.03,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildContent(Size size, bool isSmallScreen) {
//     if (!_quizStarted) {
//       return _buildQuizSetup(size, isSmallScreen);
//     } else if (_quizCompleted) {
//       return _buildQuizResults(size, isSmallScreen);
//     } else {
//       return _buildQuizQuestion(size, isSmallScreen);
//     }
//   }
//
//   Widget _buildQuizSetup(Size size, bool isSmallScreen) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(size.width * 0.04),
//       child: Column(
//         children: [
//           // Welcome Section
//           Container(
//             width: double.infinity,
//             constraints: BoxConstraints(
//               minHeight: size.height * 0.15,
//             ),
//             padding: EdgeInsets.all(size.width * 0.04),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   const Color(0xFF06B6D4).withOpacity(0.1),
//                   const Color(0xFF8B5CF6).withOpacity(0.1),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: const Color(0xFF06B6D4).withOpacity(0.3),
//                 width: 1,
//               ),
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       width: size.width * 0.12,
//                       height: size.width * 0.12,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF06B6D4).withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Center(
//                         child: Text(
//                           '📚',
//                           style: TextStyle(fontSize: size.width * 0.06),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: size.width * 0.03),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           FittedBox(
//                             fit: BoxFit.scaleDown,
//                             child: Text(
//                               'Ready to test your grammar?',
//                               style: GoogleFonts.poppins(
//                                 fontSize: size.width * 0.045,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: size.height * 0.005),
//                           Text(
//                             'Choose your JLPT level and start learning!',
//                             style: GoogleFonts.poppins(
//                               fontSize: size.width * 0.032,
//                               color: Colors.white.withOpacity(0.7),
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           SizedBox(height: size.height * 0.03),
//
//           // Level Selection
//           _buildLevelSelection(size, isSmallScreen),
//
//           SizedBox(height: size.height * 0.03),
//
//           // Quiz Info
//           _buildQuizInfo(size, isSmallScreen),
//
//           SizedBox(height: size.height * 0.04),
//
//           // Start Button
//           _buildStartButton(size, isSmallScreen),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLevelSelection(Size size, bool isSmallScreen) {
//     final levels = [
//       {'level': 'N5', 'desc': 'Beginner', 'color': const Color(0xFF10B981)},
//       {'level': 'N4', 'desc': 'Elementary', 'color': const Color(0xFF06B6D4)},
//       {'level': 'N3', 'desc': 'Intermediate', 'color': const Color(0xFF8B5CF6)},
//       {'level': 'N2', 'desc': 'Upper-Int', 'color': const Color(0xFFEC4899)},
//       {'level': 'N1', 'desc': 'Advanced', 'color': const Color(0xFFF59E0B)},
//     ];
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Select Your Level',
//           style: GoogleFonts.poppins(
//             fontSize: size.width * 0.045,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         SizedBox(height: size.height * 0.015),
//
//         // Level grid - 2 columns for better fit
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: isSmallScreen ? 2 : 3,
//             childAspectRatio: 2.2,
//             crossAxisSpacing: size.width * 0.02,
//             mainAxisSpacing: size.width * 0.02,
//           ),
//           itemCount: levels.length,
//           itemBuilder: (context, index) {
//             final level = levels[index];
//             final isSelected = _selectedLevel == level['level'];
//             final color = level['color'] as Color;
//
//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _selectedLevel = level['level'] as String;
//                 });
//                 _loadQuizData();
//               },
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: isSelected ? color : color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: color.withOpacity(0.3),
//                     width: isSelected ? 2 : 1,
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     FittedBox(
//                       fit: BoxFit.scaleDown,
//                       child: Text(
//                         level['level'] as String,
//                         style: GoogleFonts.poppins(
//                           fontSize: size.width * 0.035,
//                           fontWeight: FontWeight.bold,
//                           color: isSelected ? Colors.white : color,
//                         ),
//                       ),
//                     ),
//                     FittedBox(
//                       fit: BoxFit.scaleDown,
//                       child: Text(
//                         level['desc'] as String,
//                         style: GoogleFonts.poppins(
//                           fontSize: size.width * 0.025,
//                           color: isSelected
//                               ? Colors.white.withOpacity(0.8)
//                               : color.withOpacity(0.7),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildQuizInfo(Size size, bool isSmallScreen) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(size.width * 0.04),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.1),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.info_outline,
//                 color: const Color(0xFF06B6D4),
//                 size: size.width * 0.05,
//               ),
//               SizedBox(width: size.width * 0.02),
//               Expanded(
//                 child: Text(
//                   'Quiz Information',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.04,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: size.height * 0.015),
//
//           // Info items
//           ...[
//             {'icon': '📝', 'text': '10 multiple choice questions'},
//             {'icon': '⏱️', 'text': 'No time limit - learn at your pace'},
//             {'icon': '💡', 'text': 'Instant feedback and explanations'},
//             {'icon': '🏆', 'text': 'Track your progress and improve'},
//           ].map((item) => Padding(
//             padding: EdgeInsets.only(bottom: size.height * 0.008),
//             child: Row(
//               children: [
//                 Text(
//                   item['icon']!,
//                   style: TextStyle(fontSize: size.width * 0.04),
//                 ),
//                 SizedBox(width: size.width * 0.03),
//                 Expanded(
//                   child: Text(
//                     item['text']!,
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.032,
//                       color: Colors.white.withOpacity(0.8),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           )).toList(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStartButton(Size size, bool isSmallScreen) {
//     return AnimatedBuilder(
//       animation: _pulseAnimation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _pulseAnimation.value,
//           child: SizedBox(
//             width: double.infinity,
//             height: size.height * 0.06,
//             child: ElevatedButton(
//               onPressed: _isLoading ? null : _startQuiz,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF06B6D4),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 5,
//               ),
//               child: _isLoading
//                   ? SizedBox(
//                 width: size.width * 0.05,
//                 height: size.width * 0.05,
//                 child: const CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 ),
//               )
//                   : Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.play_arrow,
//                     size: size.width * 0.05,
//                   ),
//                   SizedBox(width: size.width * 0.02),
//                   FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: Text(
//                       'Start Quiz',
//                       style: GoogleFonts.poppins(
//                         fontSize: size.width * 0.04,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildQuizQuestion(Size size, bool isSmallScreen) {
//     if (_currentQuestion == null) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     final progress = (_currentQuestionIndex + 1) / _questions.length;
//
//     return Column(
//       children: [
//         // Progress Bar
//         Container(
//           padding: EdgeInsets.all(size.width * 0.04),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.032,
//                       color: Colors.white.withOpacity(0.7),
//                     ),
//                   ),
//                   Text(
//                     'Correct: $_correctAnswers',
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.032,
//                       color: const Color(0xFF10B981),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: size.height * 0.01),
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: LinearProgressIndicator(
//                   value: progress,
//                   backgroundColor: Colors.white.withOpacity(0.2),
//                   valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
//                   minHeight: size.height * 0.008,
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         // Question Content
//         Expanded(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
//             child: Column(
//               children: [
//                 // Question Card
//                 Container(
//                   width: double.infinity,
//                   constraints: BoxConstraints(
//                     minHeight: size.height * 0.15,
//                   ),
//                   padding: EdgeInsets.all(size.width * 0.04),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         const Color(0xFF06B6D4).withOpacity(0.1),
//                         const Color(0xFF8B5CF6).withOpacity(0.1),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: const Color(0xFF06B6D4).withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       if (_currentQuestion!.grammarPoint.isNotEmpty) ...[
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: size.width * 0.02,
//                             vertical: size.height * 0.005,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF06B6D4).withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             _currentQuestion!.grammarPoint,
//                             style: GoogleFonts.poppins(
//                               fontSize: size.width * 0.025,
//                               color: const Color(0xFF06B6D4),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: size.height * 0.015),
//                       ],
//                       Text(
//                         _currentQuestion!.question,
//                         style: GoogleFonts.poppins(
//                           fontSize: size.width * 0.04,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                           height: 1.4,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 SizedBox(height: size.height * 0.02),
//
//                 // Answer Options
//                 ..._currentQuestion!.options.asMap().entries.map((entry) {
//                   final index = entry.key;
//                   final option = entry.value;
//                   final isSelected = _selectedAnswerIndex == index;
//                   final isCorrect = index == _currentQuestion!.correctAnswerIndex;
//
//                   Color? backgroundColor;
//                   Color? borderColor;
//
//                   if (_showResult) {
//                     if (isCorrect) {
//                       backgroundColor = const Color(0xFF10B981);
//                       borderColor = const Color(0xFF10B981);
//                     } else if (isSelected && !isCorrect) {
//                       backgroundColor = Colors.red;
//                       borderColor = Colors.red;
//                     } else {
//                       backgroundColor = Colors.white.withOpacity(0.05);
//                       borderColor = Colors.white.withOpacity(0.2);
//                     }
//                   } else {
//                     backgroundColor = isSelected
//                         ? const Color(0xFF06B6D4).withOpacity(0.2)
//                         : Colors.white.withOpacity(0.05);
//                     borderColor = isSelected
//                         ? const Color(0xFF06B6D4)
//                         : Colors.white.withOpacity(0.2);
//                   }
//
//                   return Container(
//                     margin: EdgeInsets.only(bottom: size.height * 0.015),
//                     child: GestureDetector(
//                       onTap: _showResult ? null : () => _selectAnswer(index),
//                       child: Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.all(size.width * 0.04),
//                         decoration: BoxDecoration(
//                           color: backgroundColor,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: borderColor!,
//                             width: isSelected || (_showResult && isCorrect) ? 2 : 1,
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Container(
//                               width: size.width * 0.08,
//                               height: size.width * 0.08,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: (_showResult && isCorrect) || isSelected
//                                     ? Colors.white.withOpacity(0.2)
//                                     : Colors.transparent,
//                                 border: Border.all(
//                                   color: Colors.white.withOpacity(0.5),
//                                   width: 1,
//                                 ),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   String.fromCharCode(65 + index), // A, B, C, D
//                                   style: GoogleFonts.poppins(
//                                     fontSize: size.width * 0.035,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: size.width * 0.03),
//                             Expanded(
//                               child: Text(
//                                 option,
//                                 style: GoogleFonts.poppins(
//                                   fontSize: size.width * 0.035,
//                                   color: Colors.white,
//                                   height: 1.3,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//
//                 // Explanation (shown after answer)
//                 if (_showResult && _currentQuestion!.explanation.isNotEmpty) ...[
//                   SizedBox(height: size.height * 0.02),
//                   Container(
//                     width: double.infinity,
//                     padding: EdgeInsets.all(size.width * 0.04),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF8B5CF6).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: const Color(0xFF8B5CF6).withOpacity(0.3),
//                         width: 1,
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.lightbulb_outline,
//                               color: const Color(0xFF8B5CF6),
//                               size: size.width * 0.045,
//                             ),
//                             SizedBox(width: size.width * 0.02),
//                             Text(
//                               'Explanation',
//                               style: GoogleFonts.poppins(
//                                 fontSize: size.width * 0.035,
//                                 fontWeight: FontWeight.bold,
//                                 color: const Color(0xFF8B5CF6),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: size.height * 0.01),
//                         Text(
//                           _currentQuestion!.explanation,
//                           style: GoogleFonts.poppins(
//                             fontSize: size.width * 0.032,
//                             color: Colors.white.withOpacity(0.9),
//                             height: 1.4,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//
//                 SizedBox(height: size.height * 0.03),
//               ],
//             ),
//           ),
//         ),
//
//         // Next Button
//         if (_showResult)
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(size.width * 0.04),
//             child: ElevatedButton(
//               onPressed: _nextQuestion,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF06B6D4),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
//               ),
//               child: Text(
//                 _currentQuestionIndex < _questions.length - 1 ? 'Next Question' : 'View Results',
//                 style: GoogleFonts.poppins(
//                   fontSize: size.width * 0.04,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildQuizResults(Size size, bool isSmallScreen) {
//     final percentage = (_correctAnswers / _questions.length * 100).round();
//     final isPassed = percentage >= 70;
//
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(size.width * 0.04),
//       child: Column(
//         children: [
//           // Results Header
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(size.width * 0.05),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: isPassed
//                     ? [
//                   const Color(0xFF10B981).withOpacity(0.1),
//                   const Color(0xFF06B6D4).withOpacity(0.1),
//                 ]
//                     : [
//                   const Color(0xFFEC4899).withOpacity(0.1),
//                   const Color(0xFFF59E0B).withOpacity(0.1),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: isPassed
//                     ? const Color(0xFF10B981).withOpacity(0.3)
//                     : const Color(0xFFEC4899).withOpacity(0.3),
//                 width: 1,
//               ),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   isPassed ? '🎉' : '💪',
//                   style: TextStyle(fontSize: size.width * 0.15),
//                 ),
//                 SizedBox(height: size.height * 0.02),
//                 FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Text(
//                     isPassed ? 'Congratulations!' : 'Keep Practicing!',
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
//                     'You scored $percentage%',
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.05,
//                       fontWeight: FontWeight.w600,
//                       color: isPassed ? const Color(0xFF10B981) : const Color(0xFFEC4899),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           SizedBox(height: size.height * 0.03),
//
//           // Stats
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(size.width * 0.04),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.05),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _buildStatItem('Correct', '$_correctAnswers', const Color(0xFF10B981), size),
//                     _buildStatItem('Wrong', '${_questions.length - _correctAnswers}', const Color(0xFFEC4899), size),
//                     _buildStatItem('Total', '${_questions.length}', const Color(0xFF06B6D4), size),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           SizedBox(height: size.height * 0.04),
//
//           // Action Buttons
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: _retryQuiz,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white.withOpacity(0.1),
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       side: BorderSide(color: Colors.white.withOpacity(0.3)),
//                     ),
//                     padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
//                   ),
//                   child: FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: Text(
//                       'Try Again',
//                       style: GoogleFonts.poppins(
//                         fontSize: size.width * 0.035,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: size.width * 0.03),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: _newQuiz,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF06B6D4),
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
//                   ),
//                   child: FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: Text(
//                       'New Quiz',
//                       style: GoogleFonts.poppins(
//                         fontSize: size.width * 0.035,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatItem(String label, String value, Color color, Size size) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: GoogleFonts.poppins(
//             fontSize: size.width * 0.05,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: size.width * 0.03,
//             color: Colors.white.withOpacity(0.7),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // Action Methods
//   void _startQuiz() {
//     setState(() {
//       _isLoading = true;
//     });
//
//     // Simulate loading
//     Future.delayed(const Duration(seconds: 1), () {
//       setState(() {
//         _quizStarted = true;
//         _isLoading = false;
//         _currentQuestionIndex = 0;
//         _correctAnswers = 0;
//         _selectedAnswerIndex = -1;
//         _showResult = false;
//         _quizCompleted = false;
//       });
//     });
//   }
//
//   void _selectAnswer(int index) {
//     setState(() {
//       _selectedAnswerIndex = index;
//       _showResult = true;
//     });
//
//     if (index == _currentQuestion!.correctAnswerIndex) {
//       _correctAnswers++;
//     }
//   }
//
//   void _nextQuestion() {
//     if (_currentQuestionIndex < _questions.length - 1) {
//       setState(() {
//         _currentQuestionIndex++;
//         _selectedAnswerIndex = -1;
//         _showResult = false;
//       });
//     } else {
//       setState(() {
//         _quizCompleted = true;
//       });
//     }
//   }
//
//   void _retryQuiz() {
//     setState(() {
//       _currentQuestionIndex = 0;
//       _correctAnswers = 0;
//       _selectedAnswerIndex = -1;
//       _showResult = false;
//       _quizCompleted = false;
//     });
//   }
//
//   void _newQuiz() {
//     setState(() {
//       _quizStarted = false;
//       _currentQuestionIndex = 0;
//       _correctAnswers = 0;
//       _selectedAnswerIndex = -1;
//       _showResult = false;
//       _quizCompleted = false;
//     });
//     _loadQuizData();
//   }
//
//   List<QuizQuestion> _getSampleQuestions(String level) {
//     // Sample questions for different levels
//     final Map<String, List<QuizQuestion>> questionBank = {
//       'N5': [
//         QuizQuestion(
//           question: 'I _____ to school every day.',
//           options: ['go', 'goes', 'going', 'went'],
//           correctAnswerIndex: 0,
//           explanation: 'Use "go" for present habitual actions with "I".',
//           grammarPoint: 'Present Tense',
//         ),
//         QuizQuestion(
//           question: 'This is _____ book.',
//           options: ['a', 'an', 'the', 'some'],
//           correctAnswerIndex: 0,
//           explanation: 'Use "a" before singular countable nouns beginning with consonants.',
//           grammarPoint: 'Articles',
//         ),
//         // Add more N5 questions...
//       ],
//       'N4': [
//         QuizQuestion(
//           question: 'If it _____ tomorrow, we will stay home.',
//           options: ['rain', 'rains', 'rained', 'raining'],
//           correctAnswerIndex: 1,
//           explanation: 'In conditional sentences, use present tense after "if".',
//           grammarPoint: 'Conditionals',
//         ),
//         // Add more N4 questions...
//       ],
//       // Add more levels...
//     };
//
//     return questionBank[level] ?? questionBank['N5']!;
//   }
// }
//
// // Quiz Question Model
// class QuizQuestion {
//   final String question;
//   final List<String> options;
//   final int correctAnswerIndex;
//   final String explanation;
//   final String grammarPoint;
//
//   QuizQuestion({
//     required this.question,
//     required this.options,
//     required this.correctAnswerIndex,
//     required this.explanation,
//     required this.grammarPoint,
//   });
// }


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class GrammarQuizScreen extends StatefulWidget {
  const GrammarQuizScreen({super.key});

  @override
  State<GrammarQuizScreen> createState() => _GrammarQuizScreenState();
}

class _GrammarQuizScreenState extends State<GrammarQuizScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _slideController;
  late AnimationController _pulseController;

  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // Quiz State
  String _selectedLevel = 'N5';
  bool _quizStarted = false;
  bool _isLoading = false;
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _selectedAnswerIndex = -1;
  bool _showResult = false;
  bool _quizCompleted = false;

  // Quiz Data
  List<QuizQuestion> _questions = [];
  QuizQuestion? get _currentQuestion =>
      _questions.isNotEmpty && _currentQuestionIndex < _questions.length
          ? _questions[_currentQuestionIndex]
          : null;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadQuizData();
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

  void _loadQuizData() {
    _questions = _getSampleQuestions(_selectedLevel);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360 || size.height < 640;

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
              Color(0xFF06B6D4),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(size, isSmallScreen),
              // Content
              Expanded(
                child: _buildContent(size, isSmallScreen),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size, bool isSmallScreen) {
    return Container(
      height: size.height * 0.1,
      padding: EdgeInsets.all(size.width * 0.04),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
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
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(width: size.width * 0.03),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Grammar Quiz',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.055,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Test your Japanese grammar skills',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.028,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Level Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.03,
              vertical: size.height * 0.01,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _selectedLevel,
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.03,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Size size, bool isSmallScreen) {
    if (!_quizStarted) {
      return _buildQuizSetup(size, isSmallScreen);
    } else if (_quizCompleted) {
      return _buildQuizResults(size, isSmallScreen);
    } else {
      return _buildQuizQuestion(size, isSmallScreen);
    }
  }

  Widget _buildQuizSetup(Size size, bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF06B6D4).withOpacity(0.1),
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF06B6D4).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: size.width * 0.12,
                      height: size.width * 0.12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF06B6D4).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '📚',
                          style: TextStyle(fontSize: size.width * 0.06),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ready to test your grammar?',
                            style: GoogleFonts.poppins(
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: size.height * 0.005),
                          Text(
                            'Choose your JLPT level and start learning!',
                            style: GoogleFonts.poppins(
                              fontSize: size.width * 0.032,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: size.height * 0.03),

          // Level Selection
          _buildLevelSelection(size, isSmallScreen),

          SizedBox(height: size.height * 0.03),

          // Quiz Info
          _buildQuizInfo(size, isSmallScreen),

          SizedBox(height: size.height * 0.04),

          // Start Button
          _buildStartButton(size, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildLevelSelection(Size size, bool isSmallScreen) {
    final levels = [
      {'level': 'N5', 'desc': 'Beginner', 'color': const Color(0xFF10B981)},
      {'level': 'N4', 'desc': 'Elementary', 'color': const Color(0xFF06B6D4)},
      {'level': 'N3', 'desc': 'Intermediate', 'color': const Color(0xFF8B5CF6)},
      {'level': 'N2', 'desc': 'Upper-Int', 'color': const Color(0xFFEC4899)},
      {'level': 'N1', 'desc': 'Advanced', 'color': const Color(0xFFF59E0B)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Level',
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.045,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: size.height * 0.015),

        // Level options
        Wrap(
          spacing: size.width * 0.02,
          runSpacing: size.width * 0.02,
          children: levels.map((level) {
            final isSelected = _selectedLevel == level['level'];
            final color = level['color'] as Color;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedLevel = level['level'] as String;
                });
                _loadQuizData();
              },
              child: Container(
                width: (size.width - size.width * 0.1) / 3,
                height: size.height * 0.08,
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      level['level'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.035,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : color,
                      ),
                    ),
                    Text(
                      level['desc'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.025,
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : color.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuizInfo(Size size, bool isSmallScreen) {
    return Container(
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
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF06B6D4),
                size: size.width * 0.05,
              ),
              SizedBox(width: size.width * 0.02),
              Text(
                'Quiz Information',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.015),

          // Info items
          ...[
            {'icon': '📝', 'text': '10 multiple choice questions'},
            {'icon': '⏱️', 'text': 'No time limit - learn at your pace'},
            {'icon': '💡', 'text': 'Instant feedback and explanations'},
            {'icon': '🏆', 'text': 'Track your progress and improve'},
          ].map((item) => Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.008),
            child: Row(
              children: [
                Text(
                  item['icon']!,
                  style: TextStyle(fontSize: size.width * 0.04),
                ),
                SizedBox(width: size.width * 0.03),
                Expanded(
                  child: Text(
                    item['text']!,
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.032,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildStartButton(Size size, bool isSmallScreen) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: SizedBox(
            width: double.infinity,
            height: size.height * 0.06,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _startQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06B6D4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    'Start Quiz',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizQuestion(Size size, bool isSmallScreen) {
    if (_currentQuestion == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Column(
      children: [
        // Progress Bar
        Container(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.032,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    'Correct: $_correctAnswers',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.032,
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
                minHeight: size.height * 0.008,
              ),
            ],
          ),
        ),

        // Question Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            child: Column(
              children: [
                // Question Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(size.width * 0.04),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF06B6D4).withOpacity(0.1),
                        const Color(0xFF8B5CF6).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF06B6D4).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_currentQuestion!.grammarPoint.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.02,
                            vertical: size.height * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF06B6D4).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _currentQuestion!.grammarPoint,
                            style: GoogleFonts.poppins(
                              fontSize: size.width * 0.025,
                              color: const Color(0xFF06B6D4),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.015),
                      ],
                      Text(
                        _currentQuestion!.question,
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                // Answer Options
                ..._currentQuestion!.options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final isSelected = _selectedAnswerIndex == index;
                  final isCorrect = index == _currentQuestion!.correctAnswerIndex;

                  Color backgroundColor;
                  Color borderColor;

                  if (_showResult) {
                    if (isCorrect) {
                      backgroundColor = const Color(0xFF10B981);
                      borderColor = const Color(0xFF10B981);
                    } else if (isSelected && !isCorrect) {
                      backgroundColor = Colors.red;
                      borderColor = Colors.red;
                    } else {
                      backgroundColor = Colors.white.withOpacity(0.05);
                      borderColor = Colors.white.withOpacity(0.2);
                    }
                  } else {
                    backgroundColor = isSelected
                        ? const Color(0xFF06B6D4).withOpacity(0.2)
                        : Colors.white.withOpacity(0.05);
                    borderColor = isSelected
                        ? const Color(0xFF06B6D4)
                        : Colors.white.withOpacity(0.2);
                  }

                  return Container(
                    margin: EdgeInsets.only(bottom: size.height * 0.015),
                    child: GestureDetector(
                      onTap: _showResult ? null : () => _selectAnswer(index),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(size.width * 0.04),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: borderColor,
                            width: isSelected || (_showResult && isCorrect) ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: size.width * 0.08,
                              height: size.width * 0.08,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (_showResult && isCorrect) || isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index), // A, B, C, D
                                  style: GoogleFonts.poppins(
                                    fontSize: size.width * 0.035,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 0.03),
                            Expanded(
                              child: Text(
                                option,
                                style: GoogleFonts.poppins(
                                  fontSize: size.width * 0.035,
                                  color: Colors.white,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),

                // Explanation
                if (_showResult && _currentQuestion!.explanation.isNotEmpty) ...[
                  SizedBox(height: size.height * 0.02),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(size.width * 0.04),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: const Color(0xFF8B5CF6),
                              size: size.width * 0.045,
                            ),
                            SizedBox(width: size.width * 0.02),
                            Text(
                              'Explanation',
                              style: GoogleFonts.poppins(
                                fontSize: size.width * 0.035,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF8B5CF6),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.01),
                        Text(
                          _currentQuestion!.explanation,
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.032,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: size.height * 0.03),
              ],
            ),
          ),
        ),

        // Next Button
        if (_showResult)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(size.width * 0.04),
            child: ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06B6D4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
              ),
              child: Text(
                _currentQuestionIndex < _questions.length - 1
                    ? 'Next Question'
                    : 'View Results',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuizResults(Size size, bool isSmallScreen) {
    final percentage = (_correctAnswers / _questions.length * 100).round();
    final isPassed = percentage >= 70;

    return SingleChildScrollView(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        children: [
          // Results Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(size.width * 0.05),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPassed
                    ? [
                  const Color(0xFF10B981).withOpacity(0.1),
                  const Color(0xFF06B6D4).withOpacity(0.1),
                ]
                    : [
                  const Color(0xFFEC4899).withOpacity(0.1),
                  const Color(0xFFF59E0B).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPassed
                    ? const Color(0xFF10B981).withOpacity(0.3)
                    : const Color(0xFFEC4899).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  isPassed ? '🎉' : '💪',
                  style: TextStyle(fontSize: size.width * 0.15),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  isPassed ? 'Congratulations!' : 'Keep Practicing!',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  'You scored $percentage%',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.w600,
                    color: isPassed ? const Color(0xFF10B981) : const Color(0xFFEC4899),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: size.height * 0.03),

          // Stats
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Correct', '$_correctAnswers', const Color(0xFF10B981), size),
                _buildStatItem('Wrong', '${_questions.length - _correctAnswers}', const Color(0xFFEC4899), size),
                _buildStatItem('Total', '${_questions.length}', const Color(0xFF06B6D4), size),
              ],
            ),
          ),

          SizedBox(height: size.height * 0.04),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _retryQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                  ),
                  child: Text(
                    'Try Again',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: ElevatedButton(
                  onPressed: _newQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06B6D4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                  ),
                  child: Text(
                    'New Quiz',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, Size size) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.03,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // Action Methods
  void _startQuiz() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _quizStarted = true;
          _isLoading = false;
          _currentQuestionIndex = 0;
          _correctAnswers = 0;
          _selectedAnswerIndex = -1;
          _showResult = false;
          _quizCompleted = false;
        });
      }
    });
  }

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswerIndex = index;
      _showResult = true;
    });

    if (index == _currentQuestion!.correctAnswerIndex) {
      _correctAnswers++;
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = -1;
        _showResult = false;
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  void _retryQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _correctAnswers = 0;
      _selectedAnswerIndex = -1;
      _showResult = false;
      _quizCompleted = false;
    });
  }

  void _newQuiz() {
    setState(() {
      _quizStarted = false;
      _currentQuestionIndex = 0;
      _correctAnswers = 0;
      _selectedAnswerIndex = -1;
      _showResult = false;
      _quizCompleted = false;
    });
    _loadQuizData();
  }

  List<QuizQuestion> _getSampleQuestions(String level) {
    // Sample questions for different levels
    final Map<String, List<QuizQuestion>> questionBank = {
      'N5': [
        QuizQuestion(
          question: 'I _____ to school every day.',
          options: ['go', 'goes', 'going', 'went'],
          correctAnswerIndex: 0,
          explanation: 'Use "go" for present habitual actions with "I".',
          grammarPoint: 'Present Tense',
        ),
        QuizQuestion(
          question: 'This is _____ book.',
          options: ['a', 'an', 'the', 'some'],
          correctAnswerIndex: 0,
          explanation: 'Use "a" before singular countable nouns beginning with consonants.',
          grammarPoint: 'Articles',
        ),
        QuizQuestion(
          question: 'She _____ a teacher.',
          options: ['am', 'is', 'are', 'be'],
          correctAnswerIndex: 1,
          explanation: 'Use "is" with third person singular subjects like "she".',
          grammarPoint: 'Be Verb',
        ),
        QuizQuestion(
          question: 'There _____ many students in the classroom.',
          options: ['is', 'are', 'was', 'were'],
          correctAnswerIndex: 1,
          explanation: 'Use "are" with plural subjects like "many students".',
          grammarPoint: 'There is/are',
        ),
        QuizQuestion(
          question: 'I like _____ music.',
          options: ['listen', 'listening', 'to listen', 'listened'],
          correctAnswerIndex: 2,
          explanation: 'Use "to listen" after "like" for activities.',
          grammarPoint: 'Infinitives',
        ),
        QuizQuestion(
          question: '_____ you speak English?',
          options: ['Do', 'Does', 'Are', 'Is'],
          correctAnswerIndex: 0,
          explanation: 'Use "Do" for questions with "you" and base verb.',
          grammarPoint: 'Questions',
        ),
        QuizQuestion(
          question: 'He _____ to work by train.',
          options: ['go', 'goes', 'going', 'went'],
          correctAnswerIndex: 1,
          explanation: 'Use "goes" with third person singular in present tense.',
          grammarPoint: 'Present Tense',
        ),
        QuizQuestion(
          question: 'My brother is _____ than me.',
          options: ['tall', 'taller', 'tallest', 'more tall'],
          correctAnswerIndex: 1,
          explanation: 'Use "taller" for comparative form of short adjectives.',
          grammarPoint: 'Comparatives',
        ),
        QuizQuestion(
          question: 'I _____ breakfast at 7 AM.',
          options: ['eat', 'eats', 'eating', 'ate'],
          correctAnswerIndex: 0,
          explanation: 'Use "eat" for present habitual actions with "I".',
          grammarPoint: 'Present Tense',
        ),
        QuizQuestion(
          question: 'Where _____ you live?',
          options: ['do', 'does', 'are', 'is'],
          correctAnswerIndex: 0,
          explanation: 'Use "do" for questions with "you" and main verbs.',
          grammarPoint: 'Questions',
        ),
      ],
      'N4': [
        QuizQuestion(
          question: 'If it _____ tomorrow, we will stay home.',
          options: ['rain', 'rains', 'rained', 'raining'],
          correctAnswerIndex: 1,
          explanation: 'In conditional sentences, use present tense after "if".',
          grammarPoint: 'Conditionals',
        ),
        QuizQuestion(
          question: 'I have _____ finished my homework.',
          options: ['yet', 'already', 'still', 'just'],
          correctAnswerIndex: 3,
          explanation: 'Use "just" to indicate something happened very recently.',
          grammarPoint: 'Present Perfect',
        ),
        QuizQuestion(
          question: 'She said that she _____ tired.',
          options: ['is', 'was', 'were', 'be'],
          correctAnswerIndex: 1,
          explanation: 'In reported speech, present tense changes to past tense.',
          grammarPoint: 'Reported Speech',
        ),
        QuizQuestion(
          question: 'The book _____ I bought yesterday is interesting.',
          options: ['who', 'which', 'where', 'when'],
          correctAnswerIndex: 1,
          explanation: 'Use "which" for things/objects in relative clauses.',
          grammarPoint: 'Relative Clauses',
        ),
        QuizQuestion(
          question: 'I wish I _____ speak Japanese fluently.',
          options: ['can', 'could', 'will', 'would'],
          correctAnswerIndex: 1,
          explanation: 'Use "could" in wish sentences for present abilities.',
          grammarPoint: 'Wish Sentences',
        ),
        QuizQuestion(
          question: 'The movie was _____ boring that I fell asleep.',
          options: ['so', 'such', 'very', 'too'],
          correctAnswerIndex: 0,
          explanation: 'Use "so" + adjective + "that" for result clauses.',
          grammarPoint: 'So/Such',
        ),
        QuizQuestion(
          question: 'I would rather _____ at home tonight.',
          options: ['stay', 'staying', 'to stay', 'stayed'],
          correctAnswerIndex: 0,
          explanation: 'Use base form after "would rather".',
          grammarPoint: 'Would Rather',
        ),
        QuizQuestion(
          question: 'By the time we arrived, the concert _____ started.',
          options: ['already', 'had already', 'has already', 'was already'],
          correctAnswerIndex: 1,
          explanation: 'Use past perfect for actions completed before another past action.',
          grammarPoint: 'Past Perfect',
        ),
        QuizQuestion(
          question: 'Neither John _____ Mary came to the party.',
          options: ['or', 'nor', 'and', 'but'],
          correctAnswerIndex: 1,
          explanation: 'Use "nor" after "neither" in negative constructions.',
          grammarPoint: 'Neither...nor',
        ),
        QuizQuestion(
          question: 'I am used _____ early in the morning.',
          options: ['to wake up', 'to waking up', 'wake up', 'waking up'],
          correctAnswerIndex: 1,
          explanation: 'Use "to" + gerund after "be used to".',
          grammarPoint: 'Used to/Be used to',
        ),
      ],
      'N3': [
        QuizQuestion(
          question: 'By the time you arrive, I _____ cooking.',
          options: ['finish', 'will finish', 'will have finished', 'finished'],
          correctAnswerIndex: 2,
          explanation: 'Use future perfect for actions completed before a future time.',
          grammarPoint: 'Future Perfect',
        ),
        QuizQuestion(
          question: 'The meeting _____ when I got there.',
          options: ['started', 'has started', 'had started', 'was starting'],
          correctAnswerIndex: 2,
          explanation: 'Use past perfect for actions completed before another past action.',
          grammarPoint: 'Past Perfect',
        ),
      ],
      'N2': [
        QuizQuestion(
          question: '_____ the weather, we decided to go hiking.',
          options: ['Despite', 'Although', 'Because of', 'In spite'],
          correctAnswerIndex: 0,
          explanation: 'Use "Despite" + noun/noun phrase for contrast.',
          grammarPoint: 'Contrast Expressions',
        ),
      ],
      'N1': [
        QuizQuestion(
          question: 'Had it not been for your help, I _____ the project.',
          options: ['wouldn\'t complete', 'wouldn\'t have completed', 'didn\'t complete', 'couldn\'t complete'],
          correctAnswerIndex: 1,
          explanation: 'In third conditional with inversion, use "wouldn\'t have + past participle".',
          grammarPoint: 'Third Conditional',
        ),
      ],
    };

    return questionBank[level] ?? questionBank['N5']!;
  }
}

// Quiz Question Model
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String grammarPoint;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.grammarPoint,
  });
}