// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart' show PdfPageFormat;
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
//
// void main() {
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: JapaneseResumeScreen(),
//   ));
// }
//
// class JapaneseResumeScreen extends StatefulWidget {
//   @override
//   _JapaneseResumeScreenState createState() => _JapaneseResumeScreenState();
// }
//
// class _JapaneseResumeScreenState extends State<JapaneseResumeScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   String fullName = '';
//   DateTime? dob;
//   String gender = '男性';
//   String address = '';
//   String phone = '';
//   String email = '';
//   String education = '';
//   String qualifications = '';
//   String motivation = '';
//   String selfPromo = '';
//
//   Future<void> _pickDOB() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: dob ?? DateTime(1990),
//       firstDate: DateTime(1950),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && picked != dob) {
//       setState(() {
//         dob = picked;
//       });
//     }
//   }
//
//   Future<void> _generateResumePDF() async {
//     final pdf = pw.Document();
//
//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) {
//           return pw.Padding(
//             padding: pw.EdgeInsets.all(24),
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text('履歴書', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
//                 pw.SizedBox(height: 16),
//                 pw.Text('氏名: $fullName'),
//                 pw.Text('生年月日: ${dob != null ? '${dob!.year}年${dob!.month}月${dob!.day}日' : ''}'),
//                 pw.Text('性別: $gender'),
//                 pw.Text('住所: $address'),
//                 pw.Text('電話番号: $phone'),
//                 pw.Text('メールアドレス: $email'),
//                 pw.SizedBox(height: 16),
//                 pw.Text('学歴・職歴:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//                 pw.Text(education),
//                 pw.SizedBox(height: 8),
//                 pw.Text('資格・免許:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//                 pw.Text(qualifications),
//                 pw.SizedBox(height: 8),
//                 pw.Text('志望動機:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//                 pw.Text(motivation),
//                 pw.SizedBox(height: 8),
//                 pw.Text('自己PR:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//                 pw.Text(selfPromo),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//
//     await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async => pdf.save(),
//     );
//   }
//
//   void _submit() {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       _generateResumePDF(); // Generate and preview PDF
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('日本語履歴書ジェネレーター')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 decoration: InputDecoration(labelText: '氏名 (Full Name)'),
//                 onSaved: (val) => fullName = val ?? '',
//                 validator: (val) => val!.isEmpty ? '必須項目です' : null,
//               ),
//               ListTile(
//                 title: Text('生年月日: ${dob != null ? '${dob!.year}/${dob!.month}/${dob!.day}' : '未選択'}'),
//                 trailing: Icon(Icons.calendar_today),
//                 onTap: _pickDOB,
//               ),
//               DropdownButtonFormField<String>(
//                 value: gender,
//                 decoration: InputDecoration(labelText: '性別 (Gender)'),
//                 items: ['男性', '女性', 'その他'].map((String value) {
//                   return DropdownMenuItem(value: value, child: Text(value));
//                 }).toList(),
//                 onChanged: (val) => setState(() => gender = val ?? '男性'),
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: '住所'),
//                 onSaved: (val) => address = val ?? '',
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: '電話番号'),
//                 keyboardType: TextInputType.phone,
//                 onSaved: (val) => phone = val ?? '',
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'メールアドレス'),
//                 keyboardType: TextInputType.emailAddress,
//                 onSaved: (val) => email = val ?? '',
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: '学歴・職歴'),
//                 maxLines: 3,
//                 onSaved: (val) => education = val ?? '',
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: '資格・免許'),
//                 maxLines: 2,
//                 onSaved: (val) => qualifications = val ?? '',
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: '志望動機'),
//                 maxLines: 3,
//                 onSaved: (val) => motivation = val ?? '',
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: '自己PR'),
//                 maxLines: 3,
//                 onSaved: (val) => selfPromo = val ?? '',
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _submit,
//                 child: Text('履歴書を生成'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
