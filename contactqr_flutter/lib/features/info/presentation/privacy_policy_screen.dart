import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/header.dart';
import '../../../core/widgets/shell.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Shell(
      child: Column(
        children: [
          const Header(title: 'Privacy Policy'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Private by design.',
                    style: AppTextStyles.display(
                      fontSize: 28,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Qiwii is built on the principle that your address book belongs solely to you.',
                    style: TextStyle(
                      color: AppColors.ink2,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _PrivacyCard(
                    icon: Icons.cloud_off_rounded,
                    title: 'Zero Cloud & No Databases',
                    description:
                        'We do not operate servers that collect, store, or process your contacts. Nothing is sent to any cloud database.',
                  ),
                  const SizedBox(height: 14),

                  _PrivacyCard(
                    icon: Icons.wifi_protected_setup_rounded,
                    title: 'Direct Peer-to-Peer Transmission',
                    description:
                        'Contacts transfer directly between two nearby devices via optical QR code or encrypted local Wi-Fi connection.',
                  ),
                  const SizedBox(height: 14),

                  _PrivacyCard(
                    icon: Icons.no_accounts_rounded,
                    title: 'No Accounts or Tracking',
                    description:
                        'No registration, phone number, email, or third-party analytics trackers are used or required.',
                  ),
                  const SizedBox(height: 14),

                  _PrivacyCard(
                    icon: Icons.checklist_rounded,
                    title: 'Recipient Controls What Gets Saved',
                    description:
                        'The sender decides which contacts to offer; the receiver reviews and selectively imports only the chosen contacts.',
                  ),
                  const SizedBox(height: 14),

                  _PrivacyCard(
                    icon: Icons.memory_rounded,
                    title: 'Ephemeral In-Memory Sessions',
                    description:
                        'Transfer sessions use temporary encryption keys that automatically expire and are wiped from device memory upon transfer completion.',
                  ),

                  const SizedBox(height: 28),
                  const Center(
                    child: Text(
                      'Qiwii • Version 1.0.0 (Open Source)',
                      style: TextStyle(
                        color: AppColors.ink3,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.ink2,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
