
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'database_service.dart';

class SyncService extends ChangeNotifier {
  final ApiService _apiService;
  final DatabaseService _databaseService;
  
  bool _isSyncing = false;
  String _syncStatus = 'Ready';
  DateTime? _lastSyncTime;

  SyncService(this._apiService, this._databaseService);

  bool get isSyncing => _isSyncing;
  String get syncStatus => _syncStatus;
  DateTime? get lastSyncTime => _lastSyncTime;

  Future<void> syncAllData() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _syncStatus = 'Syncing...';
    notifyListeners();

    try {
      // Check connection
      final isConnected = await _apiService.checkConnection();
      if (!isConnected) {
        throw Exception('No internet connection');
      }

      // Sync inventory transfers
      await _syncInventoryTransfers();
      
      // Sync GRPO documents
      await _syncGRPODocuments();

      _syncStatus = 'Sync completed';
      _lastSyncTime = DateTime.now();
      
      print('✅ Sync completed successfully');
    } catch (e) {
      _syncStatus = 'Sync failed: ${e.toString()}';
      print('❌ Sync error: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _syncInventoryTransfers() async {
    try {
      final transfers = await _apiService.getInventoryTransfers();
      for (final transfer in transfers) {
        await _databaseService.insertOrUpdateInventoryTransfer(transfer);
      }
    } catch (e) {
      print('Error syncing inventory transfers: $e');
    }
  }

  Future<void> _syncGRPODocuments() async {
    try {
      final grpos = await _apiService.getGRPODocuments();
      for (final grpo in grpos) {
        await _databaseService.insertOrUpdateGRPODocument(grpo);
      }
    } catch (e) {
      print('Error syncing GRPO documents: $e');
    }
  }
}
