int monthIndex(DateTime date) => date.year * 12 + date.month;

String monthLabel(DateTime date) {
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
