// import 'dart:io'; // Ajouté pour Platform.isAndroid / Platform.isIOS

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:sime_v2/core/const/app_routes.dart';
// import 'package:sime_v2/core/design_system/widgets/scan_overlay.dart';
// import 'package:sime_v2/core/providers/scan_result_provider.dart';
// import 'package:sime_v2/core/services/ml_kit_services.dart';
// import 'package:sime_v2/core/services/scanned_document.dart';
// import 'package:sime_v2/core/utils/camera_utils.dart';


// /// How many successful scans must agree before we accept and navigate.
// const _kRequiredConfirmations = 4;

// /// Minimum delay between two scan attempts.
// const _kScanInterval = Duration(milliseconds: 600);

// class IdentityScannerScreen extends ConsumerStatefulWidget {
//   const IdentityScannerScreen({super.key});

//   @override
//   ConsumerState<IdentityScannerScreen> createState() =>
//       _IdentityScannerScreenState();
// }

// class _IdentityScannerScreenState extends ConsumerState<IdentityScannerScreen> {
//   CameraController? _controller;
//   final MLKitService _mlKitService = MLKitService();

//   bool _processing = false;
//   bool _done = false;
//   DateTime? _lastScan;

//   // Accumulates the richest result seen across multiple scans
//   ScannedDocument? _accumulated;
//   int _confirmations = 0;

//   @override
//   void initState() {
//     super.initState();
//     _initCamera();
//   }

//   Future<void> _initCamera() async {
//     try {
//       final cameras = await availableCameras();
//       if (cameras.isEmpty || !mounted) {
//         debugPrint('❌ Aucune caméra disponible sur cet appareil.');
//         return;
//       }

//       _controller = CameraController(
//         cameras.first,
//         ResolutionPreset.high,
//         enableAudio: false,
//         // Aligne le format de flux d'images selon la plateforme pour éviter les soucis de conversion
//         imageFormatGroup: Platform.isAndroid
//             ? ImageFormatGroup.yuv420
//             : ImageFormatGroup.bgra8888,
//       );

//       await _controller!.initialize();
//       if (!mounted) return;

//       setState(() {});
//       _startImageStream();
//       debugPrint('📸 Caméra initialisée avec succès et stream lancé.');
//     } catch (e) {
//       debugPrint('💥 Erreur lors de l\'initialisation de la caméra: $e');
//     }
//   }

//   void _startImageStream() {
//     _controller!.startImageStream((CameraImage image) async {
//       if (_processing || _done) return;

//       final now = DateTime.now();
//       if (_lastScan != null && now.difference(_lastScan!) < _kScanInterval) {
//         return;
//       }

//       _lastScan = now;
//       _processing = true;

//       try {
//         debugPrint('⚡ [SCAN] Nouvelle frame capturée. Tentative de conversion...');
        
//         final inputImage = CameraUtils.inputImageFromCameraImage(
//           image,
//           _controller!.description.sensorOrientation,
//         );
        
//         if (inputImage == null) {
//           debugPrint('⚠️ [SCAN] Échec de conversion : `inputImage` est NULL. Vérifier CameraUtils.');
//           return;
//         }

//         debugPrint('🧠 [SCAN] Image convertie. Envoi à ML Kit...');
//         final ScannedDocument? result = await _mlKitService.scanDocument(
//           inputImage,
//         );

//         if (result == null) {
//           debugPrint('❌ [SCAN] ML Kit a retourné un résultat NULL.');
//           return;
//         }

//         if (result.isEmpty) {
//           debugPrint('⚠️ [SCAN] Document détecté par ML Kit mais il est VIDE (Regex/champs non matchés).');
//           return;
//         }

//         // Si on arrive ici, le scan contient des données valides
//         debugPrint('✅ [SCAN] Scan réussi ! Données extraites : ${result.toString()}');
        
//         _accumulated = _merge(_accumulated, result);
//         _confirmations++;
//         debugPrint('📈 [SCAN] Confirmation $_confirmations/$_kRequiredConfirmations');

//         if (mounted) setState(() {}); // Rafraîchit la jauge de progression

//         if (_confirmations >= _kRequiredConfirmations) {
//           _done = true;
//           debugPrint('🎉 [SCAN] Seuil de confiance atteint. Arrêt du stream et navigation.');
//           await _controller!.stopImageStream();

//           if (!mounted) return;
//           ref.read(scanResultProvider.notifier).state = _accumulated;
          
//           context.go(
//             AppRoutes.register,
//             extra: _accumulated,
//           );
//         }
//       } catch (e, stackTrace) {
//         debugPrint('💥 [SCAN] Erreur critique pendant le traitement de la frame : $e');
//         debugPrint('$stackTrace');
//       } finally {
//         _processing = false;
//       }
//     });
//   }

//   /// Merges two results — prefers incoming non-null fields but falls back
//   /// to existing values if the new scan missed them.
//   ScannedDocument _merge(ScannedDocument? existing, ScannedDocument incoming) {
//     if (existing == null) return incoming;
//     return ScannedDocument(
//       firstName: incoming.firstName ?? existing.firstName,
//       lastName: incoming.lastName ?? existing.lastName,
//       dateOfBirth: incoming.dateOfBirth ?? existing.dateOfBirth,
//       placeOfBirth: incoming.placeOfBirth ?? existing.placeOfBirth,
//       nationalId: incoming.nationalId ?? existing.nationalId,
//       sex: incoming.sex ?? existing.sex,
//       nationality: incoming.nationality ?? existing.nationality,
//       expiryDate: incoming.expiryDate ?? existing.expiryDate,
//       deliveryDate: incoming.deliveryDate ?? existing.deliveryDate,
//       documentType: incoming.documentType ?? existing.documentType,
//     );
//   }

//   double get _progress =>
//       (_confirmations / _kRequiredConfirmations).clamp(0.0, 1.0);

//   @override
//   void dispose() {
//     _controller?.dispose();
//     _mlKitService.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ready = _controller != null && _controller!.value.isInitialized;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         leading: const BackButton(color: Colors.white),
//         title: const Text(
//           'Scanner la pièce',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//       body: ready
//           ? Stack(
//               alignment: Alignment.center,
//               children: [
//                 // ── Camera feed ─────────────────────────────────────
//                 SizedBox.expand(child: CameraPreview(_controller!)),

//                 // ── Cutout overlay ──────────────────────────────────
//                 const ScannerOverlay(),

//                 // ── Instructions ────────────────────────────────────
//                 const Positioned(
//                   bottom: 160,
//                   left: 24,
//                   right: 24,
//                   child: Column(
//                     children: [
//                       Text(
//                         'Placez votre carte dans le cadre',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 15,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(height: 6),
//                       Text(
//                         'Maintenez la carte immobile pour un meilleur scan',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(color: Colors.white70, fontSize: 13),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // ── Progress bar ─────────────────────────────────────
//                 Positioned(
//                   bottom: 60,
//                   left: 40,
//                   right: 40,
//                   child: AnimatedOpacity(
//                     opacity: _confirmations > 0 ? 1.0 : 0.0,
//                     duration: const Duration(milliseconds: 300),
//                     child: Column(
//                       children: [
//                         Text(
//                           'Analyse... ${(_progress * 100).toInt()}%',
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 13,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(4),
//                           child: LinearProgressIndicator(
//                             value: _progress,
//                             backgroundColor: Colors.white24,
//                             valueColor: const AlwaysStoppedAnimation<Color>(
//                               Colors.greenAccent,
//                             ),
//                             minHeight: 6,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           : const Center(child: CircularProgressIndicator()),
//     );
//   }
// }