import 'package:flutter/widgets.dart';
import 'package:sime_v2/core/services/scanned_document.dart';

class AfricaIdParser {
  AfricaIdParser._();

  static ScannedDocument? parse(String text) {
    final upper = _removeAccents(text.toUpperCase());

    debugPrint('========== AFRICA PARSER ==========');
    debugPrint(upper);
    debugPrint('===================================');

    final firstName = RegExp(
      r'PRENOMS?\s*:?\s*([A-Z\s\-]+)',
      multiLine: true,
    ).firstMatch(upper)?.group(1)?.trim();

    final lastName = RegExp(
      r'\bNOM\b\s*:?\s*([A-Z\s\-]+)',
      multiLine: true,
    ).firstMatch(upper)?.group(1)?.trim();

    final placeOfBirth = RegExp(
      r'LIEU\s+DE\s+NAISSANCE\s*\n\s*([^\n]+)',
      multiLine: true,
    ).firstMatch(upper)?.group(1)?.replaceAll('|', '').trim();

    RegExp(
      r'LIEU\s+DE\s+NAISSANCE\s*\n\s*([A-Z\|\-\s]+)',
      multiLine: true,
    ).firstMatch(upper)?.group(1)?.trim();

    final sex = RegExp(
      r'\bSEXE\b\s*:?\s*([MF])',
      multiLine: true,
    ).firstMatch(upper)?.group(1);

    final allDates = RegExp(
      r'(\d{2})/(\d{2})/(\d{4})',
    ).allMatches(upper).toList();

    DateTime? dob;
    DateTime? deliveryDate;
    DateTime? expiryDate;

    if (allDates.isNotEmpty) {
      dob = _dateFromMatch(allDates[0]);
    }

    if (allDates.length > 1) {
      deliveryDate = _dateFromMatch(allDates[1]);
    }

    if (allDates.length > 2) {
      expiryDate = _dateFromMatch(allDates[2]);
    }

    String? idNumber;

    final idMatch = RegExp(
      r'\d[\d\s]{10,}\d',
    ).firstMatch(upper);

    if (idMatch != null) {
      idNumber = idMatch.group(0)?.replaceAll(' ', '');
    }

    debugPrint('Prénom: $firstName');
    debugPrint('Nom: $lastName');
    debugPrint('Sexe: $sex');
    debugPrint('ID: $idNumber');
    debugPrint('Lieu de naissance: $placeOfBirth');
    if (firstName == null && lastName == null && idNumber == null) {
      return null;
    }

    return ScannedDocument(
      firstName: _capitalize(firstName),
      lastName: _capitalize(lastName),
      dateOfBirth: dob,
      placeOfBirth: _capitalize(placeOfBirth),
      nationalId: idNumber,
      sex: sex,
      nationality: 'SEN',
      expiryDate: expiryDate,
      deliveryDate: deliveryDate,
      documentType: DocumentType.nationalId,
    );
  }

  static DateTime? _dateFromMatch(RegExpMatch match) {
    try {
      return DateTime(
        int.parse(match.group(3)!),
        int.parse(match.group(2)!),
        int.parse(match.group(1)!),
      );
    } catch (_) {
      return null;
    }
  }

  static String? _capitalize(String? value) {
    if (value == null || value.isEmpty) return null;

    return value
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map(
          (e) => e[0].toUpperCase() + e.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  static String _removeAccents(String input) {
    final map = {
      'À': 'A',
      'Á': 'A',
      'Â': 'A',
      'Ã': 'A',
      'Ä': 'A',
      'Å': 'A',
      'Ç': 'C',
      'È': 'E',
      'É': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'Ì': 'I',
      'Í': 'I',
      'Î': 'I',
      'Ï': 'I',
      'Ñ': 'N',
      'Ò': 'O',
      'Ó': 'O',
      'Ô': 'O',
      'Õ': 'O',
      'Ö': 'O',
      'Ù': 'U',
      'Ú': 'U',
      'Û': 'U',
      'Ü': 'U',
      'Ý': 'Y',
    };

    return input.split('').map((c) => map[c] ?? c).join();
  }
}
