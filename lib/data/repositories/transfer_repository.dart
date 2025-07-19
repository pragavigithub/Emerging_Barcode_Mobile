
import 'package:flutter/foundation.dart';
import '../../services/api_service.dart';
import '../../services/database_service.dart';

class TransferRepository extends ChangeNotifier {
  final ApiService _apiService;
  final DatabaseService _databaseService;

  TransferRepository(this._apiService, this._databaseService);

  Future<Map<String, dynamic>> validateTransferRequest(String requestNumber) async {
    return await _apiService.validateTransferRequest(requestNumber);
  }

  Future<Map<String, dynamic>> submitTransferForQC(int id) async {
    return await _apiService.submitTransferForQC(id);
  }

  Future<Map<String, dynamic>> reopenTransfer(int id) async {
    return await _apiService.reopenTransfer(id);
  }
}
