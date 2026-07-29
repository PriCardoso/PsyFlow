import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/services/chat_service.dart';
import '../../../models/chat_message_model.dart';

class ChatDetailPage extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  final String otherUserRole;
  final Color accentColor;

  const ChatDetailPage({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    required this.otherUserRole,
    required this.accentColor,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  StreamSubscription? _messagesSubscription;

  @override
  void initState() {
    super.initState();
    context.read<ChatProvider>().loadMessages(widget.otherUserId);
    _markAsRead();
  }

  Future<void> _markAsRead() async {
    await _chatService.markAsRead(widget.otherUserId);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messagesSubscription?.cancel();
    context.read<ChatProvider>().clearMessages();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    context.read<ChatProvider>().sendMessage(
      receiverId: widget.otherUserId,
      content: text,
    ).then((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: widget.accentColor.withAlpha(30),
              backgroundImage: widget.otherUserPhotoUrl != null
                  ? NetworkImage(widget.otherUserPhotoUrl!)
                  : null,
              child: widget.otherUserPhotoUrl == null
                  ? Text(
                      widget.otherUserName.split(' ').map((e) => e[0]).take(2).join().toUpperCase(),
                      style: TextStyle(
                        color: widget.accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.otherUserRole == 'patient' ? 'Paciente' : widget.otherUserRole,
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
            onPressed: _showOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, _) {
                final messages = provider.messages;

                if (provider.isLoading && messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (messages.isEmpty) {
                  return _buildEmptyState();
                }

                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;
                    final showTime = index == 0 ||
                        messages[index - 1].timestamp.difference(message.timestamp).inMinutes > 5;

                    return _MessageBubble(
                      message: message,
                      isMe: isMe,
                      showTime: showTime,
                      accentColor: widget.accentColor,
                      otherUserId: widget.otherUserId,
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
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
              color: widget.accentColor.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline_rounded, size: 40, color: widget.accentColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma mensagem ainda',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Envie a primeira mensagem para ${widget.otherUserName}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.surfaceVariant, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.add_rounded, color: AppColors.textSecondary, size: 24),
              onPressed: _showAttachmentOptions,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Digite uma mensagem...',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: widget.accentColor, width: 1.5),
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: widget.accentColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                onPressed: _sendMessage,
                tooltip: 'Enviar',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions() {
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
              leading: Icon(Icons.person_rounded, color: widget.accentColor),
              title: const Text('Ver perfil'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.call_rounded, color: AppColors.psychologist),
              title: const Text('Iniciar videochamada'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Video call
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.block_outlined, color: AppColors.warning),
              title: const Text('Bloquear'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Block
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              title: const Text('Excluir conversa', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteChat();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
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
              leading: Icon(Icons.photo_library_rounded, color: widget.accentColor),
              title: const Text('Foto/Vídeo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.insert_drive_file_rounded, color: widget.accentColor),
              title: const Text('Documento'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Pick document
              },
            ),
            ListTile(
              leading: Icon(Icons.mic_rounded, color: widget.accentColor),
              title: const Text('Gravar áudio'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Record audio
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    // TODO: Implement image picker
    // final ImagePicker picker = ImagePicker();
    // final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    // if (image != null) {
    //   // Upload to Firebase Storage
    //   // Send image message
    // }
  }

  void _confirmDeleteChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir conversa'),
        content: Text('Tem certeza que deseja excluir a conversa com ${widget.otherUserName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to chat list
              // TODO: Actually delete chat
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;
  final bool showTime;
  final Color accentColor;
  final String otherUserId;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showTime,
    required this.accentColor,
    required this.otherUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: accentColor.withAlpha(30),
              child: Icon(
                message.senderId == otherUserId ? Icons.person_rounded : Icons.psychology_rounded,
                size: 12,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (showTime)
                  Padding(
                    padding: EdgeInsets.only(
                      left: isMe ? 0 : 48,
                      right: isMe ? 48 : 0,
                      bottom: 4,
                    ),
                    child: Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? accentColor : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: _buildMessageContent(),
                ),
                if (message.type != MessageType.text && message.attachmentName != null)
                  Padding(
                    padding: EdgeInsets.only(
                      left: isMe ? 0 : 48,
                      right: isMe ? 48 : 0,
                      top: 2,
                    ),
                    child: Text(
                      message.attachmentName!,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: accentColor.withAlpha(30),
              child: const Icon(Icons.person_rounded, size: 12, color: AppColors.textPrimary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.attachmentUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  message.attachmentUrl!,
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 200,
                    height: 150,
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.broken_image_rounded, color: AppColors.textMuted),
                  ),
                ),
              ),
            if (message.content.isNotEmpty && message.content != '📷 Imagem') ...[
              const SizedBox(height: 8),
              Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        );
      case MessageType.document:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_drive_file_rounded,
              color: isMe ? Colors.white : accentColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.attachmentName ?? 'Documento',
                style: TextStyle(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      case MessageType.audio:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_circle_fill_rounded,
              color: isMe ? Colors.white : accentColor,
              size: 28,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.attachmentName ?? 'Áudio',
                style: TextStyle(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      default:
        return Text(
          message.content,
          style: TextStyle(
            color: isMe ? Colors.white : AppColors.textPrimary,
            fontSize: 14,
            height: 1.4,
          ),
        );
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}