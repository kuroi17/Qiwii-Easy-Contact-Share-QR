import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
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
                  const Text(
                    'Review before saving',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The sender offered ${receiverState.receivedContacts.length} contacts. You decide what gets added.',
                    style: const TextStyle(color: AppColors.slate, fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  SearchBox(
                    controller: _searchController,
                    onChanged: (q) => receiverNotifier.setSearchQuery(q),
                    hint: 'Search received contacts',
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${selectedIds.length} selected',
                        style: const TextStyle(
                          color: AppColors.slate,
                          fontWeight: FontWeight.w600,
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
                            color: AppColors.teal,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
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
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
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
            label: 'Save selected contacts',
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
                backgroundColor: AppColors.ivory,
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
