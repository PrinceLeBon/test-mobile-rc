import 'package:flutter/material.dart';

import 'auth_scaffold.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static const String title = 'Créer un compte';
  static const String subtitle = 'Rejoignez la communauté en quelques secondes.';

  @override
  Widget build(BuildContext context) {
    return const AuthScaffold(title: title, subtitle: subtitle);
  }
}
