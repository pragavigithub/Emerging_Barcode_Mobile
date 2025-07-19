
import 'package:flutter/foundation.dart';
import '../../services/api_service.dart';
import '../../services/database_service.dart';
import '../../models/grpo_document.dart';

class GRPORepository extends ChangeNotifier {
  final ApiService _apiService;
  final DatabaseService _databaseService;

  GRPORepository(this._apiService, this._databaseService);

  Future<List<GRPODocument>> getGRPODocuments() async {
    try {
      // Try to get from API first
      final grpos = await _apiService.getGRPODocuments();
      
      // Save to local database
      for (final grpo in grpos) {
        await _databaseService.insertOrUpdateGRPODocument(grpo);
      }
      
      return grpos;
    } catch (e) {
      // Fallback to local database
      return await _databaseService.getGRPODocuments();
    }
  }

  Future<GRPODocument> createGRPODocument(Map<String, dynamic> data) async {
    return await _apiService.createGRPODocument(data);
  }
}
