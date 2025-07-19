
import 'package:json_annotation/json_annotation.dart';

part 'bin_item.g.dart';

@JsonSerializable()
class BinItem {
  final String itemCode;
  final String description;
  final double quantity;
  final String unit;
  final String binCode;
  final String batchNumber;
  final String expiryDate;
  final List<String> serialNumbers;

  BinItem({
    required this.itemCode,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.binCode,
    this.batchNumber = '',
    this.expiryDate = '',
    this.serialNumbers = const [],
  });

  factory BinItem.fromJson(Map<String, dynamic> json) => _$BinItemFromJson(json);
  Map<String, dynamic> toJson() => _$BinItemToJson(this);
}
