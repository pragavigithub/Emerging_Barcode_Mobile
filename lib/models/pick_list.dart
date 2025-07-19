
import 'package:json_annotation/json_annotation.dart';

part 'pick_list.g.dart';

@JsonSerializable()
class PickList {
  final String id;
  final String salesOrderId;
  final String customerName;
  final String status;
  final String assignedDate;
  final List<PickListItem> items;

  PickList({
    required this.id,
    required this.salesOrderId,
    required this.customerName,
    required this.status,
    required this.assignedDate,
    required this.items,
  });

  factory PickList.fromJson(Map<String, dynamic> json) => _$PickListFromJson(json);
  Map<String, dynamic> toJson() => _$PickListToJson(this);

  static PickList empty() => PickList(
    id: '',
    salesOrderId: '',
    customerName: '',
    status: '',
    assignedDate: '',
    items: [],
  );
}

@JsonSerializable()
class PickListItem {
  final String id;
  final String itemCode;
  final String description;
  final double requiredQuantity;
  double pickedQuantity;
  String binCode;
  final String unit;

  PickListItem({
    required this.id,
    required this.itemCode,
    required this.description,
    required this.requiredQuantity,
    this.pickedQuantity = 0.0,
    this.binCode = '',
    required this.unit,
  });

  factory PickListItem.fromJson(Map<String, dynamic> json) => _$PickListItemFromJson(json);
  Map<String, dynamic> toJson() => _$PickListItemToJson(this);
}
