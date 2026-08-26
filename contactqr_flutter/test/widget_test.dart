import 'package:flutter_test/flutter_test.dart';

import 'package:contactqr_flutter/main.dart';

void main() {
  testWidgets('ContactQR home screen renders primary actions', (tester) async {
    await tester.pumpWidget(const ContactQrApp());

    expect(find.text('ContactQR'), findsOneWidget);
    expect(find.text('Send contacts'), findsOneWidget);
    expect(find.text('Receive contacts'), findsOneWidget);
    expect(find.text('No accounts. No cloud.'), findsOneWidget);
  });
}
