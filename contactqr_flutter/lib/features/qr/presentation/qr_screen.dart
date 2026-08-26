import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/qr_codec.dart';
import '../../../core/widgets/card_box.dart';
import '../../../core/widgets/header.dart';
import '../../../core/widgets/shell.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../data/models/contact_model.dart';
import '../../contacts/providers/sender_provider.dart';

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
  late Timer _timer;
  Duration _remaining = const Duration(minutes: 10);
  late String _encodedQrData;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  void _initSession() {
    _expiresAt = DateTime.now().add(const Duration(minutes: 10));
    _remaining = const Duration(minutes: 10);
    _isExpired = false;

    // Get selected contacts from props or provider
    final contactsToTransfer = widget.selectedContacts ??
        ref.read(senderProvider).selectedContacts;

    final actualContacts = contactsToTransfer.isNotEmpty
        ? contactsToTransfer
        : demoContacts.take(widget.count).toList();

    _encodedQrData = QrCodec.encodeDirectContacts(
      actualContacts,
      timeoutMinutes: 10,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = _expiresAt.difference(DateTime.now());
      if (diff.isNegative) {
        _timer.cancel();
        setState(() {
          _isExpired = true;
          _remaining = Duration.zero;
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
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _copyQrData() {
    Clipboard.setData(ClipboardData(text: _encodedQrData));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transfer payload copied to clipboard.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    text: _isExpired ? 'EXPIRED' : 'READY TO CONNECT',
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _isExpired ? 'Transfer Expired' : 'Show this code',
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
                                  onPressed: () => setState(_initSession),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Generate New Code'),
                                  style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
                                ),
                              ],
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: _copyQrData,
                            child: QrImageView(
                              data: _encodedQrData,
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.circle, size: 8, color: AppColors.teal),
                        SizedBox(width: 8),
                        Text(
                          'Waiting for receiver…',
                          style: TextStyle(color: AppColors.slate, fontSize: 14),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
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
