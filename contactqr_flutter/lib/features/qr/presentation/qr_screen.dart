import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/card_box.dart';
import '../../../core/widgets/header.dart';
import '../../../core/widgets/shell.dart';
import '../../../core/widgets/status_pill.dart';

class QrScreen extends StatelessWidget {
  const QrScreen({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Shell(
      child: Column(
        children: [
          const Header(title: 'Transfer'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const StatusPill(),
                  const SizedBox(height: 20),
                  const Text(
                    'Show this code',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ask the receiver to scan this QR code with ContactQR.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.slate, fontSize: 15),
                  ),
                  const SizedBox(height: 28),
                  CardBox(
                    child: Column(
                      children: [
                        QrImageView(
                          data: 'contactqr://session/demo-$count',
                          size: 220,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '$count contacts • expires in 10 minutes',
                          style: const TextStyle(color: AppColors.slate, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 8, color: AppColors.teal),
                      SizedBox(width: 8),
                      Text(
                        'Waiting for receiver…',
                        style: TextStyle(color: AppColors.slate, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text(
              'Cancel transfer',
              style: TextStyle(color: AppColors.slate, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
