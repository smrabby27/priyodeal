import 'package:flutter_test/flutter_test.dart';
import 'package:priyodeal_app/main.dart';

void main() {
  testWidgets('App starts smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PriyoDealApp());
    expect(find.byType(PriyoDealApp), findsOneWidget);
  });
}
