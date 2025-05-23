import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/call_provider.dart';

class CallScreen extends StatefulWidget {
  final String chatRoomId;

  const CallScreen({Key? key, required this.chatRoomId}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  void initState() {
    super.initState();
    // If call ended, go back to previous page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final callProvider = Provider.of<CallProvider>(context, listen: false);
      if (!callProvider.isInCall) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final callProvider = Provider.of<CallProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video area
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.grey),
                child: const Center(
                  child: Text(
                    'Video Call Area',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
            // Call information area
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      callProvider.isVideoEnabled
                          ? 'Video call with ${callProvider.currentParticipants!.length} people'
                          : 'Voice Call',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'In call...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    // Control area
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Call duration
                        const SizedBox(width: 48),
                        // Control button row
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Mute button
                              IconButton(
                                onPressed: () {
                                  callProvider.toggleMute();
                                },
                                icon: Icon(
                                  callProvider.isMuted
                                      ? Icons.mic_off
                                      : Icons.mic,
                                  color:
                                      callProvider.isMuted
                                          ? Colors.red
                                          : Colors.white,
                                ),
                                iconSize: 32,
                              ),
                              // End call button
                              IconButton(
                                onPressed: () {
                                  callProvider.endCall();
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(
                                  Icons.call_end,
                                  color: Colors.red,
                                ),
                                iconSize: 48,
                              ),
                              // Speaker button
                              IconButton(
                                onPressed: () {
                                  callProvider.toggleSpeaker();
                                },
                                icon: Icon(
                                  callProvider.isSpeakerOn
                                      ? Icons.volume_up
                                      : Icons.volume_down,
                                  color: Colors.white,
                                ),
                                iconSize: 32,
                              ),
                            ],
                          ),
                        ),
                        // Switch camera button
                        if (callProvider.isVideoEnabled)
                          IconButton(
                            onPressed: () {
                              callProvider.switchCamera();
                            },
                            icon: const Icon(
                              Icons.cameraswitch,
                              color: Colors.white,
                            ),
                            iconSize: 32,
                          )
                        else
                          const SizedBox(width: 48),
                        // Back button
                        const SizedBox(width: 48),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Back button
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
