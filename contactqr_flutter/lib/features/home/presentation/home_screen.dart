import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/shell.dart';
import '../../contacts/presentation/send_screen.dart';
import '../../contacts/providers/sender_provider.dart';
import '../../info/presentation/privacy_policy_screen.dart';
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

                        // ── Modern 3-Dots Dropdown Menu ───────────────────
                        Theme(
                          data: Theme.of(context).copyWith(
                            popupMenuTheme: PopupMenuThemeData(
                              color: AppColors.cardWhite,
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: AppColors.border),
                              ),
                            ),
                          ),
                          child: PopupMenuButton<String>(
                            tooltip: 'More options',
                            offset: const Offset(0, 46),
                            icon: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Icon(
                                Icons.more_vert_rounded,
                                color: AppColors.ink,
                                size: 20,
                              ),
                            ),
                            onSelected: (value) async {
                              if (value == 'feedback') {
                                final uri = Uri.parse(
                                  'https://github.com/kuroi17/Qiwii-Easy-Contact-Share-QR/issues',
                                );
                                try {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } catch (_) {
                                  // Fallback if unable to launch browser
                                }
                              } else if (value == 'privacy') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PrivacyPolicyScreen(),
                                  ),
                                );
                              } else if (value == 'licenses') {
                                showLicensePage(
                                  context: context,
                                  applicationName: 'Qiwii - Easy Contact Share QR',
                                  applicationVersion: '1.0.0+1',
                                  applicationIcon: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        'assets/Qiwii_logo.png',
                                        width: 52,
                                        height: 52,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'feedback',
                                child: Row(
                                  children: const [
                                    Icon(Icons.feedback_outlined, size: 19, color: AppColors.ink),
                                    SizedBox(width: 12),
                                    Text(
                                      'Help & Feedback',
                                      style: TextStyle(
                                        color: AppColors.ink,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(height: 1),
                              PopupMenuItem(
                                value: 'privacy',
                                child: Row(
                                  children: const [
                                    Icon(Icons.privacy_tip_outlined, size: 19, color: AppColors.ink),
                                    SizedBox(width: 12),
                                    Text(
                                      'Privacy Policy',
                                      style: TextStyle(
                                        color: AppColors.ink,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(height: 1),
                              PopupMenuItem(
                                value: 'licenses',
                                child: Row(
                                  children: const [
                                    Icon(Icons.article_outlined, size: 19, color: AppColors.ink),
                                    SizedBox(width: 12),
                                    Text(
                                      'LICENSES',
                                      style: TextStyle(
                                        color: AppColors.ink,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
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
                          Text(
                            'Share contacts,\ninstantly.',
                            style: AppTextStyles.display(
                              fontSize: 32,
                              color: AppColors.ink,
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
