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

    // add message to subcollection
    await _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').add(newMessage.toMap());

    // update chat room metadata (last message, timestamp, unread count for receiver)
    final chatRoomRef = _firestore.collection('chat_rooms').doc(chatRoomId);

    // ensure basic metadata exists
    await chatRoomRef.set({'participants': ids}, SetOptions(merge: true));

    // update last message info and increment receiver's unread count
    await chatRoomRef.set({
      'lastMessage': messageData,
      'lastMessageTimestamp': timestamp,
      'lastMessageSenderId': currentUserId,
      'unreadCounts': {receiverId: FieldValue.increment(1)},
    }, SetOptions(merge: true));
  }

  // get Messages
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    // construct chat room id for two users ( sorted to ensure uniqueness)
    List<String> ids = [userId, otherUserId];
    ids.sort();
    final String chatRoomId = ids.join('_');

    return _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').orderBy('timestamp', descending: false).snapshots();
  }

  // stream of chat rooms for current user ordered by last activity
  Stream<QuerySnapshot> getUserChats() {
    final String currentUserId = _auth.currentUser!.uid;
    // Only filter by participants; ordering will be done client-side
    return _firestore.collection('chat_rooms').where('participants', arrayContains: currentUserId).snapshots();
  }

  // mark messages as read by setting current user's unread count to 0
  Future<void> markChatAsRead(String otherUserId) async {
    final String currentUserId = _auth.currentUser!.uid;
    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    final String chatRoomId = ids.join('_');

    final chatRoomRef = _firestore.collection('chat_rooms').doc(chatRoomId);
    await chatRoomRef.set({
      'unreadCounts': {currentUserId: 0},
    }, SetOptions(merge: true));
  }
}
