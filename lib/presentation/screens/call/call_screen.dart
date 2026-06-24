import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/call_service.dart';

class CallScreen extends StatefulWidget {
  final String callId;
  final String? receiverName;
  final bool isVideoCall;
  final bool isIncoming;

  const CallScreen({
    Key? key,
    required this.callId,
    this.receiverName,
    this.isVideoCall = true,
    this.isIncoming = false,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallService _callService = CallService();
  CallState _callState = CallState.connecting;
  Timer? _callTimer;
  int _callDuration = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _callService.startCall('receiverId', 'receiverName', null, CallType.video);
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _callDuration++));
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _callService.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam, size: 80, color: Colors.white54),
            const SizedBox(height: 24),
            Text(
              _callState == CallState.inProgress ? 'جاري المكالمة' : 'جاري الاتصال...',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
