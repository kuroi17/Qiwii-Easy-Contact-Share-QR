import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.title,
    this.light = false,
    this.onBack,
  });

  final String title;
  final bool light;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        onPressed: onBack ?? () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: light ? Colors.white : AppColors.navy,
        ),
      ),
      Expanded(
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: light ? Colors.white : AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      const SizedBox(width: 48),
    ],
  );
}
