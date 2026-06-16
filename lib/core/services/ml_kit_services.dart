// import 'package:flutter/cupertino.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:sime_v2/core/services/africa_id_parser.dart';
// import 'package:sime_v2/core/services/mz_parser.dart';
// import 'package:sime_v2/core/services/scanned_document.dart';

// class MLKitService {
//   final TextRecognizer _recognizer = TextRecognizer(
//     script: TextRecognitionScript.latin,
//   );

//   Future<ScannedDocument?> scanDocument(InputImage image) async {
//     try {
//       final recognized = await _recognizer.processImage(image);

//       debugPrint('========== OCR RAW TEXT ==========');
//       debugPrint(recognized.text);
//       debugPrint('==================================');

//       if (recognized.text.trim().isEmpty) {
//         debugPrint('⚠️ Aucun texte détecté par ML Kit');
//         return null;
//       }

//       final normalized = _normalize(recognized.text);

//       debugPrint('========== NORMALIZED TEXT ==========');
//       debugPrint(normalized);
//       debugPrint('=====================================');

//       /// 1️⃣ Passport / MRZ
//       final mrz = MrzParser.parse(normalized);

//       if (mrz != null && !mrz.isEmpty) {
//         debugPrint('✅ MRZ détectée');
//         return mrz;
//       }

//       /// 2️⃣ Carte CEDEAO / Afrique
//       final africa = AfricaIdParser.parse(normalized);

//       if (africa == null) {
//         debugPrint('⚠️ AfricaIdParser n\'a trouvé aucun champ');
//       } else {
//         debugPrint('✅ Document africain détecté');
//       }

//       return africa;
//     } catch (e, stack) {
//       debugPrint('💥 Erreur ML Kit: $e');
//       debugPrint(stack.toString());
//       return null;
//     }
//   }

//   String _normalize(String text) {
//     return text
//         .toUpperCase()
//         .replaceAll('«', '<')
//         .replaceAll('‹', '<');
//   }

//   void dispose() {
//     _recognizer.close();
//   }
// }