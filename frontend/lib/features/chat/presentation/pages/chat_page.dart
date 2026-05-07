import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/route_constants.dart';
import '../controllers/chat_controller.dart';
import '../../domain/entities/chat_cta_card.dart';
import '../../../scan/domain/entities/scan_image_file.dart';
import '../../../scan/domain/entities/scan_session.dart';
import '../widgets/ana_header.dart';
import '../widgets/chat_conversation.dart';
import '../widgets/message_composer.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    this.scanId,
    this.initialScanSession,
    this.initialScanImageFile,
    super.key,
  });

  final String? scanId;
  final ScanSession? initialScanSession;
  final ScanImageFile? initialScanImageFile;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class ChatPageArguments {
  const ChatPageArguments({
    required this.scanId,
    this.scanSession,
    this.imageFile,
  });

  final String scanId;
  final ScanSession? scanSession;
  final ScanImageFile? imageFile;
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
    _controller.startChat(
      scanId: widget.scanId,
      scanSession: widget.initialScanSession,
    );
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

  Future<void> _handleCtaSelected(ChatCtaCard card) async {
    if (card.cardType.trim().toLowerCase() == 'pickup') {
      Navigator.of(context).pushNamed(RouteConstants.pickup);
      return;
    }

    if (card.opensRoute) {
      _openCtaRoute(card);
      return;
    }

    await _controller.selectCtaCard(card);
  }

  void _openCtaRoute(ChatCtaCard card) {
    final contentId = _contentIdFromCta(card);
    if (contentId == null || contentId.isEmpty) {
      return;
    }

    Navigator.of(context).pushNamed(
      RouteConstants.educationDetail,
      arguments: contentId,
    );
  }

  String? _contentIdFromCta(ChatCtaCard card) {
    final rawContentId =
        card.payload['content_id'] ?? card.payload['module_id'];
    if (rawContentId is String && rawContentId.trim().isNotEmpty) {
      return rawContentId.trim();
    }

    final targetRoute = card.targetRoute?.trim();
    if (targetRoute == null || targetRoute.isEmpty) {
      return null;
    }

    final mappedContentId = {
      '/modules/waste-processing':
          'module_7_limbah_menjadi_pupuk_circular_economy',
      '/modules/environment-sanitation':
          'module_4_protokol_aman_membersihkan_membuang_kotoran_kucing',
      '/modules/cleanliness-health':
          'module_5_hygiene_measures_mencegah_toxoplasmosis',
    }[targetRoute];
    if (mappedContentId != null) {
      return mappedContentId;
    }

    const modulePrefix = '/modules/';
    if (targetRoute.startsWith(modulePrefix)) {
      return targetRoute.substring(modulePrefix.length);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final keyboardOpen = keyboardInset > 0;
    final bottomInset = mediaQuery.padding.bottom;
    final composerBottom = keyboardOpen ? keyboardInset + 14 : bottomInset + 14;
    final conversationBottomPadding = composerBottom + 76;

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
                      return ChatConversation(
                        controller: _controller,
                        scrollController: _scrollController,
                        bottomPadding: conversationBottomPadding,
                        initialScanSession: widget.initialScanSession,
                        initialScanImageFile: widget.initialScanImageFile,
                        onCtaSelected: _handleCtaSelected,
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
                  return MessageComposer(
                    controller: _messageController,
                    enabled: !_controller.isSending,
                    sending: _controller.isSending,
                    onSend: _sendMessage,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
