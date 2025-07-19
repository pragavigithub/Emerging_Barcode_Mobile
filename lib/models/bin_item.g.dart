// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bin_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BinItem _$BinItemFromJson(Map<String, dynamic> json) => BinItem(
      itemCode: json['itemCode'] as String,
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      binCode: json['binCode'] as String,
      batchNumber: json['batchNumber'] as String? ?? '',
      expiryDate: json['expiryDate'] as String? ?? '',
      serialNumbers: (json['serialNumbers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$BinItemToJson(BinItem instance) => <String, dynamic>{
      'itemCode': instance.itemCode,
      'description': instance.description,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'binCode': instance.binCode,
      'batchNumber': instance.batchNumber,
      'expiryDate': instance.expiryDate,
      'serialNumbers': instance.serialNumbers,
    };