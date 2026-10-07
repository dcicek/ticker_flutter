import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ticker/features/market/data/datasources/market_remote_data_source.dart';

// Sahte Dio: gerçek istek atmaz, `when` ile ne söylersek onu döner.
class _MockDio extends Mock implements Dio {}

void main() {
  const path = '/api/v3/ticker/24hr';

  late _MockDio dio;
  late MarketRemoteDataSource dataSource;

  // Her testten önce çalışır; testler birbirinin sahte ayarlarını görmesin
  // diye her seferinde sıfırdan oluşturuyoruz.
  setUp(() {
    dio = _MockDio();
    dataSource = MarketRemoteDataSource(dio);
  });

  group('MarketRemoteDataSource.getTickers', () {
    test('cevaptaki her elemanı CoinDto olarak döner', () async {
      // 1. Hazırla: sahte Dio'ya bu adres istenince ne döneceğini öğret
      when(() => dio.get<List<dynamic>>(path)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: path),
          statusCode: 200,
          data: [
            {
              'symbol': 'BTCUSDT',
              'lastPrice': '67000.10',
              'priceChangePercent': '2.35',
              'volume': '12345.678',
            },
            {
              'symbol': 'ETHUSDT',
              'lastPrice': '3500.00',
              'priceChangePercent': '-1.20',
              'volume': '98765.4',
            },
          ],
        ),
      );

      // 2. Çalıştır
      final tickers = await dataSource.getTickers();

      // 3. Doğrula
      expect(tickers.length, 2);
      expect(tickers[0].symbol, 'BTCUSDT');
      expect(tickers[0].lastPrice, 67000.10);
      expect(tickers[1].symbol, 'ETHUSDT');
      expect(tickers[1].priceChangePercent, -1.20);
    });

    test('Dio hata fırlatırsa aynı hatayı fırlatır', () async {
      when(
        () => dio.get<List<dynamic>>(path),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: path)));

      expect(() => dataSource.getTickers(), throwsA(isA<DioException>()));
    });
  });
}
