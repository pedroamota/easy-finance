import 'package:easy_finance/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('adds an installment expense to the current bill', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EasyFinanceApp());

    expect(find.text('Easy Finance'), findsOneWidget);
    expect(find.text('Nova despesa'), findsOneWidget);
    expect(find.text('Proximas faturas'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descricao'),
      'Cadeira escritorio',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Valor total'),
      '1200',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Categoria'),
      'Casa',
    );

    await tester.ensureVisible(find.byType(Slider));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Slider), const Offset(120, 0));
    await tester.pump();

    await tester.ensureVisible(find.text('Adicionar despesa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adicionar despesa'));
    await tester.pump();

    expect(find.text('Despesa adicionada na fatura'), findsOneWidget);
    expect(find.text('Cadeira escritorio'), findsOneWidget);
  });
}
