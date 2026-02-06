import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/themes/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../../../data/models/chat_model.dart';

/// Chat list page showing all conversations
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) {
      // Redirect to login if not logged in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      });
      return;
    }

    final chatProvider = context.read<ChatProvider>();
    await chatProvider.loadChats(authProvider.currentUser!.id);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    if (!authProvider.isLoggedIn) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (chatProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(chatProvider.error!, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadChats,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (chatProvider.chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada chat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mulai chat dengan penjual dari halaman produk',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadChats,
            child: ListView.separated(
              itemCount: chatProvider.chats.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final chat = chatProvider.chats[index];
                return _buildChatItem(context, chat, authProvider.currentUser!.id);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ChatModel chat, String currentUserId) {
    final otherName = chat.getOtherParticipantName(currentUserId);
    final unread = chat.getUnreadCount(currentUserId);
    final timeText = chat.lastMessageTime != null
        ? _formatTime(chat.lastMessageTime!)
        : '';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Text(
          otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              otherName,
              style: TextStyle(
                fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            timeText,
            style: TextStyle(
              fontSize: 12,
              color: unread > 0 ? AppColors.primary : Colors.grey[500],
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              chat.lastMessage ?? 'Mulai percakapan...',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: unread > 0 ? Colors.black87 : Colors.grey[600],
                fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          if (unread > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unread.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoutes.getChatDetailRoute(chat.id),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat.Hm().format(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Kemarin';
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat.E('id').format(dateTime);
    } else {
      return DateFormat('dd/MM/yy').format(dateTime);
    }
  }
}
