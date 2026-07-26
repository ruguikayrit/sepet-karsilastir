# Sepet (geçici ad)

Market alışveriş listesi fiyat karşılaştırma uygulaması (Flutter).

## Staging önizleme

**Canlı staging:** https://ruguikayrit.github.io/sepet-karsilastir/

`master` / `main` branch'e her push sonrası GitHub Pages otomatik güncellenir
(`.github/workflows/deploy-staging.yml`).

## Yerel çalıştırma

```bash
flutter pub get
flutter run
```

### Canlı fiyat modu

```bash
flutter run \
  --dart-define=USE_LIVE_PRICES=true \
  --dart-define=API_BASE_URL=https://api.sizin-backend.com \
  --dart-define=API_KEY=opsiyonel-token \
  --dart-define=DEFAULT_REGION=istanbul
```

`API_BASE_URL` verilmezse veya `example.com` içeriyorsa uygulama stub
istemcilerle çalışır (ağ çağrısı yok, entegrasyon akışı test edilir).

### Backend sözleşmesi

Uygulama market sitelerine doğrudan gitmez; kendi backend'inize istek atar.

| Endpoint | Açıklama |
| --- | --- |
| `GET /v1/catalog/search?q=` | Ürün tipi arama |
| `POST /v1/markets/{slug}/quotes` | Tek market sepet teklifi |

`POST` gövdesi:

```json
{
  "region": "istanbul",
  "storeId": null,
  "items": [
    {
      "productId": "sut-1l__icim",
      "typeId": "sut-1l",
      "brand": "İçim",
      "externalSku": "MIG-SUT-1L",
      "quantity": 2,
      "name": "İçim Tam Yağlı Süt 1L"
    }
  ]
}
```

Yanıt:

```json
{
  "marketId": "migros",
  "status": "ok",
  "fetchedAt": "2026-07-26T08:00:00.000Z",
  "storeId": "store-42",
  "quotes": [
    {
      "productId": "sut-1l__icim",
      "externalSku": "MIG-SUT-1L",
      "unitPrice": 41.5,
      "available": true,
      "currency": "TRY"
    }
  ]
}
```

Market slug'ları: `migros`, `macrocenter`, `a101`, `bim`, `sok`,
`carrefour`, `file`, `tarim-kredi`, `hakmar`, `onur`, `happy-center`,
`metro`, `getir`.

Tek market düşse bile diğerleri gösterilir. Aynı sepet teklifleri ~45 sn
önbelleğe alınır; 5xx / 429 / zaman aşımında istek yeniden denenir.

## Özellikler

- 13 market, segment bazlı karşılaştırma
- Marka seçimli sepet (aynı ürün tipi + farklı marka = ayrı satır)
- Sepet kalıcılığı (uygulama kapanınca kaybolmaz)
- Kayıtlı listeler ve karşılaştırma geçmişi
- Açık / koyu / sistem teması
- Demo veya canlı fiyat kaynağı

## Test

```bash
flutter test
```
