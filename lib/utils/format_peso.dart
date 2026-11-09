String formatPeso(int amount) {
  final digits = amount.toString();
  final formatted = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  return '₱$formatted';
}
