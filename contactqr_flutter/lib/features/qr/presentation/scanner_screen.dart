import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/qr_codec.dart';
import '../../../core/widgets/header.dart';
import '../../../core/widgets/shell.dart';
import '../../../core/widgets/transfer_error_dialog.dart';
import '../../../data/models/contact_model.dart';
import '../../../data/models/transfer_session_model.dart';
import '../../contacts/providers/sender_provider.dart';
import '../../import/presentation/received_screen.dart';
import '../../import/providers/receiver_provider.dart';
import '../../transfer/providers/transfer_provider.dart';
import '../../transfer/services/local_transfer_client.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> with SingleTickerProviderStateMixin {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  bool _isDownloading = false;
  bool _torchEnabled = false;
  bool _permissionDenied = false;
  String _downloadStatus = 'Connecting to sender...';
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initCamera();
  }

  Future<void> _initCamera() async {
    if (!kIsWeb) {
      final status = await Permission.camera.request();
      if (status.isPermanentlyDenied || status.isDenied) {
        if (mounted) {
          setState(() => _permissionDenied = true);
        }
        return;
      }
    }

    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    if (mounted) {
      setState(() => _permissionDenied = false);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing) return;

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        _processQrString(rawValue);
        break;
      }
    }
  }

  Future<void> _processQrString(String rawValue) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      HapticFeedback.mediumImpact();
      final session = QrCodec.decode(rawValue);

      List<AppContact> contacts = [];

      // TIER 1: Direct QR Payload mode
      if (session.mode == TransferMode.direct) {
        if (session.directPayload != null && session.directPayload!.isNotEmpty) {
          contacts = QrCodec.decodeDirectPayload(session.directPayload);
        } else {
          contacts = demoContacts.take(session.contactCount > 0 ? session.contactCount : 6).toList();
        }
      } else {
        // TIER 2: Bulk Local Network Transfer mode
        setState(() {
          _isDownloading = true;
          _downloadStatus = 'Downloading ${session.contactCount} contacts from sender...';
        });

        final client = ref.read(transferClientProvider);
        contacts = await client.fetchContactsFromSender(session);
      }

      // Flag duplicates against receiver's address book
      final contactRepo = ref.read(contactRepositoryProvider);
      final flaggedContacts = await contactRepo.flagDuplicates(contacts);

      ref.read(receiverProvider.notifier).setReceivedContacts(flaggedContacts);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ReceivedScreen()),
        );
      }
    } on QrExpiredException {
      _showErrorSnackBar('This transfer QR code has expired. Please ask the sender to generate a new code.');
      _resetScanner();
    } on QrProtocolException catch (e) {
      _showErrorSnackBar(e.message);
      _resetScanner();
    } on NetworkTransferException catch (e) {
      _resetScanner();
      if (mounted) {
        TransferErrorDialog.show(
          context,
          title: 'Connection Failed',
          message: e.message,
          primaryActionText: 'Try Scanning Again',
          onPrimaryAction: () => _resetScanner(),
        );
      }
    } catch (e) {
      _resetScanner();
      _showErrorSnackBar('Transfer failed: $e');
    }
  }

  void _resetScanner() {
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _isDownloading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _simulateWebScan() {
    final sampleEncoded = QrCodec.encodeDirectContacts(
      demoContacts.take(4).toList(),
      timeoutMinutes: 10,
      customSessionId: 'web-simulated-transfer',
    );
    _processQrString(sampleEncoded);
  }

  @override
  Widget build(BuildContext context) {
    return Shell(
      dark: true,
      child: Column(
        children: [
          const Header(title: 'Receive contacts', light: true),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Text(
                    _isDownloading ? 'Receiving contacts...' : 'Scan the sender’s code',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isDownloading
                        ? 'Transferring securely over local connection.'
                        : 'Align the QR code within the frame.',
                    style: const TextStyle(
                      color: AppColors.darkSubtitle,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Camera Scanner or Downloading Progress View
                  if (_permissionDenied)
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.camera_alt_outlined, size: 48, color: AppColors.accent),
                              const SizedBox(height: 16),
                              const Text(
                                'Camera access needed',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'ContactQR needs the camera to scan the transfer QR code.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.darkSubtitle, fontSize: 14),
                              ),
                              const SizedBox(height: 20),
                              FilledButton(
                                onPressed: _initCamera,
                                style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
                                child: const Text('Grant Access'),
                              ),
                              TextButton(
                                onPressed: () => openAppSettings(),
                                child: const Text('Open settings', style: TextStyle(color: AppColors.darkSubtitle)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (_isDownloading)
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.darkNavy,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.darkNavyBorder),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(color: AppColors.teal),
                              const SizedBox(height: 24),
                              Text(
                                _downloadStatus,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                   else
                    // Camera Scanner View
                    Expanded(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: AppColors.darkSurface,
                              ),
                              child: _controller == null
                                  ? GestureDetector(
                                      onTap: _simulateWebScan,
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.qr_code_scanner, size: 72, color: Colors.white70),
                                            SizedBox(height: 12),
                                            Text(
                                              'Initializing camera...',
                                              style: TextStyle(color: AppColors.darkSubtitle, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : MobileScanner(
                                      controller: _controller!,
                                      onDetect: _handleBarcode,
                                      errorBuilder: (context, error) {
                                        return GestureDetector(
                                          onTap: _simulateWebScan,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.videocam_off_outlined, size: 64, color: Colors.white70),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'Webcam: ${error.errorCode.name}',
                                                  style: const TextStyle(color: AppColors.accent, fontSize: 13),
                                                ),
                                                const SizedBox(height: 8),
                                                const Text(
                                                  'Tap to simulate scan',
                                                  style: TextStyle(color: AppColors.darkSubtitle, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),

                          // Corner bracket reticle (center of frame)
                          Center(
                            child: SizedBox(
                              width: 220,
                              height: 220,
                              child: CustomPaint(
                                painter: _CornerBracketPainter(
                                  color: AppColors.accent,
                                  bracketLength: 28,
                                  strokeWidth: 3,
                                ),
                              ),
                            ),
                          ),

                          // Floating torch button (top-right)
                          if (!kIsWeb)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: GestureDetector(
                                onTap: () {
                                  _controller?.toggleTorch();
                                  setState(() => _torchEnabled = !_torchEnabled);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Icon(
                                    _torchEnabled ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                                    color: _torchEnabled ? AppColors.accent : Colors.white70,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),
                  if (!_isDownloading)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Nothing saved automatically',
                          style: TextStyle(color: AppColors.darkSubtitle, fontSize: 13),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws 4 L-shaped corner brackets as a scan reticle
class _CornerBracketPainter extends CustomPainter {
  const _CornerBracketPainter({
    required this.color,
    this.bracketLength = 24,
    this.strokeWidth = 3,
  });

  final Color color;
  final double bracketLength;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    final bl = bracketLength;

    // Top-left
    canvas.drawLine(Offset(0, bl), Offset(0, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(bl, 0), paint);
    // Top-right
    canvas.drawLine(Offset(w - bl, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, bl), paint);
    // Bottom-left
    canvas.drawLine(Offset(0, h - bl), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(bl, h), paint);
    // Bottom-right
    canvas.drawLine(Offset(w - bl, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h - bl), Offset(w, h), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
