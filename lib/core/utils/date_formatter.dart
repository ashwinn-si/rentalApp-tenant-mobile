import 'package:intl/intl.dart';

String formatDate(String isoDate) {
  final DateTime? parsed = DateTime.tryParse(isoDate);
  if (parsed == null) {
    return '-';
  }

  try {
    return DateFormat('dd MMM yyyy', 'en_IN').format(parsed);
  } catch (_) {
    return DateFormat('dd MMM yyyy').format(parsed);
  }
}
