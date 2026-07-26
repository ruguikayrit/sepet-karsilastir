import 'package:flutter/material.dart';

import '../models/market.dart';
import '../theme/app_theme.dart';

class MarketBadge extends StatelessWidget {
  const MarketBadge({
    super.key,
    required this.market,
    this.compact = false,
  });

  final Market market;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Market marka renkleri koyu modda okunmaz kalabildiği için zemini
    // güçlendirip metni tema mürekkebiyle yazıyoruz.
    final tint = market.color.withValues(alpha: isDark ? 0.26 : 0.14);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: market.color.withValues(alpha: isDark ? 0.5 : 0.35),
        ),
      ),
      child: Text(
        compact ? market.shortName : market.name,
        style: TextStyle(
          color: palette.ink,
          fontWeight: FontWeight.w800,
          fontSize: compact ? 11 : 13,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
