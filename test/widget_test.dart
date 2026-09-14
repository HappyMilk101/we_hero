import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:we_hero/main.dart';
import 'package:we_hero/features/auth/data/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  const FakeAuthRepository();

  @override
  Future<String?> restoreSession() async => null;

  @override
  Future<String?> signInWithNickname(String nickname) async => nickname;

  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('WE HERO starts with a welcoming action', (tester) async {
    await tester.pumpWidget(
      const WeHeroApp(authRepository: FakeAuthRepository()),
    );
    await tester.pump();
    expect(find.text('WE HERO'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '슈퍼맨');
    expect(find.text('시작하기'), findsOneWidget);
    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();
    expect(find.text('오늘의 Hero HQ'), findsOneWidget);
    expect(find.text('Sidekick'), findsOneWidget);
  });
}
