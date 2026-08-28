import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/contact_model.dart';

class ContactRow extends StatelessWidget {
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
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        children: [
          // Monochrome avatar
          CircleAvatar(
            radius: 21,
            backgroundColor: AppColors.surface2,
            child: Text(
              contact.initials,
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contact.name,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (contact.isDuplicate)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AppColors.accentTint,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Duplicate',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  contact.phone,
                  style: const TextStyle(color: AppColors.ink3, fontSize: 13),
                ),
              ],
            ),
          ),
          // Orange checkmark circle
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.accent : Colors.transparent,
              border: Border.all(
                color: selected ? AppColors.accent : AppColors.border,
                width: 1.5,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
        ],
      ),
    ),
  );
}
