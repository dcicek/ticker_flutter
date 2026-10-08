import 'dart:convert';

import 'package:ticker/features/market/data/models/coin_dto.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef ChannelFactory = WebSocketChannel Function(Uri uri);

class MarketSocketDataSource {
  static final Uri _uri = Uri.parse(
    'wss://stream.binance.com:9443/ws/!miniTicker@arr',
  );

  final ChannelFactory _connect;

  MarketSocketDataSource(this._connect);

  Stream<List<CoinDto>> watchTickers() async* {
    final channel = _connect(_uri);

    try {
      await for (final message in channel.stream) {
        final items = jsonDecode(message as String) as List<dynamic>;

        yield items
            .map((item) => CoinDto.fromMiniTicker(item as Map<String, dynamic>))
            .toList();
      }
    } finally {
      await channel.sink.close();
    }
  }
}
