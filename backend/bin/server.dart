import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:sepet_backend/src/app.dart';
import 'package:sepet_backend/src/quote_service.dart';

Future<void> main(List<String> args) async {
  final port = resolvePort();
  final quotes = QuoteService();
  final handler = createApp(quoteService: quotes);
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);

  // ignore: avoid_print
  print(
    'Sepet backend listening on http://${server.address.host}:${server.port}\n'
    'PRICE_MODE=${quotes.mode.name}\n'
    'Health:  GET  /health\n'
    'Catalog: GET  /v1/catalog/search?q=sut\n'
    'Quotes:  POST /v1/markets/{slug}/quotes\n'
    'Policy:  resmi market API / partner feed — scraping yok',
  );
}
