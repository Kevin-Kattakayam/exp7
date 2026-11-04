import 'package:flutter_test/flutter_test.dart';
import 'package:firestore_employee_app/main.dart';
import 'package:firestore_employee_app/services/firestore_service.dart';

void main() {
  setUp(() async {
    await FirestoreService.instance.initialize();
  });

  testWidgets('Renders FirestoreEmployeeApp, displays Cloud Status banner and controls',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FirestoreEmployeeApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify AppBar title
    expect(find.text('Firestore HR Directory'), findsOneWidget);

    // Verify Firestore status banner
    expect(find.text('Google Cloud Firestore'), findsOneWidget);
    expect(find.text('NoSQL Persistence'), findsOneWidget);

    // Verify Add Employee action button
    expect(find.text('Add Employee'), findsOneWidget);

    // Verify Search hint
    expect(find.text('Search by Name, Role, or EMP ID...'), findsOneWidget);
  });
}
