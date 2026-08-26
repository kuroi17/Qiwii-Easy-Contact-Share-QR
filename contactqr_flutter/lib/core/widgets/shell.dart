import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Shell extends StatelessWidget {
  const Shell({
    super.key,
    required this.child,
    this.dark = false,
  });

  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: dark ? AppColors.navy : AppColors.ivory,
    body: SafeArea(child: child),
  );
}
