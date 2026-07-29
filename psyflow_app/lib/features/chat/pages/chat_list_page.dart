import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_dialog.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/services/chat_service.dart';
import '../../../models/user_model.dart';
import 'chat_detail_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
    context.read<ChatProvider>().listenUnreadCount();
  }

  Future<void> _loadChats() async {
    setState(() => _isLoading = true);
    try {
      _chats = await _chatService.getRecentChats();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar conversas: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 7) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}min';
    } else {
      return 'agora';
    }
  }

  String _getLastMessagePreview(Map<String, dynamic> chat) {
    final type = chat['lastMessageType'] ?? 'text';
    final content = chat['lastMessage'] ?? '';

    switch (type) {
      case 'image':
        return '📷 Imagem';
      case 'document':
        return '📄 ${chat['lastMessage']?.toString().replaceAll('📄 ', '') ?? 'Documento'}';
      case 'audio':
        return '🎵 Áudio';
      default:
        return content.length > 30 ? '${content.substring(0, 30)}...' : content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Conversas'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
            tooltip: 'Buscar conversas',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _chats.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadChats,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _chats.length,
                    itemBuilder: (context, index) {
                      final chat = _chats[index];
                      final otherUser = chat['otherUser'] as Map<String, dynamic>?;
                      if (otherUser == null) return const SizedBox.shrink();

                      final userId = otherUser['id'] as String;
                      final name = otherUser['full_name'] ?? otherUser['fullName'] ?? 'Usuário';
                      final photoUrl = otherUser['photo_url'] ?? otherUser['photoUrl'];
                      final role = otherUser['role'] as String? ?? 'patient';
                      final unreadCount = chat['unreadCount_${_chatService.currentUserId}'] as int? ?? 0;
                      final lastMessageTime = (chat['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now();

                      Color accentColor;
                      switch (role) {
                        case 'psychologist':
                        case 'professional':
                          accentColor = AppColors.psychologist;
                          break;
                        default:
                          accentColor = AppColors.patient;
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: accentColor.withAlpha(30),
                          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                          child: photoUrl == null
                              ? Text(
                                  name.split(' ').map((e) => e[0]).take(2).join().toUpperCase(),
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                )
                              : null,
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          _getLastMessagePreview(chat),
                          style: TextStyle(
                            color: unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                            fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatTime(lastMessageTime),
                              style: TextStyle(
                                fontSize: 11,
                                color: unreadCount > 0 ? AppColors.primary : AppColors.textMuted,
                                fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                            if (unreadCount > 0) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(minWidth: 20),
                                child: Text(
                                  unreadCount > 9 ? '9+' : '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailPage(
                                otherUserId: userId,
                                otherUserName: name,
                                otherUserPhotoUrl: photoUrl,
                                otherUserRole: role,
                                accentColor: accentColor,
                              ),
                            ),
                          ).then((_) => _loadChats());
                        },
                        onLongPress: () => _showChatOptions(chat, userId, name),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma conversa ainda',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Suas conversas com pacientes e profissionais aparecerão aqui',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showChatOptions(Map<String, dynamic> chat, String userId, String name) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              title: const Text('Excluir conversa', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteChat(chat['id'] as String, name);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined, color: AppColors.warning),
              title: const Text('Bloquear usuário'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement block user
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteChat(String chatId, String name) {
    AppDialog.confirm(
      context: context,
      title: 'Excluir conversa',
      message: 'Tem certeza que deseja excluir a conversa com $name? Esta ação não pode ser desfeita.',
      confirmText: 'Excluir',
      cancelText: 'Cancelar',
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        // TODO: Implement delete chat
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conversa excluída')),
        );
      }
    });
  }
}