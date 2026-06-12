import 'package:flutter_test/flutter_test.dart';
import 'package:voxa_app/main.dart';

void main() {
  testWidgets('Voxa app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VoxaApp());

    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(VoxaApp), findsOneWidget);
  });
}