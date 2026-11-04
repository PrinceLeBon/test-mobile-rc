import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/register_cubit.dart';
import '../cubit/register_state.dart';
import 'auth_field_error_message.dart';
import 'auth_navigation.dart';
import 'auth_scaffold.dart';
import 'password_field.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static const String title = 'Créer un compte';
  static const String subtitle =
      'Rejoignez la communauté en quelques secondes.';
  static const String usernameLabel = 'Nom d’utilisateur';
  static const String usernameHint = 'Choisissez un nom';
  static const String emailLabel = 'E-mail';
  static const String emailHint = 'vous@exemple.com';
  static const String passwordHelper = '8 caractères minimum';
  static const String submitLabel = 'Créer mon compte';
  static const String footerQuestion = 'Déjà un compte\u00A0?';
  static const String footerAction = 'Se connecter';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(context.read<AuthRepository>()),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<RegisterCubit>().submit();
  }

  void _onSignedUp(BuildContext context, RegisterState state) {
    final user = state.signedInUser;
    if (user == null) {
      return;
    }
    context.read<AuthCubit>().signedIn(user);
    context.closeAuthFlow(signedIn: true);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();

    return BlocConsumer<RegisterCubit, RegisterState>(
      listenWhen: (previous, current) =>
          previous.signedInUser == null && current.signedInUser != null,
      listener: _onSignedUp,
      builder: (context, state) {
        return PopScope(
          canPop: !state.isSubmitting,
          child: AuthScaffold(
            title: RegisterPage.title,
            subtitle: RegisterPage.subtitle,
            footer: AuthFooter(
              question: RegisterPage.footerQuestion,
              actionLabel: RegisterPage.footerAction,
              onAction: state.isSubmitting
                  ? null
                  : () => context.closeAuthFlow(signedIn: false),
            ),
            children: [
              AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: RegisterPage.usernameLabel,
                      hint: RegisterPage.usernameHint,
                      controller: _usernameController,
                      prefixIcon: Icons.person_outline_rounded,
                      autocorrect: false,
                      readOnly: state.isSubmitting,
                      errorText: state.usernameError?.message,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newUsername],
                      onChanged: cubit.usernameChanged,
                    ),
                    const SizedBox(height: AppSpacing.betweenFields),
                    AppTextField(
                      label: RegisterPage.emailLabel,
                      hint: RegisterPage.emailHint,
                      controller: _emailController,
                      prefixIcon: Icons.mail_outline_rounded,
                      autocorrect: false,
                      readOnly: state.isSubmitting,
                      errorText: state.emailError?.message,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      onChanged: cubit.emailChanged,
                    ),
                    const SizedBox(height: AppSpacing.betweenFields),
                    PasswordField(
                      controller: _passwordController,
                      autofillHint: AutofillHints.newPassword,
                      helperText: RegisterPage.passwordHelper,
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
                label: RegisterPage.submitLabel,
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
