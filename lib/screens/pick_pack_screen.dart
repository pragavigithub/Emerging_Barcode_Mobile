
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../services/api_service.dart';
import '../models/pick_list.dart';
import 'barcode_scanner_screen.dart';

class PickPackScreen extends StatefulWidget {
  const PickPackScreen({Key? key}) : super(key: key);

  @override
  State<PickPackScreen> createState() => _PickPackScreenState();
}

class _PickPackScreenState extends State<PickPackScreen> {
  List<PickList> _pickLists = [];
  bool _isLoading = false;
  String _statusFilter = 'assigned';

  @override
  void initState() {
    super.initState();
    _loadPickLists();
  }

  Future<void> _loadPickLists() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final pickLists = await apiService.getPickLists(status: _statusFilter);
      
      setState(() {
        _pickLists = pickLists;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading pick lists: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _scanPickList() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(
          title: 'Scan Pick List',
          scanType: ScanType.pickList,
        ),
      ),
    );

    if (result != null) {
      _openPickListDetails(result);
    }
  }

  void _openPickListDetails(String pickListId) {
    final pickList = _pickLists.firstWhere(
      (pl) => pl.id == pickListId,
      orElse: () => PickList.empty(),
    );

    if (pickList.id.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PickListDetailsScreen(pickList: pickList),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick list not found or not assigned to you')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick & Pack'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _statusFilter,
            onSelected: (value) {
              setState(() {
                _statusFilter = value;
              });
              _loadPickLists();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'assigned', child: Text('Assigned')),
              const PopupMenuItem(value: 'pending', child: Text('Pending Approval')),
              const PopupMenuItem(value: 'approved', child: Text('Approved')),
              const PopupMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _scanPickList,
                    icon: Icon(MdiIcons.qrcodeScan),
                    label: const Text('Scan Pick List'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _loadPickLists,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _pickLists.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              MdiIcons.packageDown,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No pick lists found',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            const Text('Scan a pick list barcode to get started'),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPickLists,
                        child: ListView.builder(
                          itemCount: _pickLists.length,
                          itemBuilder: (context, index) {
                            final pickList = _pickLists[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                title: Text('Pick List: ${pickList.id}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Sales Order: ${pickList.salesOrderId}'),
                                    Text('Items: ${pickList.items.length}'),
                                    Text('Status: ${pickList.status}'),
                                  ],
                                ),
                                trailing: _getStatusIcon(pickList.status),
                                onTap: () => _openPickListDetails(pickList.id),
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
      case 'approved':
        return Icon(Icons.check_circle, color: Colors.green);
      case 'rejected':
        return Icon(Icons.cancel, color: Colors.red);
      case 'pending':
        return Icon(Icons.pending, color: Colors.orange);
      default:
        return Icon(Icons.assignment, color: Colors.blue);
    }
  }
}

class PickListDetailsScreen extends StatefulWidget {
  final PickList pickList;

  const PickListDetailsScreen({Key? key, required this.pickList}) : super(key: key);

  @override
  State<PickListDetailsScreen> createState() => _PickListDetailsScreenState();
}

class _PickListDetailsScreenState extends State<PickListDetailsScreen> {
  final Map<String, TextEditingController> _quantityControllers = {};

  @override
  void initState() {
    super.initState();
    for (var item in widget.pickList.items) {
      _quantityControllers[item.id] = TextEditingController(
        text: item.pickedQuantity.toString(),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _scanBinAndItem(PickListItem item) async {
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
      // Validate bin and proceed to item scanning
      _scanItem(item, result);
    }
  }

  Future<void> _scanItem(PickListItem item, String binCode) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(
          title: 'Scan Item',
          scanType: ScanType.item,
        ),
      ),
    );

    if (result != null && result == item.itemCode) {
      _showQuantityDialog(item, binCode);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item mismatch. Please scan the correct item.')),
      );
    }
  }

  void _showQuantityDialog(PickListItem item, String binCode) {
    final quantityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Quantity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Item: ${item.itemCode}'),
            Text('Required: ${item.requiredQuantity}'),
            Text('Bin: $binCode'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Picked Quantity',
                border: OutlineInputBorder(),
              ),
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
              setState(() {
                item.pickedQuantity = quantity;
                item.binCode = binCode;
                _quantityControllers[item.id]?.text = quantity.toString();
              });
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPickList() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.submitPickList(widget.pickList);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick list submitted for approval')),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting pick list: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick List ${widget.pickList.id}'),
        actions: [
          if (widget.pickList.status == 'assigned')
            IconButton(
              onPressed: _submitPickList,
              icon: const Icon(Icons.send),
              tooltip: 'Submit for Approval',
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sales Order: ${widget.pickList.salesOrderId}'),
                      Text('Customer: ${widget.pickList.customerName}'),
                      Text('Status: ${widget.pickList.status}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.pickList.items.length,
              itemBuilder: (context, index) {
                final item = widget.pickList.items[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.itemCode,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(item.description),
                                  Text('Required: ${item.requiredQuantity}'),
                                  if (item.binCode.isNotEmpty)
                                    Text('Bin: ${item.binCode}'),
                                ],
                              ),
                            ),
                            if (widget.pickList.status == 'assigned')
                              ElevatedButton(
                                onPressed: () => _scanBinAndItem(item),
                                child: const Text('Pick'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _quantityControllers[item.id],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Picked Quantity',
                                  border: OutlineInputBorder(),
                                ),
                                readOnly: widget.pickList.status != 'assigned',
                                onChanged: (value) {
                                  item.pickedQuantity = double.tryParse(value) ?? 0;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              item.pickedQuantity >= item.requiredQuantity
                                  ? Icons.check_circle
                                  : Icons.pending,
                              color: item.pickedQuantity >= item.requiredQuantity
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
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
