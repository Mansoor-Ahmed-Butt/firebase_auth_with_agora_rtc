This Cloud Function sends an FCM notification to the message receiver whenever a new message document
is created under `chat_rooms/{chatRoomId}/messages/{messageId}`.

Setup & deploy

1. Install dependencies:

```bash
cd functions
npm install
```

2. Deploy the function (Firebase CLI must be installed and authenticated):

```bash
firebase deploy --only functions:sendMessageNotification
```

Notes

- The function expects each user document in `users/{uid}` to contain `fcmToken`.
- `lib/notifications/notifications_service.dart` in the app saves the FCM token to that location.
- For testing locally, you can write a message document in Firestore and watch Cloud Function logs.
