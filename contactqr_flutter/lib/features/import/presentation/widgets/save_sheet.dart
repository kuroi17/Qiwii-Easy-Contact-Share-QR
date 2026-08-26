import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../result_screen.dart';

class SaveSheet extends StatelessWidget {
  const SaveSheet({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => Padding(
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
        const SizedBox(height: 22),
        const Text(
          'Save contacts?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '$count contacts will be added to your device. Existing contacts will never be overwritten.',
          style: const TextStyle(color: AppColors.slate, fontSize: 15, height: 1.45),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ResultScreen(count: count)),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.navy,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
            child: const Text(
              'Save contacts',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.slate, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    ),
  );
}
