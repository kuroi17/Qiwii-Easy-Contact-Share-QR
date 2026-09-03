import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/header.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/search_box.dart';
import '../../../core/widgets/shell.dart';
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
                  const SizedBox(height: 10),
                  Text(
                    'Review before saving',
                    style: AppTextStyles.display(
                      fontSize: 26,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The sender offered ${receiverState.receivedContacts.length} contacts. You decide what gets added.',
                    style: const TextStyle(color: AppColors.slate, fontSize: 15),
                  ),
                  const SizedBox(height: 16),

                  // Duplicate Detection Warning Banner
                  if (dupCount > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.accentTint,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.accent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '$dupCount duplicate contact${dupCount > 1 ? 's' : ''} detected in your address book.',
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => receiverNotifier.deselectDuplicates(),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.cardWhite,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                              ),
                              child: const Text(
                                'Skip All',
                                style: TextStyle(
                                  color: AppColors.accentDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
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
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final allFilteredSelected = filtered.isNotEmpty &&
                          filtered.every((c) => selectedIds.contains(c.id));
                      final isFiltering = receiverState.searchQuery.trim().isNotEmpty;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${selectedIds.length} of ${receiverState.receivedContacts.length} selected',
                            style: const TextStyle(
                              color: AppColors.slate,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              if (allFilteredSelected) {
                                receiverNotifier.clearAll();
                              } else {
                                receiverNotifier.selectAll();
                              }
                            },
                            child: Text(
                              allFilteredSelected
                                  ? (isFiltering ? 'Deselect matches' : 'Clear all')
                                  : (isFiltering ? 'Select all matches' : 'Select all'),
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text(
                              'No matching contacts',
                              style: TextStyle(color: AppColors.slate),
                            ),
                          )
                        : ListView.separated(
                            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
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
            icon: Icons.save_alt,
            onPressed: () {
              if (selectedIds.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select at least one contact to save.')),
                );
                return;
              }
              showModalBottomSheet(
                context: context,
                isDismissible: false,
                backgroundColor: AppColors.canvas,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
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
