import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:contactqr_flutter/main.dart';
import 'package:contactqr_flutter/data/models/contact_model.dart';
import 'package:contactqr_flutter/features/contacts/providers/sender_provider.dart';

void main() {
  testWidgets('Qiwii home screen renders primary actions', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ContactQrApp(),
      ),
    );

    expect(find.text('Qiwii'), findsOneWidget);
    expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    expect(find.text('Send contacts'), findsOneWidget);
    expect(find.text('Receive contacts'), findsOneWidget);
    expect(find.text('Zero cloud. Nothing leaves your device.'), findsOneWidget);
  });

  test('AppContact model generates initials correctly', () {
    expect(AppContact.generateInitials('Maya Chen'), 'MC');
    expect(AppContact.generateInitials('Jordan'), 'JO');
    expect(AppContact.generateInitials('John Ronald Reuel Tolkien'), 'JT');
    expect(AppContact.generateInitials(''), '?');
  });

  test('SenderState filters contacts by search query', () {
    const state = SenderState(
      contacts: demoContacts,
      searchQuery: 'Maya',
    );
    expect(state.filteredContacts.length, 1);
    expect(state.filteredContacts.first.name, 'Maya Chen');
  });
}
