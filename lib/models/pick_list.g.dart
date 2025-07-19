// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pick_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PickList _$PickListFromJson(Map<String, dynamic> json) => PickList(
      id: json['id'] as String,
      salesOrderId: json['salesOrderId'] as String,
      customerName: json['customerName'] as String,
      status: json['status'] as String,
      assignedDate: json['assignedDate'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => PickListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PickListToJson(PickList instance) => <String, dynamic>{
      'id': instance.id,
      'salesOrderId': instance.salesOrderId,
      'customerName': instance.customerName,
      'status': instance.status,
      'assignedDate': instance.assignedDate,
      'items': instance.items,
    };

PickListItem _$PickListItemFromJson(Map<String, dynamic> json) =>
    PickListItem(
      id: json['id'] as String,
      itemCode: json['itemCode'] as String,
      description: json['description'] as String,
      requiredQuantity: (json['requiredQuantity'] as num).toDouble(),
      pickedQuantity: (json['pickedQuantity'] as num?)?.toDouble() ?? 0.0,
      binCode: json['binCode'] as String? ?? '',
      unit: json['unit'] as String,
    );

Map<String, dynamic> _$PickListItemToJson(PickListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itemCode': instance.itemCode,
      'description': instance.description,
      'requiredQuantity': instance.requiredQuantity,
      'pickedQuantity': instance.pickedQuantity,
      'binCode': instance.binCode,
      'unit': instance.unit,
    };