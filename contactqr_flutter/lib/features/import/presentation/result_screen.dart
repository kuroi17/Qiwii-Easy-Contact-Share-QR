import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/card_box.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/shell.dart';
import '../../../core/widgets/summary_row.dart';
import '../../../data/models/contact_model.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.count,
    this.skippedCount = 0,
    this.failedCount = 0,
    this.savedContacts = const [],
    this.skippedContacts = const [],
    this.failedContacts = const [],
  });

  final int count;
  final int skippedCount;
  final int failedCount;
  final List<AppContact> savedContacts;
  final List<AppContact> skippedContacts;
  final List<AppContact> failedContacts;

  @override
  Widget build(BuildContext context) => Shell(
    child: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: failedCount > 0 && count == 0
                        ? AppColors.errorLight
                        : AppColors.successLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      failedCount > 0 && count == 0
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_rounded,
                      color: failedCount > 0 && count == 0
                          ? AppColors.error
                          : AppColors.success,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  failedCount > 0 && count == 0 ? 'Import Failed' : 'Transfer Complete',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  count > 0
                      ? 'Your selected contacts have been added directly to your device address book.'
                      : 'No contacts were added.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 28),

                // Metrics Box
                CardBox(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SummaryRow(
                        label: 'Saved to Device',
                        value: '$count contacts',
                        color: AppColors.success,
                      ),
                      const Divider(color: AppColors.divider),
                      SummaryRow(
                        label: 'Skipped / Unselected',
                        value: '$skippedCount contacts',
                        color: AppColors.amber,
                      ),
                      if (failedCount > 0) ...[
                        const Divider(color: AppColors.divider),
                        SummaryRow(
                          label: 'Failed',
                          value: '$failedCount contacts',
                          color: AppColors.error,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Reassurance Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.shield_outlined, color: AppColors.success, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Zero cloud retention. Nothing was overwritten on your device.',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        PrimaryButton(
          label: 'Done',
          icon: Icons.done_all_rounded,
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
      ],
    ),
  );
}
