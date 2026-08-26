import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/receiver_provider.dart';
import '../result_screen.dart';

class SaveSheet extends ConsumerStatefulWidget {
  const SaveSheet({super.key, required this.count});
  final int count;

  @override
  ConsumerState<SaveSheet> createState() => _SaveSheetState();
}

class _SaveSheetState extends ConsumerState<SaveSheet> {
  bool _isSaving = false;

  Future<void> _handleSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final success = await ref.read(receiverProvider.notifier).importSelectedContacts();

    if (mounted) {
      Navigator.pop(context); // Close sheet
      final state = ref.read(receiverProvider);

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              count: state.savedCount,
              skippedCount: state.skippedCount,
              failedCount: state.failedCount,
              savedContacts: state.savedContacts,
              skippedContacts: state.skippedContacts,
              failedContacts: state.failedContacts,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage ?? 'Failed to save contacts to device.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final receiverState = ref.watch(receiverProvider);
    final progress = receiverState.importProgress;
    final total = widget.count;

    return PopScope(
      canPop: !_isSaving,
      child: Padding(
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
            const SizedBox(height: 22),
            Text(
              _isSaving ? 'Saving Contacts…' : 'Save to Address Book?',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isSaving
                  ? 'Adding $progress of $total contacts directly to your phonebook.'
                  : '${widget.count} contacts will be added. Existing contacts will never be overwritten.',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.45),
            ),
            const SizedBox(height: 22),

            if (_isSaving) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: total > 0 ? (progress / total).clamp(0.0, 1.0) : null,
                  backgroundColor: AppColors.primaryLight,
                  color: AppColors.primary,
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _handleSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    'Save ${widget.count} Contacts',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
