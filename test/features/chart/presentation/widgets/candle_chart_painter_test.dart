import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticker/features/chart/domain/entities/candle.dart';
import 'package:ticker/features/chart/presentation/widgets/candle_chart_painter.dart';

void main() {
  Candle candle({
    double open = 100,
    double high = 120,
    double low = 90,
    double close = 110,
  }) {
    return Candle(
      openTime: DateTime.utc(2026),
      open: open,
      high: high,
      low: low,
      close: close,
      volume: 1,
    );
  }

  CandleChartPainter painter(List<Candle> candles) {
    return CandleChartPainter(
      candles: candles,
      upColor: Colors.green,
      downColor: Colors.red,
      gridColor: Colors.grey,
      labelStyle: const TextStyle(fontSize: 10),
    );
  }

  // Painter'ı ekrana değil, bellekteki bir tuvale çizdirir. Çizimin neye
  // benzediğini kontrol etmiyoruz; yalnızca hata vermeden bitmesini.
  void paint(CandleChartPainter painter) {
    painter.paint(Canvas(PictureRecorder()), const Size(300, 200));
  }

  group('CandleChartPainter', () {
    test('boş listede hata vermez', () {
      expect(() => paint(painter(const [])), returnsNormally);
    });

    test('yükselen ve düşen mumları çizer', () {
      final candles = [candle(), candle(open: 110, close: 95)];

      expect(() => paint(painter(candles)), returnsNormally);
    });

    test('bütün fiyatlar aynıyken sıfıra bölmez', () {
      final flat = [candle(open: 50, high: 50, low: 50, close: 50)];

      expect(() => paint(painter(flat)), returnsNormally);
    });

    test('mum listesi aynı nesneyse yeniden çizmez, değiştiyse çizer', () {
      final candles = [candle()];

      expect(painter(candles).shouldRepaint(painter(candles)), isFalse);
      expect(painter([candle()]).shouldRepaint(painter(candles)), isTrue);
    });
  });
}
