import 'package:flutter/material.dart';

import '../models/credit_card_account.dart';
import '../models/expense.dart';
import '../utils/date_utils.dart';
import '../utils/finance_formatters.dart';
import 'card_usage_line.dart';
import 'metric_tile.dart';
import 'surface.dart';

class SummaryPanel extends StatelessWidget {
  const SummaryPanel({
    super.key,
    required this.monthTotal,
    required this.totalLimit,
    required this.cards,
    required this.expenses,
    required this.selectedMonth,
  });

  final double monthTotal;
  final double totalLimit;
  final List<CreditCardAccount> cards;
  final List<Expense> expenses;
  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context) {
    final usage = totalLimit == 0
        ? 0.0
        : (monthTotal / totalLimit).clamp(0, 1).toDouble();
    final colorScheme = Theme.of(context).colorScheme;

    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comprometido em ${monthLabel(selectedMonth)}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              MetricTile(
                icon: Icons.credit_card,
                label: 'Fatura prevista',
                value: money(monthTotal),
              ),
              MetricTile(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Limite somado',
                value: money(totalLimit),
              ),
              MetricTile(
                icon: Icons.trending_down,
                label: 'Disponivel',
                value: money(totalLimit - monthTotal),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: usage,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: usage > 0.8 ? Colors.redAccent : colorScheme.primary,
            ),
          ),
          const SizedBox(height: 18),
          ...cards.map((card) {
            final used = cardTotal(card.name, expenses, selectedMonth);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CardUsageLine(card: card, used: used),
            );
          }),
        ],
      ),
    );
  }
}

double cardTotal(String cardName, List<Expense> expenses, DateTime month) {
  return expenses
      .where(
        (expense) => expense.cardName == cardName && expense.hitsMonth(month),
      )
      .fold(0, (sum, expense) => sum + expense.installmentValue);
}
