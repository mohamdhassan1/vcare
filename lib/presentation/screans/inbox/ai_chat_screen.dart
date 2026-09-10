import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/ai_message_model.dart';
import '../../../data/repositories/ai_chat_repository.dart';
import '../../../logic/blocs/ai_chat/ai_chat_bloc.dart';
import '../../../logic/blocs/ai_chat/ai_chat_event.dart';
import '../../../logic/blocs/ai_chat/ai_chat_state.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const List<String> _suggestions = [
    'Which doctor should I see for a headache?',
    'How can I book an appointment?',
    'What is a cardiologist?',
    'Help me find the right specialty',
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
            title: const Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.smart_toy_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                SizedBox(width: AppDimensions.spaceSm),
                Flexible(
                  child: Text(
                    'VCare AI Assistant',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          body: BlocBuilder<AIChatBloc, AIChatState>(
            builder: (context, state) {
              return Column(
                children: [
                  _buildDisclaimer(),
                  Expanded(
                    child: state.messages.isEmpty
                        ? _buildWelcome(context, state)
                        : _buildMessages(state),
                  ),
                  if (state.errorMessage != null)
                    _buildError(state.errorMessage!),
                  _buildInput(context, state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMd,
        vertical: 6,
      ),
      color: AppColors.surface,
      child: Text(
        'AI responses are for general information and do not replace professional medical advice.',
        style: AppTextStyles.caption,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMessages(AIChatState state) {
    final itemCount = state.messages.length + (state.isSending ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(AppDimensions.spaceLg),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == state.messages.length) {
          return _bubble(
            'Typing…',
            false,
            typing: true,
          );
        }

        final message = state.messages[index];

        return _bubble(
          message.text,
          message.role == AIMessageRole.user,
        );
      },
    );
  }

  Widget _buildWelcome(
    BuildContext context,
    AIChatState state,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spaceLg),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.smart_toy_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(
                  height: AppDimensions.spaceMd,
                ),
                Text(
                  'Hi! Ask me anything about VCare or general health questions.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: AppDimensions.spaceLg,
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _suggestions.map(
                    (suggestion) {
                      return ActionChip(
                        label: Text(
                          suggestion,
                          textAlign: TextAlign.center,
                        ),
                        onPressed: state.isSending
                            ? null
                            : () => _send(
                                  context,
                                  suggestion,
                                ),
                      );
                    },
                  ).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildError(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceLg,
        vertical: 4,
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildInput(
    BuildContext context,
    AIChatState state,
  ) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.spaceMd,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !state.isSending,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                decoration: const InputDecoration(
                  hintText: 'Ask the AI Assistant…',
                ),
                onSubmitted: state.isSending
                    ? null
                    : (text) => _send(
                          context,
                          text,
                        ),
              ),
            ),
            const SizedBox(
              width: AppDimensions.spaceSm,
            ),
            CircleAvatar(
              backgroundColor:
                  state.isSending ? AppColors.textHint : AppColors.primary,
              child: IconButton(
                icon: state.isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                onPressed: state.isSending
                    ? null
                    : () => _send(
                          context,
                          _controller.text,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(
    String text,
    bool fromUser, {
    bool typing = false,
  }) {
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 650,
        ),
        margin: const EdgeInsets.only(
          bottom: AppDimensions.spaceSm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: fromUser ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusLg,
          ),
        ),
        child: Text(
          text,
          softWrap: true,
          style: AppTextStyles.bodyMedium.copyWith(
            color: fromUser
                ? Colors.white
                : (typing ? AppColors.textHint : AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
