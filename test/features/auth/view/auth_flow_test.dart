import 'dart:async';

import 'package:blog_app/app.dart';
import 'package:blog_app/data/models/app_user.dart';
import 'package:blog_app/data/repositories/auth_repository.dart';
import 'package:blog_app/features/auth/view/login_page.dart';
import 'package:blog_app/features/auth/view/register_page.dart';
import 'package:blog_app/features/feed/view/feed_page.dart';
import 'package:blog_app/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../helpers/fake_auth_provider.dart';

void main() {
  late FakeAuthProvider provider;

  setUp(() {
    provider = FakeAuthProvider();
  });

  Future<void> openLogin(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(BlogApp(authRepository: AuthRepository(provider)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
  }

  Finder field(String label) {
    return find.descendant(
      of: find.widgetWithText(AppTextField, label),
      matching: find.byType(TextField),
    );
  }

  Finder submitButton(String label) {
    return find.widgetWithText(FilledButton, label);
  }

  Finder accountButton() => find.byTooltip('Mon compte');

  testWidgets('affiche les erreurs locales sans appeler le serveur', (
    tester,
  ) async {
    await openLogin(tester);

    await tester.tap(submitButton('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.text('Saisissez votre nom d’utilisateur.'), findsOneWidget);
    expect(find.text('Saisissez votre mot de passe.'), findsOneWidget);
    expect(provider.logInCalls, isEmpty);
  });

  testWidgets('affiche la bannière d’erreur du serveur', (tester) async {
    provider.onLogIn = (_, _) => throw parseError(ParseError.objectNotFound);
    await openLogin(tester);

    await tester.enterText(field('Nom d’utilisateur'), 'alice');
    await tester.enterText(field('Mot de passe'), 'faux');
    await tester.tap(submitButton('Se connecter'));
    await tester.pumpAndSettle();

    expect(
      find.text('Nom d’utilisateur ou mot de passe incorrect.'),
      findsOneWidget,
    );
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('désactive le bouton avec un indicateur pendant la requête', (
    tester,
  ) async {
    final response = Completer<AppUser>();
    provider.onLogIn = (_, _) => response.future;
    await openLogin(tester);

    await tester.enterText(field('Nom d’utilisateur'), 'alice');
    await tester.enterText(field('Mot de passe'), 'Password123!');
    await tester.tap(submitButton('Se connecter'));
    await tester.pump();

    final button = tester.widget<FilledButton>(
      find.descendant(
        of: find.byType(LoginPage),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.onPressed, isNull);
    expect(
      find.descendant(
        of: find.byType(LoginPage),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );

    response.complete(alice);
    await tester.pumpAndSettle();
    expect(provider.logInCalls, hasLength(1));
  });

  testWidgets('connecte, revient au fil puis déconnecte depuis le compte', (
    tester,
  ) async {
    await openLogin(tester);

    await tester.enterText(field('Nom d’utilisateur'), ' alice ');
    await tester.enterText(field('Mot de passe'), 'Password123!');
    await tester.tap(submitButton('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(FeedPage), findsOneWidget);
    expect(provider.logInCalls, [('alice', 'Password123!')]);

    await tester.tap(accountButton());
    await tester.pumpAndSettle();

    expect(find.text('alice@example.com'), findsOneWidget);
    expect(
      find.text('Testé sur iOS · simulateur iPhone 17 Pro'),
      findsOneWidget,
    );

    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();

    expect(provider.logOutCalls, 1);
    expect(accountButton(), findsNothing);
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('inscrit depuis la connexion et revient au fil connecté', (
    tester,
  ) async {
    await openLogin(tester);

    await tester.tap(find.text('Créer un compte'));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterPage), findsOneWidget);

    await tester.enterText(field('Nom d’utilisateur'), 'prince');
    await tester.enterText(field('E-mail'), 'prince@exemple.com');
    await tester.enterText(field('Mot de passe'), 'Password123!');
    await tester.tap(submitButton('Créer mon compte'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterPage), findsNothing);
    expect(find.byType(LoginPage), findsNothing);
    expect(accountButton(), findsOneWidget);
  });

  testWidgets('le lien Se connecter de l’inscription revient à la connexion', (
    tester,
  ) async {
    await openLogin(tester);
    await tester.tap(find.text('Créer un compte'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterPage), findsNothing);
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
