// UI Batch 5 — AI Assistant presentation: header, welcome hero and
// suggestion chips, bubble chrome (speaker cues beyond color), typing
// indicator, error banner actions, composer, RTL, narrow/wide widths,
// dark-mode-safe colors. Gemini/bloc behavior is exercised elsewhere.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vcare/core/errors/app_exception.dart';
import 'package:vcare/core/theme/app_dimensions.dart';
import 'package:vcare/core/theme/app_palette.dart';
import 'package:vcare/core/theme/app_theme.dart';
import 'package:vcare/data/models/ai_message_model.dart';
import 'package:vcare/data/repositories/ai_chat_repository.dart';
import 'package:vcare/l10n/app_localizations.dart';
import 'package:vcare/l10n/app_localizations_ar.dart';
import 'package:vcare/l10n/app_localizations_en.dart';
import 'package:vcare/presentation/screans/inbox/ai_chat_screen.dart';
import 'package:vcare/presentation/widgets/content_constraint.dart';

class _FakeRepo implements AIChatRepository {
  String reply = 'ok';
  Object? error;
  Completer<String>? gate;
  int calls = 0;

  @override
  Future<String> sendMessage(List<AIMessageModel> history) async {
    calls++;
    if (error != null) throw error!;
    if (gate != null) return gate!.future;
    return reply;
  }
}

final _en = AppLocalizationsEn();
final _ar = AppLocalizationsAr();

Widget _app(_FakeRepo repo,
        {Locale locale = const Locale('en'),
        ThemeData? theme,
        bool reduceMotion = false}) =>
    RepositoryProvider<AIChatRepository>.value(
      value: repo,
      child: MaterialApp(
        locale: locale,
        theme: theme ?? AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data:
              MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
          child: child!,
        ),
        home: const AIChatScreen(),
      ),
    );

/// The bubble Container around a message text.
Finder _bubbleOf(String text) => find
    .ancestor(
        of: find.text(text, findRichText: true),
        matching: find.byType(Container))
    .first;

Finder _typing(String label) => find
    .byWidgetPredicate((w) => w is Semantics && w.properties.label == label);

Future<void> _pumpFrames(WidgetTester tester, [int n = 6]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void _useWidth(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  late _FakeRepo repo;
  setUp(() => repo = _FakeRepo());

  group('Header + welcome', () {
    testWidgets('title once (header), hero + intro + chips section',
        (tester) async {
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();

      expect(find.text(_en.aiAssistantTitle), findsOneWidget,
          reason: 'identity is not duplicated in the empty state');
      expect(find.text(_en.aiWelcome), findsOneWidget);
      expect(find.text(_en.aiSuggestionsTitle), findsOneWidget);
      expect(find.text(_en.aiDisclaimer), findsOneWidget);
      expect(find.byType(ActionChip), findsNWidgets(4));
      expect(find.byType(ContentConstraint), findsWidgets);
    });

    testWidgets(
        'suggestion chips: 48px targets, disabled while sending, '
        'and they send their own text', (tester) async {
      repo.gate = Completer<String>();
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();

      final chip = find.widgetWithText(ActionChip, _en.aiSuggestion3);
      expect(tester.getSize(chip).height,
          greaterThanOrEqualTo(AppDimensions.minTouchTarget));
      await tester.tap(chip);
      await _pumpFrames(tester);

      expect(repo.calls, 1);
      expect(find.text(_en.aiSuggestion3, findRichText: true), findsOneWidget,
          reason: 'the chip text became the user bubble');
      expect(find.byType(ActionChip), findsNothing,
          reason: 'welcome state is replaced by the conversation');
      repo.gate!.complete('Sure');
      await tester.pumpAndSettle();
    });
  });

  group('Bubbles', () {
    testWidgets(
        'user vs assistant differ by side, avatar and tail — not '
        'just color; semantics name the speaker', (tester) async {
      repo.reply = 'Reply here';
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();

      final width = tester.getSize(find.byType(AIChatScreen)).width;
      final user = tester.getRect(_bubbleOf('Hello'));
      final model = tester.getRect(_bubbleOf('Reply here'));
      expect(user.right, greaterThan(width / 2));
      expect(model.left, lessThan(width / 2));
      // Assistant avatar appears for the model bubble only (one so far).
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      // Tail corners differ per speaker.
      final userRadius = (tester
              .widget<Container>(_bubbleOf('Hello'))
              .decoration as BoxDecoration)
          .borderRadius as BorderRadiusDirectional;
      final modelRadius = (tester
              .widget<Container>(_bubbleOf('Reply here'))
              .decoration as BoxDecoration)
          .borderRadius as BorderRadiusDirectional;
      expect(userRadius.bottomEnd, isNot(userRadius.bottomStart));
      expect(modelRadius.bottomStart, isNot(modelRadius.bottomEnd));
      // Speaker semantics.
      expect(
          find.byWidgetPredicate(
              (w) => w is Semantics && w.properties.label == _en.you),
          findsOneWidget);
      expect(
          find.byWidgetPredicate((w) =>
              w is Semantics && w.properties.label == _en.navAiAssistant),
          findsOneWidget);
      // Content and rendering preserved.
      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('dark mode: bubble colors come from the palette',
        (tester) async {
      repo.reply = 'Dark reply';
      await tester.pumpWidget(_app(repo, theme: AppTheme.dark));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Hi');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();
      final user =
          tester.widget<Container>(_bubbleOf('Hi')).decoration as BoxDecoration;
      final model = tester.widget<Container>(_bubbleOf('Dark reply')).decoration
          as BoxDecoration;
      expect(user.color, AppPalette.dark.primary);
      expect(model.color, AppPalette.dark.surface);
      expect(model.border!.top.color, AppPalette.dark.cardBorder);
      expect(find.text(_en.aiDisclaimer), findsOneWidget);
    });
  });

  group('Typing indicator + composer', () {
    testWidgets(
        'typing bubble has the localized label; send target is 48px, '
        'inactive while sending; field stays enabled', (tester) async {
      repo.gate = Completer<String>();
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();

      final send = find.ancestor(
          of: find.byTooltip(_en.send), matching: find.byType(IconButton));
      expect(tester.getSize(send).width,
          greaterThanOrEqualTo(AppDimensions.minTouchTarget));
      expect(tester.widget<IconButton>(send).onPressed, isNotNull);

      await tester.enterText(find.byType(TextField), 'Go');
      await tester.tap(send);
      await _pumpFrames(tester);

      expect(_typing(_en.aiTyping), findsOneWidget);
      expect(tester.widget<IconButton>(send).onPressed, isNull,
          reason: 'send never looks/acts active while sending');
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).enabled ?? true,
          isTrue);

      repo.gate!.complete('Done');
      await tester.pumpAndSettle();
      expect(_typing(_en.aiTyping), findsNothing);
      expect(tester.widget<IconButton>(send).onPressed, isNotNull);
    });

    testWidgets('typing dots are static under reduced motion', (tester) async {
      repo.gate = Completer<String>();
      await tester.pumpWidget(_app(repo, reduceMotion: true));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Go');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();
      await tester.pump();
      expect(_typing(_en.aiTyping), findsOneWidget);
      expect(
          find.descendant(
              of: _typing(_en.aiTyping),
              matching: find.byType(AnimatedBuilder)),
          findsNothing);
      // (The send spinner is an indeterminate progress indicator, so the
      // screen itself is not expected to settle while sending.)
      repo.gate!.complete('x');
      await tester.pumpAndSettle();
    });
  });

  group('Error banner', () {
    testWidgets(
        'visible with icon, Retry looks like an action, Dismiss is '
        '48px; existing behavior intact', (tester) async {
      repo.error = const AppException('raw', code: AppErrorCode.aiTimeout);
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();

      expect(find.text(_en.aiTimeout), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      final retry = find.widgetWithText(TextButton, _en.retry);
      expect(tester.getSize(retry).height,
          greaterThanOrEqualTo(AppDimensions.minTouchTarget));
      final dismiss = find.ancestor(
          of: find.byTooltip(_en.dismiss), matching: find.byType(IconButton));
      expect(tester.getSize(dismiss).width,
          greaterThanOrEqualTo(AppDimensions.minTouchTarget));
      // Failed bubble is outlined in the error color.
      final failed = tester.widget<Container>(_bubbleOf('Hello')).decoration
          as BoxDecoration;
      expect(failed.border!.top.color, AppPalette.light.error);

      repo.error = null;
      repo.reply = 'Back';
      await tester.tap(retry);
      await tester.pumpAndSettle();
      expect(repo.calls, 2);
      expect(find.text(_en.aiTimeout), findsNothing);
      expect(find.text('Hello', findRichText: true), findsOneWidget);
      expect(find.text('Back', findRichText: true), findsOneWidget);
    });
  });

  group('Arabic + responsive', () {
    testWidgets(
        'RTL: assistant bubble on the right, user on the left, '
        'Arabic labels', (tester) async {
      repo.reply = 'Sure';
      await tester.pumpWidget(_app(repo, locale: const Locale('ar')));
      await tester.pumpAndSettle();
      expect(find.text(_ar.aiSuggestionsTitle), findsOneWidget);
      expect(find.byTooltip(_ar.send), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'مرحبا');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();
      final width = tester.getSize(find.byType(AIChatScreen)).width;
      expect(tester.getRect(_bubbleOf('مرحبا')).left, lessThan(width / 2));
      expect(tester.getRect(_bubbleOf('Sure')).right, greaterThan(width / 2));
      final avatar = tester.getCenter(find.byIcon(Icons.auto_awesome));
      expect(avatar.dx, greaterThan(tester.getRect(_bubbleOf('Sure')).right),
          reason: 'avatar sits on the start (right) side in RTL');
    });

    testWidgets(
        'no overflow at 320px (EN/AR), incl. a long answer and '
        'the error banner', (tester) async {
      _useWidth(tester, 320);
      for (final locale in const [Locale('en'), Locale('ar')]) {
        repo = _FakeRepo()
          ..reply = 'A very long answer ' * 30 + '\n* bullet\n**bold** end';
        await tester.pumpWidget(_app(repo, locale: locale));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'welcome $locale');
        await tester.enterText(
            find.byType(TextField), 'A long question that wraps ' * 4);
        await tester.testTextInput.receiveAction(TextInputAction.send);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'chat $locale');

        repo.error = const AppException('x', code: AppErrorCode.aiRateLimited);
        await tester.enterText(find.byType(TextField), 'again');
        await tester.testTextInput.receiveAction(TextInputAction.send);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'error $locale');
        expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      }
    });

    testWidgets('wide window: conversation column is constrained',
        (tester) async {
      _useWidth(tester, 1400);
      repo.reply = 'Hi';
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Hey');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(ListView)).width, lessThan(800));
      expect(tester.getSize(find.byType(TextField)).width, lessThan(800));
    });
  });
}
