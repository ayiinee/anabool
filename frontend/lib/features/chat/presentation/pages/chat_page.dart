import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../controllers/chat_controller.dart';
import '../widgets/ana_header.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/cta_card_row.dart';
import '../widgets/scan_result_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatController _controller;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = ChatController.create();
    _controller.addListener(_scrollToLatestMessage);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_scrollToLatestMessage)
      ..dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToLatestMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text;
    if (text.trim().isEmpty) {
      return;
    }

    final sent = await _controller.sendMessage(text);
    if (sent) {
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final keyboardOpen = keyboardInset > 0;
    final bottomNavHeight =
        keyboardOpen ? 0.0 : AppBottomNavigation.heightWithInset(context);
    final composerBottom =
        keyboardOpen ? keyboardInset + 14 : bottomNavHeight + 16;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AnaboolColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                const AnaHeader(),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return _ChatConversation(
                        controller: _controller,
                        scrollController: _scrollController,
                        bottomPadding: bottomNavHeight + 104,
                      );
                    },
                  ),
                ),
              ],
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              left: 7,
              right: 7,
              bottom: composerBottom,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return _MessageComposer(
                    controller: _messageController,
                    enabled: !_controller.isSending,
                    sending: _controller.isSending,
                    onSend: _sendMessage,
                  );
                },
              ),
            ),
            if (!keyboardOpen)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AppBottomNavigation(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChatConversation extends StatelessWidget {
  const _ChatConversation({
    required this.controller,
    required this.scrollController,
    required this.bottomPadding,
  });

  final ChatController controller;
  final ScrollController scrollController;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.only(top: 18, bottom: bottomPadding),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text.rich(
            TextSpan(
              text: 'Start talking and ask for\nrecommendations from ',
              children: [
                TextSpan(
                  text: 'Ana',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            style: TextStyle(
              color: AnaboolColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 1.16,
            ),
          ),
        ),
        const SizedBox(height: 22),
        if (controller.errorMessage != null)
          _ErrorBanner(message: controller.errorMessage!),
        if (controller.isStarting && controller.messages.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 42),
            child: Center(
              child: CircularProgressIndicator(
                color: AnaboolColors.brown,
                strokeWidth: 2.6,
              ),
            ),
          ),
        for (final message in controller.messages) ...[
          if (message.hasCards)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: CtaCardRow(
                cards: message.cards,
                enabled: !controller.isSending,
                onSelected: controller.selectCtaCard,
              ),
            )
          else if (message.messageType == 'scan_result')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              child: ScanResultBubble(content: message.content),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              child: ChatBubble(message: message),
            ),
        ],
        if (controller.isSending)
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 7, 18, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _TypingBubble(),
            ),
          ),
      ],
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.enabled,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: enabled ? (_) => onSend() : null,
                decoration: const InputDecoration(
                  hintText: 'Enter your message...',
                  hintStyle: TextStyle(
                    color: Color(0xFFCFC4BE),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  isDense: true,
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  color: AnaboolColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 46,
              height: 46,
              child: IconButton.filled(
                tooltip: 'Kirim pesan',
                onPressed: enabled && !sending ? onSend : null,
                style: IconButton.styleFrom(
                  backgroundColor: AnaboolColors.brown,
                  disabledBackgroundColor: AnaboolColors.brownSoft,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                ),
                icon: sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.near_me_rounded, size: 24),
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AnaboolColors.border.withValues(alpha: 0.72),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AnaboolColors.brown,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AnaboolColors.brownDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Text(
          'Ana sedang mengetik...',
          style: TextStyle(
            color: AnaboolColors.brownDark,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
