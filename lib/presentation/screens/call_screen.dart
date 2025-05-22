import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/call_provider.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({Key? key}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  Widget build(BuildContext context) {
    final callProvider = Provider.of<CallProvider>(context);

    // 如果通话结束，返回上一页
    if (!callProvider.isInCall) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 视频区域
            if (callProvider.isVideoEnabled)
              Center(
                child: Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: Text(
                      '视频通话区域',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_circle,
                      size: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      callProvider.currentParticipants?.isNotEmpty ?? false
                          ? '与 ${callProvider.currentParticipants!.length} 人的语音通话'
                          : '语音通话',
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '正在通话中...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            // 控制区域
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: Column(
                children: [
                  // 通话时长
                  const Text('00:42', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 20),
                  // 控制按钮行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 静音按钮
                      FloatingActionButton(
                        heroTag: 'mute',
                        backgroundColor:
                            callProvider.isMuted ? Colors.red : Colors.white30,
                        onPressed: callProvider.toggleMute,
                        child: Icon(
                          callProvider.isMuted ? Icons.mic_off : Icons.mic,
                          color: Colors.white,
                        ),
                      ),
                      // 结束通话按钮
                      FloatingActionButton(
                        heroTag: 'end',
                        backgroundColor: Colors.red,
                        onPressed: callProvider.endCall,
                        child: const Icon(Icons.call_end),
                      ),
                      // 扬声器按钮
                      FloatingActionButton(
                        heroTag: 'speaker',
                        backgroundColor:
                            callProvider.isSpeakerOn
                                ? Colors.white
                                : Colors.white30,
                        onPressed: callProvider.toggleSpeaker,
                        child: Icon(
                          callProvider.isSpeakerOn
                              ? Icons.volume_up
                              : Icons.volume_down,
                          color:
                              callProvider.isSpeakerOn
                                  ? Colors.black
                                  : Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (callProvider.isVideoEnabled) ...[
                    const SizedBox(height: 16),
                    // 切换摄像头按钮
                    FloatingActionButton(
                      heroTag: 'camera',
                      mini: true,
                      backgroundColor: Colors.white30,
                      onPressed: callProvider.switchCamera,
                      child: const Icon(Icons.flip_camera_ios),
                    ),
                  ],
                ],
              ),
            ),
            // 返回按钮
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
