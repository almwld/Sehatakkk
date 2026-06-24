import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

enum MessageType { text, image, file, audio }
enum MessageStatus { sending, sent, delivered, read, failed }

class ChatMessage {
  final String id, senderId, senderName, receiverId, content;
  final MessageType type;
  MessageStatus status;
  final DateTime timestamp;
  final String? fileUrl, fileName;
  ChatMessage({required this.id, required this.senderId, required this.senderName, required this.receiverId, required this.content, required this.type, this.status = MessageStatus.sending, required this.timestamp, this.fileUrl, this.fileName});
  Map<String, dynamic> toMap() => {'id': id, 'senderId': senderId, 'senderName': senderName, 'receiverId': receiverId, 'content': content, 'type': type.name, 'status': status.name, 'timestamp': Timestamp.fromDate(timestamp), 'fileUrl': fileUrl, 'fileName': fileName};
  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(id: map['id'] ?? '', senderId: map['senderId'] ?? '', senderName: map['senderName'] ?? '', receiverId: map['receiverId'] ?? '', content: map['content'] ?? '', type: MessageType.values.firstWhere((e) => e.name == map['type'], orElse: () => MessageType.text), status: MessageStatus.values.firstWhere((e) => e.name == map['status'], orElse: () => MessageStatus.sent), timestamp: (map['timestamp'] as Timestamp).toDate(), fileUrl: map['fileUrl'], fileName: map['fileName']);
}

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<void> sendMessage(String conversationId, String content) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final msg = ChatMessage(id: _uuid.v4(), senderId: user.uid, senderName: user.displayName ?? 'مستخدم', receiverId: '', content: content, type: MessageType.text, timestamp: DateTime.now());
    await _firestore.collection('conversations').doc(conversationId).collection('messages').doc(msg.id).set(msg.toMap());
    await _firestore.collection('conversations').doc(conversationId).update({'lastMessage': content, 'lastMessageTime': Timestamp.now()});
  }

  Stream<List<ChatMessage>> getMessages(String conversationId) {
    return _firestore.collection('conversations').doc(conversationId).collection('messages').orderBy('timestamp', descending: true).limit(100).snapshots().map((s) => s.docs.map((d) => ChatMessage.fromMap(d.data())).toList());
  }
}
