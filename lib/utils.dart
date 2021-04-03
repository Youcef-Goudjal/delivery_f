import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  final format = DateFormat.yMMMd('en_US');
  return format.format(date);
}
