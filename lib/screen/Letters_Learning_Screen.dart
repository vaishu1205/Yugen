// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'dart:math' as math;
//
// class LettersLearningScreen extends StatefulWidget {
//   const LettersLearningScreen({super.key});
//
//   @override
//   State<LettersLearningScreen> createState() => _LettersLearningScreenState();
// }
//
// class _LettersLearningScreenState extends State<LettersLearningScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late AnimationController _cardController;
//   late AnimationController _progressController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _slideAnimation;
//   late Animation<double> _cardFlipAnimation;
//
//   String selectedScript = "Hiragana";
//   int currentLetterIndex = 0;
//   bool isFlipped = false;
//   bool showPronunciation = false;
//   int correctAnswers = 0;
//   int totalAttempts = 0;
//
//   // Complete Hiragana data (104 characters total)
//   final hiraganaLetters = [
//     // Basic Characters (46)
//     // A-row
//     {'character': 'あ', 'romaji': 'a', 'audio': 'ah'},
//     {'character': 'い', 'romaji': 'i', 'audio': 'ee'},
//     {'character': 'う', 'romaji': 'u', 'audio': 'oo'},
//     {'character': 'え', 'romaji': 'e', 'audio': 'eh'},
//     {'character': 'お', 'romaji': 'o', 'audio': 'oh'},
//     // K-row
//     {'character': 'か', 'romaji': 'ka', 'audio': 'kah'},
//     {'character': 'き', 'romaji': 'ki', 'audio': 'kee'},
//     {'character': 'く', 'romaji': 'ku', 'audio': 'koo'},
//     {'character': 'け', 'romaji': 'ke', 'audio': 'keh'},
//     {'character': 'こ', 'romaji': 'ko', 'audio': 'koh'},
//     // S-row
//     {'character': 'さ', 'romaji': 'sa', 'audio': 'sah'},
//     {'character': 'し', 'romaji': 'shi', 'audio': 'shee'},
//     {'character': 'す', 'romaji': 'su', 'audio': 'soo'},
//     {'character': 'せ', 'romaji': 'se', 'audio': 'seh'},
//     {'character': 'そ', 'romaji': 'so', 'audio': 'soh'},
//     // T-row
//     {'character': 'た', 'romaji': 'ta', 'audio': 'tah'},
//     {'character': 'ち', 'romaji': 'chi', 'audio': 'chee'},
//     {'character': 'つ', 'romaji': 'tsu', 'audio': 'tsoo'},
//     {'character': 'て', 'romaji': 'te', 'audio': 'teh'},
//     {'character': 'と', 'romaji': 'to', 'audio': 'toh'},
//     // N-row
//     {'character': 'な', 'romaji': 'na', 'audio': 'nah'},
//     {'character': 'に', 'romaji': 'ni', 'audio': 'nee'},
//     {'character': 'ぬ', 'romaji': 'nu', 'audio': 'noo'},
//     {'character': 'ね', 'romaji': 'ne', 'audio': 'neh'},
//     {'character': 'の', 'romaji': 'no', 'audio': 'noh'},
//     // H-row
//     {'character': 'は', 'romaji': 'ha', 'audio': 'hah'},
//     {'character': 'ひ', 'romaji': 'hi', 'audio': 'hee'},
//     {'character': 'ふ', 'romaji': 'fu', 'audio': 'foo'},
//     {'character': 'へ', 'romaji': 'he', 'audio': 'heh'},
//     {'character': 'ほ', 'romaji': 'ho', 'audio': 'hoh'},
//     // M-row
//     {'character': 'ま', 'romaji': 'ma', 'audio': 'mah'},
//     {'character': 'み', 'romaji': 'mi', 'audio': 'mee'},
//     {'character': 'む', 'romaji': 'mu', 'audio': 'moo'},
//     {'character': 'め', 'romaji': 'me', 'audio': 'meh'},
//     {'character': 'も', 'romaji': 'mo', 'audio': 'moh'},
//     // Y-row
//     {'character': 'や', 'romaji': 'ya', 'audio': 'yah'},
//     {'character': 'ゆ', 'romaji': 'yu', 'audio': 'yoo'},
//     {'character': 'よ', 'romaji': 'yo', 'audio': 'yoh'},
//     // R-row
//     {'character': 'ら', 'romaji': 'ra', 'audio': 'rah'},
//     {'character': 'り', 'romaji': 'ri', 'audio': 'ree'},
//     {'character': 'る', 'romaji': 'ru', 'audio': 'roo'},
//     {'character': 'れ', 'romaji': 're', 'audio': 'reh'},
//     {'character': 'ろ', 'romaji': 'ro', 'audio': 'roh'},
//     // W-row and N
//     {'character': 'わ', 'romaji': 'wa', 'audio': 'wah'},
//     {'character': 'を', 'romaji': 'wo', 'audio': 'woh'},
//     {'character': 'ん', 'romaji': 'n', 'audio': 'n'},
//     // Dakuten Characters (濁点) - 25 characters
//     // G-row (ga, gi, gu, ge, go)
//     {'character': 'が', 'romaji': 'ga', 'audio': 'gah'},
//     {'character': 'ぎ', 'romaji': 'gi', 'audio': 'gee'},
//     {'character': 'ぐ', 'romaji': 'gu', 'audio': 'goo'},
//     {'character': 'げ', 'romaji': 'ge', 'audio': 'geh'},
//     {'character': 'ご', 'romaji': 'go', 'audio': 'goh'},
//     // Z-row (za, ji, zu, ze, zo)
//     {'character': 'ざ', 'romaji': 'za', 'audio': 'zah'},
//     {'character': 'じ', 'romaji': 'ji', 'audio': 'jee'},
//     {'character': 'ず', 'romaji': 'zu', 'audio': 'zoo'},
//     {'character': 'ぜ', 'romaji': 'ze', 'audio': 'zeh'},
//     {'character': 'ぞ', 'romaji': 'zo', 'audio': 'zoh'},
//     // D-row (da, ji, zu, de, do)
//     {'character': 'だ', 'romaji': 'da', 'audio': 'dah'},
//     {'character': 'ぢ', 'romaji': 'ji', 'audio': 'jee'},
//     {'character': 'づ', 'romaji': 'zu', 'audio': 'zoo'},
//     {'character': 'で', 'romaji': 'de', 'audio': 'deh'},
//     {'character': 'ど', 'romaji': 'do', 'audio': 'doh'},
//     // B-row (ba, bi, bu, be, bo)
//     {'character': 'ば', 'romaji': 'ba', 'audio': 'bah'},
//     {'character': 'び', 'romaji': 'bi', 'audio': 'bee'},
//     {'character': 'ぶ', 'romaji': 'bu', 'audio': 'boo'},
//     {'character': 'べ', 'romaji': 'be', 'audio': 'beh'},
//     {'character': 'ぼ', 'romaji': 'bo', 'audio': 'boh'},
//     // Handakuten Characters (半濁点) - 5 characters
//     // P-row (pa, pi, pu, pe, po)
//     {'character': 'ぱ', 'romaji': 'pa', 'audio': 'pah'},
//     {'character': 'ぴ', 'romaji': 'pi', 'audio': 'pee'},
//     {'character': 'ぷ', 'romaji': 'pu', 'audio': 'poo'},
//     {'character': 'ぺ', 'romaji': 'pe', 'audio': 'peh'},
//     {'character': 'ぽ', 'romaji': 'po', 'audio': 'poh'},
//     // Combination Characters (拗音) - 33 characters
//     // KY combinations
//     {'character': 'きゃ', 'romaji': 'kya', 'audio': 'kyah'},
//     {'character': 'きゅ', 'romaji': 'kyu', 'audio': 'kyoo'},
//     {'character': 'きょ', 'romaji': 'kyo', 'audio': 'kyoh'},
//     // SH combinations
//     {'character': 'しゃ', 'romaji': 'sha', 'audio': 'shah'},
//     {'character': 'しゅ', 'romaji': 'shu', 'audio': 'shoo'},
//     {'character': 'しょ', 'romaji': 'sho', 'audio': 'shoh'},
//     // CH combinations
//     {'character': 'ちゃ', 'romaji': 'cha', 'audio': 'chah'},
//     {'character': 'ちゅ', 'romaji': 'chu', 'audio': 'choo'},
//     {'character': 'ちょ', 'romaji': 'cho', 'audio': 'choh'},
//     // NY combinations
//     {'character': 'にゃ', 'romaji': 'nya', 'audio': 'nyah'},
//     {'character': 'にゅ', 'romaji': 'nyu', 'audio': 'nyoo'},
//     {'character': 'にょ', 'romaji': 'nyo', 'audio': 'nyoh'},
//     // HY combinations
//     {'character': 'ひゃ', 'romaji': 'hya', 'audio': 'hyah'},
//     {'character': 'ひゅ', 'romaji': 'hyu', 'audio': 'hyoo'},
//     {'character': 'ひょ', 'romaji': 'hyo', 'audio': 'hyoh'},
//     // MY combinations
//     {'character': 'みゃ', 'romaji': 'mya', 'audio': 'myah'},
//     {'character': 'みゅ', 'romaji': 'myu', 'audio': 'myoo'},
//     {'character': 'みょ', 'romaji': 'myo', 'audio': 'myoh'},
//     // RY combinations
//     {'character': 'りゃ', 'romaji': 'rya', 'audio': 'ryah'},
//     {'character': 'りゅ', 'romaji': 'ryu', 'audio': 'ryoo'},
//     {'character': 'りょ', 'romaji': 'ryo', 'audio': 'ryoh'},
//     // GY combinations
//     {'character': 'ぎゃ', 'romaji': 'gya', 'audio': 'gyah'},
//     {'character': 'ぎゅ', 'romaji': 'gyu', 'audio': 'gyoo'},
//     {'character': 'ぎょ', 'romaji': 'gyo', 'audio': 'gyoh'},
//     // J combinations
//     {'character': 'じゃ', 'romaji': 'ja', 'audio': 'jah'},
//     {'character': 'じゅ', 'romaji': 'ju', 'audio': 'joo'},
//     {'character': 'じょ', 'romaji': 'jo', 'audio': 'joh'},
//     // BY combinations
//     {'character': 'びゃ', 'romaji': 'bya', 'audio': 'byah'},
//     {'character': 'びゅ', 'romaji': 'byu', 'audio': 'byoo'},
//     {'character': 'びょ', 'romaji': 'byo', 'audio': 'byoh'},
//     // PY combinations
//     {'character': 'ぴゃ', 'romaji': 'pya', 'audio': 'pyah'},
//     {'character': 'ぴゅ', 'romaji': 'pyu', 'audio': 'pyoo'},
//     {'character': 'ぴょ', 'romaji': 'pyo', 'audio': 'pyoh'},
//   ];
//
//   // Complete Katakana data (46 basic characters)
//   final katakanaLetters = [
//     // A-row
//     {'character': 'ア', 'romaji': 'a', 'audio': 'ah'},
//     {'character': 'イ', 'romaji': 'i', 'audio': 'ee'},
//     {'character': 'ウ', 'romaji': 'u', 'audio': 'oo'},
//     {'character': 'エ', 'romaji': 'e', 'audio': 'eh'},
//     {'character': 'オ', 'romaji': 'o', 'audio': 'oh'},
//     // K-row
//     {'character': 'カ', 'romaji': 'ka', 'audio': 'kah'},
//     {'character': 'キ', 'romaji': 'ki', 'audio': 'kee'},
//     {'character': 'ク', 'romaji': 'ku', 'audio': 'koo'},
//     {'character': 'ケ', 'romaji': 'ke', 'audio': 'keh'},
//     {'character': 'コ', 'romaji': 'ko', 'audio': 'koh'},
//     // S-row
//     {'character': 'サ', 'romaji': 'sa', 'audio': 'sah'},
//     {'character': 'シ', 'romaji': 'shi', 'audio': 'shee'},
//     {'character': 'ス', 'romaji': 'su', 'audio': 'soo'},
//     {'character': 'セ', 'romaji': 'se', 'audio': 'seh'},
//     {'character': 'ソ', 'romaji': 'so', 'audio': 'soh'},
//     // T-row
//     {'character': 'タ', 'romaji': 'ta', 'audio': 'tah'},
//     {'character': 'チ', 'romaji': 'chi', 'audio': 'chee'},
//     {'character': 'ツ', 'romaji': 'tsu', 'audio': 'tsoo'},
//     {'character': 'テ', 'romaji': 'te', 'audio': 'teh'},
//     {'character': 'ト', 'romaji': 'to', 'audio': 'toh'},
//     // N-row
//     {'character': 'ナ', 'romaji': 'na', 'audio': 'nah'},
//     {'character': 'ニ', 'romaji': 'ni', 'audio': 'nee'},
//     {'character': 'ヌ', 'romaji': 'nu', 'audio': 'noo'},
//     {'character': 'ネ', 'romaji': 'ne', 'audio': 'neh'},
//     {'character': 'ノ', 'romaji': 'no', 'audio': 'noh'},
//     // H-row
//     {'character': 'ハ', 'romaji': 'ha', 'audio': 'hah'},
//     {'character': 'ヒ', 'romaji': 'hi', 'audio': 'hee'},
//     {'character': 'フ', 'romaji': 'fu', 'audio': 'foo'},
//     {'character': 'ヘ', 'romaji': 'he', 'audio': 'heh'},
//     {'character': 'ホ', 'romaji': 'ho', 'audio': 'hoh'},
//     // M-row
//     {'character': 'マ', 'romaji': 'ma', 'audio': 'mah'},
//     {'character': 'ミ', 'romaji': 'mi', 'audio': 'mee'},
//     {'character': 'ム', 'romaji': 'mu', 'audio': 'moo'},
//     {'character': 'メ', 'romaji': 'me', 'audio': 'meh'},
//     {'character': 'モ', 'romaji': 'mo', 'audio': 'moh'},
//     // Y-row
//     {'character': 'ヤ', 'romaji': 'ya', 'audio': 'yah'},
//     {'character': 'ユ', 'romaji': 'yu', 'audio': 'yoo'},
//     {'character': 'ヨ', 'romaji': 'yo', 'audio': 'yoh'},
//     // R-row
//     {'character': 'ラ', 'romaji': 'ra', 'audio': 'rah'},
//     {'character': 'リ', 'romaji': 'ri', 'audio': 'ree'},
//     {'character': 'ル', 'romaji': 'ru', 'audio': 'roo'},
//     {'character': 'レ', 'romaji': 're', 'audio': 'reh'},
//     {'character': 'ロ', 'romaji': 'ro', 'audio': 'roh'},
//     // W-row and N
//     {'character': 'ワ', 'romaji': 'wa', 'audio': 'wah'},
//     {'character': 'ヲ', 'romaji': 'wo', 'audio': 'woh'},
//     {'character': 'ン', 'romaji': 'n', 'audio': 'n'},
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//   }
//
//   void _initAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
//
//     _cardController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//
//     _progressController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//
//     _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
//     );
//
//     _cardFlipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _cardController, curve: Curves.easeInOut),
//     );
//
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     _cardController.dispose();
//     _progressController.dispose();
//     super.dispose();
//   }
//
//   List<Map<String, String>> get currentLetters =>
//       selectedScript == "Hiragana" ? hiraganaLetters : katakanaLetters;
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isSmallScreen = size.width < 360;
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
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: Column(
//               children: [
//                 // Header
//                 _buildHeader(size, isSmallScreen),
//
//                 // Progress Bar
//                 _buildProgressBar(size),
//
//                 // Script Selector
//                 _buildScriptSelector(size, isSmallScreen),
//
//                 // Main Learning Card
//                 Expanded(
//                   child: _buildLearningCard(size, isSmallScreen),
//                 ),
//
//                 // Controls
//                 _buildControls(size, isSmallScreen),
//
//                 // Bottom Navigation
//                 _buildBottomActions(size, isSmallScreen),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(Size size, bool isSmallScreen) {
//     return AnimatedBuilder(
//       animation: _slideAnimation,
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(0, _slideAnimation.value),
//           child: Padding(
//             padding: EdgeInsets.all(size.width * 0.04),
//             child: Row(
//               children: [
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: Container(
//                     padding: EdgeInsets.all(size.width * 0.025),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.2),
//                         width: 1,
//                       ),
//                     ),
//                     child: Icon(
//                       Icons.arrow_back_ios,
//                       color: Colors.white,
//                       size: size.width * 0.05,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: size.width * 0.04),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Japanese Letters',
//                         style: GoogleFonts.poppins(
//                           fontSize: size.width * 0.06,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       Text(
//                         'Master ${selectedScript.toLowerCase()} characters',
//                         style: GoogleFonts.poppins(
//                           fontSize: size.width * 0.032,
//                           color: Colors.white.withOpacity(0.7),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // View All button
//                 GestureDetector(
//                   onTap: _showAllCharacters,
//                   child: Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: size.width * 0.03,
//                       vertical: size.width * 0.02,
//                     ),
//                     margin: EdgeInsets.only(right: size.width * 0.02),
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFF10B981).withOpacity(0.3),
//                           blurRadius: 10,
//                           offset: const Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.view_module,
//                           color: Colors.white,
//                           size: size.width * 0.04,
//                         ),
//                         SizedBox(width: size.width * 0.01),
//                         Text(
//                           'View All',
//                           style: GoogleFonts.poppins(
//                             fontSize: size.width * 0.028,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Fun animated character
//                 Container(
//                   padding: EdgeInsets.all(size.width * 0.03),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
//                     ),
//                     borderRadius: BorderRadius.circular(15),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFF8B5CF6).withOpacity(0.3),
//                         blurRadius: 15,
//                         offset: const Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: Text(
//                     selectedScript == "Hiragana" ? 'あ' : 'ア',
//                     style: GoogleFonts.notoSansJp(
//                       fontSize: size.width * 0.06,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildProgressBar(Size size) {
//     final progress = (currentLetterIndex + 1) / currentLetters.length;
//
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Progress',
//                 style: GoogleFonts.poppins(
//                   fontSize: size.width * 0.035,
//                   color: Colors.white.withOpacity(0.8),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Text(
//                 '${currentLetterIndex + 1} / ${currentLetters.length}',
//                 style: GoogleFonts.poppins(
//                   fontSize: size.width * 0.035,
//                   color: const Color(0xFF8B5CF6),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: size.height * 0.008),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: LinearProgressIndicator(
//               value: progress,
//               backgroundColor: Colors.white.withOpacity(0.2),
//               valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
//               minHeight: size.height * 0.008,
//             ),
//           ),
//           SizedBox(height: size.height * 0.015),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildScriptSelector(Size size, bool isSmallScreen) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
//       child: Row(
//         children: [
//           Expanded(
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedScript = "Hiragana";
//                   currentLetterIndex = 0;
//                   isFlipped = false;
//                 });
//                 _cardController.reset();
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds:300),
//                 padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
//                 decoration: BoxDecoration(
//                   gradient: selectedScript == "Hiragana"
//                       ? const LinearGradient(
//                     colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
//                   )
//                       : null,
//                   color: selectedScript == "Hiragana"
//                       ? null
//                       : Colors.white.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(15),
//                   border: Border.all(
//                     color: selectedScript == "Hiragana"
//                         ? Colors.transparent
//                         : Colors.white.withOpacity(0.2),
//                     width: 1,
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     'Hiragana ひらがな',
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.035,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(width: size.width * 0.03),
//           Expanded(
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedScript = "Katakana";
//                   currentLetterIndex = 0;
//                   isFlipped = false;
//                 });
//                 _cardController.reset();
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
//                 decoration: BoxDecoration(
//                   gradient: selectedScript == "Katakana"
//                       ? const LinearGradient(
//                     colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
//                   )
//                       : null,
//                   color: selectedScript == "Katakana"
//                       ? null
//                       : Colors.white.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(15),
//                   border: Border.all(
//                     color: selectedScript == "Katakana"
//                         ? Colors.transparent
//                         : Colors.white.withOpacity(0.2),
//                     width: 1,
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     'Katakana カタカナ',
//                     style: GoogleFonts.poppins(
//                       fontSize: size.width * 0.035,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
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
//   Widget _buildLearningCard(Size size, bool isSmallScreen) {
//     final currentLetter = currentLetters[currentLetterIndex];
//
//     return Padding(
//       padding: EdgeInsets.all(size.width * 0.04),
//       child: GestureDetector(
//         onTap: _flipCard,
//         child: AnimatedBuilder(
//           animation: _cardFlipAnimation,
//           builder: (context, child) {
//             final isShowingFront = _cardFlipAnimation.value < 0.5;
//
//             return Transform(
//               alignment: Alignment.center,
//               transform: Matrix4.identity()
//                 ..setEntry(3, 2, 0.001)
//                 ..rotateY(_cardFlipAnimation.value * math.pi),
//               child: Container(
//                 width: double.infinity,
//                 height: size.height * 0.4,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: selectedScript == "Hiragana"
//                         ? [
//                       const Color(0xFF8B5CF6).withOpacity(0.2),
//                       const Color(0xFFEC4899).withOpacity(0.2),
//                     ]
//                         : [
//                       const Color(0xFF10B981).withOpacity(0.2),
//                       const Color(0xFF06B6D4).withOpacity(0.2),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(25),
//                   border: Border.all(
//                     color: selectedScript == "Hiragana"
//                         ? const Color(0xFF8B5CF6).withOpacity(0.3)
//                         : const Color(0xFF10B981).withOpacity(0.3),
//                     width: 2,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: selectedScript == "Hiragana"
//                           ? const Color(0xFF8B5CF6).withOpacity(0.2)
//                           : const Color(0xFF10B981).withOpacity(0.2),
//                       blurRadius: 20,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: isShowingFront ? _buildCardFront(currentLetter, size) : _buildCardBack(currentLetter, size),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCardFront(Map<String, String> letter, Size size) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // Large character display
//         Container(
//           padding: EdgeInsets.all(size.width * 0.06),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             letter['character']!,
//             style: GoogleFonts.notoSansJp(
//               fontSize: size.width * 0.25,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         SizedBox(height: size.height * 0.03),
//
//         // Hint text
//         Text(
//           'Tap to see pronunciation',
//           style: GoogleFonts.poppins(
//             fontSize: size.width * 0.035,
//             color: Colors.white.withOpacity(0.7),
//             fontStyle: FontStyle.italic,
//           ),
//         ),
//         SizedBox(height: size.height * 0.02),
//
//         // Fun memory aid
//         Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: size.width * 0.04,
//             vertical: size.height * 0.01,
//           ),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: Text(
//             _getMemoryAid(letter['character']!),
//             textAlign: TextAlign.center,
//             style: GoogleFonts.poppins(
//               fontSize: size.width * 0.03,
//               color: Colors.white.withOpacity(0.8),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildCardBack(Map<String, String> letter, Size size) {
//     return Transform(
//       alignment: Alignment.center,
//       transform: Matrix4.identity()..rotateY(math.pi),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Romaji
//           Text(
//             letter['romaji']!.toUpperCase(),
//             style: GoogleFonts.poppins(
//               fontSize: size.width * 0.15,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           SizedBox(height: size.height * 0.02),
//
//           // Audio pronunciation guide
//           Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: size.width * 0.06,
//               vertical: size.height * 0.015,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               'Sounds like: "${letter['audio']!}"',
//               style: GoogleFonts.poppins(
//                 fontSize: size.width * 0.04,
//                 color: Colors.white.withOpacity(0.9),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           SizedBox(height: size.height * 0.03),
//
//           // Practice writing guide
//           Text(
//             'Practice writing this character!',
//             style: GoogleFonts.poppins(
//               fontSize: size.width * 0.032,
//               color: Colors.white.withOpacity(0.7),
//               fontStyle: FontStyle.italic,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildControls(Size size, bool isSmallScreen) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           // Previous button
//           _buildControlButton(
//             icon: Icons.skip_previous,
//             onTap: _previousLetter,
//             enabled: currentLetterIndex > 0,
//             size: size,
//           ),
//
//           // Play audio button
//           _buildControlButton(
//             icon: Icons.volume_up,
//             onTap: _playAudio,
//             enabled: true,
//             size: size,
//             isSpecial: true,
//           ),
//
//           // Flip card button
//           _buildControlButton(
//             icon: Icons.flip,
//             onTap: _flipCard,
//             enabled: true,
//             size: size,
//           ),
//
//           // Next button
//           _buildControlButton(
//             icon: Icons.skip_next,
//             onTap: _nextLetter,
//             enabled: currentLetterIndex < currentLetters.length - 1,
//             size: size,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildControlButton({
//     required IconData icon,
//     required VoidCallback onTap,
//     required bool enabled,
//     required Size size,
//     bool isSpecial = false,
//   }) {
//     return GestureDetector(
//       onTap: enabled ? onTap : null,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: EdgeInsets.all(size.width * 0.04),
//         decoration: BoxDecoration(
//           gradient: enabled
//               ? (isSpecial
//               ? const LinearGradient(
//             colors: [Color(0xFFF59E0B), Color(0xFFFF6B35)],
//           )
//               : LinearGradient(
//             colors: selectedScript == "sturdy"
//                 ? [const Color(0xFF8B5CF6), const Color(0xFFEC4899)]
//                 : [const Color(0xFF10B981), const Color(0xFF06B6D4)],
//           ))
//               : null,
//           color: enabled ? null : Colors.white.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(
//             color: enabled
//                 ? Colors.transparent
//                 : Colors.white.withOpacity(0.2),
//             width: 1,
//           ),
//         ),
//         child: Icon(
//           icon,
//           color: enabled ? Colors.white : Colors.white.withOpacity(0.5),
//           size: size.width * 0.06,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBottomActions(Size size, bool isSmallScreen) {
//     return Padding(
//       padding: EdgeInsets.all(size.width * 0.04),
//       child: Row(
//         children: [
//           Expanded(
//             child: ElevatedButton(
//               onPressed: _startQuiz,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF06B6D4),
//                 padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 elevation: 0,
//               ),
//               child: Text(
//                 'Quick Quiz',
//                 style: GoogleFonts.poppins(
//                   fontSize: size.width * 0.04,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(width: size.width * 0.03),
//           Expanded(
//             child: ElevatedButton(
//               onPressed: _practiceWriting,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF8B5CF6),
//                 padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 elevation: 0,
//               ),
//               child: Text(
//                 'Practice Writing',
//                 style: GoogleFonts.poppins(
//                   fontSize: size.width * 0.04,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Full-page responsive view for all characters
//   void _showAllCharacters() {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => _AllCharactersScreen(
//           selectedScript: selectedScript,
//           letters: currentLetters,
//         ),
//       ),
//     );
//   }
//
//   // Helper methods
//   String _getMemoryAid(String character) {
//     final memoryAids = {
//       // Hiragana memory aids
//       'あ': 'Like a person saying "Ah!"',
//       'い': 'Two sticks standing upright',
//       'う': 'A person bowing down',
//       'え': 'An elephant\'s trunk',
//       'お': 'A surprised face',
//       'か': 'A kite in the wind',
//       'き': 'A key shape',
//       'く': 'A bird\'s beak',
//       'け': 'A person kneeling',
//       'こ': 'Two horizontal lines',
//       'さ': 'A person sitting',
//       'し': 'A curved line',
//       'す': 'A swan swimming',
//       'せ': 'A world map',
//       'そ': 'A needle and thread',
//       'た': 'A cross or "t" shape',
//       'ち': 'A cheerleader\'s pom-pom',
//       'つ': 'A tsunami wave',
//       'て': 'A telephone pole',
//       'と': 'A toe pointing',
//       'な': 'A knot in rope',
//       'に': 'A knee bending',
//       'ぬ': 'Noodles on chopsticks',
//       'ね': 'A cat\'s tail',
//       'の': 'A "no" sign',
//       'は': 'A house with chimney',
//       'ひ': 'A person\'s face in profile',
//       'ふ': 'A hook or "f" shape',
//       'へ': 'A mountain peak',
//       'ほ': 'A house with steps',
//       'ま': 'A mama with baby',
//       'み': 'Music note',
//       'む': 'A cow saying "moo"',
//       'め': 'An eye looking',
//       'も': 'A fishing hook',
//       'や': 'A yak\'s head',
//       'ゆ': 'A unique swirl',
//       'よ': 'A yo-yo string',
//       'ら': 'A rabbit hopping',
//       'り': 'A river flowing',
//       'る': 'A loop or curl',
//       'れ': 'A reception desk',
//       'ろ': 'A road sign',
//       'わ': 'A wavy line',
//       'を': 'A person doing yoga',
//       'ん': 'A simple "n" curve',
//       // Katakana memory aids
//       'ア': 'Sharp angles like "A"',
//       'イ': 'Two straight lines',
//       'ウ': 'Like a "U" shape',
//       'エ': 'Elevator going up',
//       'オ': 'Open mouth saying "Oh"',
//       'カ': 'Sharp cutting motion',
//       'キ': 'A key with teeth',
//       'ク': 'A person bowing',
//       'ケ': 'Ketchup bottle',
//       'コ': 'Corner of a box',
//       'サ': 'Samurai sword',
//       'シ': 'Shooting arrow',
//       'ス': 'Straight line with hook',
//       'セ': 'Set of stairs',
//       'ソ': 'Sewing needle',
//       'タ': 'A tall building',
//       'チ': 'A cheerful face',
//       'ツ': 'Two sharp points',
//       'テ': 'A television antenna',
//       'ト': 'A totem pole',
//       'ナ': 'A knife cutting',
//       'ニ': 'Two equal lines',
//       'ヌ': 'A nunchuck',
//       'ネ': 'A net for catching',
//       'ノ': 'A number one',
//       'ハ': 'A house roof',
//       'ヒ': 'A person standing',
//       'フ': 'A hook hanging',
//       'ヘ': 'A mountain slope',
//      // -conditioned
//       'ホ': 'A cross with line',
//       'マ': 'A map grid',
//       'ミ': 'Three lines',
//       'ム': 'A moon crescent',
//       'メ': 'A mesh or net',
//       'モ': 'A more complex shape',
//       'ヤ': 'A yacht sail',
//       'ユ': 'A unique fork',
//       'ヨ': 'A yoga pose',
//       'ラ': 'A ladder rung',
//       'リ': 'Two vertical lines',
//       'ル': 'A loop with tail',
//       'レ': 'A rectangle corner',
//       'ロ': 'A rectangular box',
//       'ワ': 'A wide opening',
//       'ヲ': 'A complex "wo"',
//       'ン': 'A simple dash',
//     };
//
//     return memoryAids[character] ?? 'Remember this character!';
//   }
//
//   void _flipCard() {
//     if (_cardController.isCompleted) {
//       _cardController.reverse();
//     } else {
//       _cardController.forward();
//     }
//   }
//
//   void _nextLetter() {
//     if (currentLetterIndex < currentLetters.length - 1) {
//       setState(() {
//         currentLetterIndex++;
//       });
//       _cardController.reset();
//     }
//   }
//
//   void _previousLetter() {
//     if (currentLetterIndex > 0) {
//       setState(() {
//         currentLetterIndex--;
//       });
//       _cardController.reset();
//     }
//   }
//
//   void _playAudio() {
//     // Implement audio playback
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Playing: ${currentLetters[currentLetterIndex]['audio']}'),
//         backgroundColor: const Color(0xFF10B981),
//         duration: const Duration(seconds: 1),
//       ),
//     );
//   }
//
//   void _startQuiz() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1C2128),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         title: Text(
//           'Quick Quiz',
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         content: Text(
//           'Test your knowledge of the characters you\'ve learned!',
//           style: GoogleFonts.poppins(color: Colors.white70),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Later',
//               style: GoogleFonts.poppins(color: Colors.white60),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               // Navigate to quiz screen
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF8B5CF6),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               elevation: 0,
//             ),
//             child: Text(
//               'Start Quiz',
//               style: GoogleFonts.poppins(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _practiceWriting() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1C2128),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         title: Text(
//           'Practice Writing',
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         content: Text(
//           'Practice writing ${selectedScript.toLowerCase()} characters with guided strokes!',
//           style: GoogleFonts.poppins(color: Colors.white70),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Later',
//               style: GoogleFonts.poppins(color: Colors.white60),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               // Navigate to writing practice screen
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF8B5CF6),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               elevation: 0,
//             ),
//             child: Text(
//               'Start Writing',
//               style: GoogleFonts.poppins(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Full-page All Characters Screen - Responsive & No Pixel Overflow
// class _AllCharactersScreen extends StatelessWidget {
//   final String selectedScript;
//   final List<Map<String, String>> letters;
//
//   const _AllCharactersScreen({
//     required this.selectedScript,
//     required this.letters,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isTablet = size.width > 600;
//     final crossAxisCount = (size.width / 80).floor().clamp(4, isTablet ? 8 : 6);
//     final aspectRatio = isTablet ? 1.2 : 1.1;
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
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               return Column(
//                 children: [
//                   // Header with back button
//                   Container(
//                     padding: EdgeInsets.all(size.width * 0.04),
//                     child: Row(
//                       children: [
//                         GestureDetector(
//                           onTap: () => Navigator.pop(context),
//                           child: Container(
//                             padding: EdgeInsets.all(size.width * 0.025),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: Colors.white.withOpacity(0.2),
//                                 width: 1,
//                               ),
//                             ),
//                             child: Icon(
//                               Icons.arrow_back_ios,
//                               color: Colors.white,
//                               size: size.width * 0.05,
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: size.width * 0.04),
//                         Expanded(
//                           child: Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: size.width * 0.04,
//                               vertical: size.height * 0.015,
//                             ),
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: selectedScript == "Hiragana"
//                                     ? [const Color(0xFF8B5CF6), const Color(0xFFEC4899)]
//                                     : [const Color(0xFF10B981), const Color(0xFF06B6D4)],
//                               ),
//                               borderRadius: BorderRadius.circular(15),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: (selectedScript == "Hiragana"
//                                       ? const Color(0xFF8B5CF6)
//                                       : const Color(0xFF10B981)).withOpacity(0.3),
//                                   blurRadius: 15,
//                                   offset: const Offset(0, 5),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   selectedScript == "Hiragana" ? 'あ' : 'ア',
//                                   style: GoogleFonts.notoSansJp(
//                                     fontSize: (size.width * 0.06).clamp(20, 24),
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 SizedBox(width: size.width * 0.03),
//                                 Flexible(
//                                   child: Text(
//                                     '$selectedScript Complete Chart',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: (size.width * 0.045).clamp(14, 18),
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Characters count info
//                   Container(
//                     margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
//                     padding: EdgeInsets.symmetric(
//                       horizontal: size.width * 0.04,
//                       vertical: size.height * 0.01,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Flexible(
//                           child: Text(
//                             'Total Characters: ${letters.length}',
//                             style: GoogleFonts.poppins(
//                               fontSize: (size.width * 0.035).clamp(12, 14),
//                               color: Colors.white.withOpacity(0.8),
//                               fontWeight: FontWeight.w500,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.touch_app,
//                               color: Colors.white.withOpacity(0.7),
//                               size: (size.width * 0.04).clamp(14, 16),
//                             ),
//                             SizedBox(width: size.width * 0.02),
//                             Text(
//                               'Tap to hear',
//                               style: GoogleFonts.poppins(
//                                 fontSize: (size.width * 0.03).clamp(10, 12),
//                                 color: Colors.white.withOpacity(0.7),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   SizedBox(height: size.height * 0.02),
//
//                   // Characters Grid - Responsive & No Overflow
//                   Expanded(
//                     child: Container(
//                       padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
//                       child: GridView.builder(
//                         physics: const BouncingScrollPhysics(),
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: crossAxisCount,
//                           childAspectRatio: aspectRatio,
//                           crossAxisSpacing: (size.width * 0.02).clamp(4, 8),
//                           mainAxisSpacing: (size.width * 0.02).clamp(4, 8),
//                         ),
//                         itemCount: letters.length,
//                         itemBuilder: (context, index) {
//                           final letter = letters[index];
//                           return GestureDetector(
//                             onTap: () {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text(
//                                     '${letter['character']} - ${letter['romaji']} (${letter['audio']})',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: (size.width * 0.035).clamp(12, 14),
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   backgroundColor: selectedScript == "Hiragana"
//                                       ? const Color(0xFF8B5CF6)
//                                       : const Color(0xFF10B981),
//                                   duration: const Duration(seconds: 1),
//                                   behavior: SnackBarBehavior.floating,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topLeft,
//                                   end: Alignment.bottomRight,
//                                   colors: selectedScript == "Hiragana"
//                                       ? [
//                                     const Color(0xFF8B5CF6).withOpacity(0.15),
//                                     const Color(0xFFEC4899).withOpacity(0.15),
//                                   ]
//                                       : [
//                                     const Color(0xFF10B981).withOpacity(0.15),
//                                     const Color(0xFF06B6D4).withOpacity(0.15),
//                                   ],
//                                 ),
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                   color: Colors.white.withOpacity(0.1),
//                                   width: 1,
//                                 ),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.1),
//                                     blurRadius: 5,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: FittedBox(
//                                 fit: BoxFit.contain,
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     // Character
//                                     Text(
//                                       letter['character']!,
//                                       style: GoogleFonts.notoSansJp(
//                                         fontSize: (size.width * (isTablet ? 0.035 : 0.07)).clamp(16, 22),
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                     SizedBox(height: (size.height * 0.005).clamp(2, 4)),
//                                     // Romaji
//                                     Text(
//                                       letter['romaji']!,
//                                       style: GoogleFonts.poppins(
//                                         fontSize: (size.width * (isTablet ? 0.02 : 0.025)).clamp(10, 12),
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.white.withOpacity(0.8),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//
//                   // Bottom info bar
//                   Container(
//                     margin: EdgeInsets.all(size.width * 0.04),
//                     padding: EdgeInsets.symmetric(
//                       horizontal: size.width * 0.04,
//                       vertical: size.height * 0.015,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.05),
//                       borderRadius: BorderRadius.circular(15),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.1),
//                         width: 1,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.school,
//                           color: Colors.white.withOpacity(0.7),
//                           size: (size.width * 0.05).clamp(16, 20),
//                         ),
//                         SizedBox(width: size.width * 0.03),
//                         Flexible(
//                           child: Text(
//                             'Master all $selectedScript characters for Japanese fluency!',
//                             style: GoogleFonts.poppins(
//                               fontSize: (size.width * 0.032).clamp(12, 14),
//                               color: Colors.white.withOpacity(0.7),
//                               fontWeight: FontWeight.w500,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class LettersLearningScreen extends StatefulWidget {
  const LettersLearningScreen({super.key});

  @override
  State<LettersLearningScreen> createState() => _LettersLearningScreenState();
}

class _LettersLearningScreenState extends State<LettersLearningScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _cardController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _cardFlipAnimation;
  late Animation<double> _pulseAnimation;

  String selectedScript = "Hiragana";
  int currentLetterIndex = 0;
  bool isFlipped = false;
  int streakCount = 3;
  DateTime? lastInteraction;

  // Hiragana data
  final hiraganaLetters = [
    {'character': 'あ', 'romaji': 'a', 'audio': 'ah'},
    {'character': 'い', 'romaji': 'i', 'audio': 'ee'},
    {'character': 'う', 'romaji': 'u', 'audio': 'oo'},
    {'character': 'え', 'romaji': 'e', 'audio': 'eh'},
    {'character': 'お', 'romaji': 'o', 'audio': 'oh'},
    {'character': 'か', 'romaji': 'ka', 'audio': 'kah'},
    {'character': 'き', 'romaji': 'ki', 'audio': 'kee'},
    {'character': 'く', 'romaji': 'ku', 'audio': 'koo'},
    {'character': 'け', 'romaji': 'ke', 'audio': 'keh'},
    {'character': 'こ', 'romaji': 'ko', 'audio': 'koh'},
    {'character': 'さ', 'romaji': 'sa', 'audio': 'sah'},
    {'character': 'し', 'romaji': 'shi', 'audio': 'shee'},
    {'character': 'す', 'romaji': 'su', 'audio': 'soo'},
    {'character': 'せ', 'romaji': 'se', 'audio': 'seh'},
    {'character': 'そ', 'romaji': 'so', 'audio': 'soh'},
    {'character': 'た', 'romaji': 'ta', 'audio': 'tah'},
    {'character': 'ち', 'romaji': 'chi', 'audio': 'chee'},
    {'character': 'つ', 'romaji': 'tsu', 'audio': 'tsoo'},
    {'character': 'て', 'romaji': 'te', 'audio': 'teh'},
    {'character': 'と', 'romaji': 'to', 'audio': 'toh'},
    {'character': 'な', 'romaji': 'na', 'audio': 'nah'},
    {'character': 'に', 'romaji': 'ni', 'audio': 'nee'},
    {'character': 'ぬ', 'romaji': 'nu', 'audio': 'noo'},
    {'character': 'ね', 'romaji': 'ne', 'audio': 'neh'},
    {'character': 'の', 'romaji': 'no', 'audio': 'noh'},
    {'character': 'は', 'romaji': 'ha', 'audio': 'hah'},
    {'character': 'ひ', 'romaji': 'hi', 'audio': 'hee'},
    {'character': 'ふ', 'romaji': 'fu', 'audio': 'foo'},
    {'character': 'へ', 'romaji': 'he', 'audio': 'heh'},
    {'character': 'ほ', 'romaji': 'ho', 'audio': 'hoh'},
    {'character': 'ま', 'romaji': 'ma', 'audio': 'mah'},
    {'character': 'み', 'romaji': 'mi', 'audio': 'mee'},
    {'character': 'む', 'romaji': 'mu', 'audio': 'moo'},
    {'character': 'め', 'romaji': 'me', 'audio': 'meh'},
    {'character': 'も', 'romaji': 'mo', 'audio': 'moh'},
    {'character': 'や', 'romaji': 'ya', 'audio': 'yah'},
    {'character': 'ゆ', 'romaji': 'yu', 'audio': 'yoo'},
    {'character': 'よ', 'romaji': 'yo', 'audio': 'yoh'},
    {'character': 'ら', 'romaji': 'ra', 'audio': 'rah'},
    {'character': 'り', 'romaji': 'ri', 'audio': 'ree'},
    {'character': 'る', 'romaji': 'ru', 'audio': 'roo'},
    {'character': 'れ', 'romaji': 're', 'audio': 'reh'},
    {'character': 'ろ', 'romaji': 'ro', 'audio': 'roh'},
    {'character': 'わ', 'romaji': 'wa', 'audio': 'wah'},
    {'character': 'を', 'romaji': 'wo', 'audio': 'woh'},
    {'character': 'ん', 'romaji': 'n', 'audio': 'n'},
  ];

  // Katakana data
  final katakanaLetters = [
    {'character': 'ア', 'romaji': 'a', 'audio': 'ah'},
    {'character': 'イ', 'romaji': 'i', 'audio': 'ee'},
    {'character': 'ウ', 'romaji': 'u', 'audio': 'oo'},
    {'character': 'エ', 'romaji': 'e', 'audio': 'eh'},
    {'character': 'オ', 'romaji': 'o', 'audio': 'oh'},
    {'character': 'カ', 'romaji': 'ka', 'audio': 'kah'},
    {'character': 'キ', 'romaji': 'ki', 'audio': 'kee'},
    {'character': 'ク', 'romaji': 'ku', 'audio': 'koo'},
    {'character': 'ケ', 'romaji': 'ke', 'audio': 'keh'},
    {'character': 'コ', 'romaji': 'ko', 'audio': 'koh'},
    {'character': 'サ', 'romaji': 'sa', 'audio': 'sah'},
    {'character': 'シ', 'romaji': 'shi', 'audio': 'shee'},
    {'character': 'ス', 'romaji': 'su', 'audio': 'soo'},
    {'character': 'セ', 'romaji': 'se', 'audio': 'seh'},
    {'character': 'ソ', 'romaji': 'so', 'audio': 'soh'},
    {'character': 'タ', 'romaji': 'ta', 'audio': 'tah'},
    {'character': 'チ', 'romaji': 'chi', 'audio': 'chee'},
    {'character': 'ツ', 'romaji': 'tsu', 'audio': 'tsoo'},
    {'character': 'テ', 'romaji': 'te', 'audio': 'teh'},
    {'character': 'ト', 'romaji': 'to', 'audio': 'toh'},
    {'character': 'ナ', 'romaji': 'na', 'audio': 'nah'},
    {'character': 'ニ', 'romaji': 'ni', 'audio': 'nee'},
    {'character': 'ヌ', 'romaji': 'nu', 'audio': 'noo'},
    {'character': 'ネ', 'romaji': 'ne', 'audio': 'neh'},
    {'character': 'ノ', 'romaji': 'no', 'audio': 'noh'},
    {'character': 'ハ', 'romaji': 'ha', 'audio': 'hah'},
    {'character': 'ヒ', 'romaji': 'hi', 'audio': 'hee'},
    {'character': 'フ', 'romaji': 'fu', 'audio': 'foo'},
    {'character': 'ヘ', 'romaji': 'he', 'audio': 'heh'},
    {'character': 'ホ', 'romaji': 'ho', 'audio': 'hoh'},
    {'character': 'マ', 'romaji': 'ma', 'audio': 'mah'},
    {'character': 'ミ', 'romaji': 'mi', 'audio': 'mee'},
    {'character': 'ム', 'romaji': 'mu', 'audio': 'moo'},
    {'character': 'メ', 'romaji': 'me', 'audio': 'meh'},
    {'character': 'モ', 'romaji': 'mo', 'audio': 'moh'},
    {'character': 'ヤ', 'romaji': 'ya', 'audio': 'yah'},
    {'character': 'ユ', 'romaji': 'yu', 'audio': 'yoo'},
    {'character': 'ヨ', 'romaji': 'yo', 'audio': 'yoh'},
    {'character': 'ラ', 'romaji': 'ra', 'audio': 'rah'},
    {'character': 'リ', 'romaji': 'ri', 'audio': 'ree'},
    {'character': 'ル', 'romaji': 'ru', 'audio': 'roo'},
    {'character': 'レ', 'romaji': 're', 'audio': 'reh'},
    {'character': 'ロ', 'romaji': 'ro', 'audio': 'roh'},
    {'character': 'ワ', 'romaji': 'wa', 'audio': 'wah'},
    {'character': 'ヲ', 'romaji': 'wo', 'audio': 'woh'},
    {'character': 'ン', 'romaji': 'n', 'audio': 'n'},
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    lastInteraction = DateTime.now();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _cardFlipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get currentLetters =>
      selectedScript == "Hiragana" ? hiraganaLetters : katakanaLetters;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
              Color(0xFFDDD6FE),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(size),
                _buildProgressBar(size),
                _buildScriptSelector(size),
                Expanded(
                  child: _buildLearningCard(size),
                ),
                _buildControls(size),
                _buildBottomActions(size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(size.width * 0.025),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios,
                color: const Color(0xFF475569),
                size: size.width * 0.05,
              ),
            ),
          ),
          SizedBox(width: size.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Japanese Letters',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.06,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Master ${selectedScript.toLowerCase()}',
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.032,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    if (streakCount > 0) ...[
                      SizedBox(width: size.width * 0.02),
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.02,
                                vertical: size.width * 0.01,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.local_fire_department,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(width: size.width * 0.01),
                                  Text(
                                    '$streakCount',
                                    style: GoogleFonts.poppins(
                                      fontSize: size.width * 0.025,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showAllCharacters,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.03,
                vertical: size.width * 0.02,
              ),
              margin: EdgeInsets.only(right: size.width * 0.02),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.view_module,
                    color: Colors.white,
                    size: size.width * 0.04,
                  ),
                  SizedBox(width: size.width * 0.01),
                  Text(
                    'All',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.028,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: EdgeInsets.all(size.width * 0.03),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    selectedScript == "Hiragana" ? 'あ' : 'ア',
                    style: GoogleFonts.notoSansJp(
                      fontSize: size.width * 0.06,
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

  Widget _buildProgressBar(Size size) {
    final progress = (currentLetterIndex + 1) / currentLetters.length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.035,
                  color: const Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${currentLetterIndex + 1} / ${currentLetters.length}',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.035,
                      color: const Color(0xFF8B5CF6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: size.width * 0.02),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.02,
                      vertical: size.width * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.025,
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: size.height * 0.008),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                selectedScript == "Hiragana"
                    ? const Color(0xFF8B5CF6)
                    : const Color(0xFF3B82F6),
              ),
              minHeight: size.height * 0.008,
            ),
          ),
          SizedBox(height: size.height * 0.015),
        ],
      ),
    );
  }

  Widget _buildScriptSelector(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _selectScript("Hiragana"),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                decoration: BoxDecoration(
                  gradient: selectedScript == "Hiragana"
                      ? const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                  )
                      : null,
                  color: selectedScript == "Hiragana" ? null : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selectedScript == "Hiragana"
                        ? Colors.transparent
                        : const Color(0xFFE2E8F0),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: selectedScript == "Hiragana"
                          ? const Color(0xFF8B5CF6).withOpacity(0.3)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: selectedScript == "Hiragana" ? 12 : 6,
                      offset: Offset(0, selectedScript == "Hiragana" ? 4 : 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ひ',
                      style: GoogleFonts.notoSansJp(
                        fontSize: size.width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: selectedScript == "Hiragana"
                            ? Colors.white
                            : const Color(0xFF8B5CF6),
                      ),
                    ),
                    SizedBox(width: size.width * 0.02),
                    Text(
                      'Hiragana',
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.038,
                        fontWeight: FontWeight.bold,
                        color: selectedScript == "Hiragana"
                            ? Colors.white
                            : const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: GestureDetector(
              onTap: () => _selectScript("Katakana"),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                decoration: BoxDecoration(
                  gradient: selectedScript == "Katakana"
                      ? const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  )
                      : null,
                  color: selectedScript == "Katakana" ? null : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selectedScript == "Katakana"
                        ? Colors.transparent
                        : const Color(0xFFE2E8F0),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: selectedScript == "Katakana"
                          ? const Color(0xFF3B82F6).withOpacity(0.3)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: selectedScript == "Katakana" ? 12 : 6,
                      offset: Offset(0, selectedScript == "Katakana" ? 4 : 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'カ',
                      style: GoogleFonts.notoSansJp(
                        fontSize: size.width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: selectedScript == "Katakana"
                            ? Colors.white
                            : const Color(0xFF3B82F6),
                      ),
                    ),
                    SizedBox(width: size.width * 0.02),
                    Text(
                      'Katakana',
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.038,
                        fontWeight: FontWeight.bold,
                        color: selectedScript == "Katakana"
                            ? Colors.white
                            : const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningCard(Size size) {
    final currentLetter = currentLetters[currentLetterIndex];

    return Padding(
      padding: EdgeInsets.all(size.width * 0.04),
      child: GestureDetector(
        onTap: _flipCard,
        child: AnimatedBuilder(
          animation: _cardFlipAnimation,
          builder: (context, child) {
            final isShowingFront = _cardFlipAnimation.value < 0.5;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_cardFlipAnimation.value * math.pi),
              child: Container(
                width: double.infinity,
                height: size.height * 0.4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: selectedScript == "Hiragana"
                        ? const Color(0xFF8B5CF6).withOpacity(0.3)
                        : const Color(0xFF3B82F6).withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: selectedScript == "Hiragana"
                          ? const Color(0xFF8B5CF6).withOpacity(0.15)
                          : const Color(0xFF3B82F6).withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: isShowingFront
                    ? _buildCardFront(currentLetter, size)
                    : _buildCardBack(currentLetter, size),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardFront(Map<String, String> letter, Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(size.width * 0.06),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: selectedScript == "Hiragana"
                  ? [
                const Color(0xFF8B5CF6).withOpacity(0.1),
                const Color(0xFFA855F7).withOpacity(0.1),
              ]
                  : [
                const Color(0xFF3B82F6).withOpacity(0.1),
                const Color(0xFF1D4ED8).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            letter['character']!,
            style: GoogleFonts.notoSansJp(
              fontSize: size.width * 0.25,
              fontWeight: FontWeight.bold,
              color: selectedScript == "Hiragana"
                  ? const Color(0xFF8B5CF6)
                  : const Color(0xFF3B82F6),
            ),
          ),
        ),
        SizedBox(height: size.height * 0.03),
        Text(
          'Tap to see pronunciation',
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.035,
            color: const Color(0xFF6B7280),
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.01,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            _getMemoryAid(letter['character']!),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.03,
              color: const Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardBack(Map<String, String> letter, Size size) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            letter['romaji']!.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.15,
              fontWeight: FontWeight.bold,
              color: selectedScript == "Hiragana"
                  ? const Color(0xFF8B5CF6)
                  : const Color(0xFF3B82F6),
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.06,
              vertical: size.height * 0.015,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: selectedScript == "Hiragana"
                    ? [
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                  const Color(0xFFA855F7).withOpacity(0.1),
                ]
                    : [
                  const Color(0xFF3B82F6).withOpacity(0.1),
                  const Color(0xFF1D4ED8).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Sounds like: "${letter['audio']!}"',
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.04,
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.03),
          Text(
            'Practice writing this character!',
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.032,
              color: const Color(0xFF6B7280),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.skip_previous,
            onTap: _previousLetter,
            enabled: currentLetterIndex > 0,
            size: size,
          ),
          _buildControlButton(
            icon: Icons.volume_up,
            onTap: _playAudio,
            enabled: true,
            size: size,
            isSpecial: true,
          ),
          _buildControlButton(
            icon: Icons.flip,
            onTap: _flipCard,
            enabled: true,
            size: size,
          ),
          _buildControlButton(
            icon: Icons.skip_next,
            onTap: _nextLetter,
            enabled: currentLetterIndex < currentLetters.length - 1,
            size: size,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
    required Size size,
    bool isSpecial = false,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          gradient: enabled
              ? (isSpecial
              ? const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFFF6B35)],
          )
              : LinearGradient(
            colors: selectedScript == "Hiragana"
                ? [const Color(0xFF8B5CF6), const Color(0xFFA855F7)]
                : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
          ))
              : null,
          color: enabled ? null : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(15),
          boxShadow: enabled
              ? [
            BoxShadow(
              color: (isSpecial
                  ? const Color(0xFFF59E0B)
                  : selectedScript == "Hiragana"
                  ? const Color(0xFF8B5CF6)
                  : const Color(0xFF3B82F6))
                  .withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : const Color(0xFF9CA3AF),
          size: size.width * 0.06,
        ),
      ),
    );
  }

  Widget _buildBottomActions(Size size) {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.04),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _startQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06B6D4),
                padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.quiz, color: Colors.white),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    'Quiz',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: ElevatedButton(
              onPressed: _practiceWriting,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit, color: Colors.white),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    'Write',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  void _selectScript(String script) {
    setState(() {
      selectedScript = script;
      currentLetterIndex = 0;
      isFlipped = false;
      lastInteraction = DateTime.now();
      streakCount++;
    });
    _cardController.reset();
  }

  void _flipCard() {
    if (_cardController.isCompleted) {
      _cardController.reverse();
    } else {
      _cardController.forward();
    }
    setState(() {
      lastInteraction = DateTime.now();
    });
  }

  void _nextLetter() {
    if (currentLetterIndex < currentLetters.length - 1) {
      setState(() {
        currentLetterIndex++;
        lastInteraction = DateTime.now();
        streakCount++;
      });
      _cardController.reset();
    }
  }

  void _previousLetter() {
    if (currentLetterIndex > 0) {
      setState(() {
        currentLetterIndex--;
        lastInteraction = DateTime.now();
      });
      _cardController.reset();
    }
  }

  void _playAudio() {
    setState(() {
      lastInteraction = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up, color: Colors.white),
            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
            Text('Playing: ${currentLetters[currentLetterIndex]['audio']}'),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _startQuiz() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Quick Quiz',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Test your knowledge of the characters you\'ve learned!',
          style: GoogleFonts.poppins(color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Later',
              style: GoogleFonts.poppins(color: const Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06B6D4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              'Start Quiz',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _practiceWriting() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Practice Writing',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Practice writing ${selectedScript.toLowerCase()} characters!',
          style: GoogleFonts.poppins(color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Later',
              style: GoogleFonts.poppins(color: const Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              'Start Writing',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllCharacters() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _AllCharactersScreen(
          selectedScript: selectedScript,
          letters: currentLetters,
        ),
      ),
    );
  }

  String _getMemoryAid(String character) {
    final memoryAids = {
      'あ': 'Like a person saying "Ah!"',
      'い': 'Two sticks standing upright',
      'う': 'A person bowing down',
      'え': 'An elephant\'s trunk',
      'お': 'A surprised face',
      'か': 'A kite in the wind',
      'き': 'A key shape',
      'く': 'A bird\'s beak',
      'け': 'A person kneeling',
      'こ': 'Two horizontal lines',
      'さ': 'A person sitting',
      'し': 'A curved line',
      'す': 'A swan swimming',
      'せ': 'A world map',
      'そ': 'A needle and thread',
      'た': 'A cross or "t" shape',
      'ち': 'A cheerleader\'s pom-pom',
      'つ': 'A tsunami wave',
      'て': 'A telephone pole',
      'と': 'A toe pointing',
      'な': 'A knot in rope',
      'に': 'A knee bending',
      'ぬ': 'Noodles on chopsticks',
      'ね': 'A cat\'s tail',
      'の': 'A "no" sign',
      'は': 'A house with chimney',
      'ひ': 'A person\'s face in profile',
      'ふ': 'A hook or "f" shape',
      'へ': 'A mountain peak',
      'ほ': 'A house with steps',
      'ま': 'A mama with baby',
      'み': 'Music note',
      'む': 'A cow saying "moo"',
      'め': 'An eye looking',
      'も': 'A fishing hook',
      'や': 'A yak\'s head',
      'ゆ': 'A unique swirl',
      'よ': 'A yo-yo string',
      'ら': 'A rabbit hopping',
      'り': 'A river flowing',
      'る': 'A loop or curl',
      'れ': 'A reception desk',
      'ろ': 'A road sign',
      'わ': 'A wavy line',
      'を': 'A person doing yoga',
      'ん': 'A simple "n" curve',
      // Katakana
      'ア': 'Sharp angles like "A"',
      'イ': 'Two straight lines',
      'ウ': 'Like a "U" shape',
      'エ': 'Elevator going up',
      'オ': 'Open mouth saying "Oh"',
      'カ': 'Sharp cutting motion',
      'キ': 'A key with teeth',
      'ク': 'A person bowing',
      'ケ': 'Ketchup bottle',
      'コ': 'Corner of a box',
      'サ': 'Samurai sword',
      'シ': 'Shooting arrow',
      'ス': 'Straight line with hook',
      'セ': 'Set of stairs',
      'ソ': 'Sewing needle',
      'タ': 'A tall building',
      'チ': 'A cheerful face',
      'ツ': 'Two sharp points',
      'テ': 'A television antenna',
      'ト': 'A totem pole',
      'ナ': 'A knife cutting',
      'ニ': 'Two equal lines',
      'ヌ': 'A nunchuck',
      'ネ': 'A net for catching',
      'ノ': 'A number one',
      'ハ': 'A house roof',
      'ヒ': 'A person standing',
      'フ': 'A hook hanging',
      'ヘ': 'A mountain slope',
      'ホ': 'A cross with line',
      'マ': 'A map grid',
      'ミ': 'Three lines',
      'ム': 'A moon crescent',
      'メ': 'A mesh or net',
      'モ': 'A more complex shape',
      'ヤ': 'A yacht sail',
      'ユ': 'A unique fork',
      'ヨ': 'A yoga pose',
      'ラ': 'A ladder rung',
      'リ': 'Two vertical lines',
      'ル': 'A loop with tail',
      'レ': 'A rectangle corner',
      'ロ': 'A rectangular box',
      'ワ': 'A wide opening',
      'ヲ': 'A complex "wo"',
      'ン': 'A simple dash',
    };
    return memoryAids[character] ?? 'Remember this character!';
  }
}

// All Characters Screen
class _AllCharactersScreen extends StatelessWidget {
  final String selectedScript;
  final List<Map<String, String>> letters;

  const _AllCharactersScreen({
    required this.selectedScript,
    required this.letters,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final crossAxisCount = (size.width / 80).floor().clamp(4, 6);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
              Color(0xFFDDD6FE),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(size.width * 0.025),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: const Color(0xFF475569),
                          size: size.width * 0.05,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                          vertical: size.height * 0.015,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: selectedScript == "Hiragana"
                                ? [const Color(0xFF8B5CF6), const Color(0xFFA855F7)]
                                : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: (selectedScript == "Hiragana"
                                  ? const Color(0xFF8B5CF6)
                                  : const Color(0xFF3B82F6)).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              selectedScript == "Hiragana" ? 'あ' : 'ア',
                              style: GoogleFonts.notoSansJp(
                                fontSize: size.width * 0.05,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: size.width * 0.02),
                            Flexible(
                              child: Text(
                                '$selectedScript Chart',
                                style: GoogleFonts.poppins(
                                  fontSize: size.width * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Characters Grid
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: size.width * 0.02,
                      mainAxisSpacing: size.width * 0.02,
                    ),
                    itemCount: letters.length,
                    itemBuilder: (context, index) {
                      final letter = letters[index];
                      return GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.volume_up, color: Colors.white),
                                  SizedBox(width: size.width * 0.02),
                                  Text('${letter['character']} - ${letter['romaji']}'),
                                ],
                              ),
                              backgroundColor: selectedScript == "Hiragana"
                                  ? const Color(0xFF8B5CF6)
                                  : const Color(0xFF3B82F6),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                letter['character']!,
                                style: GoogleFonts.notoSansJp(
                                  fontSize: size.width * 0.06,
                                  fontWeight: FontWeight.bold,
                                  color: selectedScript == "Hiragana"
                                      ? const Color(0xFF8B5CF6)
                                      : const Color(0xFF3B82F6),
                                ),
                              ),
                              SizedBox(height: size.height * 0.005),
                              Text(
                                letter['romaji']!,
                                style: GoogleFonts.poppins(
                                  fontSize: size.width * 0.025,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}