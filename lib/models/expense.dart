import '../utils/date_utils.dart';

class Expense {
  Expense({
    required this.description,
    required this.cardName,
    required this.total,
    required this.installments,
    required this.firstMonth,
    required this.category,
  });

  final String description;
  final String cardName;
  final double total;
  final int installments;
  final DateTime firstMonth;
  final String category;

  double get installmentValue => total / installments;

  bool hitsMonth(DateTime month) {
    final startIndex = monthIndex(firstMonth);
    final currentIndex = monthIndex(month);
    return currentIndex >= startIndex &&
        currentIndex < startIndex + installments;
  }

  int installmentNumber(DateTime month) {
    return monthIndex(month) - monthIndex(firstMonth) + 1;
  }
}
