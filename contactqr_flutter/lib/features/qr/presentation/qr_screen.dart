import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/crypto_utils.dart';
import '../../../core/utils/network_helper.dart';
import '../../../core/utils/qr_codec.dart';
import '../../../core/widgets/card_box.dart';
import '../../../core/widgets/header.dart';
import '../../../core/widgets/shell.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../data/models/contact_model.dart';
import '../../../data/models/transfer_session_model.dart';
import '../../contacts/providers/sender_provider.dart';
import '../../transfer/services/local_transfer_server.dart';

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
  Duration _remaining = const Duration(minutes: 10);
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
    _expiresAt = DateTime.now().add(const Duration(minutes: 10));
    _remaining = const Duration(minutes: 10);
    _isExpired = false;
    _transferStatus = TransferStatus.waiting;
    _statusMessage = 'Waiting for receiver…';

    // Fetch contacts to transfer
    final contactsToTransfer = widget.selectedContacts ??
        ref.read(senderProvider).selectedContacts;

    final actualContacts = contactsToTransfer.isNotEmpty
        ? contactsToTransfer
        : demoContacts.take(widget.count).toList();

    // TIER 1: Direct QR mode for small transfers (<= 5 contacts)
    if (actualContacts.length <= 5) {
      final qrString = QrCodec.encodeDirectContacts(
        actualContacts,
        timeoutMinutes: 10,
      );

      setState(() {
        _encodedQrData = qrString;
      });
    } else {
      // TIER 2: Bulk local network transfer mode
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
        protocolVersion: 1,
        mode: TransferMode.localNetwork,
        contactCount: actualContacts.length,
        createdAt: DateTime.now(),
        expiresAt: _expiresAt,
        host: localIp,
        port: port,
        token: sessionToken,
        encryptionKey: encryptionKey,
      );

      setState(() {
        _encodedQrData = QrCodec.encodeSession(session);
      });
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = _expiresAt.difference(DateTime.now());
      if (diff.isNegative) {
        _timer?.cancel();
        _server?.stop();
        setState(() {
          _isExpired = true;
          _remaining = Duration.zero;
          _transferStatus = TransferStatus.expired;
        });
      } else {
        setState(() {
          _remaining = diff;
        });
      }
    });
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
        SnackBar(
          content: const Text('Transfer payload copied to clipboard.'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = _transferStatus == TransferStatus.completed;

    return Shell(
      child: Column(
        children: [
          const Header(title: 'Transfer QR'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  StatusPill(
                    text: _isExpired
                        ? 'SESSION EXPIRED'
                        : isSuccess
                            ? 'TRANSFER COMPLETE'
                            : _transferStatus == TransferStatus.transferring
                                ? 'SENDING DATA...'
                                : 'READY TO SCAN',
                    color: _isExpired
                        ? AppColors.error
                        : isSuccess
                            ? AppColors.success
                            : AppColors.primary,
                    backgroundColor: _isExpired
                        ? AppColors.errorLight
                        : isSuccess
                            ? AppColors.successLight
                            : AppColors.primaryLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isExpired
                        ? 'Transfer Expired'
                        : isSuccess
                            ? 'Contacts Sent!'
                            : 'Scan this code',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isExpired
                        ? 'This session has timed out. Please generate a new code.'
                        : isSuccess
                            ? 'The receiver has securely imported your contacts.'
                            : 'Point the receiver device’s camera at this QR code.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CardBox(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        if (_isExpired)
                          Container(
                            height: 220,
                            width: 220,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.timer_off_outlined, size: 54, color: AppColors.amber),
                                const SizedBox(height: 12),
                                const Text(
                                  'Session Expired',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: _startSession,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Generate New Code'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (isSuccess)
                          Container(
                            height: 220,
                            width: 220,
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 64, color: AppColors.success),
                                SizedBox(height: 12),
                                Text(
                                  'All Done!',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (_encodedQrData == null)
                          const SizedBox(
                            height: 220,
                            width: 220,
                            child: Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: _copyQrData,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: QrImageView(
                                data: _encodedQrData!,
                                size: 210,
                                version: QrVersions.auto,
                                errorCorrectionLevel: QrErrorCorrectLevel.M,
                              ),
                            ),
                          ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 15,
                                color: _isExpired ? AppColors.error : AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.count} contacts • ',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _isExpired ? 'Expired' : 'Expires in ${_formatDuration(_remaining)}',
                                style: TextStyle(
                                  color: _isExpired ? AppColors.error : AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!_isExpired)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSuccess
                              ? Icons.check_circle_rounded
                              : _transferStatus == TransferStatus.transferring
                                  ? Icons.sync_rounded
                                  : Icons.circle,
                          size: 14,
                          color: isSuccess ? AppColors.success : AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _statusMessage,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: TextButton.icon(
              onPressed: () {
                _server?.stop();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
              label: const Text(
                'Cancel Transfer',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
