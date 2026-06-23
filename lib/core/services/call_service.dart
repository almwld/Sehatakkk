import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:flutter/material.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final JitsiMeet _jitsiMeet = JitsiMeet();

  Future<void> startCall(String roomName, String displayName, bool isVideo) async {
    final options = JitsiMeetConferenceOptions(
      room: roomName,
      userDisplayName: displayName,
      audioOnly: !isVideo,
      audioMuted: false,
      videoMuted: !isVideo,
    );
    await _jitsiMeet.joinConference(options);
  }

  Future<void> endCall() async {
    await _jitsiMeet.hangUp();
  }
}
