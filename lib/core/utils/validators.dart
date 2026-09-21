import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Shared form validators used across auth (and later) screens.
///
/// Each validator takes the active [AppLocalizations] so the messages a
/// `TextFormField` shows are in the user's language:
/// `validator: Validators.email(context.l10n)`.
///
/// Note: the API does not document a minimum password length anywhere
/// in the Postman collection. 6 characters is a reasonable common
/// default — adjust [minPasswordLength] if the backend enforces
/// something different.
class Validators {
  Validators._();

  static const int minPasswordLength = 6;

  /// Practical (not full-RFC) email check: `local@domain.tld`, where the
  /// local part allows letters, digits and `. _ % + -`, the domain is
  /// dot-separated labels of letters/digits/hyphens, and the TLD is at
  /// least two letters with no upper bound (the previous `{2,4}` limit
  /// rejected valid addresses like `.online` or `.photography`). No
  /// whitespace or second `@` anywhere.
  static final RegExp _emailRegex = RegExp(
      r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$');

  static FormFieldValidator<String> email(AppLocalizations l10n) => (value) {
        if (value == null || value.trim().isEmpty) return l10n.emailRequired;
        if (!_emailRegex.hasMatch(value.trim())) return l10n.emailInvalid;
        return null;
      };

  static FormFieldValidator<String> password(AppLocalizations l10n) => (value) {
        if (value == null || value.isEmpty) return l10n.passwordRequired;
        if (value.length < minPasswordLength) {
          return l10n.passwordTooShort(minPasswordLength);
        }
        return null;
      };

  /// [original] is read at validation time so it always compares
  /// against the password field's current text.
  static FormFieldValidator<String> confirmPassword(
          AppLocalizations l10n, String Function() original) =>
      (value) {
        if (value == null || value.isEmpty) {
          return l10n.confirmPasswordRequired;
        }
        if (value != original()) return l10n.passwordsDoNotMatch;
        return null;
      };

  static FormFieldValidator<String> phone(AppLocalizations l10n) => (value) {
        if (value == null || value.trim().isEmpty) return l10n.phoneRequired;
        if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
          return l10n.phoneDigitsOnly;
        }
        return null;
      };

  static FormFieldValidator<String> name(AppLocalizations l10n) => (value) {
        if (value == null || value.trim().isEmpty) return l10n.nameRequired;
        return null;
      };
}
