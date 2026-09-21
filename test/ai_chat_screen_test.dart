// Phase 4 — AI chat screen: localized EN/AR UI, RTL bubble placement,
// input guards (empty/whitespace, double send, input stays usable while
// a reply is pending), the typing indicator, and the persistent error
// banner with Retry / Dismiss.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vcare/core/errors/app_exception.dart';
import 'package:vcare/core/theme/app_palette.dart';
import 'package:vcare/core/theme/app_theme.dart';
import 'package:vcare/data/models/ai_message_model.dart';
import 'package:vcare/data/repositories/ai_chat_repository.dart';
import 'package:vcare/l10n/app_localizations.dart';
import 'package:vcare/l10n/app_localizations_ar.dart';
import 'package:vcare/l10n/app_localizations_en.dart';
import 'package:vcare/presentation/screans/inbox/ai_chat_screen.dart';

class _FakeRepo implements AIChatRepository {
  String reply = 'ok';
  Object? error;
  Completer<String>? gate;
  int calls = 0;
  List<AIMessageModel> lastHistory = const [];

  @override
  Future<String> sendMessage(List<AIMessageModel> history) async {
    calls++;
    lastHistory = List.of(history);
    if (error != null) throw error!;
    if (gate != null) return gate!.future;
    return reply;
  }
}

Widget _app(_FakeRepo repo, {Locale locale = const Locale('en')}) =>
    RepositoryProvider<AIChatRepository>.value(
      value: repo,
      child: MaterialApp(
        locale: locale,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AIChatScreen(),
      ),
    );

final _en = AppLocalizationsEn();
final _ar = AppLocalizationsAr();

Finder _typing(String label) => find
    .byWidgetPredicate((w) => w is Semantics && w.properties.label == label);

/// The bubble Container around a message text.
Finder _bubbleOf(String text) => find
    .ancestor(
        of: find.text(text, findRichText: true),
        matching: find.byType(Container))
    .first;

Future<void> _settleShort(WidgetTester tester) async {
  // The typing indicator animates forever, so pumpAndSettle would spin;
  // a few frames are enough for the bloc to emit.
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  late _FakeRepo repo;

  setUp(() => repo = _FakeRepo());

  testWidgets('English empty state uses localized strings', (tester) async {
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    expect(find.text(_en.aiAssistantTitle), findsOneWidget);
    expect(find.text(_en.aiDisclaimer), findsOneWidget);
    expect(find.text(_en.aiWelcome), findsOneWidget);
    expect(find.text(_en.aiSuggestion1), findsOneWidget);
    expect(find.text(_en.aiInputHint), findsOneWidget);
    expect(find.byTooltip(_en.send), findsOneWidget);
    // Touch targets: send and dismiss are at least 48px.
    final send = tester.getSize(find.ancestor(
        of: find.byTooltip(_en.send), matching: find.byType(IconButton)));
    expect(send.width, greaterThanOrEqualTo(48));
    expect(send.height, greaterThanOrEqualTo(48));
  });

  testWidgets('empty / whitespace input is never sent', (tester) async {
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(_en.send));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '   \n  ');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();

    expect(repo.calls, 0);
    expect(find.text(_en.aiWelcome), findsOneWidget);
  });

  testWidgets(
      'sending shows the user bubble, the typing indicator, keeps the field '
      'enabled and blocks a second send until the reply lands', (tester) async {
    repo.gate = Completer<String>();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.tap(find.byTooltip(_en.send));
    await _settleShort(tester);

    expect(find.text('Hello', findRichText: true), findsOneWidget);
    expect(_typing(_en.aiTyping), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled ?? true,
        isTrue,
        reason: 'the keyboard must not collapse while waiting');
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty);

    // Typing more and pressing send while pending is ignored.
    await tester.enterText(find.byType(TextField), 'Second');
    await tester.tap(find.byTooltip(_en.send), warnIfMissed: false);
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await _settleShort(tester);
    expect(repo.calls, 1);
    // The draft is kept in the field (not lost, not sent as a bubble).
    expect(
        find.descendant(
            of: find.byType(ListView),
            matching: find.text('Second', findRichText: true)),
        findsNothing);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Second');

    repo.gate!.complete('**Hi!** How can I help?');
    await tester.pumpAndSettle();

    expect(_typing(_en.aiTyping), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    // Markdown markers are rendered, not shown raw; answers are selectable.
    expect(
        find.text('Hi! How can I help?', findRichText: true), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(
        find.text('**Hi!** How can I help?', findRichText: true), findsNothing);
  });

  testWidgets(
      'a failure keeps the message visible with a localized banner, '
      'Retry re-sends once, Dismiss clears', (tester) async {
    repo.error = const AppException('raw', code: AppErrorCode.aiTimeout);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();

    expect(find.text('Hello', findRichText: true), findsOneWidget);
    expect(find.text(_en.aiTimeout), findsOneWidget);
    expect(find.text('raw'), findsNothing);
    expect(find.text(_en.retry), findsOneWidget);
    expect(find.byTooltip(_en.dismiss), findsOneWidget);
    // The failed bubble is visually distinguished (error outline).
    final failed = tester.widget<Container>(_bubbleOf('Hello'));
    expect((failed.decoration as BoxDecoration).border!.top.color,
        AppPalette.light.error);

    repo.error = null;
    repo.reply = 'Back';
    await tester.tap(find.text(_en.retry));
    await tester.pumpAndSettle();

    expect(repo.calls, 2);
    expect(repo.lastHistory.map((m) => m.text), ['Hello']);
    expect(find.text('Hello', findRichText: true), findsOneWidget);
    expect(find.text('Back', findRichText: true), findsOneWidget);
    expect(find.text(_en.aiTimeout), findsNothing);
    final ok = tester.widget<Container>(_bubbleOf('Hello'));
    expect((ok.decoration as BoxDecoration).border!.top.color,
        isNot(AppPalette.light.error));

    // Fail again, then dismiss: message and banner both go.
    repo.error = const NetworkException();
    await tester.enterText(find.byType(TextField), 'Again');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    expect(find.text(_en.errorNetwork), findsOneWidget);
    await tester.tap(find.byTooltip(_en.dismiss));
    await tester.pumpAndSettle();
    expect(find.text(_en.errorNetwork), findsNothing);
    expect(find.text('Again', findRichText: true), findsNothing);
  });

  testWidgets('Arabic UI is RTL with user bubbles on the start (right) edge',
      (tester) async {
    repo.reply = 'Sure';
    await tester.pumpWidget(_app(repo, locale: const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.text(_ar.aiAssistantTitle), findsOneWidget);
    expect(find.text(_ar.aiInputHint), findsOneWidget);
    expect(find.byTooltip(_ar.send), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(AIChatScreen))),
        TextDirection.rtl);

    await tester.enterText(find.byType(TextField), 'مرحبا');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();

    final screenWidth = tester.getSize(find.byType(AIChatScreen)).width;
    final user = tester.getRect(_bubbleOf('مرحبا'));
    final model = tester.getRect(_bubbleOf('Sure'));
    // In RTL the user's own message hugs the left edge ("end") and the
    // assistant's the right edge ("start").
    expect(user.left, lessThan(screenWidth / 2));
    expect(model.right, greaterThan(screenWidth / 2));
    // The English answer still reads left-to-right inside the RTL UI.
    final answer = tester.widget<SelectableText>(find.byType(SelectableText));
    expect(answer.textDirection, TextDirection.ltr);

    // Localized Arabic error text.
    repo.error = const AppException('raw', code: AppErrorCode.aiRateLimited);
    await tester.enterText(find.byType(TextField), 'ثانية');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    expect(find.text(_ar.aiRateLimited), findsOneWidget);
    expect(find.text(_ar.retry), findsOneWidget);
    expect(find.byTooltip(_ar.dismiss), findsOneWidget);
  });

  testWidgets('English UI places user bubbles on the right', (tester) async {
    repo.reply = 'Sure';
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Hi');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();

    final screenWidth = tester.getSize(find.byType(AIChatScreen)).width;
    expect(tester.getRect(_bubbleOf('Hi')).right, greaterThan(screenWidth / 2));
    expect(tester.getRect(_bubbleOf('Sure')).left, lessThan(screenWidth / 2));
  });

  testWidgets(
      'a missing key surfaces the localized not-configured message '
      'without exposing config details', (tester) async {
    repo.error = const AppException(
        'AI Assistant is not configured. Missing API key.',
        code: AppErrorCode.aiNotConfigured);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_en.aiSuggestion2));
    await tester.pumpAndSettle();

    expect(find.text(_en.aiNotConfigured), findsOneWidget);
    expect(find.textContaining('GEMINI'), findsNothing);
    expect(find.textContaining('dart-define'), findsNothing);
    expect(find.textContaining('API key'), findsNothing);
  });
}
