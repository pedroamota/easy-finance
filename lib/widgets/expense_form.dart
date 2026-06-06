import 'package:flutter/material.dart';

import '../data/expense_categories.dart';
import '../models/credit_card_account.dart';
import '../models/expense.dart';
import '../utils/finance_formatters.dart';
import 'surface.dart';

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({
    super.key,
    required this.cards,
    required this.selectedMonth,
    required this.onAdd,
  });

  final List<CreditCardAccount> cards;
  final DateTime selectedMonth;
  final ValueChanged<Expense> onAdd;

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _totalController = TextEditingController();
  int _installments = 1;
  late String _selectedCard = widget.cards.first.name;
  String _selectedCategory = expenseCategories.first;

  @override
  void dispose() {
    _descriptionController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Surface(
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
              onChanged: (_) => setState(() {}),
              validator: (value) {
                final parsed = parseMoney(value ?? '');
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
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                prefixIcon: Icon(Icons.sell_outlined),
                border: OutlineInputBorder(),
              ),
              items: expenseCategories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 14),
            Text(
              'Parcelas: $_installments x ${money((parseMoney(_totalController.text) ?? 0) / _installments)}',
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
        total: parseMoney(_totalController.text)!,
        installments: _installments,
        firstMonth: widget.selectedMonth,
        category: _selectedCategory,
      ),
    );

    _descriptionController.clear();
    _totalController.clear();
    setState(() {
      _installments = 1;
      _selectedCategory = expenseCategories.first;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Despesa adicionada na fatura')),
    );
  }
}
