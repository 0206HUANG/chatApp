import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/services/call_service.dart';

class CallProvider extends ChangeNotifier {
  final CallService _callService = CallService();

  bool _isInCall = false;
  bool _isVideoEnabled = false;
  String? _currentChannelId;
  List<String>? _currentParticipants;
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  String? _error;

  bool get isInCall => _isInCall;
  bool get isVideoEnabled => _isVideoEnabled;
  String? get currentChannelId => _currentChannelId;
  List<String>? get currentParticipants => _currentParticipants;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  String? get error => _error;

  StreamSubscription? _callEventSubscription;
  StreamSubscription? _callStateSubscription;

  CallProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // 监听呼叫事件
      _callEventSubscription = _callService.callEventStream.listen((event) {
        // 处理呼叫事件
        notifyListeners();
      });

      // 监听呼叫状态
      _callStateSubscription = _callService.callStateStream.listen((state) {
        _isInCall = state.isInCall;
        _isVideoEnabled = state.isVideoEnabled;
        _currentChannelId = state.channelId;
        _currentParticipants = state.participants;

        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
    }
  }

  // 发起通话
  Future<void> startCall({
    required String channelId,
    required List<String> participants,
    required bool isVideo,
  }) async {
    try {
      await _callService.startCall(
        channelId: channelId,
        participants: participants,
        isVideo: isVideo,
      );

      _isMuted = false;
      _isSpeakerOn = true;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    notifyListeners();
  }

  // 切换静音状态
  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    await _callService.toggleMute(_isMuted);
    notifyListeners();
  }

  // 切换扬声器状态
  Future<void> toggleSpeaker() async {
    _isSpeakerOn = !_isSpeakerOn;
    await _callService.toggleSpeaker(_isSpeakerOn);
    notifyListeners();
  }

  // 切换摄像头
  Future<void> switchCamera() async {
    await _callService.switchCamera();
    notifyListeners();
  }

  // 结束通话
  Future<void> endCall() async {
    await _callService.endCall();
    notifyListeners();
  }

  @override
  void dispose() {
    _callEventSubscription?.cancel();
    _callStateSubscription?.cancel();
    _callService.dispose();
    super.dispose();
  }
}
