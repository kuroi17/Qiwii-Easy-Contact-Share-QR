import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
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
                  const SizedBox(height: 10),
                  const Text(
                    'Choose people to share',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Only the contacts you select will be offered.',
                    style: TextStyle(color: AppColors.slate, fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  SearchBox(
                    controller: _searchController,
                    onChanged: (q) => senderNotifier.setSearchQuery(q),
                    hint: 'Search contacts',
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
                              'No contacts found',
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
                                onTap: () => senderNotifier.toggleContact(contact.id),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          PrimaryButton(
            label: 'Continue',
            icon: Icons.arrow_forward,
            onPressed: () {
              if (selectedIds.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select at least one contact.')),
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
