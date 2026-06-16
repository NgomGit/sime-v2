import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/scanned_document.dart';

final scanResultProvider = StateProvider<ScannedDocument?>((ref) => null);
