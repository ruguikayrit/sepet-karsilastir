/// Çalışma zamanı yapılandırması.
///
/// Örnek:
/// ```
/// flutter run \
///   --dart-define=USE_LIVE_PRICES=true \
///   --dart-define=API_BASE_URL=https://api.sizin-backend.com
/// ```
class AppConfig {
  const AppConfig._();

  /// `true` ve gerçek bir [apiBaseUrl] varsa canlı backend, aksi halde
  /// marketlerin sayfalarından okunmuş fiyat defteri kullanılır.
  static const useLivePrices = bool.fromEnvironment(
    'USE_LIVE_PRICES',
    defaultValue: false,
  );

  /// Backend kök adresi (market sitelerine doğrudan değil).
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );

  /// İsteğe bağlı API anahtarı / bearer token.
  static const apiKey = String.fromEnvironment('API_KEY', defaultValue: '');

  /// Varsayılan bölge / şehir (mağaza stok ve fiyat için).
  static const defaultRegion = String.fromEnvironment(
    'DEFAULT_REGION',
    defaultValue: 'istanbul',
  );

  static const requestTimeout = Duration(seconds: 12);

  /// Aynı sepet için market tekliflerinin yeniden kullanılma süresi.
  static const quoteCacheTtl = Duration(seconds: 45);

  /// Tek market başarısız olsa bile diğerlerini göster.
  static const allowPartialMarketFailures = true;

  /// Canlı HTTP backend gerçekten yapılandırıldı mı?
  ///
  /// `USE_LIVE_PRICES=true` ama `API_BASE_URL` hâlâ example.com ise
  /// uygulama stub istemcilere düşer.
  static bool get isLiveBackendConfigured =>
      useLivePrices && !apiBaseUrl.contains('example.com');

  /// Yerel geliştirme için tipik backend adresi.
  static const localBackendUrl = 'http://localhost:8787';
}
