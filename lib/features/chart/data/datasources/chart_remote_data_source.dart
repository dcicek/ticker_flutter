import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:ticker/features/chart/data/models/candle_dto.dart';

class ChartRemoteDataSource {
  final Dio _dio;

  ChartRemoteDataSource(this._dio);

  Future<List<CandleDto>> getKlines({
    required String symbol,
    required String interval,
    int limit = 120,
  }) async {
    // Cevabı ham metin olarak al; JSON'a çevirme işi de arka plan isolate'inde
    // yapılsın.
    final response = await _dio.get<String>(
      '/api/v3/klines',
      queryParameters: {'symbol': symbol, 'interval': interval, 'limit': limit},
      options: Options(responseType: ResponseType.plain),
    );
    final body = response.data!;

    return Isolate.run(() => parseKlines(body));
  }
}
