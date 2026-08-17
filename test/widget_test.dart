import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_projects/main.dart';

void main() {
  testWidgets('SpendTimeApp builds and shows the Home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpendTimeApp());

    expect(find.text('SpendTime'), findsOneWidget);
  });
}