enum FetchStatus {
  /// Fiyatlar başarıyla alındı.
  ok,

  /// Market yanıt vermedi / zaman aşımı / hata.
  failed,

  /// İstek atılmadı (devre dışı vb.).
  skipped,
}

extension FetchStatusX on FetchStatus {
  bool get isOk => this == FetchStatus.ok;
  bool get isFailed => this == FetchStatus.failed;
}
