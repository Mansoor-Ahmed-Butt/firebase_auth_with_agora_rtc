import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_google_with_agora/services/chat_services.dart';

class ChatDetailScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatDetailScreen({super.key, required this.receiverId, required this.receiverName});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatServices _chatServices = ChatServices();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('You must be logged in to chat.')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatServices.getMessages(currentUser.uid, widget.receiverId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load messages'));
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(child: Text('Say hi and start the conversation!'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final bool isMe = data['senderID'] == currentUser.uid;
                    final String message = (data['messageContent'] ?? '') as String;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(color: isMe ? Colors.blueAccent : Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
                        child: Text(message, style: TextStyle(color: isMe ? Colors.white : Colors.black)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(hintText: 'Type a message', border: OutlineInputBorder()),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      await _chatServices.sendMessage(widget.receiverId, text);
      _messageController.clear();
    } catch (e) {
      // You can show a snackbar or dialog here if you want
    }
  }
}
