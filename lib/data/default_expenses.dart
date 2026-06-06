import '../models/expense.dart';

List<Expense> buildDefaultExpenses() {
  return [
    Expense(
      description: 'Notebook',
      cardName: 'Nubank',
      total: 2400,
      installments: 10,
      firstMonth: DateTime(2026, 6),
      category: 'Trabalho',
    ),
    Expense(
      description: 'Mercado grande',
      cardName: 'Inter',
      total: 620,
      installments: 3,
      firstMonth: DateTime(2026, 6),
      category: 'Comida',
    ),
    Expense(
      description: 'Celular',
      cardName: 'XP',
      total: 1800,
      installments: 12,
      firstMonth: DateTime(2026, 5),
      category: 'Eletronicos',
    ),
  ];
}
