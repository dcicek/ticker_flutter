import 'package:flutter/material.dart';
import 'package:ticker/features/market/domain/entities/coin.dart';

const _upColor = Color(0xFF16C784);
const _downColor = Color(0xFFEA3943);

class CoinTile extends StatelessWidget {
  final Coin coin;

  const CoinTile({required this.coin, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUp = coin.changePercent >= 0;
    final changeColor = isUp ? _upColor : _downColor;

    // BTCUSDT -> BTC / USDT
    const quote = 'USDT';
    final base = coin.symbol.endsWith(quote)
        ? coin.symbol.substring(0, coin.symbol.length - quote.length)
        : coin.symbol;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          Text(
            formatPrice(coin.price),
            style: theme.textTheme.titleMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 78,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: changeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${isUp ? '+' : ''}${coin.changePercent.toStringAsFixed(2)}%',
              style: theme.textTheme.labelLarge?.copyWith(
                color: changeColor,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
