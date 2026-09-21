import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n.dart';

/// UI-only chat. Text input works locally (appends to an in-memory
/// list) so the design is demonstrable — no networking layer, no
/// fake backend. Messages are lost on screen close, by design.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.doctorName});
  final String doctorName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final List<({String text, bool fromMe})> _messages = [
    (text: 'Hi Dr, how can I help you?', fromMe: false),
    (text: 'Good morning, how can I help you?', fromMe: true),
  ];

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _messages.add((text: text, fromMe: true)));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.doctorName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(AppDimensions.spaceLg),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[_messages.length - 1 - i];
                return Align(
                  alignment: m.fromMe
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
                  child: Container(
                    margin:
                        const EdgeInsets.only(bottom: AppDimensions.spaceSm),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: m.fromMe
                          ? context.palette.primary
                          : context.palette.surface,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLg),
                    ),
                    child: Text(m.text,
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: m.fromMe
                                ? context.palette.onPrimary
                                : context.palette.textPrimary)),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceMd),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration:
                          InputDecoration(hintText: context.l10n.typeAMessage),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceSm),
                  CircleAvatar(
                    backgroundColor: context.palette.primary,
                    child: IconButton(
                        icon: Icon(Icons.send_rounded,
                            color: context.palette.onPrimary, size: 20),
                        onPressed: _send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
