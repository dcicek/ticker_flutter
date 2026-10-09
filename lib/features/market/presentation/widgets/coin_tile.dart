import 'package:flutter/material.dart';
import 'package:ticker/core/presentation/app_colors.dart';
import 'package:ticker/core/utils/price_format.dart';

// Satırın değişmeyen kısmı: avatar ve coin adı. Fiyat ve değişim dışarıdan
// widget olarak verilir, böylece onlar yenilenirken burası yeniden kurulmaz.
class CoinTile extends StatelessWidget {
  // Listeye itemExtent olarak verilir; satırlar ölçülmeden yerleştirilir.
  static const double height = 64;

  final String symbol;
  final Widget price;
  final Widget change;

  const CoinTile({
    required this.symbol,
    required this.price,
    required this.change,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // BTCUSDT -> BTC / USDT
    const quote = 'USDT';
    final base = symbol.endsWith(quote)
        ? symbol.substring(0, symbol.length - quote.length)
        : symbol;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  child: Text(
                    base.isEmpty ? '?' : base[0],
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: base,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(
                          text: ' /$quote',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                price,
                const SizedBox(width: 12),
                change,
              ],
            ),
          ),
        ),
        const Divider(height: 1, indent: 66),
      ],
    );
  }
}

class CoinPrice extends StatelessWidget {
  final double price;

  const CoinPrice({required this.price, super.key});

  @override
  Widget build(BuildContext context) {
    // Sabit genişlik: yazı değişince satırın geri kalanı yeniden
    // yerleştirilmez.
    return SizedBox(
      width: 96,
      child: Text(
        formatPrice(price),
        textAlign: TextAlign.right,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class CoinChange extends StatelessWidget {
  final double changePercent;

  const CoinChange({required this.changePercent, super.key});

  @override
  Widget build(BuildContext context) {
    final isUp = changePercent >= 0;
    final color = isUp ? upColor : downColor;

    return Container(
      width: 78,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        '${isUp ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
