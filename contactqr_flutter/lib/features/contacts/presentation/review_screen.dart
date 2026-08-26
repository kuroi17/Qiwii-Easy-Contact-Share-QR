import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/card_box.dart';
import '../../../core/widgets/header.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/shell.dart';
import '../../qr/presentation/qr_screen.dart';
import '../providers/sender_provider.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key, required this.ids});
  final List<String> ids;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final senderState = ref.watch(senderProvider);
    final chosen = senderState.contacts.where((c) => ids.contains(c.id)).toList();

    return Shell(
      child: Column(
        children: [
          const Header(title: 'Review selection'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Icon(Icons.verified_user, color: AppColors.teal, size: 34),
                  const SizedBox(height: 18),
                  const Text(
                    'Ready to share',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${chosen.length} contacts will be offered to the receiver.',
                    style: const TextStyle(color: AppColors.slate, fontSize: 15),
                  ),
                  const SizedBox(height: 26),
                  Expanded(
                    child: CardBox(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: chosen.length,
                        separatorBuilder: (_, _) => const Divider(color: AppColors.border, height: 1),
                        itemBuilder: (_, index) {
                          final c = chosen[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 17,
                                  backgroundColor: AppColors.mint,
                                  child: Text(
                                    c.initials,
                                    style: const TextStyle(
                                      color: AppColors.teal,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style: const TextStyle(
                                          color: AppColors.navy,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        c.phone,
                                        style: const TextStyle(
                                          color: AppColors.slate,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.teal,
                                  size: 20,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          PrimaryButton(
            label: 'Generate transfer QR',
            icon: Icons.qr_code_2,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QrScreen(
                  count: chosen.length,
                  selectedContacts: chosen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
