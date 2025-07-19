
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../services/api_service.dart';
import '../models/label_template.dart';
import 'barcode_scanner_screen.dart';

class LabelPrintScreen extends StatefulWidget {
  const LabelPrintScreen({Key? key}) : super(key: key);

  @override
  State<LabelPrintScreen> createState() => _LabelPrintScreenState();
}

class _LabelPrintScreenState extends State<LabelPrintScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<LabelTemplate> _templates = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTemplates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final templates = await apiService.getLabelTemplates();
      
      setState(() {
        _templates = templates;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading templates: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Label Printing'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Print New', icon: Icon(Icons.print)),
            Tab(text: 'Re-Print', icon: Icon(Icons.refresh)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PrintNewLabelTab(templates: _templates, isLoading: _isLoading),
          RePrintLabelTab(),
        ],
      ),
    );
  }
}

class PrintNewLabelTab extends StatefulWidget {
  final List<LabelTemplate> templates;
  final bool isLoading;

  const PrintNewLabelTab({
    Key? key,
    required this.templates,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<PrintNewLabelTab> createState() => _PrintNewLabelTabState();
}

class _PrintNewLabelTabState extends State<PrintNewLabelTab> {
  String _selectedTemplate = '';
  final TextEditingController _itemCodeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  Map<String, dynamic> _itemDetails = {};

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
      _itemCodeController.text = result;
      _loadItemDetails(result);
    }
  }

  Future<void> _loadItemDetails(String itemCode) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final details = await apiService.getItemDetails(itemCode);
      
      setState(() {
        _itemDetails = details;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading item details: $e')),
      );
    }
  }

  Future<void> _printLabel() async {
    if (_selectedTemplate.isEmpty || _itemCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select template and item')),
      );
      return;
    }

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final quantity = int.tryParse(_quantityController.text) ?? 1;
      
      await apiService.printLabel(
        templateId: _selectedTemplate,
        itemCode: _itemCodeController.text,
        quantity: quantity,
        itemDetails: _itemDetails,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Label sent to printer')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error printing label: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Label Template',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  widget.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<String>(
                          value: _selectedTemplate.isEmpty ? null : _selectedTemplate,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Choose template',
                          ),
                          items: widget.templates.map((template) {
                            return DropdownMenuItem<String>(
                              value: template.id,
                              child: Text(template.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTemplate = value ?? '';
                            });
                          },
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _itemCodeController,
                          decoration: const InputDecoration(
                            labelText: 'Item Code',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              _loadItemDetails(value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _scanItem,
                        icon: Icon(MdiIcons.qrcodeScan),
                        label: const Text('Scan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity to Print',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_itemDetails.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Description: ${_itemDetails['description'] ?? 'N/A'}'),
                          Text('Unit: ${_itemDetails['unit'] ?? 'N/A'}'),
                          if (_itemDetails['batchNumber'] != null)
                            Text('Batch: ${_itemDetails['batchNumber']}'),
                          if (_itemDetails['expiryDate'] != null)
                            Text('Expiry: ${_itemDetails['expiryDate']}'),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _printLabel,
            icon: const Icon(Icons.print),
            label: const Text('Print Label'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class RePrintLabelTab extends StatefulWidget {
  @override
  State<RePrintLabelTab> createState() => _RePrintLabelTabState();
}

class _RePrintLabelTabState extends State<RePrintLabelTab> {
  List<PrintHistory> _printHistory = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPrintHistory();
  }

  Future<void> _loadPrintHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final history = await apiService.getPrintHistory();
      
      setState(() {
        _printHistory = history;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading print history: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _reprintLabel(PrintHistory item) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.reprintLabel(item.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Label sent to printer')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reprinting label: $e')),
      );
    }
  }

  List<PrintHistory> get filteredHistory {
    if (_searchQuery.isEmpty) return _printHistory;
    
    return _printHistory.where((item) {
      return item.itemCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             item.templateName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search by item code or template',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No print history found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPrintHistory,
                      child: ListView.builder(
                        itemCount: filteredHistory.length,
                        itemBuilder: (context, index) {
                          final item = filteredHistory[index];
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
                                  Text('Template: ${item.templateName}'),
                                  Text('Printed: ${item.printedDate}'),
                                  Text('Quantity: ${item.quantity}'),
                                ],
                              ),
                              trailing: ElevatedButton.icon(
                                onPressed: () => _reprintLabel(item),
                                icon: const Icon(Icons.print),
                                label: const Text('Re-Print'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
