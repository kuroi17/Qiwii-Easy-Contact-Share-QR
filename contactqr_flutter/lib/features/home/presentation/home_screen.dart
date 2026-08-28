import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/shell.dart';
import '../../contacts/presentation/send_screen.dart';
import '../../contacts/providers/sender_provider.dart';
import '../../qr/presentation/scanner_screen.dart';
import 'widgets/action_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final senderState = ref.watch(senderProvider);
    final contactCount = senderState.contacts.length;

    return Shell(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top Bar ───────────────────────────────────────────
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/Qiwii_logo.png',
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Qiwii',
                          style: AppTextStyles.brand(
                            fontSize: 22,
                            color: AppColors.ink,
                          ),
                        ),
                        const Spacer(),
                        // Privacy indicator badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Private & Offline',
                                style: TextStyle(
                                  color: AppColors.ink2,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // ── Middle Hero Section (Centered & Prominent) ─────────
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Share contacts,\ninstantly.',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Transfer multiple contacts peer-to-peer with no cloud.',
                            style: TextStyle(
                              color: AppColors.ink2,
                              fontSize: 14.5,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ── Card 1: Send Contacts (Large Hero Card) ────
                          ActionTile(
                            icon: Icons.north_east_rounded,
                            title: 'Send contacts',
                            subtitle: contactCount > 0
                                ? '$contactCount contacts available to share'
                                : 'Select multiple contacts to transmit',
                            badgeText: contactCount > 0 ? '$contactCount contacts' : null,
                            isPrimary: true,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SendScreen()),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── Card 2: Receive Contacts (Large Hero Card) ──
                          ActionTile(
                            icon: Icons.qr_code_scanner_rounded,
                            title: 'Receive contacts',
                            subtitle: 'Scan a sender’s QR code to review & save',
                            isPrimary: false,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ScannerScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Bottom Trust Footer ───────────────────────────────
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Center(
                        child: Text(
                          'Zero cloud. Nothing leaves your device.',
                          style: TextStyle(
                            color: AppColors.ink3,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
