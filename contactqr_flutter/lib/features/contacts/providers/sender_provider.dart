import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/contact_model.dart';

class SenderState {
  const SenderState({
    this.contacts = demoContacts,
    this.selectedIds = const {'1', '2', '3'},
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  final List<AppContact> contacts;
  final Set<String> selectedIds;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  List<AppContact> get filteredContacts {
    if (searchQuery.trim().isEmpty) return contacts;
    final query = searchQuery.toLowerCase();
    return contacts.where((c) {
      return c.name.toLowerCase().contains(query) ||
          c.phone.toLowerCase().contains(query) ||
          (c.email?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<AppContact> get selectedContacts {
    return contacts.where((c) => selectedIds.contains(c.id)).toList();
  }

  SenderState copyWith({
    List<AppContact>? contacts,
    Set<String>? selectedIds,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SenderState(
      contacts: contacts ?? this.contacts,
      selectedIds: selectedIds ?? this.selectedIds,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class SenderNotifier extends StateNotifier<SenderState> {
  SenderNotifier() : super(const SenderState());

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

  void setContacts(List<AppContact> contacts) {
    state = state.copyWith(contacts: contacts);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }
}

final senderProvider = StateNotifierProvider<SenderNotifier, SenderState>((ref) {
  return SenderNotifier();
});
