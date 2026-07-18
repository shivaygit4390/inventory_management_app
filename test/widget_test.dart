import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/app/app.dart';

void main() {
  testWidgets('starts the inventory application', (WidgetTester tester) async {
    await tester.pumpWidget(const InventoryApp());

    expect(find.text('Inventory Management'), findsOneWidget);
    expect(find.text('Inventory foundation is ready'), findsOneWidget);
  });
}
