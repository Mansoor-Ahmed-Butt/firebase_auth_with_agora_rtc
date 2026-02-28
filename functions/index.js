const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Trigger: on new message document in chat_rooms/{chatRoomId}/messages/{messageId}
 * Reads the receiver ID and sends an FCM payload to the receiver's saved token
 */
exports.sendMessageNotification = functions.firestore
  .document("chat_rooms/{chatRoomId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const message = snap.data();
    if (!message) return null;

    // note: some code uses 'receriverID' (typo) so check multiple keys
    const receiverId =
      message.receriverID || message.receiverId || message.receiver || null;
    const senderId = message.senderID || message.senderId || "";
    const senderEmail = message.senderEmail || "";
    const messageContent = message.messageContent || "";

    if (!receiverId) return null;

    // get receiver's token from users collection
    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(receiverId)
      .get();
    if (!userDoc.exists) return null;
    const token = userDoc.get("fcmToken");
    if (!token) return null;

    const payload = {
      notification: {
        title: senderEmail ? `${senderEmail}` : "New message",
        body: messageContent,
      },
      data: {
        chatRoomId: context.params.chatRoomId,
        senderId: senderId,
        message: messageContent,
      },
    };

    try {
      const response = await admin.messaging().sendToDevice(token, payload);
      // handle invalid tokens
      const results = response.results || [];
      const promises = [];
      results.forEach((res, idx) => {
        if (res.error) {
          console.error("Error sending notification:", res.error);
          if (
            res.error.code === "messaging/registration-token-not-registered"
          ) {
            // remove stale token
            promises.push(
              admin
                .firestore()
                .collection("users")
                .doc(receiverId)
                .update({ fcmToken: admin.firestore.FieldValue.delete() }),
            );
          }
        }
      });
      return Promise.all(promises);
    } catch (err) {
      console.error("FCM send error", err);
      return null;
    }
  });
