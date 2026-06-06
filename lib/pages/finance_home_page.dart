import 'package:flutter/material.dart';

import '../data/default_cards.dart';
import '../data/default_expenses.dart';
import '../models/credit_card_account.dart';
import '../models/expense.dart';
import '../utils/date_utils.dart';
import '../utils/finance_formatters.dart';
import '../widgets/expense_form.dart';
import '../widgets/summary_panel.dart';
import '../widgets/upcoming_bills.dart';

class FinanceHomePage extends StatefulWidget {
  const FinanceHomePage({super.key});

  @override
  State<FinanceHomePage> createState() => _FinanceHomePageState();
}

class _FinanceHomePageState extends State<FinanceHomePage> {
  final List<CreditCardAccount> _cards = defaultCards;
  late final List<Expense> _expenses = buildDefaultExpenses();

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  double get _monthTotal => _expenses
      .where((expense) => expense.hitsMonth(_selectedMonth))
      .fold(0, (sum, expense) => sum + expense.installmentValue);

  double get _totalLimit => _cards.fold(0, (sum, card) => sum + card.limit);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Easy Finance'),
        actions: [
          IconButton(
            tooltip: 'Mes anterior',
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          Center(
            child: Text(
              monthLabel(_selectedMonth),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            tooltip: 'Proximo mes',
            onPressed: () => _changeMonth(1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 920;
            final summary = SummaryPanel(
              monthTotal: _monthTotal,
              totalLimit: _totalLimit,
              cards: _cards,
              expenses: _expenses,
              selectedMonth: _selectedMonth,
            );
            final form = ExpenseForm(
              cards: _cards,
              selectedMonth: _selectedMonth,
              onAdd: _addExpense,
            );
            final bills = UpcomingBills(
              expenses: _expenses,
              selectedMonth: _selectedMonth,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: Column(
                                children: [
                                  summary,
                                  const SizedBox(height: 16),
                                  bills,
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(flex: 4, child: form),
                          ],
                        )
                      : Column(
                          children: [
                            summary,
                            const SizedBox(height: 16),
                            form,
                            const SizedBox(height: 16),
                            bills,
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: () => _showQuickTip(context),
        icon: const Icon(Icons.lightbulb_outline),
        label: const Text('Regra do mes'),
      ),
    );
  }

  void _addExpense(Expense expense) {
    setState(() {
      _expenses.insert(0, expense);
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + offset,
      );
    });
  }

  void _showQuickTip(BuildContext context) {
    final available = _totalLimit - _monthTotal;
    final suggestion = available <= 0
        ? 'Voce ja passou do limite total planejado para este mes. Melhor pausar compras parceladas novas.'
        : 'Antes de comprar parcelado, veja se a parcela cabe no mes mais pesado. Hoje ainda sobram ${money(available)} do limite total.';

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regra pratica'),
        content: Text(suggestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}
