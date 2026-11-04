import 'package:blog_app/app.dart';
import 'package:blog_app/data/repositories/auth_repository.dart';
import 'package:blog_app/features/auth/view/login_page.dart';
import 'package:blog_app/features/feed/view/feed_page.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_auth_provider.dart';

void main() {
  BlogApp visitorApp() {
    return BlogApp(authRepository: AuthRepository(FakeAuthProvider()));
  }

  testWidgets('l’application démarre sur le fil', (tester) async {
    await tester.pumpWidget(visitorApp());
    await tester.pumpAndSettle();

    expect(find.text('Blog'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(FeedAccountAction),
        matching: find.text('Se connecter'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('le bouton Se connecter ouvre l’écran de connexion', (
    tester,
  ) async {
    await tester.pumpWidget(visitorApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Bon retour'), findsOneWidget);
  });
}
