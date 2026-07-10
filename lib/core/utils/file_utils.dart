import 'dart:convert';
import 'dart:io';

Future<String> fileToBase64(String filePath) async {
  final file = File(filePath);
  final bytes = await file.readAsBytes();
  return "data:image/jpeg;base64,${base64Encode(bytes)}";
}