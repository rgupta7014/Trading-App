import 'package:uuid/uuid.dart';

/// Represents a user-customizable list of stock symbols.
class Watchlist {
  final String id;
  final String name;
  final List<String> symbols;

  Watchlist({
    String? id,
    required this.name,
    List<String>? symbols,
  })  : id = id ?? const Uuid().v4(),
        symbols = symbols ?? [];

  Watchlist copyWith({
    String? id,
    String? name,
    List<String>? symbols,
  }) {
    return Watchlist(
      id: id ?? this.id,
      name: name ?? this.name,
      symbols: symbols ?? List.unmodifiable(this.symbols),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbols': symbols,
    };
  }

  factory Watchlist.fromJson(Map<String, dynamic> json) {
    return Watchlist(
      id: json['id'] as String? ?? const Uuid().v4(),
      name: json['name'] as String? ?? 'Watchlist',
      symbols: (json['symbols'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Watchlist &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
