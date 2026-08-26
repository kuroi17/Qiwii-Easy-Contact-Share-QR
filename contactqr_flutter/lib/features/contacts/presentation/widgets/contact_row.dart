import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/contact_model.dart';

class ContactRow extends StatefulWidget {
  const ContactRow({
    super.key,
    required this.contact,
    required this.selected,
    required this.onTap,
  });

  final AppContact contact;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<ContactRow> createState() => _ContactRowState();
}

class _ContactRowState extends State<ContactRow> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: widget.selected ? AppColors.surface : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.selected ? AppColors.primary : AppColors.cardBorder,
              width: widget.selected ? 1.5 : 1.0,
            ),
            boxShadow: AppColors.softShadow,
          ),
          child: Row(
            children: [
              // Initials Avatar
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: widget.selected ? AppColors.primaryLight : AppColors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.contact.initials,
                    style: TextStyle(
                      color: widget.selected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Contact Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.contact.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (widget.contact.isDuplicate)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            margin: const EdgeInsets.only(left: 6),
                            decoration: BoxDecoration(
                              color: AppColors.amberLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.info_outline_rounded, size: 12, color: AppColors.amber),
                                SizedBox(width: 4),
                                Text(
                                  'EXISTING',
                                  style: TextStyle(
                                    color: AppColors.amber,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.contact.phone,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Dribbble-style Selection Ring
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.selected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: widget.selected ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: widget.selected ? AppColors.primaryGlow : null,
                ),
                child: widget.selected
                    ? const Center(
                        child: Icon(Icons.check_rounded, color: Colors.white, size: 15),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
