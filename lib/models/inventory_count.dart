
import 'package:json_annotation/json_annotation.dart';

part 'inventory_count.g.dart';

@JsonSerializable()
class InventoryCountTask {
  final String id;
  final String warehouse;
  final String binCode;
  final String assignedDate;
  final String status;
  final List<ExpectedItem> items;

  InventoryCountTask({
    required this.id,
    required this.warehouse,
    required this.binCode,
    required this.assignedDate,
    required this.status,
    required this.items,
  });

  factory InventoryCountTask.fromJson(Map<String, dynamic> json) => _$InventoryCountTaskFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryCountTaskToJson(this);
}

@JsonSerializable()
class ExpectedItem {
  final String itemCode;
  final String description;
  final double expectedQuantity;
  final String unit;

  ExpectedItem({
    required this.itemCode,
    required this.description,
    required this.expectedQuantity,
    required this.unit,
  });

  factory ExpectedItem.fromJson(Map<String, dynamic> json) => _$ExpectedItemFromJson(json);
  Map<String, dynamic> toJson() => _$ExpectedItemToJson(this);
}

@JsonSerializable()
class CountedItem {
  final String itemCode;
  double countedQuantity;
  final String binCode;
  final String batchNumber;

  CountedItem({
    required this.itemCode,
    required this.countedQuantity,
    required this.binCode,
    this.batchNumber = '',
  });

  factory CountedItem.fromJson(Map<String, dynamic> json) => _$CountedItemFromJson(json);
  Map<String, dynamic> toJson() => _$CountedItemToJson(this);
}
