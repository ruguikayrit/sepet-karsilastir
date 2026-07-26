import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/app_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.retriable = false});

  final String message;
  final int? statusCode;
  final bool retriable;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Uygulamanın kendi backend'ine HTTP erişimi.
///
/// Market sitelerine doğrudan istek atılmaz; CORS, ToS ve kırılganlık riski
/// nedeniyle canlı fiyatlar backend üzerinden toplanır.
class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
    Duration? timeout,
    String? apiKey,
    this.maxRetries = 2,
  })  : _http = httpClient ?? http.Client(),
        _baseUrl = (baseUrl ?? AppConfig.apiBaseUrl).replaceAll(RegExp(r'/$'), ''),
        _timeout = timeout ?? AppConfig.requestTimeout,
        _apiKey = apiKey ?? AppConfig.apiKey;

  final http.Client _http;
  final String _baseUrl;
  final Duration _timeout;
  final String _apiKey;
  final int maxRetries;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (_apiKey.isNotEmpty) 'Authorization': 'Bearer $_apiKey',
      };

  Uri _uri(String path, [Map<String, String>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$normalized').replace(queryParameters: query);
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) {
    return _withRetry(
      () => _http.get(_uri(path, query), headers: _headers).timeout(_timeout),
    );
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) {
    return _withRetry(
      () => _http
          .post(
            _uri(path),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(_timeout),
    );
  }

  Future<Map<String, dynamic>> _withRetry(
    Future<http.Response> Function() request,
  ) async {
    Object? lastError;
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await request();
        return _decode(response);
      } on ApiException catch (e) {
        lastError = e;
        if (!e.retriable || attempt == maxRetries) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 250 * (attempt + 1)));
      } catch (e) {
        lastError = e;
        if (attempt == maxRetries) {
          throw ApiException(e.toString(), retriable: true);
        }
        await Future<void>.delayed(Duration(milliseconds: 250 * (attempt + 1)));
      }
    }
    throw lastError ?? ApiException('İstek başarısız.');
  }

  Map<String, dynamic> _decode(http.Response response) {
    final code = response.statusCode;
    if (code < 200 || code >= 300) {
      final retriable = code == 408 || code == 429 || code >= 500;
      throw ApiException(
        'HTTP $code: ${response.body}',
        statusCode: code,
        retriable: retriable,
      );
    }
    if (response.body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw ApiException('Beklenen JSON nesnesi gelmedi.');
  }

  void close() => _http.close();
}
