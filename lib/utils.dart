import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  final format = DateFormat.yMMMd('en_US');
  return format.format(date);
}

bool detectArabic(String input) {
  RegExp arabicReg = RegExp(
    r'^[\u0600-\u06FF]',
    caseSensitive: false,
    multiLine: true,
    unicode: true,
  );
  return arabicReg.hasMatch(input);
}

String replaceSpaceByPoint(String input) {
  return input.replaceAll(" ", ".");
}
