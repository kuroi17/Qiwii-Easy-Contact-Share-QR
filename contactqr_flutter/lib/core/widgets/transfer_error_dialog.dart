import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TransferErrorDialog extends StatelessWidget {
  const TransferErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.primaryActionText = 'Try Again',
    this.onPrimaryAction,
    this.showTroubleshooting = true,
  });

  final String title;
  final String message;
  final String primaryActionText;
  final VoidCallback? onPrimaryAction;
  final bool showTroubleshooting;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String primaryActionText = 'Try Again',
    VoidCallback? onPrimaryAction,
    bool showTroubleshooting = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => TransferErrorDialog(
        title: title,
        message: message,
        primaryActionText: primaryActionText,
        onPrimaryAction: onPrimaryAction,
        showTroubleshooting: showTroubleshooting,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.wifi_off_rounded, color: Colors.red.shade700, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: AppColors.ink2, fontSize: 14, height: 1.45),
            ),
            if (showTroubleshooting) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Troubleshooting Tips:',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '1. Ensure both devices are connected to the same Wi-Fi or Hotspot for live P2P transfers.\n'
                      '2. For offline/remote transfers, use "Share with 4-Digit PIN" or save a direct PIN-protected QR code.\n'
                      '3. Keep both devices nearby during transfer.',
                      style: TextStyle(color: AppColors.ink2, fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (onPrimaryAction != null) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onPrimaryAction?.call();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    primaryActionText,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Dismiss',
                  style: TextStyle(color: AppColors.ink2, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
