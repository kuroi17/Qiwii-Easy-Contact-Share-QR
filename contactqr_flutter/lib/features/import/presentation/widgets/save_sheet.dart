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
            backgroundColor: Colors.red.shade800,
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
            Text(
              _isSaving ? 'Saving Contacts…' : 'Save contacts?',
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isSaving
                  ? 'Adding $progress of $total contacts to your address book.'
                  : '${widget.count} contacts will be added to your device. Existing contacts will never be overwritten.',
              style: const TextStyle(color: AppColors.slate, fontSize: 15, height: 1.45),
            ),
            const SizedBox(height: 20),

            if (_isSaving) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: total > 0 ? (progress / total).clamp(0.0, 1.0) : null,
                  backgroundColor: AppColors.mint,
                  color: AppColors.teal,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _handleSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: Text(
                    'Save ${widget.count} Contacts',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
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
          ],
        ),
      ),
    );
  }
}
