import 'package:flutter/material.dart';

enum MarketId { migros, a101, sok, carrefour, file }

class Market {
  const Market({
    required this.id,
    required this.name,
    required this.shortName,
    required this.color,
  });

  final MarketId id;
  final String name;
  final String shortName;
  final Color color;

  static const all = <Market>[
    Market(
      id: MarketId.migros,
      name: 'Migros',
      shortName: 'MIG',
      color: Color(0xFFFF6600),
    ),
    Market(
      id: MarketId.a101,
      name: 'A101',
      shortName: 'A101',
      color: Color(0xFF00ADEF),
    ),
    Market(
      id: MarketId.sok,
      name: 'Şok',
      shortName: 'ŞOK',
      color: Color(0xFFFFCC00),
    ),
    Market(
      id: MarketId.carrefour,
      name: 'Carrefour',
      shortName: 'CRF',
      color: Color(0xFF0055A5),
    ),
    Market(
      id: MarketId.file,
      name: 'File',
      shortName: 'FILE',
      color: Color(0xFF6B2D8B),
    ),
  ];

  static Market byId(MarketId id) => all.firstWhere((m) => m.id == id);
}
