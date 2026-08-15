import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

import 'catalog.dart';
import 'quote_service.dart';

Handler createApp({QuoteService? quoteService}) {
  final quotes = quoteService ?? QuoteService();
  final router = Router();

  router.get('/health', (Request request) {
    return _json(quotes.healthPayload());
  });

  router.get('/v1/catalog/search', (Request request) {
    final q = request.url.queryParameters['q'] ?? '';
    final items = searchCatalog(q).map((e) => e.toJson()).toList();
    return _json({'items': items, 'count': items.length});
  });

  router.post('/v1/markets/<slug>/quotes', (Request request, String slug) async {
    Map<String, dynamic> body;
    try {
      final raw = await request.readAsString();
      body = raw.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return _json({'error': 'Geçersiz JSON gövdesi'}, status: 400);
    }

    final items = (body['items'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    if (items.isEmpty) {
      return _json({'error': 'items boş olamaz'}, status: 400);
    }

    final region = body['region'] as String? ?? 'istanbul';
    final storeId = body['storeId'] as String?;
    final result = await quotes.quoteMarket(
      slug: slug,
      items: items,
      region: region,
      storeId: storeId,
    );
    return _json(result);
  });

  return Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(
        corsHeaders(
          headers: {
            ACCESS_CONTROL_ALLOW_ORIGIN: '*',
            ACCESS_CONTROL_ALLOW_METHODS: 'GET,POST,OPTIONS',
            ACCESS_CONTROL_ALLOW_HEADERS:
                'Origin,Content-Type,Authorization,Accept',
          },
        ),
      )
      .addMiddleware(_jsonContentType())
      .addHandler(router.call);
}

Middleware _jsonContentType() {
  return (Handler inner) {
    return (Request request) async {
      final response = await inner(request);
      if (response.headers.containsKey('content-type')) return response;
      return response.change(headers: {
        'content-type': 'application/json; charset=utf-8',
      });
    };
  };
}

Response _json(Map<String, dynamic> body, {int status = 200}) {
  return Response(
    status,
    body: jsonEncode(body),
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

int resolvePort() {
  final fromEnv = Platform.environment['PORT'];
  if (fromEnv != null) {
    final parsed = int.tryParse(fromEnv);
    if (parsed != null) return parsed;
  }
  return 8787;
}
