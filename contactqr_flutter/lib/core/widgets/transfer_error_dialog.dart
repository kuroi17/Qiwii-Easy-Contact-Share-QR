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
      backgroundColor: AppColors.ivory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
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
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.handleBar,
                borderRadius: BorderRadius.circular(3),
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
                child: Icon(Icons.wifi_off_rounded, color: Colors.red.shade700, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(color: AppColors.slate, fontSize: 14, height: 1.45),
          ),
          if (showTroubleshooting) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Troubleshooting Tips:',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '1. Ensure both devices are connected to the same Wi-Fi.\n'
                    '2. Or turn on Mobile Hotspot on one phone and connect the other phone to it.\n'
                    '3. Keep both devices nearby during transfer.',
                    style: TextStyle(color: AppColors.slate, fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          if (onPrimaryAction != null) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  onPrimaryAction?.call();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teal,
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
                style: TextStyle(color: AppColors.slate, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
