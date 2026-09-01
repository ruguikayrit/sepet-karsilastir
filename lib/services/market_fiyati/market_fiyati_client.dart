import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../../models/product.dart';
import '../../utils/text.dart';

/// TÜBİTAK Market Fiyatı resmi arama API'si.
///
/// https://api.marketfiyati.org.tr/api/v2 — A101, BİM, Şok, Migros,
/// CarrefourSA, Hakmar, Tarım Kredi şube fiyatları.
class MarketFiyatiClient {
  MarketFiyatiClient({
    http.Client? httpClient,
    this.baseUrl = 'https://api.marketfiyati.org.tr/api/v2',
  }) : _http = httpClient ?? http.Client();

  final http.Client _http;
  final String baseUrl;

  static const _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Origin': 'https://marketfiyati.org.tr',
    'Referer': 'https://marketfiyati.org.tr/',
  };

  Future<List<MfProduct>> search(
    String keywords, {
    String region = AppConfig.defaultRegion,
    int size = 24,
  }) async {
    final coords = AppConfig.coordsFor(region);
    final json = await _post('search', {
      'keywords': keywords,
      'latitude': coords.$1,
      'longitude': coords.$2,
      'distance': AppConfig.marketFiyatiDistanceKm,
      'size': size,
    });
    return _parseList(json);
  }

  Future<MfProduct?> byId(
    String id, {
    String region = AppConfig.defaultRegion,
    String? keywords,
  }) async {
    final coords = AppConfig.coordsFor(region);
    final json = await _post('searchByIdentity', {
      'identity': id,
      'identityType': 'id',
      'latitude': coords.$1,
      'longitude': coords.$2,
      'distance': AppConfig.marketFiyatiDistanceKm,
      if (keywords != null) 'keywords': keywords,
    });
    final list = _parseList(json);
    if (list.isEmpty) return null;
    for (final product in list) {
      if (product.id == id) return product;
    }
    return list.first;
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    Object? last;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await _http
            .post(
              Uri.parse('$baseUrl/$path'),
              headers: _headers,
              body: jsonEncode(body),
            )
            .timeout(AppConfig.requestTimeout);
        if (response.statusCode == 418 ||
            response.statusCode == 429 ||
            response.statusCode >= 500) {
          last = response.statusCode;
          await Future<void>.delayed(
            Duration(milliseconds: 400 * (attempt + 1)),
          );
          continue;
        }
        if (response.statusCode < 200 || response.statusCode >= 300) {
          return const {};
        }
        final decoded = jsonDecode(response.body);
        return decoded is Map<String, dynamic> ? decoded : const {};
      } catch (e) {
        last = e;
        await Future<void>.delayed(Duration(milliseconds: 300 * (attempt + 1)));
      }
    }
    throw last ?? StateError('Market Fiyatı yanıt vermedi');
  }

  List<MfProduct> _parseList(Map<String, dynamic> json) {
    final content = json['content'] as List<dynamic>? ?? const [];
    return [
      for (final raw in content)
        if (raw is Map<String, dynamic>)
          if (MfProduct.tryParse(raw) != null) MfProduct.tryParse(raw)!,
    ];
  }
}

class MfProduct {
  const MfProduct({
    required this.id,
    required this.title,
    required this.category,
    this.brand,
    this.volume,
    this.imageUrl,
    this.depots = const [],
  });

  static MfProduct? tryParse(Map<String, dynamic> json) {
    final id = (json['id'] as String?)?.trim();
    final title = (json['title'] as String?)?.trim();
    if (id == null || id.isEmpty || title == null || title.isEmpty) {
      return null;
    }
    final depots = <MfDepot>[];
    for (final raw in json['productDepotInfoList'] as List<dynamic>? ?? []) {
      if (raw is! Map<String, dynamic>) continue;
      final depot = MfDepot.tryParse(raw, productName: title);
      if (depot != null) depots.add(depot);
    }
    return MfProduct(
      id: id,
      title: title,
      brand: json['brand'] as String?,
      volume: json['refinedVolumeOrWeight'] as String?,
      category: (json['menu_category'] as String?) ??
          (json['main_category'] as String?) ??
          'Genel',
      imageUrl: json['imageUrl'] as String?,
      depots: depots,
    );
  }

  final String id;
  final String title;
  final String? brand;
  final String? volume;
  final String category;
  final String? imageUrl;
  final List<MfDepot> depots;

  String get sourceUrl => 'https://marketfiyati.org.tr/?product=$id';

  Product toProduct() {
    return Product(
      id: 'mf:$id',
      typeId: 'mf:$id',
      name: volume == null || volume!.isEmpty ? title : title,
      category: category,
      unit: 'adet',
      brand: brand,
    );
  }

  Map<String, MfDepot> cheapestByMarket() {
    final best = <String, MfDepot>{};
    for (final depot in depots) {
      final current = best[depot.marketId];
      if (current == null || depot.price < current.price) {
        best[depot.marketId] = depot;
      }
    }
    return best;
  }

  int score({String? brand, required String name}) {
    final hay = foldTurkish('$brand $title $volume');
    var score = 0;
    final wantedBrand = foldTurkish(brand ?? this.brand ?? '');
    if (wantedBrand.isNotEmpty) {
      if (hay.contains(wantedBrand)) {
        score += 8;
      } else {
        score -= 4;
      }
    }
    for (final token in foldTurkish(name).split(RegExp(r'\s+'))) {
      if (token.length < 2) continue;
      if (hay.contains(token)) score += 2;
    }
    return score;
  }
}

class MfDepot {
  const MfDepot({
    required this.marketId,
    required this.depotId,
    required this.depotName,
    required this.price,
    required this.productName,
    this.indexTime,
  });

  static const aliases = <String, String>{
    'a101': 'a101',
    'bim': 'bim',
    'sok': 'sok',
    'sokmarket': 'sok',
    'migros': 'migros',
    'carrefour': 'carrefour',
    'carrefoursa': 'carrefour',
    'hakmar': 'hakmar',
    'tarimkredi': 'tarimKredi',
    'tarim-kredi': 'tarimKredi',
    'tkk': 'tarimKredi',
  };

  static MfDepot? tryParse(
    Map<String, dynamic> json, {
    required String productName,
  }) {
    final market = _marketId(json['marketAdi'] as String?);
    final price = (json['price'] as num?)?.toDouble();
    if (market == null || price == null || price <= 0) return null;
    return MfDepot(
      marketId: market,
      depotId: '${json['depotId'] ?? ''}',
      depotName: '${json['depotName'] ?? ''}',
      price: price,
      productName: productName,
      indexTime: json['indexTime'] as String?,
    );
  }

  static String? _marketId(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final key = foldTurkish(raw).replaceAll(' ', '');
    return aliases[key] ?? aliases[raw.toLowerCase()];
  }

  final String marketId;
  final String depotId;
  final String depotName;
  final double price;
  final String productName;
  final String? indexTime;
}
