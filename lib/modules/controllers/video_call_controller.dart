import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sign_in_google_with_agora/utils/constants.dart';

class VideoCallController extends GetxController {
  final channelControl = TextEditingController();
  RxBool validator = false.obs;
  // choose role: broadcaster or audience
  ClientRoleType roleOptions = ClientRoleType.clientRoleBroadcaster;

  // Agora related
  late final RtcEngine _engine;
  final RxnInt remoteUid = RxnInt();
  RxBool localUserJoined = false.obs;
  bool _initialized = false;
  // audio/video states
  RxBool isMuted = false.obs;
  RxBool isVideoEnabled = true.obs;

  // TODO: replace these with your actual Agora App ID / Token or supply them from secure config
  static const String appId = appIdd;
  static const String token = tokenn;

  //  @override
  // void onInit() {
  //   super.onInit();
  //   print("LoginController onInit");
  // }

  // @override
  // void onReady() {
  //   super.onReady();
  //   print("LoginController onReady");
  // }
  @override
  void onClose() {
    channelControl.dispose();
    _dispose();
    super.onClose();
  }

  Future<void> initAgora() async {
    // request permissions
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(appId: appId, channelProfile: ChannelProfileType.channelProfileLiveBroadcasting));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint('local user ${connection.localUid} joined');
          localUserJoined.value = true;
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          debugPrint('remote user $remoteUid joined');
          remoteUid != 0 ? this.remoteUid.value = remoteUid : null;
        },
        onUserOffline: (connection, remoteUid, reason) {
          debugPrint('remote user $remoteUid left channel');
          this.remoteUid.value = null;
        },
        onTokenPrivilegeWillExpire: (connection, token) {
          debugPrint('[onTokenPrivilegeWillExpire] token: $token');
        },
      ),
    );

    await _engine.setClientRole(role: roleOptions);
    await _engine.enableVideo();
    await _engine.startPreview();
    _initialized = true;
  }

  Future<void> joinChannel(String channelId) async {
    if (channelId.isEmpty) return;
    // initialize engine if not done
    try {
      if (!_initialized) {
        await initAgora();
      }
    } catch (_) {
      // engine might not have isInitialized on all versions; ignore and continue
    }

    await _engine.joinChannel(token: token, channelId: channelId, uid: 0, options: const ChannelMediaOptions());
  }

  Future<void> leaveChannel() async {
    try {
      await _engine.leaveChannel();
      localUserJoined.value = false;
      remoteUid.value = null;
    } catch (e) {
      debugPrint('leaveChannel error: $e');
    }
  }

  Future<void> _dispose() async {
    try {
      await _engine.leaveChannel();
      await _engine.release();
    } catch (_) {}
  }

  // mute/unmute local microphone
  Future<void> toggleMute() async {
    if (!_initialized) {
      debugPrint('toggleMute: engine not initialized');
      return;
    }
    try {
      final mute = !isMuted.value;
      await _engine.muteLocalAudioStream(mute);
      isMuted.value = mute;
    } catch (e) {
      debugPrint('toggleMute error: $e');
    }
  }

  // enable/disable local camera video (used as a simple "screen share / video toggle" placeholder)
  Future<void> toggleVideo() async {
    if (!_initialized) {
      debugPrint('toggleVideo: engine not initialized');
      return;
    }
    try {
      final enable = !isVideoEnabled.value;
      if (enable) {
        await _engine.enableLocalVideo(true);
        await _engine.startPreview();
      } else {
        await _engine.stopPreview();
        await _engine.enableLocalVideo(false);
      }
      isVideoEnabled.value = enable;
    } catch (e) {
      debugPrint('toggleVideo error: $e');
    }
  }

  // switch between front and back camera
  Future<void> switchCamera() async {
    if (!_initialized) {
      debugPrint('switchCamera: engine not initialized');
      return;
    }
    try {
      await _engine.switchCamera();
    } catch (e) {
      debugPrint('switchCamera error: $e');
    }
  }

  // Public getters for the view
  RtcEngine get engine => _engine;
  RxnInt get remote => remoteUid;
  RxBool get localJoined => localUserJoined;
  RxBool get muted => isMuted;
  RxBool get videoEnabled => isVideoEnabled;
}
