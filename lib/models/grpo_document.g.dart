// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grpo_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GRPODocument _$GRPODocumentFromJson(Map<String, dynamic> json) => GRPODocument(
      id: (json['id'] as num).toInt(),
      poNumber: json['po_number'] as String,
      supplierCode: json['supplier_code'] as String?,
      supplierName: json['supplier_name'] as String?,
      warehouseCode: json['warehouse_code'] as String?,
      userId: (json['user_id'] as num).toInt(),
      qcApproverId: (json['qc_approver_id'] as num?)?.toInt(),
      qcApprovedAt: json['qc_approved_at'] == null
          ? null
          : DateTime.parse(json['qc_approved_at'] as String),
      qcNotes: json['qc_notes'] as String?,
      status: json['status'] as String,
      poTotal: (json['po_total'] as num?)?.toDouble(),
      sapDocumentNumber: json['sap_document_number'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      syncStatus: (json['sync_status'] as num?)?.toInt() ?? 0,
      lastSyncedAt: json['last_synced_at'] == null
          ? null
          : DateTime.parse(json['last_synced_at'] as String),
    );

Map<String, dynamic> _$GRPODocumentToJson(GRPODocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'po_number': instance.poNumber,
      'supplier_code': instance.supplierCode,
      'supplier_name': instance.supplierName,
      'warehouse_code': instance.warehouseCode,
      'user_id': instance.userId,
      'qc_approver_id': instance.qcApproverId,
      'qc_approved_at': instance.qcApprovedAt?.toIso8601String(),
      'qc_notes': instance.qcNotes,
      'status': instance.status,
      'po_total': instance.poTotal,
      'sap_document_number': instance.sapDocumentNumber,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'sync_status': instance.syncStatus,
      'last_synced_at': instance.lastSyncedAt?.toIso8601String(),
    };
