import 'package:flutter/material.dart';

/// Renders one AI-chat message.
///
/// Gemini answers arrive as light Markdown (`**bold**`, `* bullets`,
/// `### headings`, `` `code` ``). Showing that raw makes answers hard to
/// read, so this widget converts the handful of constructs the model
/// actually uses into styled spans — no Markdown package needed, and
/// nothing is ever executed or fetched. Text stays selectable so users
/// can copy an answer.
///
/// Direction follows the message's own script (an English answer inside
/// the Arabic UI reads left-to-right, and vice-versa) instead of the
/// surrounding layout direction.
class AiMessageText extends StatelessWidget {
  const AiMessageText({
    super.key,
    required this.text,
    required this.style,
    this.selectable = true,
    this.format = true,
  });

  final String text;
  final TextStyle style;

  /// Model answers are selectable (copyable); user bubbles need not be.
  final bool selectable;

  /// User messages are shown verbatim; only model output is formatted.
  final bool format;

  @override
  Widget build(BuildContext context) {
    final direction = directionFor(text) ?? Directionality.of(context);
    final span = TextSpan(
      style: style,
      children: format ? parseLite(text, style) : [TextSpan(text: text)],
    );
    if (!selectable) {
      return Text.rich(span,
          textDirection: direction, textAlign: TextAlign.start);
    }
    return SelectableText.rich(span,
        textDirection: direction, textAlign: TextAlign.start);
  }

  static final RegExp _arabic = RegExp(r'[؀-ۿݐ-ݿ]');
  static final RegExp _latin = RegExp(r'[A-Za-z]');

  /// Direction of the first strongly-directional letter in [text], or
  /// null when there is none (numbers/punctuation only).
  static TextDirection? directionFor(String text) {
    final arabic = _arabic.firstMatch(text);
    final latin = _latin.firstMatch(text);
    if (arabic == null && latin == null) return null;
    if (arabic == null) return TextDirection.ltr;
    if (latin == null) return TextDirection.rtl;
    return arabic.start < latin.start ? TextDirection.rtl : TextDirection.ltr;
  }

  static final RegExp _heading = RegExp(r'^\s{0,3}#{1,6}\s+(.*)$');
  static final RegExp _bullet = RegExp(r'^(\s*)[*\-•]\s+(.*)$');
  static final RegExp _inline = RegExp(r'(\*\*.+?\*\*|`[^`]+`)');

  /// Markdown-lite → spans. Supported: `# heading` (bold line),
  /// `* item` / `- item` (→ "• item"), `**bold**`, `` `code` ``.
  /// Everything else is passed through untouched.
  static List<InlineSpan> parseLite(String text, TextStyle base) {
    final spans = <InlineSpan>[];
    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      var lineStyle = base;

      final heading = _heading.firstMatch(line);
      if (heading != null) {
        line = heading.group(1)!;
        lineStyle = base.copyWith(fontWeight: FontWeight.w700);
      } else {
        final bullet = _bullet.firstMatch(line);
        if (bullet != null) {
          line = '${bullet.group(1)}• ${bullet.group(2)}';
        }
      }

      spans.add(TextSpan(
          style: identical(lineStyle, base) ? null : lineStyle,
          children: _inlineSpans(line, lineStyle)));
      if (i < lines.length - 1) spans.add(const TextSpan(text: '\n'));
    }
    return spans;
  }

  static List<InlineSpan> _inlineSpans(String line, TextStyle base) {
    final spans = <InlineSpan>[];
    var index = 0;
    for (final match in _inline.allMatches(line)) {
      if (match.start > index) {
        spans.add(TextSpan(text: line.substring(index, match.start)));
      }
      final token = match.group(0)!;
      if (token.startsWith('**')) {
        spans.add(TextSpan(
            text: token.substring(2, token.length - 2),
            style: base.copyWith(fontWeight: FontWeight.w700)));
      } else {
        spans.add(TextSpan(
            text: token.substring(1, token.length - 1),
            style: base.copyWith(fontFamily: 'monospace')));
      }
      index = match.end;
    }
    if (index < line.length) spans.add(TextSpan(text: line.substring(index)));
    if (spans.isEmpty) spans.add(const TextSpan(text: ''));
    return spans;
  }
}
