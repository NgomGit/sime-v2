// core/services/mrz_parser.dart

import 'package:sime_v2/core/services/scanned_document.dart';

class MrzParser {
  MrzParser._();

  static ScannedDocument? parse(String rawText) {
    final lines = _extractMrzLines(rawText);

    if (lines == null) return null;

    try {
      if (lines.length == 2) {
        return _parseTd3(lines[0], lines[1]);
      }

      if (lines.length == 3) {
        return _parseTd1(lines[0], lines[1], lines[2]);
      }
    } catch (e) {
      // print('MRZ parse error: $e');
      return null;
    }

    return null;
  }

  static ScannedDocument _parseTd3(String l1, String l2) {
    final line1 = l1.padRight(44, '<').substring(0, 44);
    final line2 = l2.padRight(44, '<').substring(0, 44);

    final nameSection = line1.substring(5);
    final names = _parseName(nameSection);

    final docNumber = line2.substring(0, 9).replaceAll('<', '');
    final nationality = line2.substring(10, 13).replaceAll('<', '');
    final dob = _parseDate(line2.substring(13, 19));
    final sex = _parseSex(line2[20]);
    final expiry = _parseDate(line2.substring(21, 27));

    return ScannedDocument(
      firstName: names.$1,
      lastName: names.$2,
      nationalId: docNumber,
      dateOfBirth: dob,
      sex: sex,
      expiryDate: expiry,
      nationality: nationality,
      documentType: DocumentType.passport,
    );
  }

  static ScannedDocument _parseTd1(String l1, String l2, String l3) {
    final line1 = l1.padRight(30, '<').substring(0, 30);
    final line2 = l2.padRight(30, '<').substring(0, 30);
    final line3 = l3.padRight(30, '<').substring(0, 30);

    final docNumber = line1.substring(5, 14).replaceAll('<', '');

    final dob = _parseDate(line2.substring(0, 6));
    final sex = _parseSex(line2[7]);
    final expiry = _parseDate(line2.substring(8, 14));
    final nationality = line2.substring(15, 18).replaceAll('<', '');

    final names = _parseName(line3);

    return ScannedDocument(
      firstName: names.$1,
      lastName: names.$2,
      nationalId: docNumber,
      dateOfBirth: dob,
      sex: sex,
      expiryDate: expiry,
      nationality: nationality,
      documentType: DocumentType.nationalId,
    );
  }

  static List<String>? _extractMrzLines(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.contains('<'))
        .toList();

    if (lines.length >= 2) {
      return lines.take(3).toList();
    }

    return null;
  }

  static (String?, String?) _parseName(String section) {
    final parts = section.split('<<');

    if (parts.isEmpty) return (null, null);

    final lastName = _clean(parts[0]);

    final firstName = parts.length > 1
        ? _clean(parts[1].replaceAll('<', ' '))
        : null;

    return (firstName, lastName);
  }

  static DateTime? _parseDate(String yymmdd) {
    if (yymmdd.length != 6) return null;

    final yy = int.tryParse(yymmdd.substring(0, 2));
    final mm = int.tryParse(yymmdd.substring(2, 4));
    final dd = int.tryParse(yymmdd.substring(4, 6));

    if (yy == null || mm == null || dd == null) return null;

    final currentYear = DateTime.now().year % 100;
    final year = yy > currentYear ? 1900 + yy : 2000 + yy;

    return DateTime(year, mm, dd);
  }

  static String? _parseSex(String c) {
    if (c == 'M') return 'M';
    if (c == 'F') return 'F';
    return null;
  }

  static String _clean(String text) {
    return text.replaceAll('<', ' ').trim();
  }
}
