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

class CallEvent {
  final String type;
  final Map<String, dynamic> data;

  CallEvent({required this.type, required this.data});
}

class CallService {
  final _callEventController = StreamController<CallEvent>.broadcast();
  final _callStateController = StreamController<CallState>.broadcast();

  // Initiate call
  Future<void> startCall({
    required String channelId,
    required List<String> participants,
    required bool isVideo,
  }) async {
    // In a real app, this would call API to initiate call request
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate the other party accepting the call
    await Future.delayed(const Duration(seconds: 1));

    // Update call status
    _callStateController.add(
      CallState(
        isInCall: true,
        isVideoEnabled: isVideo,
        channelId: channelId,
        participants: participants,
      ),
    );
  }

  // Toggle mute status
  Future<void> toggleMute(bool isMuted) async {
    // In a real app, this would call SDK to set microphone status
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Toggle speaker status
  Future<void> toggleSpeaker(bool isSpeakerOn) async {
    // In a real app, this would call SDK to set speaker status
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Switch camera
  Future<void> switchCamera() async {
    // In a real app, this would call SDK to switch front/back camera
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // End call
  Future<void> endCall() async {
    // In a real app, this would call API to end call
    await Future.delayed(const Duration(milliseconds: 100));

    _callStateController.add(CallState(isInCall: false, isVideoEnabled: false));
  }

  // Get call event stream
  Stream<CallEvent> get callEventStream => _callEventController.stream;

  // Get call state stream
  Stream<CallState> get callStateStream => _callStateController.stream;

  void dispose() {
    _callEventController.close();
    _callStateController.close();
  }
}
