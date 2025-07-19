// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'label_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LabelTemplate _$LabelTemplateFromJson(Map<String, dynamic> json) =>
    LabelTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      template: json['template'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$LabelTemplateToJson(LabelTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'template': instance.template,
    };

PrintHistory _$PrintHistoryFromJson(Map<String, dynamic> json) =>
    PrintHistory(
      id: json['id'] as String,
      itemCode: json['itemCode'] as String,
      templateName: json['templateName'] as String,
      printedDate: json['printedDate'] as String,
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$PrintHistoryToJson(PrintHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itemCode': instance.itemCode,
      'templateName': instance.templateName,
      'printedDate': instance.printedDate,
      'quantity': instance.quantity,
    };