
import 'package:json_annotation/json_annotation.dart';

part 'label_template.g.dart';

@JsonSerializable()
class LabelTemplate {
  final String id;
  final String name;
  final String description;
  final Map<String, dynamic> template;

  LabelTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.template,
  });

  factory LabelTemplate.fromJson(Map<String, dynamic> json) => _$LabelTemplateFromJson(json);
  Map<String, dynamic> toJson() => _$LabelTemplateToJson(this);
}

@JsonSerializable()
class PrintHistory {
  final String id;
  final String itemCode;
  final String templateName;
  final String printedDate;
  final int quantity;

  PrintHistory({
    required this.id,
    required this.itemCode,
    required this.templateName,
    required this.printedDate,
    required this.quantity,
  });

  factory PrintHistory.fromJson(Map<String, dynamic> json) => _$PrintHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$PrintHistoryToJson(this);
}
