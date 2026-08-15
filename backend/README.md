# Sepet Backend

Flutter uygulamasının beklediği fiyat API’si.

## Fiyat politikası

- **Hedef kaynak:** her marketin resmi API’si / partner feed’i / sözleşmeli veri kanalı.
- **Yapılmayanlar:** market mobil uygulamalarını reverse-engineer etmek, private
  trafiği taklit etmek, site scrap etmek, `marketfiyati.org.tr` gibi üçüncü
  taraf toplayıcıları kullanmak.

Türk market zincirlerinin çoğu halka açık fiyat API’si yayınlamaz. Resmi
uygulama fiyatına ulaşmak için market ile partnerlik / developer erişimi gerekir.

## Modlar (`PRICE_MODE`)

| Mod | Anlamı |
| --- | --- |
| `synthetic` (varsayılan) | Yerel demo motoru — geliştirme için. Resmi uygulama fiyatı **değil**. |
| `official` | Yalnızca `*_API_BASE` + `*_API_KEY` ile yapılandırılmış market adaptörleri |

```bash
# Demo (varsayılan)
dart run bin/server.dart

# Resmi adaptör modu
PRICE_MODE=official dart run bin/server.dart
```

## Resmi adaptör ortam değişkenleri

Her market için:

```text
MIGROS_API_BASE=...
MIGROS_API_KEY=...
BIM_API_BASE=...
BIM_API_KEY=...
# A101, SOK, CARREFOUR, FILE, TARIM_KREDI, HAKMAR, ONUR,
# HAPPY_CENTER, METRO, GETIR, MACROCENTER aynı kalıp
```

Kimlik bilgisi olsa bile HTTP istemcisi, marketin verdiği dokümantasyona göre
adaptöre ayrıca yazılmalıdır. Sahte “uygulama fiyatı” üretilmez.

## Çalıştırma

```bash
cd backend
dart pub get
dart run bin/server.dart
```

Adres: `http://localhost:8787` (`PORT` ile değiştirilebilir).

## Endpointler

| Method | Path | Açıklama |
| --- | --- | --- |
| GET | `/health` | Mod, market yapılandırma durumu |
| GET | `/v1/catalog/search?q=` | Ürün tipi arama |
| POST | `/v1/markets/{slug}/quotes` | Tek market sepet teklifi |

## Flutter

```bash
flutter run \
  --dart-define=USE_LIVE_PRICES=true \
  --dart-define=API_BASE_URL=http://localhost:8787 \
  --dart-define=DEFAULT_REGION=istanbul
```
