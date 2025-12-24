import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_google_with_agora/modules/controllers/video_call_controller.dart';
import 'package:sign_in_google_with_agora/auth/firebase_auth/firebase_auth.dart';

class VideoCallScreen extends GetView<VideoCallController> {
  const VideoCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Home / Agora'),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                try {
                  await AuthService.instance.signOutWithGoogle();

                  if (!context.mounted) return;
                  context.go('/login');
                } catch (e) {
                  // ignore: avoid_print
                  print('Logout error: $e');
                }
              },
            ),
          ],
        ),
      ),

      // 👇 Bottom controls
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() {
              final muted = controller.muted.value;
              return IconButton(
                onPressed: controller.toggleMute,
                icon: Icon(muted ? Icons.mic_off : Icons.mic, color: Colors.white, size: 28),
              );
            }),
            const SizedBox(width: 24),
            Obx(() {
              final videoOn = controller.videoEnabled.value;
              return IconButton(
                onPressed: controller.toggleVideo,
                icon: Icon(videoOn ? Icons.videocam : Icons.videocam_off, color: Colors.white, size: 28),
              );
            }),
            const SizedBox(width: 24),
            IconButton(
              onPressed: controller.switchCamera,
              icon: const Icon(Icons.cameraswitch, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.blue.shade400, Colors.purple.shade400]),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // join / leave row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.channelControl,
                          decoration: const InputDecoration(hintText: 'Channel name', filled: true, fillColor: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          await controller.joinChannel(controller.channelControl.text.trim());
                        },
                        child: const Text('Join'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: controller.leaveChannel, child: const Text('Leave')),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // video area
                  Expanded(
                    child: Stack(
                      children: [
                        Center(
                          child: Obx(() {
                            final r = controller.remote.value;
                            if (r != null) {
                              return AgoraVideoView(
                                controller: VideoViewController.remote(
                                  rtcEngine: controller.engine,
                                  canvas: VideoCanvas(uid: r),
                                  connection: RtcConnection(channelId: controller.channelControl.text.trim()),
                                ),
                              );
                            }
                            return const Text('Waiting for remote user to join', style: TextStyle(color: Colors.white));
                          }),
                        ),

                        Positioned(
                          top: 12,
                          left: 12,
                          width: 120,
                          height: 160,
                          child: Container(
                            color: Colors.black45,
                            child: Obx(() {
                              return controller.localJoined.value
                                  ? AgoraVideoView(
                                      controller: VideoViewController(rtcEngine: controller.engine, canvas: const VideoCanvas(uid: 0)),
                                    )
                                  : const Center(child: CircularProgressIndicator());
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
