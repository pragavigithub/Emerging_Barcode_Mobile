// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_transfer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryTransfer _$InventoryTransferFromJson(Map<String, dynamic> json) =>
    InventoryTransfer(
      id: (json['id'] as num).toInt(),
      transferRequestNumber: json['transfer_request_number'] as String,
      sapDocumentNumber: json['sap_document_number'] as String?,
      status: json['status'] as String,
      userId: (json['user_id'] as num).toInt(),
      qcApproverId: (json['qc_approver_id'] as num?)?.toInt(),
      qcApprovedAt: json['qc_approved_at'] == null
          ? null
          : DateTime.parse(json['qc_approved_at'] as String),
      qcNotes: json['qc_notes'] as String?,
      fromWarehouse: json['from_warehouse'] as String?,
      toWarehouse: json['to_warehouse'] as String?,
      transferType: json['transfer_type'] as String,
      priority: json['priority'] as String,
      reasonCode: json['reason_code'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      syncStatus: (json['sync_status'] as num?)?.toInt() ?? 0,
      lastSyncedAt: json['last_synced_at'] == null
          ? null
          : DateTime.parse(json['last_synced_at'] as String),
    );

Map<String, dynamic> _$InventoryTransferToJson(InventoryTransfer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transfer_request_number': instance.transferRequestNumber,
      'sap_document_number': instance.sapDocumentNumber,
      'status': instance.status,
      'user_id': instance.userId,
      'qc_approver_id': instance.qcApproverId,
      'qc_approved_at': instance.qcApprovedAt?.toIso8601String(),
      'qc_notes': instance.qcNotes,
      'from_warehouse': instance.fromWarehouse,
      'to_warehouse': instance.toWarehouse,
      'transfer_type': instance.transferType,
      'priority': instance.priority,
      'reason_code': instance.reasonCode,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'sync_status': instance.syncStatus,
      'last_synced_at': instance.lastSyncedAt?.toIso8601String(),
    };
