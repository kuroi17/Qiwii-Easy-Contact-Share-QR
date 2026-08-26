import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.title,
    this.light = false,
    this.trailing,
    this.onBack,
  });

  final String title;
  final bool light;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final textColor = light ? Colors.white : AppColors.textPrimary;
    final iconBg = light ? Colors.white.withValues(alpha: 0.12) : AppColors.surface;
    final iconColor = light ? Colors.white : AppColors.textPrimary;
    final canPop = Navigator.canPop(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          if (canPop)
            GestureDetector(
              onTap: onBack ?? () => Navigator.pop(context),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                  border: light ? null : Border.all(color: AppColors.cardBorder),
                  boxShadow: light ? null : AppColors.softShadow,
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: iconColor,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 42),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          if (trailing != null)
            trailing!
          else
            const SizedBox(width: 42),
        ],
      ),
    );
  }
}
