import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/ai_message_model.dart';
import '../../../data/repositories/ai_chat_repository.dart';
import '../../../l10n/l10n.dart';
import '../../../logic/blocs/ai_chat/ai_chat_bloc.dart';
import '../../../logic/blocs/ai_chat/ai_chat_event.dart';
import '../../../logic/blocs/ai_chat/ai_chat_state.dart';
import '../../widgets/ai_message_text.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/motion.dart';

/// Chat with the VCare AI Assistant. All Gemini behavior (history rules,
/// retry/dismiss, error mapping, key handling) lives in the bloc and the
/// data source and is untouched here — this file is presentation only.
class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Conversation column: a little wider than the app default so long
  /// answers keep a comfortable line length on desktop.
  static const double _chatMaxWidth = 720;

  /// Localized starter prompts shown on the empty state.
  List<String> _suggestions(AppLocalizations l10n) => [
        l10n.aiSuggestion1,
        l10n.aiSuggestion2,
        l10n.aiSuggestion3,
        l10n.aiSuggestion4,
      ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(BuildContext context, String text) {
    final message = text.trim();

    if (message.isEmpty) return;

    final bloc = context.read<AIChatBloc>();

    if (bloc.state.isSending) return;

    bloc.add(AIChatMessageSent(message));
    _controller.clear();

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: context.motion(const Duration(milliseconds: 250)),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (context) => AIChatBloc(
        context.read<AIChatRepository>(),
      ),
      child: BlocListener<AIChatBloc, AIChatState>(
        listenWhen: (previous, current) =>
            previous.messages.length != current.messages.length ||
            previous.isSending != current.isSending,
        listener: (_, __) {
          _scrollToBottom();
        },
        child: Scaffold(
          appBar: AppBar(
            // Identity lives in the welcome hero and the assistant
            // bubbles' avatar; the bar stays a plain, readable title.
            title: Semantics(
              header: true,
              child: Text(l10n.aiAssistantTitle,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
          body: BlocBuilder<AIChatBloc, AIChatState>(
            builder: (context, state) {
              return Column(
                children: [
                  _buildDisclaimer(context),
                  Expanded(
                    child: ContentConstraint(
                      maxWidth: _chatMaxWidth,
                      child: StateSwitcher(
                        child: state.messages.isEmpty
                            ? _buildWelcome(context, state)
                            : _buildMessages(state),
                      ),
                    ),
                  ),
                  _buildErrorSlot(context, state),
                  _buildInput(context, state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMd,
        vertical: AppDimensions.spaceSm,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded,
              size: AppDimensions.iconSm, color: palette.textSecondary),
          const SizedBox(width: AppDimensions.spaceXs + 2),
          Flexible(
            child: Text(
              context.l10n.aiDisclaimer,
              style: context.textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(AIChatState state) {
    final itemCount = state.messages.length + (state.isSending ? 1 : 0);

    return ListView.builder(
      key: const ValueKey('messages'),
      controller: _scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == state.messages.length) {
          return _typingBubble(context);
        }

        final message = state.messages[index];

        // New messages settle in; earlier items keep their state and
        // do not re-animate when the list grows.
        return FadeIn(
          offset: 6,
          child: _bubble(
            context,
            message.text,
            message.role == AIMessageRole.user,
            failed: message.failed,
          ),
        );
      },
    );
  }

  Widget _buildWelcome(
    BuildContext context,
    AIChatState state,
  ) {
    final l10n = context.l10n;
    final palette = context.palette;
    return LayoutBuilder(
      key: const ValueKey('welcome'),
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spaceLg),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - 2 * AppDimensions.spaceLg)
                    .clamp(0.0, double.infinity),
                maxWidth: 480,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeIn(
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                              color: palette.primaryLight,
                              shape: BoxShape.circle),
                          child: Icon(Icons.auto_awesome,
                              size: AppDimensions.iconXl - 12,
                              color: palette.primary),
                        ),
                        const SizedBox(height: AppDimensions.spaceMd),
                        // The bar already names the assistant; the hero
                        // carries the icon and the friendly opener.
                        Text(
                          l10n.aiWelcome,
                          style: AppTextStyles.bodyLarge
                              .copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceLg),
                  FadeIn(
                    delay: const Duration(milliseconds: 60),
                    child: Text(l10n.aiSuggestionsTitle,
                        style: context.textTheme.labelSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: AppDimensions.spaceSm),
                  Wrap(
                    spacing: AppDimensions.spaceSm,
                    runSpacing: AppDimensions.spaceSm,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final (i, suggestion) in _suggestions(l10n).indexed)
                        FadeIn(
                          delay: Duration(milliseconds: 90 + 40 * i),
                          child: _SuggestionChip(
                            label: suggestion,
                            enabled: !state.isSending,
                            onTap: () => _send(context, suggestion),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Persistent error banner: stays until the user retries, dismisses,
  /// or sends a new message (the bloc never clears it on its own). The
  /// message text comes from the mapped AppException — never a raw
  /// exception, URL or key. Grows in / out instead of popping.
  Widget _buildErrorSlot(BuildContext context, AIChatState state) {
    final child = state.error == null
        ? const SizedBox(width: double.infinity)
        : ContentConstraint(
            maxWidth: _chatMaxWidth,
            child: _buildError(context, state),
          );
    if (context.reduceMotion) return child;
    return AnimatedSize(
      duration: AppDurations.normal,
      curve: Curves.easeOut,
      alignment: Alignment.bottomCenter,
      child: child,
    );
  }

  Widget _buildError(BuildContext context, AIChatState state) {
    final bloc = context.read<AIChatBloc>();
    final l10n = context.l10n;
    final palette = context.palette;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(AppDimensions.spaceMd, 0,
            AppDimensions.spaceMd, AppDimensions.spaceSm),
        padding: const EdgeInsetsDirectional.fromSTEB(
            AppDimensions.spaceMd,
            AppDimensions.spaceSm,
            AppDimensions.spaceXs,
            AppDimensions.spaceSm),
        decoration: BoxDecoration(
          // Stronger tint + hairline than a plain 8% wash so it stays
          // visible on dark surfaces too.
          color: palette.error.withValues(alpha: 0.12),
          border: Border.all(color: palette.error.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        // Message row, then the action on its own line so a long
        // localized label never squeezes the text on narrow screens.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline_rounded,
                    size: AppDimensions.iconMd, color: palette.error),
                const SizedBox(width: AppDimensions.spaceSm),
                Expanded(
                  child: Text(
                    context.errorText(state.error!),
                    style: context.textTheme.bodySmall!
                        .copyWith(color: palette.textPrimary),
                  ),
                ),
                IconButton(
                  tooltip: l10n.dismiss,
                  constraints: const BoxConstraints(
                      minWidth: AppDimensions.minTouchTarget,
                      minHeight: AppDimensions.minTouchTarget),
                  icon: Icon(Icons.close_rounded,
                      size: AppDimensions.iconMd, color: palette.textSecondary),
                  onPressed: () => bloc.add(const AIChatErrorDismissed()),
                ),
              ],
            ),
            if (state.failedMessage != null)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                // An action, not a warning: refresh icon + brand color.
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                      minimumSize: const Size(0, AppDimensions.minTouchTarget),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spaceSm + 2)),
                  onPressed: state.isSending
                      ? null
                      : () => bloc.add(const AIChatRetryRequested()),
                  icon: const Icon(Icons.refresh_rounded,
                      size: AppDimensions.iconMd),
                  label: Text(l10n.retry),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
    BuildContext context,
    AIChatState state,
  ) {
    final l10n = context.l10n;
    final palette = context.palette;
    return Material(
      color: palette.background,
      shape: Border(top: BorderSide(color: palette.divider)),
      child: SafeArea(
        top: false,
        child: ContentConstraint(
          maxWidth: _chatMaxWidth,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppDimensions.spaceMd,
                AppDimensions.spaceSm,
                AppDimensions.spaceMd,
                AppDimensions.spaceSm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    // Stays enabled while a reply is generating so the
                    // keyboard does not collapse on every send; sending
                    // itself is blocked by _send() and the disabled button
                    // until the reply lands.
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: l10n.aiInputHint,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spaceMd,
                          vertical: AppDimensions.spaceSm + 4),
                    ),
                    onSubmitted:
                        state.isSending ? null : (text) => _send(context, text),
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceSm),
                // 48px filled send target; while sending it is disabled
                // and shows progress (never looks tappable).
                AnimatedContainer(
                  duration: context.motion(AppDurations.fast),
                  width: AppDimensions.minTouchTarget,
                  height: AppDimensions.minTouchTarget,
                  decoration: BoxDecoration(
                    color:
                        state.isSending ? palette.inputFill : palette.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    tooltip: l10n.send,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                        minWidth: AppDimensions.minTouchTarget,
                        minHeight: AppDimensions.minTouchTarget),
                    icon: AnimatedSwitcher(
                      duration: context.motion(AppDurations.fast),
                      child: state.isSending
                          ? SizedBox(
                              key: const ValueKey('sending'),
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: palette.textSecondary,
                                semanticsLabel: l10n.loading,
                              ),
                            )
                          : Icon(
                              Icons.send_rounded,
                              key: const ValueKey('send'),
                              color: palette.onPrimary,
                              size: AppDimensions.iconMd,
                            ),
                    ),
                    onPressed: state.isSending
                        ? null
                        : () => _send(context, _controller.text),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// "Assistant is typing" placeholder shown while a reply is pending.
  /// Visual: three pulsing dots in an assistant bubble; screen readers
  /// get the localized label.
  Widget _typingBubble(BuildContext context) {
    return _bubbleShell(
      context,
      fromUser: false,
      child: Semantics(
        label: context.l10n.aiTyping,
        liveRegion: true,
        child: ExcludeSemantics(
          child: _TypingDots(color: context.palette.textHint),
        ),
      ),
    );
  }

  Widget _bubble(
    BuildContext context,
    String text,
    bool fromUser, {
    bool failed = false,
  }) {
    final palette = context.palette;
    return _bubbleShell(
      context,
      fromUser: fromUser,
      failed: failed,
      // Model answers are formatted (Markdown-lite) and selectable so
      // they can be copied; user text is shown verbatim. Each bubble
      // takes its direction from its own script, so an English answer
      // in the Arabic UI (or vice-versa) still reads correctly.
      child: AiMessageText(
        text: text,
        format: !fromUser,
        selectable: !fromUser,
        style: AppTextStyles.bodyMedium.copyWith(
          color: fromUser ? palette.onPrimary : palette.textPrimary,
        ),
      ),
    );
  }

  /// Bubble chrome. Beyond color, the two sides differ by placement
  /// (user = end, assistant = start), by the assistant avatar and by the
  /// flattened "tail" corner — so the speaker is clear in any theme.
  Widget _bubbleShell(
    BuildContext context, {
    required bool fromUser,
    required Widget child,
    bool failed = false,
  }) {
    final palette = context.palette;
    final l10n = context.l10n;
    const tail = Radius.circular(AppDimensions.radiusXs);
    const round = Radius.circular(AppDimensions.radiusLg);
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 560),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMd - 2,
        vertical: AppDimensions.spaceSm + 2,
      ),
      decoration: BoxDecoration(
        // A failed (unanswered) user message is dimmed and outlined
        // so it's clearly not a delivered turn.
        color: fromUser
            ? (failed
                ? palette.primary.withValues(alpha: 0.5)
                : palette.primary)
            : palette.surface,
        border: Border.all(
            color: failed ? palette.error : palette.cardBorder,
            width: failed ? 1.5 : 1),
        borderRadius: BorderRadiusDirectional.only(
          topStart: round,
          topEnd: round,
          bottomStart: fromUser ? round : tail,
          bottomEnd: fromUser ? tail : round,
        ),
      ),
      child: child,
    );
    return Semantics(
      label: fromUser ? l10n.you : l10n.navAiAssistant,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.spaceSm + 2),
        child: Row(
          mainAxisAlignment:
              fromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!fromUser) ...[
              ExcludeSemantics(
                child: Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                      color: palette.primaryLight, shape: BoxShape.circle),
                  child: Icon(Icons.auto_awesome,
                      size: AppDimensions.iconSm, color: palette.primary),
                ),
              ),
              const SizedBox(width: AppDimensions.spaceSm),
            ],
            Flexible(child: bubble),
          ],
        ),
      ),
    );
  }
}

/// Starter prompt: a Material action chip with a 48px tap target,
/// disabled (not just dimmed) while a reply is pending.
class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip(
      {required this.label, required this.enabled, required this.onTap});

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ActionChip(
      avatar: Icon(Icons.auto_awesome_outlined,
          size: AppDimensions.iconSm,
          color: enabled ? palette.primary : palette.textHint),
      label: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
      labelStyle: AppTextStyles.bodySmall
          .copyWith(color: enabled ? palette.textPrimary : palette.textHint),
      backgroundColor: palette.surface,
      side: BorderSide(color: palette.cardBorder),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      onPressed: enabled ? onTap : null,
    );
  }
}

/// Three dots that pulse in sequence. Purely decorative — the parent
/// supplies the accessible label. Static under reduced motion.
class _TypingDots extends StatefulWidget {
  const _TypingDots({required this.color});

  final Color color;

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(double opacity) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: widget.color, shape: BoxShape.circle),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) {
      _controller.stop();
      return SizedBox(
        height: 20,
        child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [_dot(1), _dot(0.6), _dot(0.3)]),
      );
    }
    if (!_controller.isAnimating) _controller.repeat();
    return SizedBox(
      height: 20,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              // Each dot peaks a third of a cycle after the previous one.
              final phase = (_controller.value - i / 3) % 1.0;
              return _dot(0.3 + 0.7 * (1 - (phase * 2 - 1).abs()));
            }),
          );
        },
      ),
    );
  }
}
