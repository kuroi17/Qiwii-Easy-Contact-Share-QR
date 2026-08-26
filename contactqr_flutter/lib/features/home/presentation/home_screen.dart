import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/card_box.dart';
import '../../../core/widgets/shell.dart';
import '../../contacts/presentation/send_screen.dart';
import '../../qr/presentation/scanner_screen.dart';
import 'widgets/action_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Shell(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.contact_page, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 62),
          const Text(
            AppConstants.appTagline,
            style: TextStyle(
              color: AppColors.teal,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            AppConstants.appHeadline,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 35,
              height: 1.14,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.1,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            AppConstants.appSubtitle,
            style: TextStyle(
              color: AppColors.slate,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 38),
          ActionTile(
            icon: Icons.north_east,
            color: AppColors.navy,
            title: 'Send contacts',
            subtitle: 'Choose who to share',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SendScreen()),
            ),
          ),
          const SizedBox(height: 12),
          ActionTile(
            icon: Icons.qr_code_scanner,
            color: AppColors.teal,
            title: 'Receive contacts',
            subtitle: 'Scan a sender’s QR code',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScannerScreen()),
            ),
          ),
          const SizedBox(height: 145),
          CardBox(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.shield, color: AppColors.teal),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.privacyNoticeTitle,
                        style: TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        AppConstants.privacyNoticeSubtitle,
                        style: TextStyle(
                          color: AppColors.slate,
                          fontSize: 13,
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
