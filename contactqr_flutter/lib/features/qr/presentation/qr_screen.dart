import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
      dark: true,
      child: Column(
        children: [
          Header(title: 'Transfer', light: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  StatusPill(
                    text: _isExpired
                        ? 'EXPIRED'
                        : isSuccess
                            ? 'TRANSFER COMPLETE'
                            : _transferStatus == TransferStatus.transferring
                                ? 'SENDING DATA'
                                : 'READY TO CONNECT',
                    active: !_isExpired,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Show this code\nto the receiver',
                    style: AppTextStyles.displayDark(
                      fontSize: 26,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // QR White Card on dark background
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: _isExpired
                          ? SizedBox(
                              height: 200,
                              width: 200,
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
                                  height: 200,
                                  width: 200,
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
                                      height: 200,
                                      width: 200,
                                      child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
                                    )
                                  : GestureDetector(
                                      onTap: _copyQrData,
                                      child: QrImageView(
                                        data: _encodedQrData!,
                                        size: 220,
                                        version: QrVersions.auto,
                                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                                      ),
                                    ),
                    ),
                  ),

                  const SizedBox(height: 20),

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
                        value: _remaining.inSeconds / (10 * 60),
                        backgroundColor: AppColors.darkBorder,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Animated pulse status
                  if (!_isExpired)
                    Row(
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
