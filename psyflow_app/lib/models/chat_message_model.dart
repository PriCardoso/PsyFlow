import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, document, audio }

class ChatMessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final String? attachmentUrl;
  final String? attachmentName;
  final DateTime timestamp;
  final bool read;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = MessageType.text,
    this.attachmentUrl,
    this.attachmentName,
    required this.timestamp,
    this.read = false,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime time;
    final ts = map['timestamp'];
    if (ts is Timestamp) {
      time = ts.toDate();
    } else if (ts is String) {
      time = DateTime.tryParse(ts) ?? DateTime.now();
    } else {
      time = DateTime.now();
    }

    final typeStr = map['type'] as String? ?? 'text';
    final parsedType = MessageType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => MessageType.text,
    );

    return ChatMessageModel(
      id: id,
      senderId: map['sender_id'] ?? '',
      receiverId: map['receiver_id'] ?? '',
      content: map['content'] ?? '',
      type: parsedType,
      attachmentUrl: map['attachment_url'],
      attachmentName: map['attachment_name'],
      timestamp: time,
      read: map['read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'type': type.name,
      'attachment_url': attachmentUrl,
      'attachment_name': attachmentName,
      'timestamp': Timestamp.fromDate(timestamp),
      'read': read,
    };
  }
}
