import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/card_box.dart';
import '../../../core/widgets/shell.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../data/models/contact_model.dart';
import '../../contacts/presentation/send_screen.dart';
import '../../qr/presentation/scanner_screen.dart';
import 'widgets/action_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Shell(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppColors.primaryGlow,
                      ),
                      child: const Center(
                        child: Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          AppConstants.appName,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Privacy-First Transfer',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const StatusPill(
                  text: '100% OFFLINE',
                  color: AppColors.success,
                  backgroundColor: AppColors.successLight,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Hero Featured Card (Inspired by Dribbble Visa / Doctor Card)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(26),
                boxShadow: AppColors.primaryGlow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'P2P ENGINE ACTIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.wifi_off_rounded, color: Colors.white70, size: 20),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Move the right contacts,\nnot your entire phonebook.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Zero cloud retention. Encrypted on-device transfer.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildHeroStat(Icons.qr_code_scanner_rounded, 'Direct QR Optical'),
                      const SizedBox(width: 16),
                      _buildHeroStat(Icons.lock_outline_rounded, '256-Bit Encrypted'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Quick Actions Title
            const Text(
              'Quick Actions',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 14),

            // Action Tiles
            ActionTile(
              icon: Icons.north_east_rounded,
              iconColor: AppColors.primary,
              iconBgColor: AppColors.primaryLight,
              title: 'Send Contacts',
              subtitle: 'Select contacts & generate transfer QR',
              badgeText: 'Instant',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SendScreen()),
              ),
            ),

            const SizedBox(height: 14),

            ActionTile(
              icon: Icons.qr_code_scanner_rounded,
              iconColor: AppColors.teal,
              iconBgColor: AppColors.tealLight,
              title: 'Receive Contacts',
              subtitle: 'Scan a sender’s code using camera',
              badgeText: 'Camera',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              ),
            ),

            const SizedBox(height: 28),

            // Quick Starred / Recent Contacts Strip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Quick Select',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Demo Pool',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: demoContacts.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final contact = demoContacts[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SendScreen()),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.cardBorder, width: 1.5),
                            boxShadow: AppColors.softShadow,
                          ),
                          child: Center(
                            child: Text(
                              contact.initials,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          contact.name.split(' ').first,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Privacy Guarantee Box
            CardBox(
              padding: const EdgeInsets.all(16),
              backgroundColor: AppColors.surface,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.shield_outlined, color: AppColors.success, size: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '100% Private & On-Device',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'No cloud, no accounts, no data leaves your control.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
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
      ),
    );
  }

  Widget _buildHeroStat(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
