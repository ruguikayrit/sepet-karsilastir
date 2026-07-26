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

`API_BASE_URL` verilmezse veya `example.com` içeriyorsa uygulama fiyat
defterine düşer. Uydurma fiyat üreten bir taklit servis yok.

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
      "currency": "TRY",
      "marketProduct": "İçim Süt Tam Yağlı 1 L",
      "sourceUrl": "https://www.migros.com.tr/icim-sut-tam-yagli-1-l-p-1a2b3c"
    }
  ]
}
```

`sourceUrl` zorunludur. Fiyatın okunduğu ürün sayfası gelmezse uygulama o
satırı fiyatsız gösterir: kullanıcı tıklayıp doğrulayamayacağı bir tutarı
görmemeli.

Market slug'ları: `migros`, `macrocenter`, `a101`, `bim`, `sok`,
`carrefour`, `file`, `tarim-kredi`, `hakmar`, `onur`, `happy-center`,
`metro`, `getir`.

Tek market düşse bile diğerleri gösterilir. Aynı sepet teklifleri ~45 sn
önbelleğe alınır; 5xx / 429 / zaman aşımında istek yeniden denenir.

## Özellikler

- Marka ve gramajı seçilmiş liste, marketlerin kendi sayfalarındaki fiyatlarla
  karşılaştırılır
- 80+ ürün tipi (süt, temel gıda, meyve-sebze, et, temizlik, bebek vb.)
- Her tutar, satıra dokununca açılan ürün sayfasından okunmuştur: kullanıcı
  tıklayıp doğrulayabilir
- Fiyatı okunamayan satır "Fiyat yok" kalır; tahmin üretilmez ve toplama
  eklenmez
- Listeyi eksiksiz karşılamayan market "en ucuz" sayılmaz
- Marka seçimli sepet (aynı ürün tipi + farklı marka = ayrı satır); marka
  listesinde her markanın kaç markette fiyatlandığı yazar
- "Markasız" satırda her market o gramajdaki kendi ürününü gösterir; hangi ürün
  olduğu satırın altında görünür
- Sepet kalıcılığı, kayıtlı listeler ve karşılaştırma geçmişi
- Açık / koyu / sistem teması

## Fiyat kaynağı

Tek kaynak `lib/data/price_book.dart`: marketlerin kendi sayfalarından okunmuş
ürün adı, ürün sayfası adresi ve raf fiyatı. Dosya elle düzenlenmez,
`tools/price_sync/sync.py` üretir.

Bir kayıt yalnızca üçü birlikte doğrulandığında oluşur — ad, adres, fiyat — ve
marka, çeşit, gramaj katalogdaki satırla birebir aynı olmak zorundadır. Kaydı
olmayan satır uygulamada fiyatsız görünür.

Son adım ürünün kendi sayfasında geçer: araç adresi açar, ürün adını sayfadan
okur, tutarın o sayfada yazdığını görür ve adın hâlâ katalog satırının çeşidini
ve gramajını taşıdığını denetler. Geçemeyen kayıt deftere girmez — böylece
"satıra dokun, aynı fiyatı gör" sözü her çekimde sınanmış olur.

| Market | Durum |
| --- | --- |
| [Şok](https://www.sokmarket.com.tr) | ürün sayfası + fiyat okunuyor |
| [Migros](https://www.migros.com.tr) | ürün sayfası + fiyat okunuyor |
| [Macrocenter](https://www.macrocenter.com.tr) | ürün sayfası + fiyat okunuyor |
| [Hakmar Express](https://www.hakmarexpress.com.tr) | ürün sayfası + fiyat okunuyor |
| [Happy Center](https://happycenter.com.tr) | ürün sayfası + fiyat okunuyor |
| BİM | online satış yapmıyor, raf fiyatı yayınlamıyor |
| A101, CarrefourSA, Metro, Getir | site otomatik erişimi engelliyor |
| File, Onur | sitesinde ürün fiyatı yayınlanmıyor |

Karşılaştırma, o günün defterinde fiyatı olan marketleri kapsar. Fiyat
yayınlamayan zincir de, o gün sitesi yanıt vermeyen market de listeye girmez;
uygulama ikisini de sebebiyle birlikte ekranda yazar. Nedenler
`lib/models/market.dart` içindeki `noPriceReason` alanında ve
`tools/price_sync/markets.py` içindeki `UNSUPPORTED` listesinde tutulur.

Migros'un arama servisi yalnızca bazı ağlardan yanıt veriyor: GitHub
runner'ından çalışıyor, geliştirme makinelerinin çoğundan 403 dönüyor. Bu yüzden
günlük iş CI'da koşar.

### Fiyatları yenile

```bash
python3 tools/price_sync/sync.py              # bütün marketler
python3 tools/price_sync/sync.py --markets sok
python3 tools/price_sync/sync.py --offline    # ağa çıkmadan yeniden eşleştir
python3 tools/price_sync/sync.py --no-verify  # sayfa doğrulamasını atla (hızlı)

# Tek marketi yenile, ötekilerin kayıtlarını aynı günün defterinden devral
python3 tools/price_sync/sync.py --markets sok --merge-from lib/data/price_book.dart
```

Yeni defter eskisinin %70'inden azını taşıyorsa araç yazmayı reddeder: bir
market yanıt vermediğinde kullanıcı fiyatların yarısını kaybetmesin.
`--allow-shrink` bu kontrolü kapatır.

`.github/workflows/price-sync.yml` her gün 07:10 TRT'de aynı işi yapar:
fiyatları çeker, testleri koşar, defter değiştiyse commit'ler ve staging'i
yeniden yayınlar.

## Test

```bash
flutter test
```
