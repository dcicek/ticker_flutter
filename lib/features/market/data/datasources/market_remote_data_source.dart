import 'package:dio/dio.dart';
import 'package:ticker/features/market/data/models/coin_dto.dart';

/// Talks to Binance's public REST API.
///
/// It only fetches and parses; errors are left to propagate so the repository
/// can translate them into failures.
class MarketRemoteDataSource {
  /// Creates a data source that sends its requests through [_dio].
  MarketRemoteDataSource(this._dio);

  final Dio _dio;

  /// Fetches the 24-hour ticker of every trading pair.
  ///
  /// Throws a [DioException] when the request fails, and a [FormatException]
  /// or [TypeError] when the response is not in the expected shape.
  Future<List<CoinDto>> getTickers() async {
    final response = await _dio.get<List<dynamic>>('/api/v3/ticker/24hr');

    return response.data!
        .map((item) => CoinDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
