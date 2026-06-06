import 'package:flutter/material.dart';

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
