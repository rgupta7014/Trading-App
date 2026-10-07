import 'package:uuid/uuid.dart';

enum OrderSide { buy, sell }

class OrderModel {
  final String id;
  final String symbol;
  final OrderSide side;
  final int quantity;
  final int pricePaise;
  final int totalValuePaise;
  final DateTime timestamp;

  OrderModel({
    String? id,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.pricePaise,
    int? totalValuePaise,
    DateTime? timestamp,
  })  : assert(quantity > 0, 'Quantity must be a positive integer'),
        assert(pricePaise > 0, 'Price must be a positive integer'),
        id = id ?? const Uuid().v4(),
        totalValuePaise = totalValuePaise ?? (quantity * pricePaise),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'side': side.name,
      'quantity': quantity,
      'pricePaise': pricePaise,
      'totalValuePaise': totalValuePaise,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? const Uuid().v4(),
      symbol: json['symbol'] as String? ?? '',
      side: json['side'] == 'sell' ? OrderSide.sell : OrderSide.buy,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      pricePaise: (json['pricePaise'] as num?)?.toInt() ?? 0,
      totalValuePaise: (json['totalValuePaise'] as num?)?.toInt(),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
