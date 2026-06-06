import 'package:flutter/material.dart';

import 'pages/finance_home_page.dart';

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
