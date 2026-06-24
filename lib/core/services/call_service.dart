import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jitsi_meet/jitsi_meet.dart';

enum CallState { idle, connecting, ringing, inProgress, ended, failed, declined }

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final JitsiMeet _jitsiMeet = JitsiMeet();
  final StreamController<CallState> _callStateController = StreamController<CallState>.broadcast();
  Stream<CallState> get callStateStream => _callStateController.stream;

  Future<void> startCall(String receiverId) async {
    _callStateController.add(CallState.connecting);
    await Future.delayed(const Duration(seconds: 1));
    _callStateController.add(CallState.ringing);
  }

  Future<void> acceptCall(String callId) async {
    _callStateController.add(CallState.inProgress);
  }

  Future<void> declineCall(String callId) async {
    _callStateController.add(CallState.declined);
  }

  Future<void> endCall() async {
    _callStateController.add(CallState.ended);
    await _jitsiMeet.hangUp();
  }

  Future<void> joinMeeting(String roomName, String displayName, bool isVideo) async {
    final options = JitsiMeetConferenceOptions(
      room: roomName,
      userDisplayName: displayName,
      audioOnly: !isVideo,
      audioMuted: false,
      videoMuted: !isVideo,
    );
    await _jitsiMeet.joinConference(options);
  }

  void dispose() { _callStateController.close(); }
}
