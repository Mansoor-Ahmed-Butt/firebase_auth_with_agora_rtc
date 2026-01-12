import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_google_with_agora/modules/models/message.dart';

class ChatServices {
  // get instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user stream collection
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // get through each individual user
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  // send message to firestore
  Future<void> sendMessage(String receiverId, messageData) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
    MessageChat newMessage = MessageChat(
      messageContent: messageData,
      receriverID: receiverId,
      senderEmail: currentUserEmail,
      senderID: currentUserId,
      timestamp: timestamp.toDate(),
    );
    // construct chat room id for two users ( sorted to ensure uniqueness)
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    final String chatRoomId = ids.join('_');

    await _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').add(newMessage.toMap());
  }

  // get Messages
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    // construct chat room id for two users ( sorted to ensure uniqueness)
    List<String> ids = [userId, otherUserId];
    ids.sort();
    final String chatRoomId = ids.join('_');

    return _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').orderBy('timestamp', descending: false).snapshots();
  }
}
