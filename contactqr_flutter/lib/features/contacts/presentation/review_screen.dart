import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/card_box.dart';
import '../../../core/widgets/header.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/shell.dart';
import '../../../core/widgets/status_pill.dart';
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ready to share',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                        ),
                      ),
                      StatusPill(
                        text: '${chosen.length} CONTACTS',
                        color: AppColors.primary,
                        backgroundColor: AppColors.primaryLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'The receiver will scan a QR code to import these contacts.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: CardBox(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListView.separated(
                        itemCount: chosen.length,
                        separatorBuilder: (_, _) => const Divider(color: AppColors.divider, height: 1),
                        itemBuilder: (_, index) {
                          final c = chosen[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      c.initials,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        c.phone,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.check_rounded,
                                      color: AppColors.primary,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          PrimaryButton(
            label: 'Generate Transfer QR',
            icon: Icons.qr_code_2_rounded,
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
