import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_google_with_agora/modules/views/bottom_navigation_screens/chat_screen/chat_screen_controller.dart';
import 'package:sign_in_google_with_agora/services/chat_services.dart';
import 'package:searchfield/searchfield.dart';

class ChatScreenView extends GetView<ChatScreenController> {
  ChatScreenView({super.key});

  final ChatServices _chatServices = ChatServices();

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Center(child: Text('You must be logged in to see chats'));
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Search bar for users by email/name
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _chatServices.getUserStream(),
            builder: (context, usersSnapshot) {
              if (usersSnapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }

              if (usersSnapshot.hasError) {
                return const SizedBox.shrink();
              }

              final users = (usersSnapshot.data ?? []).where((u) => u['uid'] != currentUserId).toList();

              if (users.isEmpty) {
                return const SizedBox.shrink();
              }

              final suggestions = users.map((user) {
                final String name = (user['name'] ?? '') as String;
                final String email = (user['email'] ?? '') as String;
                final String title = name.isNotEmpty ? name : email;

                return SearchFieldListItem<Map<String, dynamic>>(
                  email,
                  item: user,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(title),
                    subtitle: Text(email),
                  ),
                );
              }).toList();

              return SearchField<Map<String, dynamic>>(
                suggestions: suggestions,
                maxSuggestionBoxHeight: 300,
                suggestionsDecoration: SuggestionDecoration(borderRadius: BorderRadius.all(Radius.circular(8))),
                searchInputDecoration: SearchInputDecoration(
                  hintText: 'Search by email',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                ),
                suggestionState: Suggestion.expand,
                onSuggestionTap: (SearchFieldListItem<Map<String, dynamic>> item) {
                  final user = item.item ?? {};
                  final String receiverId = (user['uid'] ?? '') as String;
                  final String name = (user['name'] ?? '') as String;
                  final String email = (user['email'] ?? '') as String;
                  final String title = name.isNotEmpty ? name : email;

                  if (receiverId.isEmpty) return;

                  context.push('/chatDetailScreen', extra: {'receiverId': receiverId, 'receiverName': title});
                },
                onSearchTextChanged: (searchText) {
                  if (searchText.isEmpty) {
                    return suggestions;
                  }

                  final lower = searchText.toLowerCase();
                  return suggestions.where((s) {
                    final user = s.item ?? {};
                    final name = ((user['name'] ?? '') as String).toLowerCase();
                    final email = ((user['email'] ?? '') as String).toLowerCase();
                    return name.contains(lower) || email.contains(lower);
                  }).toList();
                },
              );
            },
          ),
          const SizedBox(height: 16),
          // Chat list (existing behaviour)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatServices.getUserChats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load chats'));
                }

                final docs = [...(snapshot.data?.docs ?? [])];

                // sort chats by last activity (newest first)
                docs.sort((a, b) {
                  final ad = a.data() as Map<String, dynamic>;
                  final bd = b.data() as Map<String, dynamic>;
                  final at = ad['lastMessageTimestamp'] as Timestamp?;
                  final bt = bd['lastMessageTimestamp'] as Timestamp?;

                  if (at == null && bt == null) return 0;
                  if (at == null) return 1; // chats without timestamp go last
                  if (bt == null) return -1;
                  return bt.compareTo(at); // newest first
                });

                if (docs.isEmpty) {
                  // No existing conversations yet – show info text
                  return const Center(child: Text('Start a chat by searching for a user above'));
                }

                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, _) => const Divider(color: Colors.grey, thickness: 0.5),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    final List<dynamic> participants = (data['participants'] ?? []) as List<dynamic>;
                    if (participants.length != 2) {
                      return const SizedBox.shrink();
                    }

                    final String otherUserId = participants.firstWhere((id) => id != currentUserId) as String;
                    final String lastMessage = (data['lastMessage'] ?? '') as String;

                    // unreadCounts may be missing or not a map on some documents
                    final dynamic unreadRaw = data['unreadCounts'];
                    final Map<String, dynamic> unreadCounts = unreadRaw is Map<String, dynamic> ? unreadRaw : <String, dynamic>{};

                    final dynamic rawUnread = unreadCounts[currentUserId];
                    int unreadCount;
                    if (rawUnread == null) {
                      unreadCount = 0;
                    } else if (rawUnread is int) {
                      unreadCount = rawUnread;
                    } else {
                      unreadCount = int.tryParse(rawUnread.toString()) ?? 0;
                    }

                    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return const ListTile(
                            leading: CircleAvatar(backgroundColor: Colors.grey),
                            title: Text('Loading...'),
                          );
                        }

                        final userData = userSnapshot.data?.data() ?? {};
                        final String name = (userData['name'] ?? '') as String;
                        final String email = (userData['email'] ?? '') as String;
                        final String title = name.isNotEmpty ? name : email;

                        return _chatTiles(
                          title: title,
                          subtitle: lastMessage.isNotEmpty ? lastMessage : email,
                          unreadCount: unreadCount,
                          onTap: () {
                            _chatServices.markChatAsRead(otherUserId);
                            context.push('/chatDetailScreen', extra: {'receiverId': otherUserId, 'receiverName': title});
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _chatTiles({required String title, required String subtitle, required int unreadCount, required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    child: Column(
      children: [
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(title),
          subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: unreadCount > 0
              ? Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                )
              : null,
        ),
      ],
    ),
  );
}
