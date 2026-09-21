// Phase 4 — AI answer rendering: Markdown-lite formatting and
// per-message text direction (Arabic answer in the English UI and
// vice-versa).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vcare/presentation/widgets/ai_message_text.dart';

String _plain(List<InlineSpan> spans) {
  final buffer = StringBuffer();
  for (final span in spans) {
    buffer.write((span as TextSpan).toPlainText());
  }
  return buffer.toString();
}

/// Every leaf TextSpan, depth-first (parseLite emits one line span per
/// line, with the inline pieces as children).
Iterable<TextSpan> _leaves(List<InlineSpan> spans) sync* {
  for (final span in spans) {
    final s = span as TextSpan;
    if (s.children == null || s.children!.isEmpty) {
      yield s;
    } else {
      yield* _leaves(s.children!);
    }
  }
}

void main() {
  const base = TextStyle(fontSize: 14);

  group('AiMessageText.directionFor', () {
    test('Arabic → rtl, Latin → ltr, neither → null', () {
      expect(AiMessageText.directionFor('مرحبا'), TextDirection.rtl);
      expect(AiMessageText.directionFor('Hello'), TextDirection.ltr);
      expect(AiMessageText.directionFor('123 !?'), isNull);
      expect(AiMessageText.directionFor(''), isNull);
    });

    test('mixed text follows the first strong letter', () {
      expect(AiMessageText.directionFor('VCare هو تطبيق'), TextDirection.ltr);
      expect(AiMessageText.directionFor('تطبيق VCare'), TextDirection.rtl);
      expect(AiMessageText.directionFor('1. صداع'), TextDirection.rtl);
    });
  });

  group('AiMessageText.parseLite', () {
    test('strips bold/code markers and styles them', () {
      final spans = AiMessageText.parseLite('See **a doctor** for `x`.', base);
      expect(_plain(spans), 'See a doctor for x.');
      final bold = _leaves(spans).firstWhere((s) => s.text == 'a doctor');
      expect(bold.style?.fontWeight, FontWeight.w700);
      final code = _leaves(spans).firstWhere((s) => s.text == 'x');
      expect(code.style?.fontFamily, 'monospace');
    });

    test('headings become bold lines, bullets become •', () {
      final spans = AiMessageText.parseLite(
          '## Tips\n* Rest\n- Drink water\n  * nested', base);
      expect(_plain(spans), 'Tips\n• Rest\n• Drink water\n  • nested');
      expect((spans.first as TextSpan).style?.fontWeight, FontWeight.w700);
      // Bullet lines keep the base weight.
      expect((spans[2] as TextSpan).style, isNull);
    });

    test('plain, multiline and Arabic text pass through untouched', () {
      const text = 'سطر أول\n\nسطر ثالث: 2 * 3 = 6';
      expect(_plain(AiMessageText.parseLite(text, base)), text);
      expect(_plain(AiMessageText.parseLite('', base)), '');
      // Unbalanced markers are left as-is rather than eaten.
      expect(_plain(AiMessageText.parseLite('a ** b', base)), 'a ** b');
    });
  });

  group('AiMessageText widget', () {
    Widget host(Widget child, TextDirection dir) => MaterialApp(
          home:
              Directionality(textDirection: dir, child: Scaffold(body: child)),
        );

    testWidgets('an Arabic answer is rtl even inside an ltr layout',
        (tester) async {
      await tester.pumpWidget(host(
          const AiMessageText(text: 'مرحبا بك', style: base),
          TextDirection.ltr));
      final rich = tester.widget<SelectableText>(find.byType(SelectableText));
      expect(rich.textDirection, TextDirection.rtl);
      expect(rich.textAlign, TextAlign.start);
    });

    testWidgets('an English answer is ltr inside an rtl layout',
        (tester) async {
      await tester.pumpWidget(host(
          const AiMessageText(text: 'Hello there', style: base),
          TextDirection.rtl));
      final rich = tester.widget<SelectableText>(find.byType(SelectableText));
      expect(rich.textDirection, TextDirection.ltr);
    });

    testWidgets('neutral text inherits the layout direction', (tester) async {
      await tester.pumpWidget(host(
          const AiMessageText(text: '42', style: base), TextDirection.rtl));
      final rich = tester.widget<SelectableText>(find.byType(SelectableText));
      expect(rich.textDirection, TextDirection.rtl);
    });

    testWidgets('user bubbles are verbatim and not selectable', (tester) async {
      await tester.pumpWidget(host(
          const AiMessageText(
              text: '**raw**', style: base, format: false, selectable: false),
          TextDirection.ltr));
      expect(find.byType(SelectableText), findsNothing);
      expect(find.text('**raw**', findRichText: true), findsOneWidget);
    });
  });
}
