import 'dart:convert';

import 'package:ticker/features/chart/domain/entities/candle.dart';

final class CandleDto {
  final int openTime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const CandleDto({
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  // Binance her mumu isimsiz bir dizi olarak gönderir:
  // [açılış zamanı (ms), "açılış", "en yüksek", "en düşük", "kapanış",
  //  "hacim", ...]
  factory CandleDto.fromJson(List<dynamic> json) {
    return CandleDto(
      openTime: json[0] as int,
      open: double.parse(json[1] as String),
      high: double.parse(json[2] as String),
      low: double.parse(json[3] as String),
      close: double.parse(json[4] as String),
      volume: double.parse(json[5] as String),
    );
  }

  Candle toEntity() {
    return Candle(
      openTime: DateTime.fromMillisecondsSinceEpoch(openTime, isUtc: true),
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    );
  }
}

// Isolate.run'a verilebilsin diye sınıfın dışında, tek başına bir fonksiyon.
List<CandleDto> parseKlines(String body) {
  final items = jsonDecode(body) as List<dynamic>;
  return items
      .map((item) => CandleDto.fromJson(item as List<dynamic>))
      .toList();
}
