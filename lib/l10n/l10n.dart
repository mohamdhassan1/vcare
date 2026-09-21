import 'package:flutter/widgets.dart';
import '../core/errors/app_exception.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

/// `context.l10n.someKey` — the one way screens read localized text.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Whether the active locale lays out right-to-left (Arabic).
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  /// User-facing text for a failure reported by a BLoC.
  ///
  /// Known application errors are localized from their [AppErrorCode].
  /// When the backend itself explained the problem (validation text,
  /// a 4xx with a `message`) that dynamic text is shown as-is — it is
  /// never machine-translated. [invalidCredentials] lets the Sign In
  /// screen turn a plain 401 into a friendlier message.
  String errorText(AppErrorInfo error, {bool invalidCredentials = false}) {
    final serverMessage = error.serverMessage?.trim();
    final hasServerMessage = serverMessage != null && serverMessage.isNotEmpty;

    switch (error.code) {
      case AppErrorCode.network:
        return l10n.errorNetwork;
      case AppErrorCode.timeout:
        return l10n.errorTimeout;
      case AppErrorCode.cancelled:
        return l10n.errorCancelled;
      case AppErrorCode.server:
        return l10n.errorServer;
      case AppErrorCode.tooManyRequests:
        return l10n.errorTooManyRequests;
      case AppErrorCode.invalidResponse:
        return l10n.errorInvalidResponse;
      case AppErrorCode.unauthorized:
        if (hasServerMessage) return serverMessage;
        return invalidCredentials
            ? l10n.invalidCredentials
            : l10n.sessionExpired;
      case AppErrorCode.validation:
        return hasServerMessage ? serverMessage : l10n.errorValidation;
      case AppErrorCode.badRequest:
        return hasServerMessage ? serverMessage : l10n.errorBadRequest;
      case AppErrorCode.forbidden:
        return hasServerMessage ? serverMessage : l10n.errorForbidden;
      case AppErrorCode.notFound:
        return hasServerMessage ? serverMessage : l10n.errorNotFound;
      case AppErrorCode.aiNotConfigured:
        return l10n.aiNotConfigured;
      case AppErrorCode.aiInvalidKey:
        return l10n.aiInvalidKey;
      case AppErrorCode.aiRateLimited:
        return l10n.aiRateLimited;
      case AppErrorCode.aiTimeout:
        return l10n.aiTimeout;
      case AppErrorCode.aiServiceError:
        return l10n.aiServiceError;
      case AppErrorCode.aiBlocked:
        return l10n.aiBlocked;
      case AppErrorCode.aiEmptyResponse:
        return l10n.aiEmptyResponse;
      case AppErrorCode.aiInvalidRequest:
        return l10n.aiInvalidRequest;
      case AppErrorCode.unknown:
        return hasServerMessage ? serverMessage : l10n.somethingWentWrong;
    }
  }
}

/// Null-safe lookup for low-level widgets (buttons, loaders) that may be
/// pumped in a bare MaterialApp without the app delegates.
extension L10nMaybe on BuildContext {
  AppLocalizations? get l10nOrNull =>
      Localizations.of<AppLocalizations>(this, AppLocalizations);
}
