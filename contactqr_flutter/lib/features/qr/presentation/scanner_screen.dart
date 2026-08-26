import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/qr_codec.dart';
import '../../../core/widgets/card_box.dart';
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

    if (!kIsWeb) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied || status.isDenied) {
      if (mounted) {
        setState(() => _permissionDenied = true);
      }
      return;
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
                    _isDownloading ? 'Receiving Contacts...' : 'Scan the sender’s code',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isDownloading
                        ? 'Transferring securely over local connection.'
                        : 'Align the QR code inside the frame. Nothing is saved automatically.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.subtitleLight,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Camera Scanner or Downloading Progress View
                  if (_permissionDenied)
                    Expanded(
                      child: Center(
                        child: CardBox(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.camera_alt_outlined, size: 54, color: AppColors.teal),
                              const SizedBox(height: 16),
                              const Text(
                                'Camera Access Needed',
                                style: TextStyle(
                                  color: AppColors.navy,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'ContactQR requires camera access to scan the transfer QR code.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.slate, fontSize: 14),
                              ),
                              const SizedBox(height: 20),
                              FilledButton(
                                onPressed: _initCamera,
                                style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
                                child: const Text('Grant Access'),
                              ),
                              TextButton(
                                onPressed: () => openAppSettings(),
                                child: const Text('Open App Settings', style: TextStyle(color: AppColors.navy)),
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
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            height: 310,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.darkNavy,
                              border: Border.all(color: AppColors.darkNavyBorder),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: kIsWeb || _controller == null
                                ? GestureDetector(
                                    onTap: _simulateWebScan,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.qr_code_scanner, size: 72, color: Colors.white70),
                                          const SizedBox(height: 12),
                                          Text(
                                            kIsWeb ? 'Click to simulate scan on Web' : 'Initializing camera...',
                                            style: const TextStyle(color: AppColors.subtitleLight, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : MobileScanner(
                                    controller: _controller!,
                                    onDetect: _handleBarcode,
                                  ),
                          ),
                        ),

                        // Animated scanning reticle
                        IgnorePointer(
                          child: AnimatedBuilder(
                            animation: _animController,
                            builder: (_, _) {
                              return Container(
                                height: 310,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: AppColors.teal.withValues(alpha: 0.6),
                                    width: 2,
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment(0, (_animController.value * 2) - 1),
                                  child: Container(
                                    height: 2,
                                    width: 240,
                                    decoration: BoxDecoration(
                                      color: AppColors.teal,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.teal.withValues(alpha: 0.8),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 18),
                  if (!_isDownloading)
                    Text(
                      kIsWeb
                          ? 'Tap frame to test with simulated 4-contact payload'
                          : 'Point camera at the sender’s QR code',
                      style: const TextStyle(color: AppColors.subtitleLight, fontSize: 12),
                    ),

                  const Spacer(),
                  if (!_isDownloading)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            _controller?.toggleTorch();
                            setState(() => _torchEnabled = !_torchEnabled);
                          },
                          icon: Icon(
                            _torchEnabled ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _torchEnabled ? 'Torch On' : 'Torch Off',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(width: 32),
                        const Icon(Icons.lock_outline, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          '100% Private',
                          style: TextStyle(color: Colors.white, fontSize: 14),
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
