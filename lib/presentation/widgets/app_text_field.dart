import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import '../../l10n/l10n.dart';

/// Standard text input used across auth (and later) forms.
///
/// With [label] the field shows a floating label (so the field stays
/// identified after typing) and [hint] becomes an optional example
/// value; without it, [hint] identifies the field as before. Supports an
/// optional obscure-text toggle (localized tooltip + semantics) for
/// password fields, and configurable capitalization/autocorrect so
/// fields like email can avoid keyboard-driven casing inconsistencies.
/// Long (Arabic) validation messages wrap instead of clipping.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.label,
    this.prefixIcon,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.autocorrect = true,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String hint;
  final String? label;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool autocorrect;

  /// Keyboard action button (e.g. `next` to move on, `done` to submit).
  final TextInputAction? textInputAction;

  /// Called when the keyboard action / Enter is pressed. Lets the last
  /// field of a form submit it without duplicating the button's logic.
  final ValueChanged<String>? onFieldSubmitted;

  final Iterable<String>? autofillHints;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10nOrNull;
    final hasLabel = widget.label != null;
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      autocorrect: widget.autocorrect,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      autofillHints: widget.autofillHints,
      decoration: InputDecoration(
        labelText: widget.label,
        // With a label, the hint is only an example shown while empty
        // and focused; the label keeps identifying the field.
        hintText: hasLabel && widget.hint == widget.label ? null : widget.hint,
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon, size: AppDimensions.iconMd),
        errorMaxLines: 3,
        suffixIcon: widget.obscureText
            ? IconButton(
                tooltip: _obscured ? l10n?.showPassword : l10n?.hidePassword,
                constraints: const BoxConstraints(
                    minWidth: AppDimensions.minTouchTarget,
                    minHeight: AppDimensions.minTouchTarget),
                icon: Icon(_obscured
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
      ),
    );
  }
}
