double? parseMoney(String value) {
  final normalized = value.replaceAll('.', '').replaceAll(',', '.').trim();
  return double.tryParse(normalized);
}

String money(double value) {
  final signal = value < 0 ? '-' : '';
  final fixed = value.abs().toStringAsFixed(2).replaceAll('.', ',');
  return '${signal}R\$ $fixed';
}
