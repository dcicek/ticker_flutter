import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ticker/features/market/data/datasources/market_socket_data_source.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class _MockChannel extends Mock implements WebSocketChannel {}

class _MockSink extends Mock implements WebSocketSink {}

void main() {
  const btcMessage =
      '[{"e":"24hrMiniTicker","s":"BTCUSDT",'
      '"c":"110.00","o":"100.00","v":"5"}]';
  const ethMessage =
      '[{"e":"24hrMiniTicker","s":"ETHUSDT",'
      '"c":"45.00","o":"50.00","v":"8"}]';

  // Sunucunun yerine geçen controller: add() ile "sunucudan mesaj geldi"
  // taklidi yapıyoruz.
  late StreamController<dynamic> server;
  late _MockChannel channel;
  late _MockSink sink;
  late MarketSocketDataSource dataSource;

  setUp(() {
    server = StreamController<dynamic>();
    channel = _MockChannel();
    sink = _MockSink();

    when(() => channel.stream).thenAnswer((_) => server.stream);
    when(() => channel.sink).thenReturn(sink);
    when(() => sink.close()).thenAnswer((_) async {});

    dataSource = MarketSocketDataSource((_) => channel);
  });

  group('MarketSocketDataSource.watchTickers', () {
    test('gelen her mesajı CoinDto listesi olarak yayınlar', () async {
      // 1. Hazırla + 3. Doğrula: stream'de beklentiyi önce kurarız, çünkü
      // değerler ileride gelecek.
      final expectation = expectLater(
        dataSource.watchTickers().map((tickers) => tickers.single.symbol),
        emitsInOrder(['BTCUSDT', 'ETHUSDT']),
      );

      // 2. Çalıştır: sunucu iki mesaj gönderir
      server
        ..add(btcMessage)
        ..add(ethMessage);

      await expectation;
    });

    test('yüzde değişimi açılış ve son fiyattan hesaplar', () async {
      final expectation = expectLater(
        dataSource.watchTickers().map(
          (tickers) => tickers.single.priceChangePercent,
        ),
        emitsInOrder([closeTo(10, 0.0001), closeTo(-10, 0.0001)]),
      );

      server
        ..add(btcMessage)
        ..add(ethMessage);

      await expectation;
    });
  });
}
