import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/validation_rules.dart';
import '../../../core/error/failure.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../auth/view/auth_navigation.dart';
import '../../feed/cubit/feed_cubit.dart';
import '../cubit/new_post_cubit.dart';
import '../cubit/new_post_state.dart';

class NewPostPage extends StatelessWidget {
  const NewPostPage({super.key});

  static const String title = 'Nouvel article';
  static const String closeTooltip = 'Fermer';
  static const String titleLabel = 'Titre';
  static const String titleHint = 'Un titre clair et accrocheur';
  static const String titleHelper = '3 à 120 caractères';
  static const String bodyLabel = 'Contenu';
  static const String bodyHint = 'Racontez votre histoire…';
  static const String bodyHelper = 'Jusqu’à 5000 caractères';
  static const String submitLabel = 'Publier';
  static const String publishedMessage = 'Article publié.';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NewPostCubit(context.read<PostRepository>()),
      child: const NewPostView(),
    );
  }
}

class NewPostView extends StatefulWidget {
  const NewPostView({super.key});

  @override
  State<NewPostView> createState() => _NewPostViewState();
}

class _NewPostViewState extends State<NewPostView> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _requireSignedIn());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _requireSignedIn() async {
    if (!mounted || context.read<AuthCubit>().state is AuthAuthenticated) {
      return;
    }
    final signedIn = await context.openLogin();
    if (!signedIn && mounted) {
      _close();
    }
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.feed);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final signedIn = await context.ensureSignedIn();
    if (signedIn && mounted) {
      await context.read<NewPostCubit>().submit();
    }
  }

  void _onPublished(BuildContext context, NewPostState state) {
    final post = state.createdPost;
    if (post == null) {
      return;
    }
    context.read<FeedCubit>().insertPost(post);
    context.showInfoSnackBar(NewPostPage.publishedMessage);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NewPostCubit>();

    return MultiBlocListener(
      listeners: [
        BlocListener<NewPostCubit, NewPostState>(
          listenWhen: (previous, current) =>
              previous.createdPost == null && current.createdPost != null,
          listener: _onPublished,
        ),
        BlocListener<NewPostCubit, NewPostState>(
          listenWhen: (previous, current) =>
              current.failure is SessionFailure &&
              previous.failure != current.failure,
          listener: (context, _) => context.read<AuthCubit>().sessionExpired(),
        ),
      ],
      child: BlocBuilder<NewPostCubit, NewPostState>(
        builder: (context, state) {
          return PopScope(
            canPop: !state.isSubmitting,
            child: Scaffold(
              backgroundColor: context.colorScheme.surface,
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: const Text(NewPostPage.title),
                leading: IconButton(
                  tooltip: NewPostPage.closeTooltip,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: state.isSubmitting ? null : _close,
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.detailHorizontal,
                        AppSpacing.xs,
                        AppSpacing.detailHorizontal,
                        AppSpacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            label: NewPostPage.titleLabel,
                            hint: NewPostPage.titleHint,
                            helperText: NewPostPage.titleHelper,
                            controller: _titleController,
                            maxLength: ValidationRules.postTitleMaxLength,
                            minLines: 1,
                            maxLines: 3,
                            readOnly: state.isSubmitting,
                            errorText: state.titleError?.message,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            onChanged: cubit.titleChanged,
                          ),
                          const SizedBox(height: AppSpacing.betweenFields),
                          AppTextField(
                            label: NewPostPage.bodyLabel,
                            hint: NewPostPage.bodyHint,
                            helperText: NewPostPage.bodyHelper,
                            controller: _bodyController,
                            maxLength: ValidationRules.postBodyMaxLength,
                            minLines: AppSizes.postBodyMinLines,
                            maxLines: null,
                            readOnly: state.isSubmitting,
                            errorText: state.bodyError?.message,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            onChanged: cubit.bodyChanged,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.detailHorizontal,
                        AppSpacing.xs,
                        AppSpacing.detailHorizontal,
                        AppSpacing.md,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AnimatedErrorBanner(
                            message: state.failure?.message,
                            spacingBelow: AppSpacing.sm,
                          ),
                          AppPrimaryButton(
                            label: NewPostPage.submitLabel,
                            isLoading: state.isSubmitting,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
