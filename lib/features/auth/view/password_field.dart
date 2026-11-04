import 'package:flutter/material.dart';

import '../../../shared/widgets/app_text_field.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.autofillHint,
    this.helperText,
    this.errorText,
    this.readOnly = false,
    this.onChanged,
    this.onSubmitted,
  });

  static const String label = 'Mot de passe';
  static const String hint = 'Votre mot de passe';
  static const String showTooltip = 'Afficher le mot de passe';
  static const String hideTooltip = 'Masquer le mot de passe';

  final TextEditingController controller;
  final String autofillHint;
  final String? helperText;
  final String? errorText;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isHidden = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: PasswordField.label,
      hint: PasswordField.hint,
      controller: widget.controller,
      prefixIcon: Icons.lock_outline_rounded,
      obscureText: _isHidden,
      autocorrect: false,
      readOnly: widget.readOnly,
      helperText: widget.helperText,
      errorText: widget.errorText,
      textInputAction: TextInputAction.done,
      autofillHints: [widget.autofillHint],
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      suffix: IconButton(
        tooltip: _isHidden
            ? PasswordField.showTooltip
            : PasswordField.hideTooltip,
        icon: Icon(
          _isHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: () => setState(() => _isHidden = !_isHidden),
      ),
    );
  }
}
