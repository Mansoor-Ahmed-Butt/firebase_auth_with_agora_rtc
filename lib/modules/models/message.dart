class MessageChat {
  final String senderID;
  final String senderEmail;
  final String messageContent;
  final String receriverID;
  final DateTime timestamp;
  MessageChat({required this.senderID, required this.senderEmail, required this.messageContent, required this.timestamp, required this.receriverID});
  // convert to Map
  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'messageContent': messageContent,
      'timestamp': timestamp.toIso8601String(),
      'receriverID': receriverID,
    };
  }
}
