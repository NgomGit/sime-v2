// import 'package:camera/camera.dart';
// import 'package:flutter/services.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// class CameraUtils {
//   static InputImage? inputImageFromCameraImage(
//     CameraImage image,
//     int rotation,
//   ) {
//     try {
//       final WriteBuffer allBytes = WriteBuffer();

//       for (final plane in image.planes) {
//         allBytes.putUint8List(plane.bytes);
//       }

//       final bytes = allBytes.done().buffer.asUint8List();

//       final Size imageSize = Size(
//         image.width.toDouble(),
//         image.height.toDouble(),
//       );

//       final imageRotation =
//           InputImageRotationValue.fromRawValue(rotation) ??
//           InputImageRotation.rotation0deg;

//       final inputImageFormat = InputImageFormatValue.fromRawValue(
//         image.format.raw,
//       );

//       if (inputImageFormat == null) return null;

//       final metadata = InputImageMetadata(
//         size: imageSize,
//         rotation: imageRotation,
//         format: inputImageFormat,
//         bytesPerRow: image.planes.first.bytesPerRow,
//       );

//       return InputImage.fromBytes(bytes: bytes, metadata: metadata);
//     } catch (e) {
//       return null;
//     }
//   }
// }
