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
        const SnackBar(
          content: Text('Transfer payload copied to clipboard.'),
          duration: Duration(seconds: 2),
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
          const Header(title: 'Transfer'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  StatusPill(
                    text: _isExpired
                        ? 'EXPIRED'
                        : isSuccess
                            ? 'TRANSFER COMPLETE'
                            : _transferStatus == TransferStatus.transferring
                                ? 'SENDING DATA...'
                                : 'READY TO CONNECT',
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _isExpired
                        ? 'Transfer Expired'
                        : isSuccess
                            ? 'Contacts Sent!'
                            : 'Show this code',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isExpired
                        ? 'This session has timed out. Please generate a new code.'
                        : isSuccess
                            ? 'The receiver has securely received your contacts.'
                            : 'Ask the receiver to scan this QR code with ContactQR.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.slate, fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  CardBox(
                    child: Column(
                      children: [
                        if (_isExpired)
                          Container(
                            height: 220,
                            width: 220,
                            decoration: BoxDecoration(
                              color: AppColors.ivory,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.timer_off_outlined, size: 54, color: AppColors.amber),
                                const SizedBox(height: 12),
                                const Text(
                                  'Session Expired',
                                  style: TextStyle(
                                    color: AppColors.navy,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: _startSession,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Generate New Code'),
                                  style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
                                ),
                              ],
                            ),
                          )
                        else if (isSuccess)
                          Container(
                            height: 220,
                            width: 220,
                            decoration: BoxDecoration(
                              color: AppColors.mint,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, size: 64, color: AppColors.success),
                                SizedBox(height: 12),
                                Text(
                                  'Done!',
                                  style: TextStyle(
                                    color: AppColors.navy,
                                    fontWeight: FontWeight.w800,
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
                              child: CircularProgressIndicator(color: AppColors.teal),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: _copyQrData,
                            child: QrImageView(
                              data: _encodedQrData!,
                              size: 220,
                              version: QrVersions.auto,
                              errorCorrectionLevel: QrErrorCorrectLevel.M,
                            ),
                          ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${widget.count} contacts • ',
                              style: const TextStyle(color: AppColors.slate, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              _isExpired ? 'Expired' : 'Expires in ${_formatDuration(_remaining)}',
                              style: TextStyle(
                                color: _isExpired ? Colors.red : AppColors.teal,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!_isExpired)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSuccess
                              ? Icons.check_circle
                              : _transferStatus == TransferStatus.transferring
                                  ? Icons.sync
                                  : Icons.circle,
                          size: 14,
                          color: isSuccess ? AppColors.success : AppColors.teal,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _statusMessage,
                          style: const TextStyle(color: AppColors.slate, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _server?.stop();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text(
              'Cancel transfer',
              style: TextStyle(color: AppColors.slate, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
