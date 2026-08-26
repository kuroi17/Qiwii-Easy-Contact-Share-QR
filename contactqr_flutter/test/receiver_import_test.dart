import 'package:flutter_test/flutter_test.dart';
import 'package:contactqr_flutter/data/models/contact_model.dart';
import 'package:contactqr_flutter/data/repositories/contact_repository.dart';
import 'package:contactqr_flutter/features/import/providers/receiver_provider.dart';

void main() {
  group('Receiver & Contact Importer Tests', () {
    test('computes duplicateCount and deselects duplicates correctly', () {
      const contacts = [
        AppContact(id: '1', name: 'Maya Chen', phone: '+14155550198', initials: 'MC', isDuplicate: false),
        AppContact(id: '2', name: 'Jordan Rivera', phone: '+14155550142', initials: 'JR', isDuplicate: true),
        AppContact(id: '3', name: 'Theo Martin', phone: '+15105550164', initials: 'TM', isDuplicate: true),
      ];

      final notifier = ReceiverNotifier(const ContactRepository(isMock: true));
      notifier.setReceivedContacts(contacts);

      var state = notifier.currentState;
      expect(state.duplicateCount, 2);
      expect(state.selectedIds.length, 3);

      notifier.deselectDuplicates();
      state = notifier.currentState;
      expect(state.selectedIds.length, 1);
      expect(state.selectedIds.contains('1'), true);
      expect(state.selectedIds.contains('2'), false);
    });

    test('imports selected contacts with accurate metrics reporting', () async {
      const contacts = [
        AppContact(id: '1', name: 'Maya Chen', phone: '+14155550198', initials: 'MC'),
        AppContact(id: '2', name: 'Jordan Rivera', phone: '+14155550142', initials: 'JR'),
        AppContact(id: '3', name: 'Theo Martin', phone: '+15105550164', initials: 'TM'),
      ];

      final notifier = ReceiverNotifier(const ContactRepository(isMock: true));
      notifier.setReceivedContacts(contacts);

      // Deselect contact 3
      notifier.toggleContact('3');

      final success = await notifier.importSelectedContacts();
      expect(success, true);

      final state = notifier.currentState;
      expect(state.savedCount, 2);
      expect(state.skippedCount, 1);
      expect(state.failedCount, 0);
      expect(state.isImporting, false);
      expect(state.savedContacts.length, 2);
      expect(state.skippedContacts.length, 1);
    });
  });
}
