import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Bar ───────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.contact_page, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'ContactQR',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                // Privacy badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Private',
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

            const SizedBox(height: 48),

            // ── Hero Headline ─────────────────────────────────────────────
            const Text(
              'Share contacts,\ninstantly.',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1.12,
                letterSpacing: -1.0,
              ),
            ),

            const SizedBox(height: 32),

            // ── Send Action Tile ──────────────────────────────────────────
            ActionTile(
              icon: Icons.north_east_rounded,
              title: 'Send contacts',
              subtitle: contactCount > 0
                  ? '$contactCount contacts available'
                  : 'Choose who to share',
              isPrimary: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SendScreen()),
              ),
            ),

            const SizedBox(height: 10),

            // ── Receive Action Tile ───────────────────────────────────────
            ActionTile(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Receive contacts',
              subtitle: 'Scan a sender\u2019s QR code',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              ),
            ),

            const Spacer(),

            // ── Trust Footer ──────────────────────────────────────────────
            const Center(
              child: Text(
                'Zero cloud. Nothing leaves your device.',
                style: TextStyle(
                  color: AppColors.ink3,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
