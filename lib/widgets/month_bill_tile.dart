import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../utils/date_utils.dart';
import '../utils/finance_formatters.dart';

class MonthBillTile extends StatelessWidget {
  const MonthBillTile({
    super.key,
    required this.month,
    required this.expenses,
    required this.initiallyExpanded,
  });

  final DateTime month;
  final List<Expense> expenses;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final monthExpenses = expenses
        .where((expense) => expense.hitsMonth(month))
        .toList();
    final total = monthExpenses.fold(
      0.0,
      (sum, item) => sum + item.installmentValue,
    );

    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: Text(
        monthLabel(month),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      trailing: Text(
        money(total),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      children: monthExpenses.isEmpty
          ? [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Nenhuma parcela prevista.'),
              ),
            ]
          : monthExpenses
                .map(
                  (expense) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Text(expense.description),
                    subtitle: Text(
                      '${expense.cardName} - ${expense.category} - ${expense.installmentNumber(month)}/${expense.installments}',
                    ),
                    trailing: Text(money(expense.installmentValue)),
                  ),
                )
                .toList(),
    );
  }
}
