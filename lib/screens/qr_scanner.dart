import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/visitor_provider.dart';
import '../services/api_service.dart';
import 'visitor_details.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _isProcessing = false;
  MobileScannerException? _scannerError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _scannerError != null) {
      _checkPermissionAndResume();
    }
  }

  void _checkPermissionAndResume() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      _rescan();
    }
  }

  void _openSettings() async {
    await openAppSettings();
  }

  void _rescan() async {
    setState(() {
      _isProcessing = false;
      _scannerError = null;
    });
    try {
      await _controller.start();
    } catch (_) {}
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? scannedRaw = barcodes.first.rawValue;
    if (scannedRaw == null || scannedRaw.trim().isEmpty) return;

    final scannedId = scannedRaw.trim();

    if (scannedId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid QR code format'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final provider = context.read<VisitorProvider>();
      final visitor = await provider.getVisitorById(scannedId);

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VisitorDetails(visitor: visitor)),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'RE-SCAN',
              textColor: Colors.white,
              onPressed: _rescan,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Visitor lookup failed: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'RE-SCAN',
              textColor: Colors.white,
              onPressed: _rescan,
            ),
          ),
        );
      }
    } finally {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showManualEntryDialog() {
    final textCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Visitor Pass ID'),
        content: TextField(
          controller: textCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Visitor Pass ID',
            hintText: 'e.g. 1 or VIS001',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final id = textCtrl.text.trim();
              if (id.isEmpty) return;
              Navigator.pop(ctx);

              setState(() => _isProcessing = true);
              try {
                final visitor =
                    await context.read<VisitorProvider>().getVisitorById(id);
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VisitorDetails(visitor: visitor),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Visitor not found: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => _isProcessing = false);
                }
              }
            },
            child: const Text('LOOKUP PASS'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Visitor Pass'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_outlined),
            tooltip: 'Enter ID Manually',
            onPressed: _showManualEntryDialog,
          ),
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: 'Flashlight',
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            tooltip: 'Switch Camera',
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              if (_scannerError != error) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() => _scannerError = error);
                  }
                });
              }
              return const SizedBox.shrink();
            },
          ),
          if (_scannerError != null)
            _buildErrorView(_scannerError!)
          else ...[
            _buildViewfinder(),
            _buildTopStatusPill(),
            _buildBottomControls(),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorView(MobileScannerException error) {
    final isPermission =
        error.errorCode == MobileScannerErrorCode.permissionDenied;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF334155), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.videocam_off_rounded,
                  size: 44,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isPermission
                    ? 'Camera Permission Required'
                    : 'Camera Unavailable',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                isPermission
                    ? 'Please grant camera permission in your device Settings to scan visitor passes.'
                    : 'Camera hardware is not available on this device or emulator. You can allow camera access or enter the Visitor ID manually.',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13.5,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _openSettings,
                  icon: const Icon(Icons.settings_outlined, size: 20),
                  label: const Text(
                    'ALLOW ACCESS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: _rescan,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'RETRY CAMERA',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: _showManualEntryDialog,
                  icon: const Icon(Icons.keyboard_outlined, size: 18),
                  label: const Text(
                    'ENTER PASS ID MANUALLY',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF38BDF8),
                    side: const BorderSide(color: Color(0xFF38BDF8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewfinder() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(
            color: _isProcessing ? Colors.amber : const Color(0xFF0284C7),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (_isProcessing ? Colors.amber : const Color(0xFF0284C7))
                  .withValues(alpha: 0.2),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isProcessing)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Verifying Pass...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStatusPill() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _isProcessing ? Colors.amber : Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isProcessing ? 'Reading barcode...' : 'Scanner Active',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _rescan,
              icon: const Icon(Icons.refresh_rounded, size: 22),
              label: const Text(
                'SCAN AGAIN',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Point camera at the visitor pass QR code',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
