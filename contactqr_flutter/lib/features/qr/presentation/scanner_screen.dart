import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/header.dart';
import '../../../core/widgets/shell.dart';
import '../../import/presentation/received_screen.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Shell(
      dark: true,
      child: Column(
        children: [
          const Header(title: 'Receive contacts', light: true),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'Scan the sender’s code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Align the QR code inside the frame. Nothing is saved automatically.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.subtitleLight,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReceivedScreen()),
                    ),
                    child: Container(
                      height: 310,
                      decoration: BoxDecoration(
                        color: AppColors.darkNavy,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.darkNavyBorder),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.qr_code_2,
                          size: 86,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Tap the frame to simulate a successful scan',
                    style: TextStyle(color: AppColors.subtitleLight, fontSize: 12),
                  ),
                  const Spacer(),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flash_on, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Flash', style: TextStyle(color: Colors.white)),
                      SizedBox(width: 36),
                      Icon(Icons.lock, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Private session',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
