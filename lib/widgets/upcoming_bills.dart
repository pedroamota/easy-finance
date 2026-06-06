import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../utils/date_utils.dart';
import 'month_bill_tile.dart';
import 'surface.dart';

class UpcomingBills extends StatelessWidget {
  const UpcomingBills({
    super.key,
    required this.expenses,
    required this.selectedMonth,
  });

  final List<Expense> expenses;
  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context) {
    final months = List.generate(
      6,
      (index) => DateTime(selectedMonth.year, selectedMonth.month + index),
    );

    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Proximas faturas',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...months.map(
            (month) => MonthBillTile(
              month: month,
              expenses: expenses,
              initiallyExpanded: monthIndex(month) == monthIndex(selectedMonth),
            ),
          ),
        ],
      ),
    );
  }
}
