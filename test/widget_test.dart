import 'package:flutter_test/flutter_test.dart';
import 'package:we_hero/main.dart';

void main() {
  testWidgets('WE HERO starts with a welcoming action', (tester) async {
    await tester.pumpWidget(const WeHeroApp());
    expect(find.text('WE HERO'), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);
    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();
    expect(find.text('오늘의 Mission'), findsOneWidget);
    expect(find.text('Sidekick'), findsOneWidget);
  });
}
