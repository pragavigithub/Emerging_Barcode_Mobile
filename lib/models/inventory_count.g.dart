// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_count.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryCountTask _$InventoryCountTaskFromJson(Map<String, dynamic> json) =>
    InventoryCountTask(
      id: json['id'] as String,
      warehouse: json['warehouse'] as String,
      binCode: json['binCode'] as String,
      assignedDate: json['assignedDate'] as String,
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => ExpectedItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$InventoryCountTaskToJson(InventoryCountTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'warehouse': instance.warehouse,
      'binCode': instance.binCode,
      'assignedDate': instance.assignedDate,
      'status': instance.status,
      'items': instance.items,
    };

ExpectedItem _$ExpectedItemFromJson(Map<String, dynamic> json) =>
    ExpectedItem(
      itemCode: json['itemCode'] as String,
      description: json['description'] as String,
      expectedQuantity: (json['expectedQuantity'] as num).toDouble(),
      unit: json['unit'] as String,
    );

Map<String, dynamic> _$ExpectedItemToJson(ExpectedItem instance) =>
    <String, dynamic>{
      'itemCode': instance.itemCode,
      'description': instance.description,
      'expectedQuantity': instance.expectedQuantity,
      'unit': instance.unit,
    };

CountedItem _$CountedItemFromJson(Map<String, dynamic> json) => CountedItem(
      itemCode: json['itemCode'] as String,
      countedQuantity: (json['countedQuantity'] as num).toDouble(),
      binCode: json['binCode'] as String,
      batchNumber: json['batchNumber'] as String? ?? '',
    );

Map<String, dynamic> _$CountedItemToJson(CountedItem instance) =>
    <String, dynamic>{
      'itemCode': instance.itemCode,
      'countedQuantity': instance.countedQuantity,
      'binCode': instance.binCode,
      'batchNumber': instance.batchNumber,
    };