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
      backgroundColor: AppColors.surface,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.wifi_off_rounded, color: AppColors.error, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.45),
          ),
          if (showTroubleshooting) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Troubleshooting Guide:',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Ensure both devices are connected to the same Wi-Fi network.\n'
                    '2. Or turn on Personal Hotspot on one device and connect the other.\n'
                    '3. Keep both devices close during transfer.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          if (onPrimaryAction != null) ...[
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  onPrimaryAction?.call();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
