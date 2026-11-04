import 'package:flutter/material.dart';

import 'auth_scaffold.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const String title = 'Bon retour';
  static const String subtitle =
      'Connectez-vous pour publier, aimer et commenter.';

  @override
  Widget build(BuildContext context) {
    return const AuthScaffold(title: title, subtitle: subtitle, showLogo: true);
  }
}
