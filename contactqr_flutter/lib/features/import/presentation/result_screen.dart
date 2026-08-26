import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/card_box.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/shell.dart';
import '../../../core/widgets/summary_row.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.count,
    this.skippedCount = 0,
    this.failedCount = 0,
  });

  final int count;
  final int skippedCount;
  final int failedCount;

  @override
  Widget build(BuildContext context) => Shell(
    child: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 65, 20, 20),
            child: Column(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 72),
                const SizedBox(height: 22),
                const Text(
                  'Transfer complete',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your selected contacts are ready on this device.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.slate, fontSize: 15),
                ),
                const SizedBox(height: 36),
                CardBox(
                  child: Column(
                    children: [
                      SummaryRow(
                        label: 'Saved',
                        value: '$count contacts',
                        color: AppColors.success,
                      ),
                      const Divider(color: AppColors.border),
                      SummaryRow(
                        label: 'Skipped',
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
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    'Nothing was overwritten. You can safely repeat a transfer anytime.',
                    style: TextStyle(color: AppColors.navy, fontSize: 13, height: 1.5),
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
