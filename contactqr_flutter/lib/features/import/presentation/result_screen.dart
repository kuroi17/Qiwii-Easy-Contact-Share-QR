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
                Icon(
                  failedCount > 0 && count == 0 ? Icons.error_outline : Icons.check_circle,
                  color: failedCount > 0 && count == 0 ? Colors.red : AppColors.success,
                  size: 72,
                ),
                const SizedBox(height: 18),
                Text(
                  failedCount > 0 && count == 0 ? 'Import Failed' : 'Transfer Complete',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  count > 0
                      ? 'Your selected contacts have been added directly to your device address book.'
                      : 'No contacts were added.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.slate, fontSize: 15),
                ),
                const SizedBox(height: 28),

                // Metrics Box
                CardBox(
                  child: Column(
                    children: [
                      SummaryRow(
                        label: 'Saved to Device',
                        value: '$count contacts',
                        color: AppColors.success,
                      ),
                      const Divider(color: AppColors.border),
                      SummaryRow(
                        label: 'Skipped / Unselected',
                        value: '$skippedCount contacts',
                        color: AppColors.amber,
                      ),
                      if (failedCount > 0) ...[
                        const Divider(color: AppColors.border),
                        SummaryRow(
                          label: 'Failed',
                          value: '$failedCount contacts',
                          color: Colors.red,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Reassurance Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.teal, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Zero cloud retention. Nothing was overwritten on your device.',
                          style: TextStyle(color: AppColors.navy, fontSize: 13, height: 1.4),
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
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
      ],
    ),
  );
}
