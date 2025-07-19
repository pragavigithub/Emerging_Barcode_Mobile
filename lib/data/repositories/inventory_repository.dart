
import 'package:flutter/foundation.dart';
import '../../services/api_service.dart';
import '../../services/database_service.dart';
import '../../models/inventory_transfer.dart';

class InventoryRepository extends ChangeNotifier {
  final ApiService _apiService;
  final DatabaseService _databaseService;

  InventoryRepository(this._apiService, this._databaseService);

  Future<List<InventoryTransfer>> getInventoryTransfers() async {
    try {
      // Try to get from API first
      final transfers = await _apiService.getInventoryTransfers();
      
      // Save to local database
      for (final transfer in transfers) {
        await _databaseService.insertOrUpdateInventoryTransfer(transfer);
      }
      
      return transfers;
    } catch (e) {
      // Fallback to local database
      return await _databaseService.getInventoryTransfers();
    }
  }

  Future<InventoryTransfer> createInventoryTransfer(Map<String, dynamic> data) async {
    return await _apiService.createInventoryTransfer(data);
  }

  Future<InventoryTransfer> updateInventoryTransfer(int id, Map<String, dynamic> data) async {
    return await _apiService.updateInventoryTransfer(id, data);
  }
}
