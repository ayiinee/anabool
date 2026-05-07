import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../scan/domain/entities/scan_image_file.dart';
import '../../../scan/domain/entities/scan_session.dart';
import '../../domain/entities/chat_cta_card.dart';
import '../controllers/chat_controller.dart';
import 'chat_bubble.dart';
import 'cta_card_row.dart';
import 'error_banner.dart';
import 'initial_scan_message.dart';
import 'scan_result_bubble.dart';
import 'typing_bubble.dart';

class ChatConversation extends StatelessWidget {
  const ChatConversation({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.bottomPadding,
    required this.initialScanSession,
    required this.initialScanImageFile,
    required this.onCtaSelected,
  });

  final ChatController controller;
  final ScrollController scrollController;
  final double bottomPadding;
  final ScanSession? initialScanSession;
  final ScanImageFile? initialScanImageFile;
  final ValueChanged<ChatCtaCard> onCtaSelected;

  @override
  Widget build(BuildContext context) {
    final hasInitialScanMessage =
        initialScanSession != null && initialScanImageFile != null;

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.only(top: 18, bottom: bottomPadding),
      children: [
        const _ConversationTitle(),
        const SizedBox(height: 22),
        if (controller.errorMessage != null)
          ErrorBanner(message: controller.errorMessage!),
        if (controller.isStarting && controller.messages.isEmpty)
          const _StartingIndicator(),
        if (hasInitialScanMessage)
          InitialScanMessage(
            scanSession: initialScanSession!,
            imageFile: initialScanImageFile!,
          ),
        for (final message in controller.messages) ...[
          if (hasInitialScanMessage &&
              message.isUser &&
              message.messageType == 'scan_result')
            const SizedBox.shrink()
          else if (message.hasCards)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (message.content.trim().isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                    child: ChatBubble(message: message),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  child: CtaCardRow(
                    cards: message.cards,
                    enabled: !controller.isSending,
                    onSelected: onCtaSelected,
                  ),
                ),
              ],
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
              child: TypingBubble(),
            ),
          ),
      ],
    );
  }
}

class _ConversationTitle extends StatelessWidget {
  const _ConversationTitle();

  @override
  Widget build(BuildContext context) {
    return const Padding(
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
    );
  }
}

class _StartingIndicator extends StatelessWidget {
  const _StartingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 42),
      child: Center(
        child: CircularProgressIndicator(
          color: AnaboolColors.brown,
          strokeWidth: 2.6,
        ),
      ),
    );
  }
}
