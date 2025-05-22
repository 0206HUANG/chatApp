import 'dart:async';

class CallState {
  final bool isInCall;
  final bool isVideoEnabled;
  final String? channelId;
  final List<String>? participants;

  CallState({
    required this.isInCall,
    required this.isVideoEnabled,
    this.channelId,
    this.participants,
  });
}

enum CallEvent { incoming, accepted, rejected, ended, missedCall }

class CallService {
  final StreamController<CallEvent> _callEventStreamController =
      StreamController<CallEvent>.broadcast();
  final StreamController<CallState> _callStateStreamController =
      StreamController<CallState>.broadcast();

  Stream<CallEvent> get callEventStream => _callEventStreamController.stream;
  Stream<CallState> get callStateStream => _callStateStreamController.stream;

  CallState _currentState = CallState(isInCall: false, isVideoEnabled: false);

  // 发起通话
  Future<void> startCall({
    required String channelId,
    required List<String> participants,
    required bool isVideo,
  }) async {
    // 在真实应用中，这里会调用API发起通话请求
    await Future.delayed(const Duration(seconds: 1));

    // 模拟对方接受通话
    _callEventStreamController.add(CallEvent.accepted);

    // 更新通话状态
    _currentState = CallState(
      isInCall: true,
      isVideoEnabled: isVideo,
      channelId: channelId,
      participants: participants,
    );
    _callStateStreamController.add(_currentState);
  }

  // 切换静音状态
  Future<void> toggleMute(bool isMuted) async {
    // 在真实应用中，这里会调用SDK设置麦克风状态
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // 切换扬声器状态
  Future<void> toggleSpeaker(bool isSpeakerOn) async {
    // 在真实应用中，这里会调用SDK设置扬声器状态
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // 切换摄像头
  Future<void> switchCamera() async {
    // 在真实应用中，这里会调用SDK切换前后摄像头
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // 结束通话
  Future<void> endCall() async {
    // 在真实应用中，这里会调用API结束通话
    await Future.delayed(const Duration(milliseconds: 500));

    // 发送通话结束事件
    _callEventStreamController.add(CallEvent.ended);

    // 更新通话状态
    _currentState = CallState(isInCall: false, isVideoEnabled: false);
    _callStateStreamController.add(_currentState);
  }

  void dispose() {
    _callEventStreamController.close();
    _callStateStreamController.close();
  }
}
