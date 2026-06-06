import 'package:flutter/material.dart';

import '../models/credit_card_account.dart';
import '../utils/finance_formatters.dart';

class CardUsageLine extends StatelessWidget {
  const CardUsageLine({super.key, required this.card, required this.used});

  final CreditCardAccount card;
  final double used;

  @override
  Widget build(BuildContext context) {
    final percent = card.limit == 0
        ? 0.0
        : (used / card.limit).clamp(0, 1).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: card.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                card.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text('${money(used)} / ${money(card.limit)}'),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: percent,
            color: percent > 0.85 ? Colors.redAccent : card.color,
            backgroundColor: card.color.withValues(alpha: 0.16),
          ),
        ),
      ],
    );
  }
}
