import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/header.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/search_box.dart';
import '../../../core/widgets/shell.dart';
import '../../../core/widgets/status_pill.dart';
import '../../contacts/presentation/widgets/contact_row.dart';
import '../providers/receiver_provider.dart';
import 'widgets/save_sheet.dart';

class ReceivedScreen extends ConsumerStatefulWidget {
  const ReceivedScreen({super.key});

  @override
  ConsumerState<ReceivedScreen> createState() => _ReceivedScreenState();
}

class _ReceivedScreenState extends ConsumerState<ReceivedScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(receiverProvider).searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final receiverState = ref.watch(receiverProvider);
    final receiverNotifier = ref.read(receiverProvider.notifier);
    final filtered = receiverState.filteredContacts;
    final selectedIds = receiverState.selectedIds;
    final dupCount = receiverState.duplicateCount;

    return Shell(
      child: Column(
        children: [
          const Header(title: 'Received contacts'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Review before saving',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                        ),
                      ),
                      StatusPill(
                        text: '${receiverState.receivedContacts.length} OFFERED',
                        color: AppColors.primary,
                        backgroundColor: AppColors.primaryLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You decide which contacts get added to your device.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Duplicate Warning Banner
                  if (dupCount > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.amberLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.amber, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '$dupCount duplicate contact${dupCount > 1 ? 's' : ''} already in address book.',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => receiverNotifier.deselectDuplicates(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Skip All',
                              style: TextStyle(
                                color: AppColors.amber,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  SearchBox(
                    controller: _searchController,
                    onChanged: (q) => receiverNotifier.setSearchQuery(q),
                    hint: 'Search received contacts',
                  ),
                  const SizedBox(height: 10),

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
                          '${selectedIds.length} of ${receiverState.receivedContacts.length} selected',
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
                            receiverNotifier.clearAll();
                          } else {
                            receiverNotifier.selectAll();
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

                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text(
                              'No matching contacts found',
                              style: TextStyle(color: AppColors.textSecondary),
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
                                onTap: () => receiverNotifier.toggleContact(contact.id),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          PrimaryButton(
            label: selectedIds.isEmpty ? 'Select Contacts' : 'Save ${selectedIds.length} Contacts',
            icon: Icons.download_rounded,
            onPressed: () {
              if (selectedIds.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please select at least one contact to save.'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
                return;
              }
              showModalBottomSheet(
                context: context,
                isDismissible: false,
                backgroundColor: AppColors.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                builder: (_) => SaveSheet(count: selectedIds.length),
              );
            },
          ),
        ],
      ),
    );
  }
}
