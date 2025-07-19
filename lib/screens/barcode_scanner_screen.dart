
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

enum ScanType {
  item,
  bin,
  po,
  pickList,
  transfer,
  general,
}

class BarcodeScannerScreen extends StatefulWidget {
  final String title;
  final ScanType scanType;
  
  const BarcodeScannerScreen({
    Key? key,
    this.title = 'Scan Barcode',
    this.scanType = ScanType.general,
  }) : super(key: key);

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _hasPermission = false;
  bool _isFlashOn = false;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final permission = await Permission.camera.request();
    setState(() {
      _hasPermission = permission.isGranted;
    });
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _isScanning = false;
        });
        
        // Provide haptic feedback
        _processBarcode(barcode.rawValue!);
        break;
      }
    }
  }

  void _processBarcode(String value) {
    // Add validation based on scan type
    String validatedValue = _validateBarcode(value);
    
    if (validatedValue.isNotEmpty) {
      Navigator.of(context).pop(validatedValue);
    } else {
      setState(() {
        _isScanning = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getInvalidBarcodeMessage()),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _validateBarcode(String value) {
    switch (widget.scanType) {
      case ScanType.item:
        // Item codes typically have specific format
        if (value.length >= 3) return value;
        break;
      case ScanType.bin:
        // Bin codes validation
        if (value.length >= 2) return value;
        break;
      case ScanType.po:
        // PO number validation
        if (value.length >= 3) return value;
        break;
      case ScanType.pickList:
        // Pick list validation
        if (value.contains('PL') || value.length >= 5) return value;
        break;
      case ScanType.transfer:
        // Transfer request validation
        if (value.contains('TR') || value.length >= 5) return value;
        break;
      case ScanType.general:
        return value;
    }
    return '';
  }

  String _getInvalidBarcodeMessage() {
    switch (widget.scanType) {
      case ScanType.item:
        return 'Invalid item barcode. Please scan a valid item.';
      case ScanType.bin:
        return 'Invalid bin code. Please scan a valid bin location.';
      case ScanType.po:
        return 'Invalid PO number. Please scan a valid purchase order.';
      case ScanType.pickList:
        return 'Invalid pick list code. Please scan a valid pick list.';
      case ScanType.transfer:
        return 'Invalid transfer code. Please scan a valid transfer request.';
      default:
        return 'Invalid barcode format.';
    }
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    controller.toggleTorch();
  }

  void _manualEntry() {
    showDialog(
      context: context,
      builder: (context) {
        final textController = TextEditingController();
        return AlertDialog(
          title: Text('Enter ${_getScanTypeLabel()} Manually'),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(
              labelText: _getScanTypeLabel(),
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = textController.text.trim();
                if (value.isNotEmpty) {
                  Navigator.pop(context);
                  _processBarcode(value);
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  String _getScanTypeLabel() {
    switch (widget.scanType) {
      case ScanType.item:
        return 'Item Code';
      case ScanType.bin:
        return 'Bin Code';
      case ScanType.po:
        return 'PO Number';
      case ScanType.pickList:
        return 'Pick List ID';
      case ScanType.transfer:
        return 'Transfer ID';
      default:
        return 'Code';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Camera permission is required'),
              SizedBox(height: 8),
              Text('Please grant camera permission to scan barcodes'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _toggleFlash,
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
          ),
          IconButton(
            onPressed: _manualEntry,
            icon: const Icon(Icons.keyboard),
            tooltip: 'Manual Entry',
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          // Scanning overlay
          Container(
            decoration: ShapeDecoration(
              shape: QRScannerOverlayShape(
                borderColor: Theme.of(context).primaryColor,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 5,
                cutOutSize: 250,
              ),
            ),
          ),
          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Position the ${_getScanTypeLabel().toLowerCase()} within the frame',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        onPressed: _toggleFlash,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          _isFlashOn ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                        ),
                      ),
                      FloatingActionButton(
                        onPressed: _manualEntry,
                        backgroundColor: Colors.white24,
                        child: const Icon(
                          Icons.keyboard,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class QRScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QRScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path()..addRect(rect);
    Path cutOutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: cutOutSize,
            height: cutOutSize,
          ),
          Radius.circular(borderRadius),
        ),
      );
    return Path.combine(PathOperation.difference, path, cutOutPath);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = borderWidth;
    final height = rect.height;
    final borderOffset = borderWidthSize / 2;
    final cutOutWidth = cutOutSize + borderWidthSize;
    final cutOutHeight = cutOutSize + borderWidthSize;

    final cutOutRect = Rect.fromLTWH(
      rect.center.dx - cutOutWidth / 2 + borderOffset,
      rect.center.dy - cutOutHeight / 2 + borderOffset,
      cutOutWidth,
      cutOutHeight,
    );

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidthSize;

    final backgroundRect = Rect.fromLTWH(0, 0, width, height);
    final backgroundPath = Path()
      ..addRect(backgroundRect)
      ..addRRect(RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    // Draw border corners
    final borderPath = Path();

    // Top left corner
    borderPath.moveTo(cutOutRect.left, cutOutRect.top + borderLength);
    borderPath.lineTo(cutOutRect.left, cutOutRect.top + borderRadius);
    borderPath.arcToPoint(
      Offset(cutOutRect.left + borderRadius, cutOutRect.top),
      radius: Radius.circular(borderRadius),
    );
    borderPath.lineTo(cutOutRect.left + borderLength, cutOutRect.top);

    // Top right corner
    borderPath.moveTo(cutOutRect.right - borderLength, cutOutRect.top);
    borderPath.lineTo(cutOutRect.right - borderRadius, cutOutRect.top);
    borderPath.arcToPoint(
      Offset(cutOutRect.right, cutOutRect.top + borderRadius),
      radius: Radius.circular(borderRadius),
    );
    borderPath.lineTo(cutOutRect.right, cutOutRect.top + borderLength);

    // Bottom right corner
    borderPath.moveTo(cutOutRect.right, cutOutRect.bottom - borderLength);
    borderPath.lineTo(cutOutRect.right, cutOutRect.bottom - borderRadius);
    borderPath.arcToPoint(
      Offset(cutOutRect.right - borderRadius, cutOutRect.bottom),
      radius: Radius.circular(borderRadius),
    );
    borderPath.lineTo(cutOutRect.right - borderLength, cutOutRect.bottom);

    // Bottom left corner
    borderPath.moveTo(cutOutRect.left + borderLength, cutOutRect.bottom);
    borderPath.lineTo(cutOutRect.left + borderRadius, cutOutRect.bottom);
    borderPath.arcToPoint(
      Offset(cutOutRect.left, cutOutRect.bottom - borderRadius),
      radius: Radius.circular(borderRadius),
    );
    borderPath.lineTo(cutOutRect.left, cutOutRect.bottom - borderLength);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QRScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
