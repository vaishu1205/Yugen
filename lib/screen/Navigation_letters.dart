// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_tts/flutter_tts.dart';
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
//
//   // Animation Controllers
//   late AnimationController _animationController;
//   late AnimationController _cardFlipController;
//   late AnimationController _pulseController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _slideAnimation;
//   late Animation<double> _cardFlipAnimation;
//   late Animation<double> _pulseAnimation;
//
//   // TTS
//   late FlutterTts _flutterTts;
//
//   // Current State
//   String _selectedScript = 'hiragana'; // 'hiragana' or 'katakana'
//   String _currentMode = 'learn'; // 'learn', 'practice', 'quiz'
//   int _currentIndex = 0;
//   bool _showRomaji = false;
//   bool _isCardFlipped = false;
//   int _streak = 0;
//   int _correctAnswers = 0;
//   int _totalAnswers = 0;
//
//   // User Progress
//   Map<String, Set<String>> learnedCharacters = {
//     'hiragana': {},
//     'katakana': {},
//   };
//
//   // Hiragana Data
//   final Map<String, Map<String, String>> hiraganaData = {
//     'あ': {'romaji': 'a', 'example': 'あさ (asa) - morning'},
//     'い': {'romaji': 'i', 'example': 'いえ (ie) - house'},
//     'う': {'romaji': 'u', 'example': 'うみ (umi) - sea'},
//     'え': {'romaji': 'e', 'example': 'えき (eki) - station'},
//     'お': {'romaji': 'o', 'example': 'おはよう (ohayou) - good morning'},
//     'か': {'romaji': 'ka', 'example': 'かぞく (kazoku) - family'},
//     'き': {'romaji': 'ki', 'example': 'きれい (kirei) - beautiful'},
//     'く': {'romaji': 'ku', 'example': 'くるま (kuruma) - car'},
//     'け': {'romaji': 'ke', 'example': 'けいたい (keitai) - mobile phone'},
//     'こ': {'romaji': 'ko', 'example': 'こども (kodomo) - child'},
//     'さ': {'romaji': 'sa', 'example': 'さくら (sakura) - cherry blossom'},
//     'し': {'romaji': 'shi', 'example': 'しごと (shigoto) - work'},
//     'す': {'romaji': 'su', 'example': 'すし (sushi) - sushi'},
//     'せ': {'romaji': 'se', 'example': 'せんせい (sensei) - teacher'},
//     'そ': {'romaji': 'so', 'example': 'そら (sora) - sky'},
//     'た': {'romaji': 'ta', 'example': 'たべもの (tabemono) - food'},
//     'ち': {'romaji': 'chi', 'example': 'ちいさい (chiisai) - small'},
//     'つ': {'romaji': 'tsu', 'example': 'つき (tsuki) - moon'},
//     'て': {'romaji': 'te', 'example': 'てがみ (tegami) - letter'},
//     'と': {'romaji': 'to', 'example': 'ともだち (tomodachi) - friend'},
//     'な': {'romaji': 'na', 'example': 'なまえ (namae) - name'},
//     'に': {'romaji': 'ni', 'example': 'にほん (nihon) - Japan'},
//     'ぬ': {'romaji': 'nu', 'example': 'ぬいぐるみ (nuigurumi) - stuffed toy'},
//     'ね': {'romaji': 'ne', 'example': 'ねこ (neko) - cat'},
//     'の': {'romaji': 'no', 'example': 'のみもの (nomimono) - drink'},
//     'は': {'romaji': 'ha', 'example': 'はな (hana) - flower'},
//     'ひ': {'romaji': 'hi', 'example': 'ひと (hito) - person'},
//     'ふ': {'romaji': 'fu', 'example': 'ふゆ (fuyu) - winter'},
//     'へ': {'romaji': 'he', 'example': 'へや (heya) - room'},
//     'ほ': {'romaji': 'ho', 'example': 'ほん (hon) - book'},
//     'ま': {'romaji': 'ma', 'example': 'まち (machi) - town'},
//     'み': {'romaji': 'mi', 'example': 'みず (mizu) - water'},
//     'む': {'romaji': 'mu', 'example': 'むずかしい (muzukashii) - difficult'},
//     'め': {'romaji': 'me', 'example': 'め (me) - eye'},
//     'も': {'romaji': 'mo', 'example': 'もの (mono) - thing'},
//     'や': {'romaji': 'ya', 'example': 'やま (yama) - mountain'},
//     'ゆ': {'romaji': 'yu', 'example': 'ゆき (yuki) - snow'},
//     'よ': {'romaji': 'yo', 'example': 'よる (yoru) - night'},
//     'ら': {'romaji': 'ra', 'example': 'らいねん (rainen) - next year'},
//     'り': {'romaji': 'ri', 'example': 'りんご (ringo) - apple'},
//     'る': {'romaji': 'ru', 'example': 'るす (rusu) - absence'},
//     'れ': {'romaji': 're', 'example': 'れいぞうこ (reizouko) - refrigerator'},
//     'ろ': {'romaji': 'ro', 'example': 'ろく (roku) - six'},
//     'わ': {'romaji': 'wa', 'example': 'わたし (watashi) - I/me'},
//     'を': {'romaji': 'wo', 'example': 'パンをたべる (pan wo taberu) - eat bread'},
//     'ん': {'romaji': 'n', 'example': 'にほん (nihon) - Japan'},
//   };
//
//   // Katakana Data
//   final Map<String, Map<String, String>> katakanaData = {
//     'ア': {'romaji': 'a', 'example': 'アメリカ (amerika) - America'},
//     'イ': {'romaji': 'i', 'example': 'イタリア (itaria) - Italy'},
//     'ウ': {'romaji': 'u', 'example': 'ウイルス (uirusu) - virus'},
//     'エ': {'romaji': 'e', 'example': 'エレベーター (erebeetaa) - elevator'},
//     'オ': {'romaji': 'o', 'example': 'オレンジ (orenji) - orange'},
//     'カ': {'romaji': 'ka', 'example': 'カメラ (kamera) - camera'},
//     'キ': {'romaji': 'ki', 'example': 'キーボード (kiiboodo) - keyboard'},
//     'ク': {'romaji': 'ku', 'example': 'クッキー (kukkii) - cookie'},
//     'ケ': {'romaji': 'ke', 'example': 'ケーキ (keeki) - cake'},
//     'コ': {'romaji': 'ko', 'example': 'コーヒー (koohii) - coffee'},
//     'サ': {'romaji': 'sa', 'example': 'サラダ (sarada) - salad'},
//     'シ': {'romaji': 'shi', 'example': 'シャツ (shatsu) - shirt'},
//     'ス': {'romaji': 'su', 'example': 'スポーツ (supootsu) - sports'},
//     'セ': {'romaji': 'se', 'example': 'セーター (seetaa) - sweater'},
//     'ソ': {'romaji': 'so', 'example': 'ソファー (sofaa) - sofa'},
//     'タ': {'romaji': 'ta', 'example': 'タクシー (takushii) - taxi'},
//     'チ': {'romaji': 'chi', 'example': 'チーズ (chiizu) - cheese'},
//     'ツ': {'romaji': 'tsu', 'example': 'ツアー (tsuaa) - tour'},
//     'テ': {'romaji': 'te', 'example': 'テレビ (terebi) - television'},
//     'ト': {'romaji': 'to', 'example': 'トマト (tomato) - tomato'},
//     'ナ': {'romaji': 'na', 'example': 'ナイフ (naifu) - knife'},
//     'ニ': {'romaji': 'ni', 'example': 'ニュース (nyuusu) - news'},
//     'ヌ': {'romaji': 'nu', 'example': 'ヌードル (nuudoru) - noodle'},
//     'ネ': {'romaji': 'ne', 'example': 'ネット (netto) - net/internet'},
//     'ノ': {'romaji': 'no', 'example': 'ノート (nooto) - notebook'},
//     'ハ': {'romaji': 'ha', 'example': 'ハンバーガー (hanbaagaa) - hamburger'},
//     'ヒ': {'romaji': 'hi', 'example': 'ヒーター (hiitaa) - heater'},
//     'フ': {'romaji': 'fu', 'example': 'フォーク (fooku) - fork'},
//     'ヘ': {'romaji': 'he', 'example': 'ヘルメット (herumetto) - helmet'},
//     'ホ': {'romaji': 'ho', 'example': 'ホテル (hoteru) - hotel'},
//     'マ': {'romaji': 'ma', 'example': 'マウス (mausu) - mouse'},
//     'ミ': {'romaji': 'mi', 'example': 'ミルク (miruku) - milk'},
//     'ム': {'romaji': 'mu', 'example': 'ムービー (muubii) - movie'},
//     'メ': {'romaji': 'me', 'example': 'メール (meeru) - email'},
//     'モ': {'romaji': 'mo', 'example': 'モニター (monitaa) - monitor'},
//     'ヤ': {'romaji': 'ya', 'example': 'ヤード (yaado) - yard'},
//     'ユ': {'romaji': 'yu', 'example': 'ユーザー (yuuzaa) - user'},
//     'ヨ': {'romaji': 'yo', 'example': 'ヨーグルト (yooguruto) - yogurt'},
//     'ラ': {'romaji': 'ra', 'example': 'ラジオ (rajio) - radio'},
//     'リ': {'romaji': 'ri', 'example': 'リモコン (rimokon) - remote control'},
//     'ル': {'romaji': 'ru', 'example': 'ルール (ruuru) - rule'},
//     'レ': {'romaji': 're', 'example': 'レストラン (resutoran) - restaurant'},
//     'ロ': {'romaji': 'ro', 'example': 'ロボット (robotto) - robot'},
//     'ワ': {'romaji': 'wa', 'example': 'ワイン (wain) - wine'},
//     'ヲ': {'romaji': 'wo', 'example': 'rarely used in modern Japanese'},
//     'ン': {'romaji': 'n', 'example': 'サン (san) - three'},
//   };
//
//   List<String> get currentCharacters => _selectedScript == 'hiragana'
//       ? hiraganaData.keys.toList()
//       : katakanaData.keys.toList();
//
//   Map<String, Map<String, String>> get currentData => _selectedScript == 'hiragana'
//       ? hiraganaData
//       : katakanaData;
//
//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//     _initTTS();
//     _loadProgress();
//   }
//
//   void _initAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//
//     _cardFlipController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
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
//       CurvedAnimation(parent: _cardFlipController, curve: Curves.easeInOut),
//     );
//
//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//
//     _animationController.forward();
//     _pulseController.repeat(reverse: true);
//   }
//
//   void _initTTS() {
//     _flutterTts = FlutterTts();
//     _flutterTts.setLanguage('ja-JP');
//     _flutterTts.setSpeechRate(0.5);
//     _flutterTts.setVolume(1.0);
//     _flutterTts.setPitch(1.0);
//   }
//
//   Future<void> _loadProgress() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final doc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();
//
//         if (doc.exists) {
//           final data = doc.data()!;
//           setState(() {
//             learnedCharacters['hiragana'] = Set<String>.from(
//                 data['learnedHiragana'] ?? []
//             );
//             learnedCharacters['katakana'] = Set<String>.from(
//                 data['learnedKatakana'] ?? []
//             );
//             _streak = data['letterStreak'] ?? 0;
//           });
//         }
//       }
//     } catch (e) {
//       print('Error loading progress: $e');
//     }
//   }
//
//   Future<void> _saveProgress() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .update({
//           'learnedHiragana': learnedCharacters['hiragana']!.toList(),
//           'learnedKatakana': learnedCharacters['katakana']!.toList(),
//           'letterStreak': _streak,
//           'lastStudyDate': FieldValue.serverTimestamp(),
//         });
//       }
//     } catch (e) {
//       print('Error saving progress: $e');
//     }
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     _cardFlipController.dispose();
//     _pulseController.dispose();
//     _flutterTts.stop();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isSmallScreen = size.width < 360;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1117),
//       body: Container(
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
//                 // Custom App Bar
//                 _buildCustomAppBar(size, isSmallScreen),
//
//                 // Mode Selector
//                 _buildModeSelector(size, isSmallScreen),
//
//                 // Script Selector
//                 _buildScriptSelector(size, isSmallScreen),
//
//                 // Progress Indicator
//                 _buildProgressIndicator(size, isSmallScreen),
//
//                 // Main Content
//                 Expanded(
//                   child: _buildMainContent(size, isSmallScreen),
//                 ),
//
//                 // Bottom Controls
//                 _buildBottomControls(size, isSmallScreen),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCustomAppBar(Size size, bool isSmallScreen) {
//     return Container(
//       padding: EdgeInsets.all(size.width * 0.04),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               padding: EdgeInsets.all(size.width * 0.025),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.2),
//                   width: 1,
//                 ),
//               ),
//               child: Icon(
//                 Icons.arrow_back_ios,
//                 color: Colors.white,
//                 size: size.width * 0.05,
//               ),
//             ),
//           ),
//           SizedBox(width: size.width * 0.04),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Learn ${_selectedScript.toUpperCase()}',
//                   style: GoogleFonts.poppins(
//                     fontSize: isSmallScreen ? size.width * 0.05 : size.width * 0.055,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Text(
//                   '${learnedCharacters[_selectedScript]!.length}/${currentCharacters.length} characters learned',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.03,
//                     color: Colors.white.withOpacity(0.7),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Streak indicator
//           Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: size.width * 0.03,
//               vertical: size.height * 0.005,
//             ),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFFFF6B35), Color(0xFFF59E0B)],
//               ),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   Icons.local_fire_department,
//                   color: Colors.white,
//                   size: size.width * 0.04,
//                 ),
//                 SizedBox(width: size.width * 0.01),
//                 Text(
//                   '$_streak',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.032,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildModeSelector(Size size, bool isSmallScreen) {
//     final modes = [
//       {'id': 'learn', 'name': 'Learn', 'icon': Icons.school, 'color': const Color(0xFF8B5CF6)},
//       {'id': 'practice', 'name': 'Practice', 'icon': Icons.fitness_center, 'color': const Color(0xFF10B981)},
//       {'id': 'quiz', 'name': 'Quiz', 'icon': Icons.quiz, 'color': const Color(0xFFEC4899)},
//     ];
//
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
//       child: Row(
//         children: modes.map((mode) {
//           final isSelected = _currentMode == mode['id'];
//           return Expanded(
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _currentMode = mode['id'] as String;
//                   _currentIndex = 0;
//                   _isCardFlipped = false;
//                 });
//                 _cardFlipController.reset();
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 margin: EdgeInsets.symmetric(horizontal: size.width * 0.01),
//                 padding: EdgeInsets.symmetric(
//                   vertical: size.height * 0.015,
//                 ),
//                 decoration: BoxDecoration(
//                   color: isSelected
//                       ? (mode['color'] as Color).withOpacity(0.2)
//                       : Colors.white.withOpacity(0.05),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color: isSelected
//                         ? (mode['color'] as Color)
//                         : Colors.white.withOpacity(0.2),
//                     width: isSelected ? 2 : 1,
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Icon(
//                       mode['icon'] as IconData,
//                       color: isSelected
//                           ? (mode['color'] as Color)
//                           : Colors.white.withOpacity(0.7),
//                       size: size.width * 0.06,
//                     ),
//                     SizedBox(height: size.height * 0.005),
//                     Text(
//                       mode['name'] as String,
//                       style: GoogleFonts.poppins(
//                         fontSize: size.width * 0.032,
//                         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                         color: isSelected
//                             ? Colors.white
//                             : Colors.white.withOpacity(0.7),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _buildScriptSelector(Size size, bool isSmallScreen) {
//     return Container(
//       margin: EdgeInsets.all(size.width * 0.04),
//       child: Row(
//         children: [
//           Expanded(
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _selectedScript = 'hiragana';
//                   _currentIndex = 0;
//                   _isCardFlipped = false;
//                 });
//                 _cardFlipController.reset();
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 padding: EdgeInsets.all(size.width * 0.04),
//                 decoration: BoxDecoration(
//                   gradient: _selectedScript == 'hiragana'
//                       ? const LinearGradient(
//                     colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
//                   )
//                       : null,
//                   color: _selectedScript != 'hiragana'
//                       ? Colors.white.withOpacity(0.1)
//                       : null,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color: _selectedScript == 'hiragana'
//                         ? Colors.transparent
//                         : Colors.white.withOpacity(0.3),
//                     width: 1,
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       'あ',
//                       style: GoogleFonts.notoSansJp(
//                         fontSize: size.width * 0.08,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.005),
//                     Text(
//                       'Hiragana',
//                       style: GoogleFonts.poppins(
//                         fontSize: size.width * 0.032,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       '${learnedCharacters['hiragana']!.length}/${hiraganaData.length}',
//                       style: GoogleFonts.poppins(
//                         fontSize: size.width * 0.028,
//                         color: Colors.white.withOpacity(0.8),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(width: size.width * 0.03),
//           Expanded(
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _selectedScript = 'katakana';
//                   _currentIndex = 0;
//                   _isCardFlipped = false;
//                 });
//                 _cardFlipController.reset();
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 padding: EdgeInsets.all(size.width * 0.04),
//                 decoration: BoxDecoration(
//                   gradient: _selectedScript == 'katakana'
//                       ? const LinearGradient(
//                     colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
//                   )
//                       : null,
//                   color: _selectedScript != 'katakana'
//                       ? Colors.white.withOpacity(0.1)
//                       : null,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color: _selectedScript == 'katakana'
//                         ? Colors.transparent
//                         : Colors.white.withOpacity(0.3),
//                     width: 1,
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       'ア',
//                       style: GoogleFonts.notoSansJp(
//                         fontSize: size.width * 0.08,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.005),
//                     Text(
//                       'Katakana',
//                       style: GoogleFonts.poppins(
//                         fontSize: size.width * 0.032,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       '${learnedCharacters['katakana']!.length}/${katakanaData.length}',
//                       style: GoogleFonts.poppins(
//                         fontSize: size.width * 0.028,
//                         color: Colors.white.withOpacity(0.8),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   **Project Title:** **"Yūgen: AI-Powered Japanese Learning Companion"** 🌟 **One-Liner:** An all-in-one AI-driven Japanese learning app that helps users master Kanji, grammar, resume writing, and storytelling through personalized content, quizzes, and interactive tools. 📝 **Project Description:*
//
//   pasted
//
//
//   import 'package:flutter/material.dart'; import 'package:google_fonts/google_fonts.dart'; import 'package:firebase_auth/firebase_auth.dart'; import 'package:cloud_firestore/cloud_firestore.dart'; import 'dart:math' as math; // Import your actual Kanji screen - update this path to match your fi
//
//   pasted
//
//   All most all screenm are done some screen left can you genmerate an nice enaging UI screens with functionality for that in bottom navigation bar where for learn and in navigation bar add letters option where in that he can study hiragana katakana for that page geneate a nice and fun enagging learning for users for both hiragana and katakana and also for this learn and page add new fautuers and make it more fun and learninf for them . Thhe UI should be responsive and attractive and no Pixel out errors
//
//   Edit
//   I'll create engaging UI screens for the Learn section and add a Letters (Hiragana/Katakana) learning feature. Let me build comprehensive screens with animations and interactive elements.
//
//
//   Learn Main Screen - Enhanced Learning Hub
//   Code
//
//
//
//   Continue
//
//   Edit
//
//   Learn Main Screen - Enhanced Learning Hub
//   Code ∙ Version 2
//   Now let me create the Letters Learning Screen with Hiragana and Katakana learning features:
//
//
//   Letters Learning Screen - Hiragana & Katakana
//   Code
//
//
//
//   If the code is very long and difficlt generate give in parts if your ok with that
//
//   Edit
//   You're absolutely right! Let me break this down into manageable parts. I'll start with the first part of the Letters Learning Screen:
//
//
//   Letters Learning Screen - Hiragana & Katakana
//   Code ∙ Version 2
//   Perfect! Now let me create the second part with the main content area and learning features:
//
//
//   Letters Learning Screen - Part 2 (Main Content & Features)
//   Code
//
//
//
//   Continue
//
//   Edit
//
//   Letters Learning Screen - Part 2 (Main Content & Features)
//   Code ∙ Version 2
//   Now let me create the final part with all the action methods and utility functions:
//
//
//   Letters Learning Screen - Part 3 (Action Methods & Utilities)
//   Code
//
//
//
//   Continue
//
//   Edit
//
//   Letters Learning Screen - Part 3 (Action Methods & Utilities)
//   Code ∙ Version 2
//   Perfect! Now let me update the main HomeScreen to include navigation to the new Learn section. I'll update the bottom navigation to integrate properly:
//
//
//   Learn Main Screen - Enhanced Learning Hub
//   Code ∙ Version 3
//   Now let me update the existing HomeScreen to properly connect to the new Learn section:
//
//
//   Learn Main Screen - Enhanced Learning Hub
//   Code ∙ Version 4
//   Now, let me create a simple update to show how to integrate this into your existing HomeScreen navigation:
//
//
//   HomeScreen Navigation Update - Integration Guide
//   Code
//   Great! I've created a comprehensive learning system for your Yūgen app. Here's what I've built:
//
//   🎯 What's Been Created:
//   1. Enhanced Learn Main Screen (LearnMainScreen)
//   Beautiful UI with animated cards and responsive design
//   Progress tracking with visual indicators and streaks
//   Category filtering (All, Letters, Kanji, Grammar, Practice)
//   Multiple learning modules including the new Letters feature
//   Daily challenges and achievement system
//   AI Learning button for future adaptive learning
//   2. Complete Letters Learning Screen (LettersLearningScreen)
//   Three Modes:
//   📚 Learn Mode: Interactive character cards with flip animation
//   🏋️ Practice Mode: Self-assessment with learned characters
//   🧠 Quiz Mode: Multiple choice tests with randomized options
//   3. Comprehensive Hiragana & Katakana Data
//   Complete character sets with romaji and example words
//   Audio pronunciation using Flutter TTS
//   Progress tracking per script (Hiragana/Katakana)
//   Firebase integration for saving user progress
//   4. Interactive Features:
//   ✨ Flip animations for character cards
//   🔊 Text-to-Speech for pronunciation
//   🔥 Streak tracking and gamification
//   📊 Progress visualization with circular and linear indicators
//   🎯 Smart quizzing with wrong answer generation
//   5. Placeholder Screens for Future Development:
//   Vocabulary Builder
//   Grammar Patterns
//   Listening Practice
//   Speaking Practice
//   Flashcards
//   Achievements
//   🎨 Key Features:
//   Responsive Design:
//   Works perfectly on all screen sizes
//   Dynamic font scaling and spacing
//   Adaptive layouts for small screens
//   Engaging Animations:
//   Card flip animations
//   Floating effects
//   Pulse animations
//   Smooth transitions
//   User Experience:
//   Intuitive navigation
//   Clear progress feedback
//   Success/error messages
//   Audio feedback
//   Firebase Integration:
//   User progress saving
//   Character learning tracking
//   Streak maintenance
//   Real-time data sync
//   🚀 How to Integrate:
//   Add the new screens to your project
//   Update your HomeScreen navigation using the provided integration guide
//   Ensure you have the required dependencies:
//   yaml
//   dependencies:
//   flutter_tts: ^3.8.5
//   firebase_auth: ^4.15.3
//   cloud_firestore: ^4.13.6
//   google_fonts: ^6.1.0
//   Update your imports in the HomeScreen to include the new screens
//   🎯 What Makes This Special:
//   Complete Learning System: From basic character recognition to advanced quizzing
//   Gamification: Streaks, progress tracking, and achievements
//   Accessibility: Audio pronunciation and clear visual feedback
//   Scalable Architecture: Easy to add more learning features
//   Modern UI: Beautiful gradients, animations, and responsive design
//   This creates a comprehensive, engaging learning experience that will make foreign students excited to learn Japanese characters! The UI is designed to be both beautiful and functional, with plenty of visual feedback to keep users motivated. 🌸✨
//
//
//
//
//
//
//
//
// // Continue from Letters Learning Screen Part 1
//
//   Widget _buildProgressIndicator(Size size, bool isSmallScreen) {
//   final progress = learnedCharacters[_selectedScript]!.length / currentCharacters.length;
//
//   return Container(
//   margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
//   padding: EdgeInsets.all(size.width * 0.04),
//   decoration: BoxDecoration(
//   color: Colors.white.withOpacity(0.05),
//   borderRadius: BorderRadius.circular(16),
//   border: Border.all(
//   color: Colors.white.withOpacity(0.1),
//   width: 1,
//   ),
//   ),
//   child: Column(
//   children: [
//   Row(
//   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   children: [
//   Text(
//   'Progress',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.035,
//   color: Colors.white.withOpacity(0.8),
//   ),
//   ),
//   Text(
//   '${(progress * 100).toInt()}%',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.035,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   ),
//   ),
//   ],
//   ),
//   SizedBox(height: size.height * 0.01),
//   ClipRRect(
//   borderRadius: BorderRadius.circular(10),
//   child: LinearProgressIndicator(
//   value: progress,
//   backgroundColor: Colors.white.withOpacity(0.2),
//   valueColor: AlwaysStoppedAnimation<Color>(
//   _selectedScript == 'hiragana'
//   ? const Color(0xFF8B5CF6)
//       : const Color(0xFF10B981),
//   ),
//   minHeight: size.height * 0.008,
//   ),
//   ),
//   ],
//   ),
//   );
//   }
//
//   Widget _buildMainContent(Size size, bool isSmallScreen) {
//   switch (_currentMode) {
//   case 'learn':
//   return _buildLearnMode(size, isSmallScreen);
//   case 'practice':
//   return _buildPracticeMode(size, isSmallScreen);
//   case 'quiz':
//   return _buildQuizMode(size, isSmallScreen);
//   default:
//   return _buildLearnMode(size, isSmallScreen);
//   }
//   }
//
//   Widget _buildLearnMode(Size size, bool isSmallScreen) {
//   if (currentCharacters.isEmpty || _currentIndex >= currentCharacters.length) {
//   return _buildCompletionScreen(size, isSmallScreen);
//   }
//
//   final character = currentCharacters[_currentIndex];
//   final data = currentData[character]!;
//   final isLearned = learnedCharacters[_selectedScript]!.contains(character);
//
//   return AnimatedBuilder(
//   animation: _slideAnimation,
//   builder: (context, child) {
//   return Transform.translate(
//   offset: Offset(0, _slideAnimation.value),
//   child: Padding(
//   padding: EdgeInsets.all(size.width * 0.04),
//   child: Column(
//   children: [
//   // Character Card
//   Expanded(
//   flex: 3,
//   child: _buildCharacterCard(character, data, size, isSmallScreen),
//   ),
//
//   SizedBox(height: size.height * 0.02),
//
//   // Character Info
//   Expanded(
//   flex: 2,
//   child: _buildCharacterInfo(character, data, size, isSmallScreen),
//   ),
//
//   SizedBox(height: size.height * 0.02),
//
//   // Action Buttons
//   _buildActionButtons(character, isLearned, size, isSmallScreen),
//   ],
//   ),
//   ),
//   );
//   },
//   );
//   }
//
//   Widget _buildCharacterCard(String character, Map<String, String> data, Size size, bool isSmallScreen) {
//   return GestureDetector(
//   onTap: _flipCard,
//   child: AnimatedBuilder(
//   animation: _cardFlipAnimation,
//   builder: (context, child) {
//   final isShowingFront = _cardFlipAnimation.value < 0.5;
//   return Transform(
//   alignment: Alignment.center,
//   transform: Matrix4.identity()
//   ..setEntry(3, 2, 0.001)
//   ..rotateY(_cardFlipAnimation.value * math.pi),
//   child: Container(
//   width: double.infinity,
//   decoration: BoxDecoration(
//   gradient: LinearGradient(
//   colors: _selectedScript == 'hiragana'
//   ? [
//   const Color(0xFF8B5CF6).withOpacity(0.2),
//   const Color(0xFFEC4899).withOpacity(0.2),
//   ]
//       : [
//   const Color(0xFF10B981).withOpacity(0.2),
//   const Color(0xFF06B6D4).withOpacity(0.2),
//   ],
//   ),
//   borderRadius: BorderRadius.circular(24),
//   border: Border.all(
//   color: _selectedScript == 'hiragana'
//   ? const Color(0xFF8B5CF6).withOpacity(0.3)
//       : const Color(0xFF10B981).withOpacity(0.3),
//   width: 2,
//   ),
//   boxShadow: [
//   BoxShadow(
//   color: (_selectedScript == 'hiragana'
//   ? const Color(0xFF8B5CF6)
//       : const Color(0xFF10B981)).withOpacity(0.3),
//   blurRadius: 20,
//   offset: const Offset(0, 8),
//   ),
//   ],
//   ),
//   child: isShowingFront || !_isCardFlipped
//   ? _buildCardFront(character, size, isSmallScreen)
//       : _buildCardBack(data, size, isSmallScreen),
//   ),
//   );
//   },
//   ),
//   );
//   }
//
//   Widget _buildCardFront(String character, Size size, bool isSmallScreen) {
//   return Container(
//   child: Column(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: [
//   // Character
//   AnimatedBuilder(
//   animation: _pulseAnimation,
//   builder: (context, child) {
//   return Transform.scale(
//   scale: _pulseAnimation.value,
//   child: Text(
//   character,
//   style: GoogleFonts.notoSansJp(
//   fontSize: isSmallScreen ? size.width * 0.25 : size.width * 0.3,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   shadows: [
//   Shadow(
//   offset: const Offset(0, 4),
//   blurRadius: 8,
//   color: Colors.black.withOpacity(0.3),
//   ),
//   ],
//   ),
//   ),
//   );
//   },
//   ),
//
//   SizedBox(height: size.height * 0.02),
//
//   // Tap hint
//   Container(
//   padding: EdgeInsets.symmetric(
//   horizontal: size.width * 0.04,
//   vertical: size.height * 0.01,
//   ),
//   decoration: BoxDecoration(
//   color: Colors.white.withOpacity(0.1),
//   borderRadius: BorderRadius.circular(20),
//   ),
//   child: Text(
//   'Tap to see romaji',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.032,
//   color: Colors.white.withOpacity(0.8),
//   ),
//   ),
//   ),
//   ],
//   ),
//   );
//   }
//
//   Widget _buildCardBack(Map<String, String> data, Size size, bool isSmallScreen) {
//   return Transform(
//   alignment: Alignment.center,
//   transform: Matrix4.identity()..rotateY(math.pi),
//   child: Container(
//   child: Column(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: [
//   // Romaji
//   Text(
//   data['romaji']!.toUpperCase(),
//   style: GoogleFonts.poppins(
//   fontSize: isSmallScreen ? size.width * 0.15 : size.width * 0.18,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   letterSpacing: 2,
//   ),
//   ),
//
//   SizedBox(height: size.height * 0.02),
//
//   // Pronunciation Guide
//   Container(
//   padding: EdgeInsets.symmetric(
//   horizontal: size.width * 0.04,
//   vertical: size.height * 0.01,
//   ),
//   decoration: BoxDecoration(
//   color: Colors.white.withOpacity(0.1),
//   borderRadius: BorderRadius.circular(20),
//   ),
//   child: Text(
//   'Pronounced: "${data['romaji']!}"',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.032,
//   color: Colors.white.withOpacity(0.8),
//   ),
//   ),
//   ),
//   ],
//   ),
//   ),
//   );
//   }
//
//   Widget _buildCharacterInfo(String character, Map<String, String> data, Size size, bool isSmallScreen) {
//   return Container(
//   padding: EdgeInsets.all(size.width * 0.04),
//   decoration: BoxDecoration(
//   color: Colors.white.withOpacity(0.05),
//   borderRadius: BorderRadius.circular(16),
//   border: Border.all(
//   color: Colors.white.withOpacity(0.1),
//   width: 1,
//   ),
//   ),
//   child: Column(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: [
//   // Title
//   Row(
//   children: [
//   Icon(
//   Icons.info_outline,
//   color: _selectedScript == 'hiragana'
//   ? const Color(0xFF8B5CF6)
//       : const Color(0xFF10B981),
//   size: size.width * 0.05,
//   ),
//   SizedBox(width: size.width * 0.02),
//   Text(
//   'Character Info',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.04,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   ),
//   ),
//   ],
//   ),
//
//   SizedBox(height: size.height * 0.015),
//
//   // Romaji
//   Row(
//   children: [
//   Text(
//   'Romaji: ',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.035,
//   color: Colors.white.withOpacity(0.7),
//   ),
//   ),
//   Text(
//   data['romaji']!,
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.035,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   ),
//   ),
//   SizedBox(width: size.width * 0.02),
//   GestureDetector(
//   onTap: () => _speak(data['romaji']!),
//   child: Container(
//   padding: EdgeInsets.all(size.width * 0.02),
//   decoration: BoxDecoration(
//   color: const Color(0xFF8B5CF6).withOpacity(0.2),
//   borderRadius: BorderRadius.circular(8),
//   ),
//   child: Icon(
//   Icons.volume_up,
//   color: const Color(0xFF8B5CF6),
//   size: size.width * 0.04,
//   ),
//   ],
//   ),
//   ),
//   ),
//   ],
//   ),
//   );
//   }
//
//   // Practice Mode
//   Widget _buildPracticeMode(Size size, bool isSmallScreen) {
//   final learnedChars = learnedCharacters[_selectedScript]!.toList();
//   if (learnedChars.isEmpty) {
//   return _buildEmptyState(
//   'No characters learned yet!',
//   'Learn some characters first before practicing.',
//   Icons.school,
//   size,
//   isSmallScreen,
//   );
//   }
//
//   final character = learnedChars[_currentIndex % learnedChars.length];
//   final data = currentData[character]!;
//
//   return Padding(
//   padding: EdgeInsets.all(size.width * 0.04),
//   child: Column(
//   children: [
//   // Practice Header
//   Container(
//   padding: EdgeInsets.all(size.width * 0.04),
//   decoration: BoxDecoration(
//   gradient: LinearGradient(
//   colors: [
//   const Color(0xFF10B981).withOpacity(0.1),
//   const Color(0xFF06B6D4).withOpacity(0.1),
//   ],
//   ),
//   borderRadius: BorderRadius.circular(16),
//   ),
//   child: Row(
//   children: [
//   Icon(
//   Icons.fitness_center,
//   color: const Color(0xFF10B981),
//   size: size.width * 0.06,
//   ),
//   SizedBox(width: size.width * 0.03),
//   Expanded(
//   child: Column(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: [
//   Text(
//   'Practice Mode',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.045,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   ),
//   ),
//   Text(
//   'Review learned characters',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.032,
//   color: Colors.white.withOpacity(0.7),
//   ),
//   ),
//   ],
//   ),
//   ),
//   Text(
//   '${_correctAnswers}/${_totalAnswers}',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.035,
//   fontWeight: FontWeight.bold,
//   color: const Color(0xFF10B981),
//   ),
//   ),
//   ],
//   ),
//   ),
//
//   SizedBox(height: size.height * 0.03),
//
//   // Practice Card
//   Expanded(
//   child: _buildPracticeCard(character, data, size, isSmallScreen),
//   ),
//
//   SizedBox(height: size.height * 0.02),
//
//   // Practice Controls
//   _buildPracticeControls(size, isSmallScreen),
//   ],
//   ),
//   );
//   }
//
//   Widget _buildPracticeCard(String character, Map<String, String> data, Size size, bool isSmallScreen) {
//   return Container(
//   width: double.infinity,
//   padding: EdgeInsets.all(size.width * 0.06),
//   decoration: BoxDecoration(
//   gradient: LinearGradient(
//   colors: [
//   const Color(0xFF10B981).withOpacity(0.1),
//   const Color(0xFF06B6D4).withOpacity(0.1),
//   ],
//   ),
//   borderRadius: BorderRadius.circular(24),
//   border: Border.all(
//   color: const Color(0xFF10B981).withOpacity(0.3),
//   width: 2,
//   ),
//   ),
//   child: Column(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: [
//   Text(
//   'What is this character?',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.04,
//   color: Colors.white.withOpacity(0.8),
//   ),
//   ),
//
//   SizedBox(height: size.height * 0.03),
//
//   Text(
//   character,
//   style: GoogleFonts.notoSansJp(
//   fontSize: size.width * 0.3,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   ),
//   ),
//
//   SizedBox(height: size.height * 0.03),
//
//   if (_showRomaji) ...[
//   Container(
//   padding: EdgeInsets.symmetric(
//   horizontal: size.width * 0.06,
//   vertical: size.height * 0.015,
//   ),
//   decoration: BoxDecoration(
//   color: const Color(0xFF10B981).withOpacity(0.2),
//   borderRadius: BorderRadius.circular(16),
//   ),
//   child: Text(
//   data['romaji']!.toUpperCase(),
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.06,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   ),
//   ),
//   ),
//   ],
//   ],
//   ),
//   );
//   }
//
//   Widget _buildPracticeControls(Size size, bool isSmallScreen) {
//   return Column(
//   children: [
//   // Show/Hide Answer
//   SizedBox(
//   width: double.infinity,
//   child: ElevatedButton(
//   onPressed: () {
//   setState(() {
//   _showRomaji = !_showRomaji;
//   });
//   },
//   style: ElevatedButton.styleFrom(
//   backgroundColor: _showRomaji
//   ? const Color(0xFF10B981)
//       : const Color(0xFF8B5CF6),
//   padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
//   shape: RoundedRectangleBorder(
//   borderRadius: BorderRadius.circular(12),
//   ),
//   ),
//   child: Text(
//   _showRomaji ? 'Hide Answer' : 'Show Answer',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.04,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   ),
//   ),
//   ),
//   ),
//
//   if (_showRomaji) ...[
//   SizedBox(height: size.height * 0.015),
//   Row(
//   children: [
//   // Correct Button
//   Expanded(
//   child: ElevatedButton(
//   onPressed: () => _handlePracticeAnswer(true),
//   style: ElevatedButton.styleFrom(
//   backgroundColor: const Color(0xFF10B981),
//   padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
//   shape: RoundedRectangleBorder(
//   borderRadius: BorderRadius.circular(12),
//   ),
//   ),
//   child: Row(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: [
//   Icon(
//   Icons.check,
//   color: Colors.white,
//   size: size.width * 0.05,
//   ),
//   SizedBox(width: size.width * 0.02),
//   Text(
//   'Correct',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.035,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   ),
//   ),
//   ],
//   ),
//   ),
//   ),
//
//   SizedBox(width: size.width * 0.03),
//
//   // Incorrect Button
//   Expanded(
//   child: ElevatedButton(
//   onPressed: () => _handlePracticeAnswer(false),
//   style: ElevatedButton.styleFrom(
//   backgroundColor: const Color(0xFFEF4444),
//   padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
//   shape: RoundedRectangleBorder(
//   borderRadius: BorderRadius.circular(12),
//   ),
//   ),
//   child: Row(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: [
//   Icon(
//   Icons.close,
//   color: Colors.white,
//   size: size.width * 0.05,
//   ),
//   SizedBox(width: size.width * 0.02),
//   Text(
//   'Incorrect',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.035,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   ),
//   ),
//   ],
//   ),
//   ),
//   ),
//   ],
//   ),
//   ],
//   ],
//   );
//   }
//
//   // Quiz Mode
//   Widget _buildQuizMode(Size size, bool isSmallScreen) {
//   final learnedChars = learnedCharacters[_selectedScript]!.toList();
//   if (learnedChars.isEmpty) {
//   return _buildEmptyState(
//   'No characters to quiz!',
//   'Learn some characters first before taking a quiz.',
//   Icons.quiz,
//   size,
//   isSmallScreen,
//   );
//   }
//
//   if (learnedChars.length < 4) {
//   return _buildEmptyState(
//   'Need more characters!',
//   'Learn at least 4 characters to take a quiz.',
//   Icons.quiz,
//   size,
//   isSmallScreen,
//   );
//   }
//
//   return _buildQuizContent(learnedChars, size, isSmallScreen);
//   }
//
//   Widget _buildQuizContent(List<String> learnedChars, Size size, bool isSmallScreen) {
//   final currentChar = learnedChars[_currentIndex % learnedChars.length];
//   final correctAnswer = currentData[currentChar]!['romaji']!;
//
//   // Generate wrong answers
//   final wrongAnswers = <String>[];
//   final allRomaji = currentData.values.map((e) => e['romaji']!).toList();
//   allRomaji.shuffle();
//
//   for (final romaji in allRomaji) {
//   if (romaji != correctAnswer && wrongAnswers.length < 3) {
//   wrongAnswers.add(romaji);
//   }
//   }
//
//   final options = [correctAnswer, ...wrongAnswers]..shuffle();
//
//   return Padding(
//   padding: EdgeInsets.all(size.width * 0.04),
//   child: Column(
//   children: [
//   // Quiz Header
//   Container(
//   padding: EdgeInsets.all(size.width * 0.04),
//   decoration: BoxDecoration(
//   gradient: LinearGradient(
//   colors: [
//   const Color(0xFFEC4899).withOpacity(0.1),
//   const Color(0xFF8B5CF6).withOpacity(0.1),
//   ],
//   ),
//   borderRadius: BorderRadius.circular(16),
//   ),
//   child: Row(
//   children: [
//   Icon(
//   Icons.quiz,
//   color: const Color(0xFFEC4899),
//   size: size.width * 0.06,
//   ),
//   SizedBox(width: size.width * 0.03),
//   Expanded(
//   child: Column(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: [
//   Text(
//   'Quiz Mode',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.045,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   ),
//   ),
//   Text(
//   'Choose the correct romaji',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.032,
//   color: Colors.white.withOpacity(0.7),
//   ),
//   ),
//   ],
//   ),
//   ),
//   Text(
//   '${_correctAnswers}/${_totalAnswers}',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.035,
//   fontWeight: FontWeight.bold,
//   color: const Color(0xFFEC4899),
//   ),
//   ),
//   ],
//   ),
//   ),
//
//   SizedBox(height: size.height * 0.03),
//
//   // Question
//   Expanded(
//   flex: 2,
//   child: Container(
//   width: double.infinity,
//   padding: EdgeInsets.all(size.width * 0.06),
//   decoration: BoxDecoration(
//   gradient: LinearGradient(
//   colors: [
//   const Color(0xFFEC4899).withOpacity(0.1),
//   const Color(0xFF8B5CF6).withOpacity(0.1),
//   ],
//   ),
//   borderRadius: BorderRadius.circular(24),
//   border: Border.all(
//   color: const Color(0xFFEC4899).withOpacity(0.3),
//   width: 2,
//   ),
//   ),
//   child: Column(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: [
//   Text(
//   'What is the romaji for:',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.04,
//   color: Colors.white.withOpacity(0.8),
//   ),
//   ),
//
//   SizedBox(height: size.height * 0.03),
//
//   Text(
//   currentChar,
//   style: GoogleFonts.notoSansJp(
//   fontSize: size.width * 0.25,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   ),
//   ),
//   ],
//   ),
//   ),
//   ),
//
//   SizedBox(height: size.height * 0.03),
//
//   // Options
//   Expanded(
//   flex: 2,
//   child: GridView.builder(
//   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//   crossAxisCount: 2,
//   crossAxisSpacing: 12,
//   mainAxisSpacing: 12,
//   childAspectRatio: 2.5,
//   ),
//   itemCount: options.length,
//   itemBuilder: (context, index) {
//   final option = options[index];
//   return GestureDetector(
//   onTap: () => _handleQuizAnswer(option, correctAnswer),
//   child: Container(
//   decoration: BoxDecoration(
//   color: Colors.white.withOpacity(0.1),
//   borderRadius: BorderRadius.circular(16),
//   border: Border.all(
//   color: Colors.white.withOpacity(0.3),
//   width: 1,
//   ),
//   ),
//   child: Center(
//   child: Text(
//   option.toUpperCase(),
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.04,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   ),
//   ),
//   ),
//   ),
//   );
//   },
//   ),
//   ),
//   ],
//   ),
//   );
//   }
//
//   Widget _buildEmptyState(String title, String subtitle, IconData icon, Size size, bool isSmallScreen) {
//   return Center(
//   child: Padding(
//   padding: EdgeInsets.all(size.width * 0.06),
//   child: Column(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: [
//   Icon(
//   icon,
//   size: size.width * 0.15,
//   color: Colors.white.withOpacity(0.5),
//   ),
//   SizedBox(height: size.height * 0.02),
//   Text(
//   title,
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.05,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   ),
//   textAlign: TextAlign.center,
//   ),
//   SizedBox(height: size.height * 0.01),
//   Text(
//   subtitle,
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.035,
//   color: Colors.white.withOpacity(0.7),
//   ),
//   textAlign: TextAlign.center,
//   ),
//   SizedBox(height: size.height * 0.03),
//   ElevatedButton(
//   onPressed: () {
//   setState(() {
//   _currentMode = 'learn';
//   _currentIndex = 0;
//   });
//   },
//   style: ElevatedButton.styleFrom(
//   backgroundColor: const Color(0xFF8B5CF6),
//   padding: EdgeInsets.symmetric(
//   horizontal: size.width * 0.08,
//   vertical: size.height * 0.015,
//   ),
//   shape: RoundedRectangleBorder(
//   borderRadius: BorderRadius.circular(12),
//   ),
//   ),
//   child: Text(
//   'Start Learning',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.035,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   ),
//   ),
//   ),
//   ],
//   ),
//   ),
//   );
//   }
//
//   Widget _buildCompletionScreen(Size size, bool isSmallScreen) {
//   return Center(
//   child: Padding(
//   padding: EdgeInsets.all(size.width * 0.06),
//   child: Column(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: [
//   Text(
//   '🎉',
//   style: TextStyle(fontSize: size.width * 0.2),
//   ),
//   SizedBox(height: size.height * 0.02),
//   Text(
//   'Congratulations!',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.06,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   ),
//   textAlign: TextAlign.center,
//   ),
//   SizedBox(height: size.height * 0.01),
//   Text(
//   'You\'ve completed all ${_selectedScript} characters!',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.04,
//   color: Colors.white.withOpacity(0.8),
//   ),
//   textAlign: TextAlign.center,
//   ),
//   SizedBox(height: size.height * 0.03),
//   Row(
//   children: [
//   Expanded(
//   child: ElevatedButton(
//   onPressed: () {
//   setState(() {
//   _currentMode = 'practice';
//   _currentIndex = 0;
//   });
//   },
//   style: ElevatedButton.styleFrom(
//   backgroundColor: const Color(0xFF10B981),
//   padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
//   shape: RoundedRectangleBorder(
//   borderRadius: BorderRadius.circular(12),
//   ),
//   ),
//   child: Text(
//   'Practice',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.035,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   ),
//   ),
//   ),
//   ),
//   SizedBox(width: size.width * 0.03),
//   Expanded(
//   child: ElevatedButton(
//   onPressed: () {
//   setState(() {
//   _selectedScript = _selectedScript == 'hiragana' ? 'katakana' : 'hiragana';
//   _currentMode = 'learn';
//   _currentIndex = 0;
//   });
//   },
//   style: ElevatedButton.styleFrom(
//   backgroundColor: const Color(0xFF8B5CF6),
//   padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
//   shape: RoundedRectangleBorder(
//   borderRadius: BorderRadius.circular(12),
//   ),
//   ),
//   child: Text(
//   _selectedScript == 'hiragana' ? 'Try Katakana' : 'Try Hiragana',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.035,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   ),
//   ),
//   ),
//   ),
//   ],
//   ),
//   ],
//   ),
//   ),
//   );
//   }
//   ),
//   ),
//   ),
//   ],
//   ),
//
//   SizedBox(height: size.height * 0.01),
//
//   // Example
//   Text(
//   'Example:',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.035,
//   color: Colors.white.withOpacity(0.7),
//   ),
//   ),
//
//   SizedBox(height: size.height * 0.005),
//
//   Container(
//   width: double.infinity,
//   padding: EdgeInsets.all(size.width * 0.03),
//   decoration: BoxDecoration(
//   color: Colors.white.withOpacity(0.05),
//   borderRadius: BorderRadius.circular(12),
//   ),
//   child: Text(
//   data['example']!,
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.032,
//   color: Colors.white.withOpacity(0.9),
//   height: 1.4,
//   ),
//   ),
//   ),
//   ],
//   ),
//   );
// }
//
// Widget _buildActionButtons(String character, bool isLearned, Size size, bool isSmallScreen) {
//   return Row(
//     children: [
//       // Mark as Learned/Unlearned
//       Expanded(
//         child: ElevatedButton(
//           onPressed: () => _toggleLearned(character),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: isLearned
//                 ? const Color(0xFF10B981)
//                 : const Color(0xFF8B5CF6),
//             padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 isLearned ? Icons.check_circle : Icons.star_border,
//                 color: Colors.white,
//                 size: size.width * 0.05,
//               ),
//               SizedBox(width: size.width * 0.02),
//               Text(
//                 isLearned ? 'Learned!' : 'Mark Learned',
//                 style: GoogleFonts.poppins(
//                   fontSize: size.width * 0.035,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//
//       SizedBox(width: size.width * 0.03),
//
//       // Audio Button
//       Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               const Color(0xFFFF6B35).withOpacity(0.8),
//               const Color(0xFFF59E0B).withOpacity(0.8),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: ElevatedButton(
//           onPressed: () => _speak(character),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.transparent,
//             shadowColor: Colors.transparent,
//             padding: EdgeInsets.symmetric(
//               horizontal: size.width * 0.06,
//               vertical: size.height * 0.018,
//             ),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           child: Icon(
//             Icons.volume_up,
//             color: Colors.white,
//             size: size.width * 0.06,
//           ),
//         ),
//       ),
//     ],
//   );
// }
//
// Widget _buildBottomControls(Size size, bool isSmallScreen) {
//   return Container(
//     padding: EdgeInsets.all(size.width * 0.04),
//     decoration: BoxDecoration(
//       color: const Color(0xFF1C2128),
//       borderRadius: const BorderRadius.only(
//         topLeft: Radius.circular(20),
//         topRight: Radius.circular(20),
//       ),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.3),
//           blurRadius: 10,
//           offset: const Offset(0, -2),
//         ),
//       ],
//     ),
//     child: Row(
//       children: [
//     // Previous Button
//     Expanded(
//     child: ElevatedButton(
//     onPressed: _currentIndex > 0 ? _previousCharacter : null,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: _currentIndex > 0
//             ? Colors.white.withOpacity(0.1)
//             : Colors.white.withOpacity(0.05),
//         padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.arrow_back_ios,
//             color: _currentIndex > 0
//                 ? Colors.white
//                 : Colors.white.withOpacity(0.5),
//             size: size.width * 0.04,
//           ),
//           SizedBox(width: size.width * 0.01),
//           Text(
//             'Previous',
//             style: GoogleFonts.poppins(
//               fontSize: size.width * 0.032,
//               color: _currentIndex > 0
//                   ? Colors.white
//                   : Colors.white.withOpacity(0.5),
//             ),
//           ),
//         ],
//       ),
//     ),
//   ),
//
//   SizedBox(width: size.width * 0.03),
//
//   // Character Counter
//   Container(
//   padding: EdgeInsets.symmetric(
//   horizontal: size.width * 0.04,
//   vertical: size.height * 0.018,
//   ),
//   decoration: BoxDecoration(
//   color: Colors.white.withOpacity(0.1),
//   borderRadius: BorderRadius.circular(12),
//   ),
//   child: Text(
//   '${_currentIndex + 1}/${currentCharacters.length}',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.032,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
//   ),
//   ),
//   ),
//
//   SizedBox(width: size.width * 0.03),
//
//   // Next Button
//   Expanded(
//   child: ElevatedButton(
//   onPressed: _currentIndex < currentCharacters.length - 1 ? _nextCharacter : null,
//   style: ElevatedButton.styleFrom(
//   backgroundColor: _currentIndex < currentCharacters.length - 1
//   ? const Color(0xFF8B5CF6)
//       : Colors.white.withOpacity(0.05),
//   padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
//   shape: RoundedRectangleBorder(
//   borderRadius: BorderRadius.circular(12),
//   ),
//   ),
//   child: Row(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: [
//   Text(
//   'Next',
//   style: GoogleFonts.poppins(
//   fontSize: size.width * 0.032,
//   color: _currentIndex < currentCharacters.length - 1
//   ? Colors.white
//       : Colors.white.withOpacity(0.5),
//   ),
//   ),
//   SizedBox(width: size.width * 0.01),
//   Icon(
//   Icons.arrow_forward_ios,
//   color: _currentIndex < currentCharacters.length - 1
//   ? Colors.white
//
//   // Continue from Letters Learning Screen Part 2
//   // Action Methods
//
//   void _flipCard() {
//   if (_cardFlipController.isCompleted) {
//   _cardFlipController.reverse();
//   setState(() {
//   _isCardFlipped = false;
//   });
//   } else {
//   _cardFlipController.forward();
//   setState(() {
//   _isCardFlipped = true;
//   });
//   }
//   }
//
//   void _toggleLearned(String character) {
//   setState(() {
//   if (learnedCharacters[_selectedScript]!.contains(character)) {
//   learnedCharacters[_selectedScript]!.remove(character);
//   _showSuccessMessage('Removed from learned characters');
//   } else {
//   learnedCharacters[_selectedScript]!.add(character);
//   _streak++;
//   _showSuccessMessage('Character learned! 🎉');
//   }
//   });
//   _saveProgress();
//   }
//
//   void _nextCharacter() {
//   if (_currentIndex < currentCharacters.length - 1) {
//   setState(() {
//   _currentIndex++;
//   _isCardFlipped = false;
//   _showRomaji = false;
//   });
//   _cardFlipController.reset();
//   }
//   }
//
//   void _previousCharacter() {
//   if (_currentIndex > 0) {
//   setState(() {
//   _currentIndex--;
//   _isCardFlipped = false;
//   _showRomaji = false;
//   });
//   _cardFlipController.reset();
//   }
//   }
//
//   void _handlePracticeAnswer(bool isCorrect) {
//   setState(() {
//   _totalAnswers++;
//   if (isCorrect) {
//   _correctAnswers++;
//   }
//   _showRomaji = false;
//   });
//
//   if (isCorrect) {
//   _showSuccessMessage('Correct! Well done! 🎉');
//   } else {
//   _showErrorMessage('Keep practicing! 💪');
//   }
//
//   // Move to next character after a delay
//   Future.delayed(const Duration(milliseconds: 1500), () {
//   if (mounted) {
//   final learnedChars = learnedCharacters[_selectedScript]!.toList();
//   setState(() {
//   _currentIndex = (_currentIndex + 1) % learnedChars.length;
//   });
//   }
//   });
//   }
//
//   void _handleQuizAnswer(String selectedAnswer, String correctAnswer) {
//   setState(() {
//   _totalAnswers++;
//   if (selectedAnswer == correctAnswer) {
//   _correctAnswers++;
//   }
//   });
//
//   if (selectedAnswer == correctAnswer) {
//   _showSuccessMessage('Correct! 🎉');
//   _speak(correctAnswer);
//   } else {
//   _showErrorMessage('Incorrect. The answer was: $correctAnswer');
//   _speak(correctAnswer);
//   }
//
//   // Move to next question after a delay
//   Future.delayed(const Duration(milliseconds: 2000), () {
//   if (mounted) {
//   final learnedChars = learnedCharacters[_selectedScript]!.toList();
//   setState(() {
//   _currentIndex = (_currentIndex + 1) % learnedChars.length;
//   });
//   }
//   });
//   }
//
//   Future<void> _speak(String text) async {
//   try {
//   await _flutterTts.speak(text);
//   } catch (e) {
//   print('TTS Error: $e');
//   _showErrorMessage('Audio not available');
//   }
//   }
//
//   void _showSuccessMessage(String message) {
//   if (!mounted) return;
//   ScaffoldMessenger.of(context).showSnackBar(
//   SnackBar(
//   content: Row(
//   children: [
//   const Icon(Icons.check_circle, color: Colors.white),
//   const SizedBox(width: 8),
//   Expanded(
//   child: Text(
//   message,
//   style: GoogleFonts.poppins(color: Colors.white),
//   ),
//   ),
//   ],
//   ),
//   backgroundColor: const Color(0xFF10B981),
//   duration: const Duration(seconds: 2),
//   behavior: SnackBarBehavior.floating,
//   shape: RoundedRectangleBorder(
//   borderRadius: BorderRadius.circular(12),
//   ),
//   ),
//   );
//   }
//
//   void _showErrorMessage(String message) {
//   if (!mounted) return;
//   ScaffoldMessenger.of(context).showSnackBar(
//   SnackBar(
//   content: Row(
//   children: [
//   const Icon(Icons.error_outline, color: Colors.white),
//   const SizedBox(width: 8),
//   Expanded(
//   child: Text(
//   message,
//   style: GoogleFonts.poppins(color: Colors.white),
//   ),
//   ),
//   ],
//   ),
//   backgroundColor: const Color(0xFFEF4444),
//   duration: const Duration(seconds: 3),
//   behavior: SnackBarBehavior.floating,
//   shape: RoundedRectangleBorder(
//   borderRadius: BorderRadius.circular(12),
//   ),
//   ),
//   );
//   }
// }
//
// // Additional Utility Screens for completeness
//
// // Vocabulary Screen Placeholder
// class VocabularyScreen extends StatelessWidget {
//   const VocabularyScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1117),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         title: Text(
//           'Vocabulary',
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Container(
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
//         child: Center(
//           child: Padding(
//             padding: EdgeInsets.all(size.width * 0.06),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.psychology,
//                   size: size.width * 0.15,
//                   color: const Color(0xFF10B981),
//                 ),
//                 SizedBox(height: size.height * 0.02),
//                 Text(
//                   'Vocabulary Builder',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.06,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.01),
//                 Text(
//                   'Coming Soon! Build your Japanese vocabulary with interactive lessons.',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.035,
//                     color: Colors.white.withOpacity(0.7),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Grammar Patterns Screen Placeholder
// class GrammarPatternsScreen extends StatelessWidget {
//   const GrammarPatternsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1117),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         title: Text(
//           'Grammar Patterns',
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Container(
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
//         child: Center(
//           child: Padding(
//             padding: EdgeInsets.all(size.width * 0.06),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.account_tree,
//                   size: size.width * 0.15,
//                   color: const Color(0xFF06B6D4),
//                 ),
//                 SizedBox(height: size.height * 0.02),
//                 Text(
//                   'Grammar Patterns',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.06,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.01),
//                 Text(
//                   'Coming Soon! Master Japanese grammar patterns step by step.',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.035,
//                     color: Colors.white.withOpacity(0.7),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Listening Practice Screen Placeholder
// class ListeningPracticeScreen extends StatelessWidget {
//   const ListeningPracticeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1117),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         title: Text(
//           'Listening Practice',
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Container(
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
//         child: Center(
//           child: Padding(
//             padding: EdgeInsets.all(size.width * 0.06),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.headphones,
//                   size: size.width * 0.15,
//                   color: const Color(0xFFF59E0B),
//                 ),
//                 SizedBox(height: size.height * 0.02),
//                 Text(
//                   'Listening Practice',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.06,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.01),
//                 Text(
//                   'Coming Soon! Improve your listening skills with audio exercises.',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.035,
//                     color: Colors.white.withOpacity(0.7),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Speaking Practice Screen Placeholder
// class SpeakingPracticeScreen extends StatelessWidget {
//   const SpeakingPracticeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1117),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         title: Text(
//           'Speaking Practice',
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Container(
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
//         child: Center(
//           child: Padding(
//             padding: EdgeInsets.all(size.width * 0.06),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.mic,
//                   size: size.width * 0.15,
//                   color: const Color(0xFFFF6B35),
//                 ),
//                 SizedBox(height: size.height * 0.02),
//                 Text(
//                   'Speaking Practice',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.06,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.01),
//                 Text(
//                   'Coming Soon! Practice pronunciation with AI feedback.',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.035,
//                     color: Colors.white.withOpacity(0.7),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Flashcards Screen Placeholder
// class FlashcardsScreen extends StatelessWidget {
//   const FlashcardsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1117),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         title: Text(
//           'Flashcards',
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Container(
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
//         child: Center(
//           child: Padding(
//             padding: EdgeInsets.all(size.width * 0.06),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.style,
//                   size: size.width * 0.15,
//                   color: const Color(0xFF8B5CF6),
//                 ),
//                 SizedBox(height: size.height * 0.02),
//                 Text(
//                   'Flashcards',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.06,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.01),
//                 Text(
//                   'Coming Soon! Review with intelligent spaced repetition flashcards.',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.035,
//                     color: Colors.white.withOpacity(0.7),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Achievement Screen Placeholder
// class AchievementScreen extends StatelessWidget {
//   const AchievementScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1117),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         title: Text(
//           'Achievements',
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Container(
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
//         child: Center(
//           child: Padding(
//             padding: EdgeInsets.all(size.width * 0.06),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.emoji_events,
//                   size: size.width * 0.15,
//                   color: const Color(0xFFF59E0B),
//                 ),
//                 SizedBox(height: size.height * 0.02),
//                 Text(
//                   'Achievements',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.06,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.01),
//                 Text(
//                   'Coming Soon! Track your progress and unlock achievements.',
//                   style: GoogleFonts.poppins(
//                     fontSize: size.width * 0.035,
//                     color: Colors.white.withOpacity(0.7),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }