import 'package:blog_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('l application demarre', (tester) async {
    await tester.pumpWidget(const MainApp());
    expect(find.text('Hello World!'), findsOneWidget);
  });
}
