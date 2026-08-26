import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/card_box.dart';
import '../../../core/widgets/header.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/search_box.dart';
import '../../../core/widgets/shell.dart';
import '../providers/sender_provider.dart';
import 'review_screen.dart';
import 'widgets/contact_row.dart';

class SendScreen extends ConsumerStatefulWidget {
  const SendScreen({super.key});

  @override
  ConsumerState<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends ConsumerState<SendScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(senderProvider).searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final senderState = ref.watch(senderProvider);
    final senderNotifier = ref.read(senderProvider.notifier);
    final filtered = senderState.filteredContacts;
    final selectedIds = senderState.selectedIds;

    return Shell(
      child: Column(
        children: [
          const Header(title: 'Send contacts'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Choose contacts to share',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Only the contacts you select will be transferred.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Handle Permission Denied State
                  if (senderState.permissionDenied) ...[
                    Expanded(
                      child: Center(
                        child: CardBox(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.contacts_outlined,
                                    size: 32,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Contacts Access Needed',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'ContactQR requires contacts permission so you can choose which contacts to share.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 24),
                              FilledButton.icon(
                                onPressed: () => senderNotifier.loadContacts(),
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Grant Access'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => senderNotifier.openSettings(),
                                child: const Text(
                                  'Open App Settings',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else if (senderState.isLoading) ...[
                    // Loading Spinner
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            SizedBox(height: 16),
                            Text(
                              'Loading contacts...',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Search Bar
                    SearchBox(
                      controller: _searchController,
                      onChanged: (q) => senderNotifier.setSearchQuery(q),
                      hint: 'Search by name, number, or email',
                    ),
                    const SizedBox(height: 12),

                    // Selection Control Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${selectedIds.length} of ${senderState.contacts.length} selected',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (selectedIds.length == filtered.length && filtered.isNotEmpty) {
                              senderNotifier.clearAll();
                            } else {
                              senderNotifier.selectAll();
                            }
                          },
                          child: Text(
                            selectedIds.length == filtered.length && filtered.isNotEmpty
                                ? 'Clear all'
                                : 'Select all',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Contact List
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.person_search_rounded,
                                    size: 48,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    senderState.contacts.isEmpty
                                        ? 'No contacts found on device'
                                        : 'No matching contacts for "${_searchController.text}"',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (_, index) {
                                final contact = filtered[index];
                                return ContactRow(
                                  contact: contact,
                                  selected: selectedIds.contains(contact.id),
                                  onTap: () => senderNotifier.toggleContact(contact.id),
                                );
                              },
                            ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (!senderState.permissionDenied && !senderState.isLoading)
            PrimaryButton(
              label: 'Review Selection (${selectedIds.length})',
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                if (selectedIds.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please select at least one contact to transfer.'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewScreen(ids: selectedIds.toList()),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
