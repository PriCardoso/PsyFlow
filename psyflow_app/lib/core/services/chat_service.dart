import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/chat_repository.dart';
import '../models/chat_message_model.dart';

class ChatService {
  final ChatRepository _repository;
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  ChatService({
    ChatRepository? repository,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _repository = repository ?? FirestoreChatRepository(),
        _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  Stream<List<ChatMessageModel>> getMessages(String otherUserId) {
    final chatId = _repository is FirestoreChatRepository
        ? ( _repository as FirestoreChatRepository).getOrCreateChatId(currentUserId, otherUserId) is Future<String>
            ? '' // This is a workaround since getOrCreateChatId is async
            : ( _repository as FirestoreChatRepository)._getChatId(currentUserId, otherUserId)
        : '';
    // We'll use a different approach - get chat ID synchronously
    final ids = [currentUserId, otherUserId]..sort();
    final syncChatId = 'chat_${ids[0]}_${ids[1]}';
    return _repository.getMessages(syncChatId);
  }

  Future<void> sendMessage({
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
    String? attachmentUrl,
    String? attachmentName,
  }) async {
    if (currentUserId.isEmpty) throw Exception('Usuário não autenticado');

    final message = ChatMessageModel(
      id: '',
      senderId: currentUserId,
      receiverId: receiverId,
      content: content,
      type: type,
      attachmentUrl: attachmentUrl,
      attachmentName: attachmentName,
      timestamp: DateTime.now(),
    );

    await _repository.sendMessage(message);
  }

  Future<void> markAsRead(String otherUserId) async {
    final ids = [currentUserId, otherUserId]..sort();
    final chatId = 'chat_${ids[0]}_${ids[1]}';
    await _repository.markAsRead(chatId, currentUserId);
  }

  Future<void> sendImageMessage({
    required String receiverId,
    required String imageUrl,
    required String imageName,
  }) async {
    await sendMessage(
      receiverId: receiverId,
      content: '📷 Imagem',
      type: MessageType.image,
      attachmentUrl: imageUrl,
      attachmentName: imageName,
    );
  }

  Future<void> sendDocumentMessage({
    required String receiverId,
    required String documentUrl,
    required String documentName,
  }) async {
    await sendMessage(
      receiverId: receiverId,
      content: '📄 $documentName',
      type: MessageType.document,
      attachmentUrl: documentUrl,
      attachmentName: documentName,
    );
  }

  Future<void> sendAudioMessage({
    required String receiverId,
    required String audioUrl,
    required String audioName,
  }) async {
    await sendMessage(
      receiverId: receiverId,
      content: '🎵 Áudio',
      type: MessageType.audio,
      attachmentUrl: audioUrl,
      attachmentName: audioName,
    );
  }

  Stream<int> getTotalUnreadCount() {
    return _repository.getUnreadCount(currentUserId);
  }

  Future<List<Map<String, dynamic>>> getRecentChats() async {
    if (currentUserId.isEmpty) return [];

    final snapshot = await _db
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .limit(20)
        .get();

    final chats = <Map<String, dynamic>>[];
    for (final doc in snapshot.docs) {
      final data = {'id': doc.id, ...doc.data()};
      final participants = List<String>.from(data['participants'] ?? []);
      final otherId = participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );

      if (otherId.isNotEmpty) {
        final userDoc = await _db.collection('users').doc(otherId).get();
        if (userDoc.exists) {
          data['otherUser'] = {'id': userDoc.id, ...userDoc.data()!};
          chats.add(data);
        }
      }
    }

    return chats;
  }

  Future<void> deleteMessage(String otherUserId, String messageId) async {
    final ids = [currentUserId, otherUserId]..sort();
    final chatId = 'chat_${ids[0]}_${ids[1]}';
    await _repository.deleteMessage(chatId, messageId);
  }
}

extension FirestoreChatRepositorySync on FirestoreChatRepository {
  String _getChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return 'chat_${ids[0]}_${ids[1]}';
  }
}