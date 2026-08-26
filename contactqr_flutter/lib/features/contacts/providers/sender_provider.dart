import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/contact_model.dart';
import '../../../data/repositories/contact_repository.dart';

final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  return const ContactRepository();
});

class SenderState {
  const SenderState({
    this.contacts = const [],
    this.selectedIds = const {},
    this.searchQuery = '',
    this.isLoading = false,
    this.permissionDenied = false,
    this.errorMessage,
  });

  final List<AppContact> contacts;
  final Set<String> selectedIds;
  final String searchQuery;
  final bool isLoading;
  final bool permissionDenied;
  final String? errorMessage;

  List<AppContact> get filteredContacts {
    if (searchQuery.trim().isEmpty) return contacts;
    final query = searchQuery.toLowerCase();
    return contacts.where((c) {
      return c.name.toLowerCase().contains(query) ||
          c.phone.toLowerCase().contains(query) ||
          (c.email?.toLowerCase().contains(query) ?? false) ||
          (c.organization?.toLowerCase().contains(query) ?? false);
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
    bool? permissionDenied,
    String? errorMessage,
  }) {
    return SenderState(
      contacts: contacts ?? this.contacts,
      selectedIds: selectedIds ?? this.selectedIds,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      errorMessage: errorMessage,
    );
  }
}

class SenderNotifier extends StateNotifier<SenderState> {
  SenderNotifier(this._repository) : super(const SenderState()) {
    loadContacts();
  }

  final ContactRepository _repository;

  /// Loads real device contacts using background isolate parsing.
  Future<void> loadContacts() async {
    state = state.copyWith(isLoading: true, permissionDenied: false, errorMessage: null);

    try {
      final fetched = await _repository.getDeviceContacts();
      state = state.copyWith(
        contacts: fetched,
        selectedIds: {}, // clean default selection
        isLoading: false,
        permissionDenied: false,
      );
    } catch (e) {
      if (e.toString().contains('CONTACTS_PERMISSION_DENIED')) {
        state = state.copyWith(
          isLoading: false,
          permissionDenied: true,
          errorMessage: 'Contacts access permission was denied.',
        );
      } else {
        state = state.copyWith(
          contacts: demoContacts,
          isLoading: false,
          errorMessage: e.toString(),
        );
      }
    }
  }

  Future<void> openSettings() async {
    await openAppSettings();
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
}

final senderProvider = StateNotifierProvider<SenderNotifier, SenderState>((ref) {
  final repository = ref.watch(contactRepositoryProvider);
  return SenderNotifier(repository);
});
