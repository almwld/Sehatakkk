import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import '../../../core/services/call_service.dart';

class CallScreen extends StatefulWidget {
  final String roomName;
  final String? displayName;

  const CallScreen({
    Key? key,
    required this.roomName,
    this.displayName,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallService _callService = CallService();
  bool _isConnecting = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _joinMeeting();
  }

  Future<void> _joinMeeting() async {
    try {
      await _callService.joinMeeting(
        widget.roomName,
        widget.displayName ?? 'مستخدم',
      );
      setState(() => _isConnecting = false);
    } catch (e) {
      setState(() => _isConnecting = false);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _callService.endCall();
    super.dispose();
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
              _isConnecting ? 'جاري الاتصال...' : 'جاري المكالمة',
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
