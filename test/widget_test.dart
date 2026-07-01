import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('shows ClinicSync dashboard content', (tester) async {
    await tester.pumpWidget(const ClinicSyncApp());

    expect(find.text('ClinicSync'), findsOneWidget);
    expect(find.text('Today queue'), findsOneWidget);
    expect(find.text('Upcoming appointments'), findsOneWidget);
  });
}
