import 'package:intl/intl.dart';

class Formatters {
  // static final _currencyFormatter = NumberFormat.currency(
  //   symbol: '\$',
  //   decimalDigits: 2,
  // );

  static final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',  // Indonesian locale
    symbol: 'Rp ',
    decimalDigits: 0, // No decimal digits for Rupiah
  );

  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }
}