import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/crypto_utils.dart';
import '../../../core/utils/network_helper.dart';
import '../../../core/utils/qr_codec.dart';
import '../../../core/widgets/header.dart';
import '../../../core/widgets/shell.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../data/models/contact_model.dart';
import '../../../data/models/transfer_session_model.dart';
import '../../contacts/providers/sender_provider.dart';
import '../../transfer/services/local_transfer_server.dart';
import 'widgets/set_pin_modal.dart';

class QrScreen extends ConsumerStatefulWidget {
  const QrScreen({
    super.key,
    required this.count,
    this.selectedContacts,
  });

  final int count;
  final List<AppContact>? selectedContacts;

  @override
  ConsumerState<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends ConsumerState<QrScreen> {
  late DateTime _expiresAt;
  Timer? _timer;
  Duration _remaining = const Duration(minutes: 15);
  String? _encodedQrData;
  bool _isExpired = false;
  TransferStatus _transferStatus = TransferStatus.waiting;
  String _statusMessage = 'Waiting for receiver…';

  LocalTransferServer? _server;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  Future<void> _startSession() async {
    _expiresAt = DateTime.now().add(const Duration(minutes: 15));
    _remaining = const Duration(minutes: 15);
    _isExpired = false;
    _transferStatus = TransferStatus.waiting;
    _statusMessage = 'Waiting for receiver…';

    // Fetch contacts to transfer
    final contactsToTransfer = widget.selectedContacts ??
        ref.read(senderProvider).selectedContacts;

    final actualContacts = contactsToTransfer.isNotEmpty
        ? contactsToTransfer
        : demoContacts.take(widget.count).toList();

    // TIER 1: Direct QR mode (now supports up to 30 contacts seamlessly via minification)
    if (actualContacts.length <= 30) {
      final qrString = QrCodec.encodeDirectContacts(
        actualContacts,
        timeoutMinutes: 15,
      );

      setState(() {
        _encodedQrData = qrString;
      });
    } else {
      // TIER 2: Bulk local network transfer mode for large contact books (>30 contacts)
      final sessionId = 'p2p-${DateTime.now().millisecondsSinceEpoch}';
      final sessionToken = CryptoUtils.generateRandomToken(length: 16);
      final encryptionKey = CryptoUtils.generateSessionKey();
      final localIp = await NetworkHelper.getLocalIpAddress();

      _server = LocalTransferServer(
        contacts: actualContacts,
        sessionId: sessionId,
        sessionToken: sessionToken,
        encryptionKey: encryptionKey,
        onStatusChanged: (status, msg) {
          if (mounted) {
            setState(() {
              _transferStatus = status;
              if (msg != null) _statusMessage = msg;
            });
          }
        },
      );

      final port = await _server!.start();

      final session = TransferSession(
        sessionId: sessionId,
        protocolVersion: QrCodec.currentVersion,
        mode: TransferMode.localNetwork,
        contactCount: actualContacts.length,
        createdAt: DateTime.now(),
        expiresAt: _expiresAt,
        host: localIp,
        port: port,
        token: sessionToken,
        encryptionKey: encryptionKey,
      );

      final qrString = QrCodec.encodeSession(session);

      setState(() {
        _encodedQrData = qrString;
      });
    }

    // Start 1-second countdown ticker
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      if (now.isAfter(_expiresAt)) {
        timer.cancel();
        _server?.stop();
        setState(() {
          _isExpired = true;
          _remaining = Duration.zero;
          _transferStatus = TransferStatus.expired;
          _statusMessage = 'Transfer code expired';
        });
      } else {
        setState(() {
          _remaining = _expiresAt.difference(now);
        });
      }
    });
  }

  void _onShareWithPinPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SetPinModal(
        onPinConfirmed: (pin) async {
          final contactsToTransfer = widget.selectedContacts ??
              ref.read(senderProvider).selectedContacts;

          final actualContacts = contactsToTransfer.isNotEmpty
              ? contactsToTransfer
              : demoContacts.take(widget.count).toList();

          // Generate clickable, compact PIN-protected transfer URL
          final shareUrl = QrCodec.encodeShareUrl(
            actualContacts,
            timeoutMinutes: 60 * 24, // 24 hours
            pin: pin,
          );

          final shareText = '🔐 Qiwii Secure Contact Transfer\n\n'
              'I shared ${widget.count} contact${widget.count == 1 ? '' : 's'} with you.\n\n'
              '📋 Transfer Link:\n'
              '$shareUrl\n\n'
              '👉 In Qiwii: Copy this message, open Qiwii, and unlock with your 4-digit PIN.';

          try {
            await Share.share(
              shareText,
              subject: 'Qiwii Shared Contacts',
            );
          } catch (_) {
            await Clipboard.setData(ClipboardData(text: shareText));
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PIN-encrypted link copied to clipboard! (Ready to paste in chat)'),
                  backgroundColor: AppColors.accent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _server?.stop();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _copyQrData() {
    if (_encodedQrData != null) {
      Clipboard.setData(ClipboardData(text: _encodedQrData!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR transfer link copied to clipboard'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = _transferStatus == TransferStatus.completed;

    return Shell(
      dark: true,
      child: Column(
        children: [
          const Header(title: 'Transfer', light: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  StatusPill(
                    text: _isExpired
                        ? 'TRANSFER EXPIRED'
                        : isSuccess
                            ? 'TRANSFER COMPLETE'
                            : _transferStatus == TransferStatus.transferring
                                ? 'SENDING DATA'
                                : 'READY TO CONNECT',
                    active: !_isExpired,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Show this code\nto the receiver',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displayDark(
                      fontSize: 26,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // QR White Card on dark background
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: _isExpired
                          ? SizedBox(
                              height: 190,
                              width: 190,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.timer_off_outlined, size: 48, color: AppColors.accent),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Expired',
                                    style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700, fontSize: 16),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: _startSession,
                                    child: const Text('Generate new code'),
                                  ),
                                ],
                              ),
                            )
                          : isSuccess
                              ? const SizedBox(
                                  height: 190,
                                  width: 190,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle_rounded, size: 64, color: AppColors.success),
                                      SizedBox(height: 12),
                                      Text(
                                        'Contacts sent!',
                                        style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                )
                              : _encodedQrData == null
                                  ? const SizedBox(
                                      height: 190,
                                      width: 190,
                                      child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
                                    )
                                  : GestureDetector(
                                      onTap: _copyQrData,
                                      child: QrImageView(
                                        data: _encodedQrData!,
                                        size: 215,
                                        version: QrVersions.auto,
                                        errorCorrectionLevel: QrErrorCorrectLevel.L,
                                        padding: const EdgeInsets.all(8),
                                        backgroundColor: Colors.white,
                                        eyeStyle: const QrEyeStyle(
                                          eyeShape: QrEyeShape.square,
                                          color: Colors.black,
                                        ),
                                        dataModuleStyle: const QrDataModuleStyle(
                                          dataModuleShape: QrDataModuleShape.square,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Progress bar countdown
                  if (!_isExpired && !isSuccess) ...[
                    Row(
                      children: [
                        Text(
                          '${widget.count} contact${widget.count == 1 ? '' : 's'}',
                          style: const TextStyle(color: AppColors.darkSubtitle, fontSize: 13),
                        ),
                        const Spacer(),
                        Text(
                          _formatDuration(_remaining),
                          style: const TextStyle(color: AppColors.darkSubtitle, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _remaining.inSeconds / (15 * 60),
                        backgroundColor: AppColors.darkBorder,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Share with PIN Button ──────────────────────────────
                  if (!_isExpired && !isSuccess) ...[
                    InkWell(
                      onTap: _onShareWithPinPressed,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.orangeGradient,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.lock_outline_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Share with 4-Digit PIN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Status Indicator
                  if (!_isExpired)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSuccess ? AppColors.success : AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _statusMessage,
                          style: const TextStyle(color: AppColors.darkSubtitle, fontSize: 14),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: TextButton(
              onPressed: () {
                _server?.stop();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text(
                'Cancel transfer',
                style: TextStyle(color: AppColors.darkSubtitle, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
