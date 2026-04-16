import 'package:intl/intl.dart';

final NumberFormat _inrFormatter = NumberFormat.currency(
  locale: 'en_IN',
  symbol: 'Rs ',
  decimalDigits: 0,
);

String formatINR(num amount) {
  return _inrFormatter.format(amount);
}
