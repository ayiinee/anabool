import 'package:flutter/foundation.dart';

import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_cta_card.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/usecases/select_chat_cta_card.dart';
import '../../domain/usecases/send_chat_message.dart';
import '../../domain/usecases/start_chat_from_scan.dart';
import '../../../scan/domain/entities/scan_session.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    required StartChatFromScan startChatFromScan,
    required SendChatMessage sendChatMessage,
    required SelectChatCtaCard selectChatCtaCard,
  })  : _startChatFromScan = startChatFromScan,
        _sendChatMessage = sendChatMessage,
        _selectChatCtaCard = selectChatCtaCard;

  factory ChatController.create() {
    final datasource = DioChatRemoteDatasource();
    final repository = ChatRepositoryImpl(remoteDatasource: datasource);
    return ChatController(
      startChatFromScan: StartChatFromScan(repository),
      sendChatMessage: SendChatMessage(repository),
      selectChatCtaCard: SelectChatCtaCard(repository),
    );
  }

  final StartChatFromScan _startChatFromScan;
  final SendChatMessage _sendChatMessage;
  final SelectChatCtaCard _selectChatCtaCard;

  bool isStarting = false;
  bool isSending = false;
  String? errorMessage;
  ChatSession? session;
  Future<void>? _startChatRequest;

  List<ChatMessage> get messages => session?.messages ?? const [];

  Future<void> startChat({
    String? scanId,
    ScanSession? scanSession,
  }) {
    final currentRequest = _startChatRequest;
    if (currentRequest != null) {
      return currentRequest;
    }

    final request = _startChat(
      scanId: scanId,
      scanSession: scanSession,
    );
    _startChatRequest = request;
    return request.whenComplete(() {
      _startChatRequest = null;
    });
  }

  Future<void> _startChat({
    String? scanId,
    ScanSession? scanSession,
  }) async {
    isStarting = true;
    errorMessage = null;
    notifyListeners();

    try {
      session = await _startChatFromScan(
        scanId: scanId,
        scanSession: scanSession,
      );
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isStarting = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty || isSending) {
      return false;
    }

    isSending = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (session == null) {
        await startChat();
      }

      final currentSession = session;
      if (currentSession == null) {
        return false;
      }

      session = await _sendChatMessage(currentSession.id, trimmed);
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  Future<void> selectCtaCard(ChatCtaCard card) async {
    final currentSession = session;
    if (currentSession == null || isSending) {
      return;
    }

    isSending = true;
    errorMessage = null;
    notifyListeners();

    try {
      session = await _selectChatCtaCard(currentSession, card);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isSending = false;
      notifyListeners();
    }
  }
}
