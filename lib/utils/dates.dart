const _monthsShortTr = [
  'Oca',
  'Şub',
  'Mar',
  'Nis',
  'May',
  'Haz',
  'Tem',
  'Ağu',
  'Eyl',
  'Eki',
  'Kas',
  'Ara',
];

String formatClock(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String formatDateTr(DateTime dt) =>
    '${dt.day} ${_monthsShortTr[dt.month - 1]} ${dt.year}';

/// "3 dk önce", "Dün 14:05", "12 Tem 2026 09:30" gibi kısa etiketler.
String relativeTimeTr(DateTime dt, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final diff = reference.difference(dt);

  if (diff.inMinutes < 1) return 'az önce';
  if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
  if (diff.inHours < 24 && reference.day == dt.day) {
    return '${diff.inHours} sa önce';
  }

  final yesterday = DateTime(reference.year, reference.month, reference.day)
      .subtract(const Duration(days: 1));
  if (dt.year == yesterday.year &&
      dt.month == yesterday.month &&
      dt.day == yesterday.day) {
    return 'Dün ${formatClock(dt)}';
  }

  return '${formatDateTr(dt)} ${formatClock(dt)}';
}
