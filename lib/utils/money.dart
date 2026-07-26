import 'package:intl/intl.dart';

final _try = NumberFormat.currency(
  locale: 'tr_TR',
  symbol: '₺',
  decimalDigits: 2,
);

String formatTry(double value) => _try.format(value);
