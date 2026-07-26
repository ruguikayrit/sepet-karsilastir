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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: market.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: market.color.withValues(alpha: 0.35)),
      ),
      child: Text(
        compact ? market.shortName : market.name,
        style: TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w800,
          fontSize: compact ? 11 : 13,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
