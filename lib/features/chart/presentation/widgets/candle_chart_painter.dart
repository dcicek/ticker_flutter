import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ticker/core/utils/price_format.dart';
import 'package:ticker/features/chart/domain/entities/candle.dart';

class CandleChartPainter extends CustomPainter {
  static const _labelWidth = 72.0;
  static const _gridLines = 4;

  final List<Candle> candles;
  final Color upColor;
  final Color downColor;
  final Color gridColor;
  final TextStyle labelStyle;

  const CandleChartPainter({
    required this.candles,
    required this.upColor,
    required this.downColor,
    required this.gridColor,
    required this.labelStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    final chartWidth = size.width - _labelWidth;

    // Dikey ölçek: görünen mumların en düşük ve en yüksek fiyatı.
    var low = candles.first.low;
    var high = candles.first.high;
    for (final candle in candles) {
      low = math.min(low, candle.low);
      high = math.max(high, candle.high);
    }
    final range = high == low ? 1.0 : high - low;

    // Fiyatı piksele çevirir. Canvas'ta y aşağı doğru büyür, o yüzden ters.
    double y(double price) => size.height * (1 - (price - low) / range);

    _paintGrid(canvas, size, chartWidth, low, range, y);

    final slot = chartWidth / candles.length;
    final bodyWidth = math.max(1, slot * 0.7).toDouble();
    final paint = Paint()..strokeWidth = 1;

    for (var i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final x = slot * i + slot / 2;
      paint.color = candle.close >= candle.open ? upColor : downColor;

      // Fitil: en yüksekten en düşüğe ince çizgi.
      canvas.drawLine(
        Offset(x, y(candle.high)),
        Offset(x, y(candle.low)),
        paint,
      );

      // Gövde: açılış ile kapanış arası dikdörtgen.
      final top = y(math.max(candle.open, candle.close));
      final bottom = y(math.min(candle.open, candle.close));
      canvas.drawRect(
        Rect.fromLTRB(
          x - bodyWidth / 2,
          top,
          x + bodyWidth / 2,
          math.max(bottom, top + 1),
        ),
        paint,
      );
    }
  }

  void _paintGrid(
    Canvas canvas,
    Size size,
    double chartWidth,
    double low,
    double range,
    double Function(double price) y,
  ) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 0; i <= _gridLines; i++) {
      final price = low + range * i / _gridLines;
      final dy = y(price);
      canvas.drawLine(Offset(0, dy), Offset(chartWidth, dy), gridPaint);

      final label = TextPainter(
        text: TextSpan(text: formatPrice(price), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: _labelWidth - 8);
      final labelY = (dy - label.height / 2).clamp(
        0.0,
        math.max(0, size.height - label.height).toDouble(),
      );
      label.paint(canvas, Offset(chartWidth + 8, labelY));
    }
  }

  @override
  bool shouldRepaint(CandleChartPainter oldDelegate) {
    return oldDelegate.candles != candles;
  }
}
