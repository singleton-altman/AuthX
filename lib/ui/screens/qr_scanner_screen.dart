import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  String? scanResult;

  void _handleBarcode(BarcodeCapture barcodes) {
    final barcode = barcodes.barcodes.firstOrNull;
    if (barcode?.rawValue == null) {
      debugPrint('Failed to scan QR code');
    } else {
      setState(() {
        scanResult = barcode!.rawValue;
      });
      
      // 自动返回扫描结果
      if (scanResult != null) {
        Navigator.of(context).pop(scanResult);
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('扫描二维码'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: _handleBarcode,
                ),
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width: 3.0,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (scanResult != null)
                  ? Text('二维码内容: $scanResult')
                  : const Text('请将摄像头对准二维码'),
            ),
          ),
        ],
      ),
    );
  }
}
