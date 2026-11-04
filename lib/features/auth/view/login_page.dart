import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import 'auth_field_error_message.dart';
import 'auth_navigation.dart';
import 'auth_scaffold.dart';
import 'password_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const String title = 'Bon retour';
  static const String subtitle =
      'Connectez-vous pour publier, aimer et commenter.';
  static const String usernameLabel = 'Nom d’utilisateur';
  static const String usernameHint = 'Votre nom d’utilisateur';
  static const String submitLabel = 'Se connecter';
  static const String footerQuestion = 'Pas encore de compte\u00A0?';
  static const String footerAction = 'Créer un compte';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(context.read<AuthRepository>()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<LoginCubit>().submit();
  }

  Future<void> _openRegister() async {
    final signedUp = await context.push<bool>(AppRoutes.register);
    if (signedUp == true && mounted) {
      context.closeAuthFlow(signedIn: true);
    }
  }

  void _onSignedIn(BuildContext context, LoginState state) {
    final user = state.signedInUser;
    if (user == null) {
      return;
    }
    context.read<AuthCubit>().signedIn(user);
    context.closeAuthFlow(signedIn: true);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoginCubit>();

    return BlocConsumer<LoginCubit, LoginState>(
      listenWhen: (previous, current) =>
          previous.signedInUser == null && current.signedInUser != null,
      listener: _onSignedIn,
      builder: (context, state) {
        return PopScope(
          canPop: !state.isSubmitting,
          child: AuthScaffold(
            title: LoginPage.title,
            subtitle: LoginPage.subtitle,
            showLogo: true,
            footer: AuthFooter(
              question: LoginPage.footerQuestion,
              actionLabel: LoginPage.footerAction,
              onAction: state.isSubmitting ? null : _openRegister,
            ),
            children: [
              AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: LoginPage.usernameLabel,
                      hint: LoginPage.usernameHint,
                      controller: _usernameController,
                      prefixIcon: Icons.person_outline_rounded,
                      autocorrect: false,
                      readOnly: state.isSubmitting,
                      errorText: state.usernameError?.message,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      onChanged: cubit.usernameChanged,
                    ),
                    const SizedBox(height: AppSpacing.betweenFields),
                    PasswordField(
                      controller: _passwordController,
                      autofillHint: AutofillHints.password,
                      readOnly: state.isSubmitting,
                      errorText: state.passwordError?.message,
                      onChanged: cubit.passwordChanged,
                      onSubmitted: (_) => _submit(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.betweenFields),
              AnimatedErrorBanner(message: state.failure?.message),
              const SizedBox(height: AppSpacing.xxs),
              AppPrimaryButton(
                label: LoginPage.submitLabel,
                isLoading: state.isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        );
      },
    );
  }
}
