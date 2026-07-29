import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/chat_message_model.dart';
import '../../core/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService;

  ChatProvider({ChatService? chatService})
      : _chatService = chatService ?? ChatService();

  List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;
  String? _currentChatUserId;
  StreamSubscription? _messagesSubscription;
  int _unreadCount = 0;
  StreamSubscription? _unreadSubscription;

  List<ChatMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  void loadMessages(String otherUserId) {
    _cancelMessagesSubscription();
    _currentChatUserId = otherUserId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _messagesSubscription = _chatService.getMessages(otherUserId).listen(
        (messages) {
          _messages = messages;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _error = 'Erro ao carregar mensagens: $e';
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Erro ao iniciar listener: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage({
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
    String? attachmentUrl,
    String? attachmentName,
  }) async {
    try {
      await _chatService.sendMessage(
        receiverId: receiverId,
        content: content,
        type: type,
        attachmentUrl: attachmentUrl,
        attachmentName: attachmentName,
      );
    } catch (e) {
      _error = 'Erro ao enviar mensagem: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markAsRead(String otherUserId) async {
    try {
      await _chatService.markAsRead(otherUserId);
    } catch (e) {
      _error = 'Erro ao marcar como lida: $e';
      notifyListeners();
    }
  }

  void listenUnreadCount() {
    _unreadSubscription?.cancel();
    _unreadSubscription = _chatService.getTotalUnreadCount().listen(
      (count) {
        _unreadCount = count;
        notifyListeners();
      },
      onError: (e) {
        // Silently handle error
      },
    );
  }

  void _cancelMessagesSubscription() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
  }

  void clearMessages() {
    _messages = [];
    _currentChatUserId = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelMessagesSubscription();
    _unreadSubscription?.cancel();
    super.dispose();
  }
}