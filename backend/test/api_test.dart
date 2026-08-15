import 'dart:convert';

import 'package:sepet_backend/sepet_backend.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  test('katalog araması ürün döner', () {
    final hits = searchCatalog('süt');
    expect(hits, isNotEmpty);
    expect(hits.first.id, 'sut-1l');
  });

  test('synthetic modda quotes fiyat döner', () async {
    final app = createApp(
      quoteService: QuoteService(mode: PriceMode.synthetic),
    );

    final health = await app(Request('GET', Uri.parse('http://localhost/health')));
    final healthBody = jsonDecode(await health.readAsString()) as Map;
    expect(healthBody['priceMode'], 'synthetic');
    expect(healthBody['policy'], contains('Scraping'));

    final response = await app(
      Request(
        'POST',
        Uri.parse('http://localhost/v1/markets/bim/quotes'),
        body: jsonEncode({
          'region': 'istanbul',
          'items': [
            {
              'productId': 'sut-1l__icim',
              'typeId': 'sut-1l',
              'brand': 'İçim',
              'name': 'İçim Tam Yağlı Süt 1L',
              'quantity': 1,
            },
          ],
        }),
      ),
    );

    expect(response.statusCode, 200);
    final body = jsonDecode(await response.readAsString()) as Map;
    expect(body['status'], 'ok');
    expect(body['source'], 'synthetic');
    expect(body['quotes'][0]['available'], isTrue);
    expect(body['quotes'][0]['unitPrice'], greaterThan(0));
  });

  test('official modda yapılandırılmamış market failed döner', () async {
    final app = createApp(
      quoteService: QuoteService(mode: PriceMode.official),
    );

    final response = await app(
      Request(
        'POST',
        Uri.parse('http://localhost/v1/markets/migros/quotes'),
        body: jsonEncode({
          'items': [
            {
              'productId': 'sut-1l__icim',
              'typeId': 'sut-1l',
              'brand': 'İçim',
              'quantity': 1,
            },
          ],
        }),
      ),
    );

    final body = jsonDecode(await response.readAsString()) as Map;
    expect(body['status'], 'failed');
    expect(body['errorMessage'], contains('resmi'));
  });
}
