import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LiveScreen extends StatefulWidget {
  final String channelName;
  final bool isBroadcaster; // True for streamer, False for audience

  const LiveScreen({super.key, required this.channelName, required this.isBroadcaster});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // 1. Request permissions
    await [Permission.microphone, Permission.camera].request();

    // 2. Create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: "YOUR_APP_ID_HERE", // Get from Agora Console
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    // 3. Set up event handlers
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() { _localUserJoined = true; });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() { _remoteUid = remoteUid; });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() { _remoteUid = null; });
        },
      ),
    );

    // 4. Set Client Role
    await _engine.setClientRole(
      role: widget.isBroadcaster ? ClientRoleType.clientRoleBroadcaster : ClientRoleType.clientRoleAudience,
    );

    await _engine.enableVideo();
    await _engine.startPreview();

    // 5. Join Channel
    await _engine.joinChannel(
      token: "YOUR_TEMP_TOKEN", // Use "" for testing if token is disabled
      channelId: widget.channelName,
      uid: 0, // 0 allows Agora to assign a random UID
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live: ${widget.channelName}')),
      body: Stack(
        children: [
          Center(child: _remoteVideo()), // Remote user view
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100, height: 150,
              child: Center(child: _localUserJoined ? AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ) : const CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      return const Text('Waiting for a broadcaster...', textAlign: TextAlign.center);
    }
  }
}
