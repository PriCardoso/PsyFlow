import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/chat_message_model.dart';
import '../../core/errors/app_exception.dart';

abstract class ChatRepository {
  Stream<List<ChatMessageModel>> getMessages(String chatId);
  Future<void> sendMessage(ChatMessageModel message);
  Future<void> markAsRead(String chatId, String userId);
  Future<String> getOrCreateChatId(String userId1, String userId2);
  Future<void> deleteMessage(String chatId, String messageId);
  Stream<int> getUnreadCount(String userId);
}

class FirestoreChatRepository implements ChatRepository {
  final FirebaseFirestore _db;

  FirestoreChatRepository({required FirebaseFirestore firestore})
      : _db = firestore;

  String _getChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return 'chat_${ids[0]}_${ids[1]}';
  }

  @override
  Stream<List<ChatMessageModel>> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = {'id': doc.id, ...doc.data()};
              return ChatMessageModel.fromMap(data, data['id'] as String);
            })
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp)));
  }

  @override
  Future<void> sendMessage(ChatMessageModel message) async {
    try {
      final chatId = _getChatId(message.senderId, message.receiverId);
      final batch = _db.batch();

      final messageRef = _db
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();

      batch.set(messageRef, message.toMap());

      final chatRef = _db.collection('chats').doc(chatId);
      batch.set(chatRef, {
        'participants': [message.senderId, message.receiverId],
        'lastMessage': message.content,
        'lastMessageTime': Timestamp.fromDate(message.timestamp),
        'lastMessageType': message.type.name,
        'unreadCount_${message.receiverId}': FieldValue.increment(1),
      }, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      throw AppException('Erro ao enviar mensagem: $e', originalError: e);
    }
  }

  @override
  Future<void> markAsRead(String chatId, String userId) async {
    try {
      final chatRef = _db.collection('chats').doc(chatId);
      await chatRef.update({
        'unreadCount_$userId': 0,
      });

      final messagesQuery = await _db
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      final batch = _db.batch();
      for (final doc in messagesQuery.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      throw AppException('Erro ao marcar como lida: $e', originalError: e);
    }
  }

  @override
  Future<String> getOrCreateChatId(String userId1, String userId2) async {
    return _getChatId(userId1, userId2);
  }

  @override
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _db
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      throw AppException('Erro ao excluir mensagem: $e', originalError: e);
    }
  }

  @override
  Stream<int> getUnreadCount(String userId) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        total += data['unreadCount_$userId'] as int? ?? 0;
      }
      return total;
    });
  }
}