import 'package:flutter/foundation.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/repositories/chat_repository.dart';

/// Chat state provider
class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();

  List<ChatModel> _chats = [];
  List<ChatMessageModel> _currentMessages = [];
  ChatModel? _currentChat;
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  // Getters
  List<ChatModel> get chats => _chats;
  List<ChatMessageModel> get currentMessages => _currentMessages;
  ChatModel? get currentChat => _currentChat;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  /// Load all chats for user
  Future<void> loadChats(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _chats = await _chatRepository.getChatsForUser(userId);
      _unreadCount = await _chatRepository.getUnreadCount(userId);
    } catch (e) {
      _setError('Gagal memuat chat: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load messages for a specific chat
  Future<void> loadMessages(String chatId, String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _currentChat = await _chatRepository.getChatById(chatId);
      _currentMessages = await _chatRepository.getMessages(chatId);
      
      // Mark messages as read
      await _chatRepository.markAsRead(chatId, userId);
      
      // Refresh unread count
      _unreadCount = await _chatRepository.getUnreadCount(userId);
    } catch (e) {
      _setError('Gagal memuat pesan: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Start or open chat with a seller (for buyer)
  Future<ChatModel?> startChatWithSeller(String buyerId, String sellerId) async {
    _setLoading(true);
    _clearError();

    try {
      final chat = await _chatRepository.getOrCreateChat(buyerId, sellerId);
      _currentChat = chat;
      _currentMessages = await _chatRepository.getMessages(chat.id);
      
      // Refresh chat list
      await loadChats(buyerId);
      
      return chat;
    } catch (e) {
      _setError('Gagal memulai chat: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Send a message
  Future<bool> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    if (message.trim().isEmpty) return false;

    try {
      final newMessage = await _chatRepository.sendMessage(
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        message: message.trim(),
      );

      // Add to current messages
      _currentMessages = [..._currentMessages, newMessage];
      
      // Update current chat's last message
      if (_currentChat != null) {
        _currentChat = _currentChat!.copyWith(
          lastMessage: message.trim(),
          lastMessageTime: newMessage.createdAt,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Gagal mengirim pesan: ${e.toString()}');
      return false;
    }
  }

  /// Refresh unread count
  Future<void> refreshUnreadCount(String userId) async {
    try {
      _unreadCount = await _chatRepository.getUnreadCount(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing unread count: $e');
    }
  }

  /// Clear current chat
  void clearCurrentChat() {
    _currentChat = null;
    _currentMessages = [];
    notifyListeners();
  }

  /// Get other participant ID for current chat
  String? getOtherParticipantId(String currentUserId) {
    if (_currentChat == null) return null;
    return currentUserId == _currentChat!.buyerId
        ? _currentChat!.sellerId
        : _currentChat!.buyerId;
  }

  // Private helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
