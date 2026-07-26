/// Bir market satırının hangi tür sayfaya gittiğini anlatır.
enum ProductLinkKind {
  /// Marketin sitesindeki tam ürün sayfası (marka + birim birebir aynı).
  product,

  /// Marketin site içi arama sonucu (marka + birim sorguda).
  search,

  /// Market online ürün araması sunmuyor; yalnızca kendi sitesi açılır.
  site,
}

extension ProductLinkKindX on ProductLinkKind {
  String get label => switch (this) {
        ProductLinkKind.product => 'Ürün sayfası',
        ProductLinkKind.search => 'Site içi arama',
        ProductLinkKind.site => 'Market sitesi',
      };
}

/// Fiyatın doğrulanabileceği market bağlantısı.
class ProductLink {
  const ProductLink({required this.url, required this.kind});

  final String url;
  final ProductLinkKind kind;

  String get host => Uri.parse(url).host;
}
