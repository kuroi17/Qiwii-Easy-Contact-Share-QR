import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/contact_model.dart';

class ReceiverState {
  const ReceiverState({
    this.receivedContacts = demoContacts,
    this.selectedIds = const {'1', '2', '3', '4', '5', '6'},
    this.searchQuery = '',
    this.isImporting = false,
    this.savedCount = 0,
    this.skippedCount = 0,
    this.failedCount = 0,
    this.errorMessage,
  });

  final List<AppContact> receivedContacts;
  final Set<String> selectedIds;
  final String searchQuery;
  final bool isImporting;
  final int savedCount;
  final int skippedCount;
  final int failedCount;
  final String? errorMessage;

  List<AppContact> get filteredContacts {
    if (searchQuery.trim().isEmpty) return receivedContacts;
    final query = searchQuery.toLowerCase();
    return receivedContacts.where((c) {
      return c.name.toLowerCase().contains(query) ||
          c.phone.toLowerCase().contains(query) ||
          (c.email?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<AppContact> get selectedContacts {
    return receivedContacts.where((c) => selectedIds.contains(c.id)).toList();
  }

  ReceiverState copyWith({
    List<AppContact>? receivedContacts,
    Set<String>? selectedIds,
    String? searchQuery,
    bool? isImporting,
    int? savedCount,
    int? skippedCount,
    int? failedCount,
    String? errorMessage,
  }) {
    return ReceiverState(
      receivedContacts: receivedContacts ?? this.receivedContacts,
      selectedIds: selectedIds ?? this.selectedIds,
      searchQuery: searchQuery ?? this.searchQuery,
      isImporting: isImporting ?? this.isImporting,
      savedCount: savedCount ?? this.savedCount,
      skippedCount: skippedCount ?? this.skippedCount,
      failedCount: failedCount ?? this.failedCount,
      errorMessage: errorMessage,
    );
  }
}

class ReceiverNotifier extends StateNotifier<ReceiverState> {
  ReceiverNotifier() : super(const ReceiverState());

  void setReceivedContacts(List<AppContact> contacts) {
    final allIds = contacts.map((c) => c.id).toSet();
    state = state.copyWith(
      receivedContacts: contacts,
      selectedIds: allIds,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleContact(String id) {
    final nextSelected = Set<String>.from(state.selectedIds);
    if (nextSelected.contains(id)) {
      nextSelected.remove(id);
    } else {
      nextSelected.add(id);
    }
    state = state.copyWith(selectedIds: nextSelected);
  }

  void selectAll() {
    final allIds = state.filteredContacts.map((c) => c.id).toSet();
    state = state.copyWith(selectedIds: allIds);
  }

  void clearAll() {
    state = state.copyWith(selectedIds: {});
  }

  void setImportResults({
    required int saved,
    required int skipped,
    required int failed,
  }) {
    state = state.copyWith(
      savedCount: saved,
      skippedCount: skipped,
      failedCount: failed,
      isImporting: false,
    );
  }

  void reset() {
    state = const ReceiverState();
  }
}

final receiverProvider = StateNotifierProvider<ReceiverNotifier, ReceiverState>((ref) {
  return ReceiverNotifier();
});
