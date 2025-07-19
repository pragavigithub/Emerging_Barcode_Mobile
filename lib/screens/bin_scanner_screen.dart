
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../services/api_service.dart';
import '../models/bin_item.dart';
import 'barcode_scanner_screen.dart';

class BinScannerScreen extends StatefulWidget {
  const BinScannerScreen({Key? key}) : super(key: key);

  @override
  State<BinScannerScreen> createState() => _BinScannerScreenState();
}

class _BinScannerScreenState extends State<BinScannerScreen> {
  List<BinItem> _binItems = [];
  bool _isLoading = false;
  String _currentBinCode = '';

  Future<void> _scanBin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(
          title: 'Scan Bin Code',
          scanType: ScanType.bin,
        ),
      ),
    );

    if (result != null) {
      _loadBinItems(result);
    }
  }

  Future<void> _loadBinItems(String binCode) async {
    setState(() {
      _isLoading = true;
      _currentBinCode = binCode;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final items = await apiService.getBinItems(binCode);
      
      setState(() {
        _binItems = items;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bin items: $e')),
      );
      setState(() {
        _binItems = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showItemDetails(BinItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.itemCode),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Description: ${item.description}'),
              const SizedBox(height: 8),
              Text('Quantity: ${item.quantity}'),
              const SizedBox(height: 8),
              Text('Unit: ${item.unit}'),
              const SizedBox(height: 8),
              Text('Bin: ${item.binCode}'),
              if (item.batchNumber.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Batch: ${item.batchNumber}'),
              ],
              if (item.expiryDate.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Expiry: ${item.expiryDate}'),
              ],
              if (item.serialNumbers.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Serial Numbers:'),
                ...item.serialNumbers.map((sn) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text('• $sn'),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bin Scanner'),
        actions: [
          if (_currentBinCode.isNotEmpty)
            IconButton(
              onPressed: () => _loadBinItems(_currentBinCode),
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _scanBin,
                        icon: Icon(MdiIcons.qrcodeScan),
                        label: const Text('Scan Bin Code'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_currentBinCode.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Current Bin: $_currentBinCode',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _currentBinCode.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              MdiIcons.qrcodeScan,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Scan a bin code',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            const Text('Scan a bin barcode to view all items'),
                          ],
                        ),
                      )
                    : _binItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  MdiIcons.packageVariantClosed,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Bin is empty',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text('No items found in bin $_currentBinCode'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _binItems.length,
                            itemBuilder: (context, index) {
                              final item = _binItems[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ListTile(
                                  title: Text(item.itemCode),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.description),
                                      Text('Quantity: ${item.quantity} ${item.unit}'),
                                      if (item.batchNumber.isNotEmpty)
                                        Text('Batch: ${item.batchNumber}'),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(MdiIcons.packageVariant),
                                      Text(
                                        '${item.quantity}',
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                    ],
                                  ),
                                  onTap: () => _showItemDetails(item),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
