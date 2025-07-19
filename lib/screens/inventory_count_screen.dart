
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../services/api_service.dart';
import '../models/inventory_count.dart';
import 'barcode_scanner_screen.dart';

class InventoryCountScreen extends StatefulWidget {
  const InventoryCountScreen({Key? key}) : super(key: key);

  @override
  State<InventoryCountScreen> createState() => _InventoryCountScreenState();
}

class _InventoryCountScreenState extends State<InventoryCountScreen> {
  List<InventoryCountTask> _countTasks = [];
  bool _isLoading = false;
  String _selectedWarehouse = '';
  
  @override
  void initState() {
    super.initState();
    _loadCountTasks();
  }

  Future<void> _loadCountTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final tasks = await apiService.getInventoryCountTasks();
      
      setState(() {
        _countTasks = tasks;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading count tasks: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startCounting(InventoryCountTask task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CountingDetailsScreen(task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Counting'),
        actions: [
          IconButton(
            onPressed: _loadCountTasks,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Icon(MdiIcons.counter),
                const SizedBox(width: 8),
                const Text('Allocated Count Tasks'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _countTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              MdiIcons.counter,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No count tasks assigned',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            const Text('Wait for count tasks to be assigned'),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadCountTasks,
                        child: ListView.builder(
                          itemCount: _countTasks.length,
                          itemBuilder: (context, index) {
                            final task = _countTasks[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                title: Text('${task.warehouse} - ${task.binCode}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Assigned: ${task.assignedDate}'),
                                    Text('Status: ${task.status}'),
                                    if (task.items.isNotEmpty)
                                      Text('Expected Items: ${task.items.length}'),
                                  ],
                                ),
                                trailing: _getStatusIcon(task.status),
                                onTap: () => _startCounting(task),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icon(Icons.check_circle, color: Colors.green);
      case 'in_progress':
        return Icon(Icons.pending, color: Colors.orange);
      default:
        return Icon(Icons.assignment, color: Colors.blue);
    }
  }
}

class CountingDetailsScreen extends StatefulWidget {
  final InventoryCountTask task;

  const CountingDetailsScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<CountingDetailsScreen> createState() => _CountingDetailsScreenState();
}

class _CountingDetailsScreenState extends State<CountingDetailsScreen> {
  final List<CountedItem> _countedItems = [];
  bool _isScanning = false;

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
      if (result == widget.task.binCode) {
        _scanItem();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wrong bin code scanned')),
        );
      }
    }
  }

  Future<void> _scanItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(
          title: 'Scan Item',
          scanType: ScanType.item,
        ),
      ),
    );

    if (result != null) {
      _showQuantityDialog(result);
    }
  }

  void _showQuantityDialog(String itemCode) {
    final quantityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Count'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Item: $itemCode'),
            Text('Bin: ${widget.task.binCode}'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Counted Quantity',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = double.tryParse(quantityController.text) ?? 0;
              _addCountedItem(itemCode, quantity);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addCountedItem(String itemCode, double quantity) {
    final existingIndex = _countedItems.indexWhere((item) => item.itemCode == itemCode);
    
    setState(() {
      if (existingIndex >= 0) {
        _countedItems[existingIndex].countedQuantity += quantity;
      } else {
        _countedItems.add(CountedItem(
          itemCode: itemCode,
          countedQuantity: quantity,
          binCode: widget.task.binCode,
        ));
      }
    });
  }

  Future<void> _submitCount() async {
    if (_countedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please count at least one item')),
      );
      return;
    }

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.submitInventoryCount(widget.task.id, _countedItems);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Count submitted successfully')),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting count: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Count: ${widget.task.binCode}'),
        actions: [
          IconButton(
            onPressed: _countedItems.isNotEmpty ? _submitCount : null,
            icon: const Icon(Icons.send),
            tooltip: 'Submit Count',
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Warehouse: ${widget.task.warehouse}'),
                          Text('Bin: ${widget.task.binCode}'),
                          Text('Status: ${widget.task.status}'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _scanBin,
                        icon: Icon(MdiIcons.qrcodeScan),
                        label: const Text('Start Scanning'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _countedItems.isEmpty
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
                        const Text('No items counted yet'),
                        const SizedBox(height: 8),
                        const Text('Scan bin code and items to start counting'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _countedItems.length,
                    itemBuilder: (context, index) {
                      final item = _countedItems[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(item.itemCode),
                          subtitle: Text('Bin: ${item.binCode}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${item.countedQuantity}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Text('Counted'),
                            ],
                          ),
                          onTap: () {
                            // Allow editing count
                            _showQuantityDialog(item.itemCode);
                          },
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
