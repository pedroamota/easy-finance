import 'package:flutter/material.dart';

void main() {
  runApp(const EasyFinanceApp());
}

class EasyFinanceApp extends StatelessWidget {
  const EasyFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Easy Finance',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF226C63),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7F4),
        useMaterial3: true,
      ),
      home: const FinanceHomePage(),
    );
  }
}

class CreditCardAccount {
  const CreditCardAccount({
    required this.name,
    required this.limit,
    required this.color,
  });

  final String name;
  final double limit;
  final Color color;
}

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
    final startIndex = _monthIndex(firstMonth);
    final currentIndex = _monthIndex(month);
    return currentIndex >= startIndex &&
        currentIndex < startIndex + installments;
  }

  int installmentNumber(DateTime month) {
    return _monthIndex(month) - _monthIndex(firstMonth) + 1;
  }
}

class FinanceHomePage extends StatefulWidget {
  const FinanceHomePage({super.key});

  @override
  State<FinanceHomePage> createState() => _FinanceHomePageState();
}

class _FinanceHomePageState extends State<FinanceHomePage> {
  final List<CreditCardAccount> _cards = const [
    CreditCardAccount(name: 'Nubank', limit: 3200, color: Color(0xFF7B3FA1)),
    CreditCardAccount(name: 'Inter', limit: 2500, color: Color(0xFFE8702A)),
    CreditCardAccount(name: 'Santander', limit: 1800, color: Color(0xFFC62828)),
    CreditCardAccount(name: 'XP', limit: 4200, color: Color(0xFF222222)),
  ];

  final List<Expense> _expenses = [
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
      category: 'Casa',
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
              _monthLabel(_selectedMonth),
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
            final content = [
              _SummaryPanel(
                monthTotal: _monthTotal,
                totalLimit: _totalLimit,
                cards: _cards,
                expenses: _expenses,
                selectedMonth: _selectedMonth,
              ),
              _ExpenseForm(
                cards: _cards,
                selectedMonth: _selectedMonth,
                onAdd: _addExpense,
              ),
              _UpcomingBills(
                cards: _cards,
                expenses: _expenses,
                selectedMonth: _selectedMonth,
              ),
            ];

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
                                  content[0],
                                  const SizedBox(height: 16),
                                  content[2],
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(flex: 4, child: content[1]),
                          ],
                        )
                      : Column(
                          children: [
                            content[0],
                            const SizedBox(height: 16),
                            content[1],
                            const SizedBox(height: 16),
                            content[2],
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
        : 'Antes de comprar parcelado, veja se a parcela cabe no mes mais pesado. Hoje ainda sobram ${_money(available)} do limite total.';

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

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({
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

    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comprometido em ${_monthLabel(selectedMonth)}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricTile(
                icon: Icons.credit_card,
                label: 'Fatura prevista',
                value: _money(monthTotal),
              ),
              _MetricTile(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Limite somado',
                value: _money(totalLimit),
              ),
              _MetricTile(
                icon: Icons.trending_down,
                label: 'Disponivel',
                value: _money(totalLimit - monthTotal),
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
            final used = _cardTotal(card.name, expenses, selectedMonth);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CardUsageLine(card: card, used: used),
            );
          }),
        ],
      ),
    );
  }
}

class _ExpenseForm extends StatefulWidget {
  const _ExpenseForm({
    required this.cards,
    required this.selectedMonth,
    required this.onAdd,
  });

  final List<CreditCardAccount> cards;
  final DateTime selectedMonth;
  final ValueChanged<Expense> onAdd;

  @override
  State<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<_ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _totalController = TextEditingController();
  final _categoryController = TextEditingController();
  int _installments = 1;
  late String _selectedCard = widget.cards.first.name;

  @override
  void dispose() {
    _descriptionController.dispose();
    _totalController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Surface(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nova despesa',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descricao',
                prefixIcon: Icon(Icons.shopping_bag_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Informe o nome'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _totalController,
              decoration: const InputDecoration(
                labelText: 'Valor total',
                prefixIcon: Icon(Icons.payments_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                final parsed = _parseMoney(value ?? '');
                if (parsed == null || parsed <= 0) {
                  return 'Informe um valor valido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCard,
              decoration: const InputDecoration(
                labelText: 'Cartao',
                prefixIcon: Icon(Icons.credit_card),
                border: OutlineInputBorder(),
              ),
              items: widget.cards
                  .map(
                    (card) => DropdownMenuItem(
                      value: card.name,
                      child: Text(card.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCard = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                prefixIcon: Icon(Icons.sell_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Parcelas: $_installments x ${_money((_parseMoney(_totalController.text) ?? 0) / _installments)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Slider(
              value: _installments.toDouble(),
              min: 1,
              max: 24,
              divisions: 23,
              label: '$_installments',
              onChanged: (value) {
                setState(() => _installments = value.round());
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar despesa'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    widget.onAdd(
      Expense(
        description: _descriptionController.text.trim(),
        cardName: _selectedCard,
        total: _parseMoney(_totalController.text)!,
        installments: _installments,
        firstMonth: widget.selectedMonth,
        category: _categoryController.text.trim().isEmpty
            ? 'Sem categoria'
            : _categoryController.text.trim(),
      ),
    );

    _descriptionController.clear();
    _totalController.clear();
    _categoryController.clear();
    setState(() => _installments = 1);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Despesa adicionada na fatura')),
    );
  }
}

class _UpcomingBills extends StatelessWidget {
  const _UpcomingBills({
    required this.cards,
    required this.expenses,
    required this.selectedMonth,
  });

  final List<CreditCardAccount> cards;
  final List<Expense> expenses;
  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context) {
    final months = List.generate(
      6,
      (index) => DateTime(selectedMonth.year, selectedMonth.month + index),
    );

    return _Surface(
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
            (month) => _MonthBillTile(
              month: month,
              expenses: expenses,
              initiallyExpanded:
                  _monthIndex(month) == _monthIndex(selectedMonth),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthBillTile extends StatelessWidget {
  const _MonthBillTile({
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
        _monthLabel(month),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      trailing: Text(
        _money(total),
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
                    trailing: Text(_money(expense.installmentValue)),
                  ),
                )
                .toList(),
    );
  }
}

class _CardUsageLine extends StatelessWidget {
  const _CardUsageLine({required this.card, required this.used});

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
            Text('${_money(used)} / ${_money(card.limit)}'),
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(height: 10),
          Text(label),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _Surface extends StatelessWidget {
  const _Surface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }
}

double? _parseMoney(String value) {
  final normalized = value.replaceAll('.', '').replaceAll(',', '.').trim();
  return double.tryParse(normalized);
}

double _cardTotal(String cardName, List<Expense> expenses, DateTime month) {
  return expenses
      .where(
        (expense) => expense.cardName == cardName && expense.hitsMonth(month),
      )
      .fold(0, (sum, expense) => sum + expense.installmentValue);
}

int _monthIndex(DateTime date) => date.year * 12 + date.month;

String _monthLabel(DateTime date) {
  const months = [
    'Janeiro',
    'Fevereiro',
    'Marco',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  return '${months[date.month - 1]} ${date.year}';
}

String _money(double value) {
  final signal = value < 0 ? '-' : '';
  final fixed = value.abs().toStringAsFixed(2).replaceAll('.', ',');
  return '${signal}R\$ $fixed';
}
