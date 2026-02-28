import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_google_with_agora/services/chat_services.dart';

class ChatScreenController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final RxBool isLoading = false.obs;
  final ChatServices _chatServices = ChatServices();

  Stream<QuerySnapshot> getMessages(String receiverId) {
    final user = FirebaseAuth.instance.currentUser!;
    return _chatServices.getMessages(user.uid, receiverId);
  }

  Future<void> sendMessage(String receiverId) async {
    final text = messageController.text.trim();
    messageController.clear();
    if (text.isEmpty) return;
    try {
      await _chatServices.sendMessage(receiverId, text);
    } catch (e) {
      rethrow;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
