// 67000.1 -> 67,000.10; 1'in altındaki fiyatlarda 6 basamak (0.000012 gibi).
String formatPrice(double price) {
  if (price < 1) return price.toStringAsFixed(6);

  final parts = price.toStringAsFixed(2).split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '$whole.${parts[1]}';
}
