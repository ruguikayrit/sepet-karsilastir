import 'list_item.dart';

/// Kullanıcının isim vererek sakladığı alışveriş listesi.
class SavedList {
  const SavedList({
    required this.id,
    required this.name,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavedList.fromJson(Map<String, dynamic> json) {
    return SavedList(
      id: json['id'] as String,
      name: json['name'] as String,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => ListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(
        json['updatedAt'] as String? ?? json['createdAt'] as String,
      ),
    );
  }

  final String id;
  final String name;
  final List<ListItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get totalQuantity =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  SavedList copyWith({
    String? name,
    List<ListItem>? items,
    DateTime? updatedAt,
  }) {
    return SavedList(
      id: id,
      name: name ?? this.name,
      items: items ?? this.items,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'items': items.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
