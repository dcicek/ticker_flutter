import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ticker/features/chart/data/datasources/chart_remote_data_source.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  const path = '/api/v3/klines';
  const body =
      '[[1700000000000,"100.0","120.0","90.0","110.0","5.5",1700003599999]]';

  late _MockDio dio;
  late ChartRemoteDataSource dataSource;

  setUpAll(() {
    // any() ile eşleştirilen özel tipler için mocktail bir örnek değer ister.
    registerFallbackValue(Options());
  });

  setUp(() {
    dio = _MockDio();
    dataSource = ChartRemoteDataSource(dio);

    // any(named: ...): "bu parametre ne gelirse gelsin eşleş". Gelen değerleri
    // aşağıda verify ile ayrıca kontrol ediyoruz.
    when(
      () => dio.get<String>(
        path,
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: body,
      ),
    );
  });

  group('ChartRemoteDataSource.getKlines', () {
    test("cevabı arka plan isolate'inde parse edip döner", () async {
      // Bu test gerçek bir isolate açar. Isolate.run içine gönderilemeyen bir
      // nesne (örneğin Dio) sızsaydı burada hata alırdık.
      final klines = await dataSource.getKlines(
        symbol: 'BTCUSDT',
        interval: '1h',
      );

      expect(klines.single.open, 100);
      expect(klines.single.close, 110);
    });

    test('sembol, aralık ve limit sorgu parametresi olarak gider', () async {
      await dataSource.getKlines(symbol: 'ETHUSDT', interval: '4h', limit: 50);

      // captured: any() ile yakalanan gerçek değerleri geri verir.
      final captured = verify(
        () => dio.get<String>(
          path,
          queryParameters: captureAny(named: 'queryParameters'),
          options: captureAny(named: 'options'),
        ),
      ).captured;

      expect(captured[0], {'symbol': 'ETHUSDT', 'interval': '4h', 'limit': 50});
      expect((captured[1] as Options).responseType, ResponseType.plain);
    });
  });
}
