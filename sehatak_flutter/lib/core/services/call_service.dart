import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:uuid/uuid.dart';

/// Call types supported by the service
enum CallType {
  video,
  audio,
}

/// Call states during a session
enum CallState {
  idle,
  connecting,
  ringing,
  inProgress,
  ended,
  failed,
  declined,
  timeout,
}

/// Model for a call session
class CallSession {
  final String id;
  final String callerId;
  final String callerName;
  final String? callerPhoto;
  final String receiverId;
  final String receiverName;
  final String? receiverPhoto;
  final CallType type;
  CallState state;
  final DateTime startTime;
  DateTime? endTime;
  String? roomName;
  String? jitsiToken;

  CallSession({
    required this.id,
    required this.callerId,
    required this.callerName,
    this.callerPhoto,
    required this.receiverId,
    required this.receiverName,
    this.receiverPhoto,
    required this.type,
    this.state = CallState.idle,
    required this.startTime,
    this.endTime,
    this.roomName,
    this.jitsiToken,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'callerId': callerId,
    'callerName': callerName,
    'callerPhoto': callerPhoto,
    'receiverId': receiverId,
    'receiverName': receiverName,
    'receiverPhoto': receiverPhoto,
    'type': type.name,
    'state': state.name,
    'startTime': Timestamp.fromDate(startTime),
    'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
    'roomName': roomName,
  };

  factory CallSession.fromMap(Map<String, dynamic> map) => CallSession(
    id: map['id'] ?? '',
    callerId: map['callerId'] ?? '',
    callerName: map['callerName'] ?? '',
    callerPhoto: map['callerPhoto'],
    receiverId: map['receiverId'] ?? '',
    receiverName: map['receiverName'] ?? '',
    receiverPhoto: map['receiverPhoto'],
    type: CallType.values.firstWhere(
      (e) => e.name == map['type'],
      orElse: () => CallType.video,
    ),
    state: CallState.values.firstWhere(
      (e) => e.name == map['state'],
      orElse: () => CallState.idle,
    ),
    startTime: (map['startTime'] as Timestamp).toDate(),
    endTime: map['endTime'] != null
        ? (map['endTime'] as Timestamp).toDate()
        : null,
    roomName: map['roomName'],
  );

  Duration? get duration =>
      endTime != null ? endTime!.difference(startTime) : null;
}

/// Jitsi Meet call service for video and audio calls
class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final JitsiMeet _jitsiMeet = JitsiMeet();
  final Uuid _uuid = const Uuid();

  // Stream controllers
  final _callStateController = StreamController<CallState>.broadcast();
  final _incomingCallController = StreamController<CallSession>.broadcast();

  Stream<CallState> get callStateStream => _callStateController.stream;
  Stream<CallSession> get incomingCallStream => _incomingCallController.stream;

  // Current session
  CallSession? _currentSession;
  CallSession? get currentSession => _currentSession;

  // Firestore subscriptions
  StreamSubscription? _callSubscription;

  /// Initialize call service and listen for incoming calls
  Future<void> initialize() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Listen for incoming calls
    _callSubscription = _firestore
        .collection('calls')
        .where('receiverId', isEqualTo: userId)
        .where('state', isEqualTo: CallState.connecting.name)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final call = CallSession.fromMap(change.doc.data()!);
          _incomingCallController.add(call);
        }
      }
    });
  }

  /// Start a new call (video or audio)
  Future<CallSession> startCall({
    required String receiverId,
    required String receiverName,
    String? receiverPhoto,
    required CallType type,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Create room name
    final roomName = 'sehatak_${_uuid.v4().substring(0, 8)}';

    // Create call session
    final session = CallSession(
      id: _uuid.v4(),
      callerId: currentUser.uid,
      callerName: currentUser.displayName ?? currentUser.email ?? 'مستخدم',
      callerPhoto: currentUser.photoURL,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverPhoto: receiverPhoto,
      type: type,
      state: CallState.connecting,
      startTime: DateTime.now(),
      roomName: roomName,
    );

    _currentSession = session;
    _callStateController.add(CallState.connecting);

    // Save to Firestore
    await _firestore.collection('calls').doc(session.id).set(session.toMap());

    // Listen for state changes
    _listenToCallState(session.id);

    return session;
  }

  /// Accept incoming call
  Future<void> acceptCall(String callId) async {
    _callStateController.add(CallState.inProgress);

    await _firestore.collection('calls').doc(callId).update({
      'state': CallState.inProgress.name,
      'acceptedAt': Timestamp.now(),
    });

    // Get call details
    final doc = await _firestore.collection('calls').doc(callId).get();
    if (doc.exists) {
      _currentSession = CallSession.fromMap(doc.data()!);
    }
  }

  /// Decline incoming call
  Future<void> declineCall(String callId) async {
    await _firestore.collection('calls').doc(callId).update({
      'state': CallState.declined.name,
      'endedAt': Timestamp.now(),
    });
    _callStateController.add(CallState.declined);
    _currentSession = null;
  }

  /// End current call
  Future<void> endCall() async {
    if (_currentSession == null) return;

    final now = DateTime.now();
    _currentSession!.endTime = now;
    _currentSession!.state = CallState.ended;

    await _firestore.collection('calls').doc(_currentSession!.id).update({
      'state': CallState.ended.name,
      'endTime': Timestamp.fromDate(now),
    });

    _callStateController.add(CallState.ended);

    // Close Jitsi meeting
    await _jitsiMeet.hangUp();

    _currentSession = null;
  }

  /// Join Jitsi Meet room
  Future<void> joinJitsiMeeting(CallSession session) async {
    if (session.roomName == null) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    _callStateController.add(CallState.inProgress);

    final options = JitsiMeetConferenceOptions(
      room: session.roomName!,
      configOverrides: {
        "startWithAudioMuted": false,
        "startWithVideoMuted": session.type == CallType.audio,
        "subject": "مكالمة صحتك",
        "localSubject": "مكالمة صحتك",
        "prejoinPageEnabled": false,
        "disableModeratorIndicator": true,
        "disableReactions": true,
        "disablePolls": true,
        "breakoutsEnabled": false,
        "hideLobbyButton": true,
        "notifications": [],
        "toolbarButtons": [
          if (session.type == CallType.video) "camera",
          "microphone",
          "hangup",
          "tileview",
          "fullscreen",
        ],
      },
      featureFlags: {
        "welcomepage.enabled": false,
        "resolution": 720,
        "ios.recording.enabled": false,
        "live-streaming.enabled": false,
        "calendar.enabled": false,
        "call-integration.enabled": true,
        "pip.enabled": true,
        "invite.enabled": false,
        "help.enabled": false,
        "settings.enabled": true,
      },
      userInfo: JitsiMeetUserInfo(
        displayName: currentUser.displayName ?? 'مستخدم صحتك',
        email: currentUser.email,
        avatar: currentUser.photoURL != null
            ? Uri.parse(currentUser.photoURL!)
            : null,
      ),
    );

    // Listen to Jitsi events
    _jitsiMeet.join(options,
      listener: JitsiMeetEventListener(
        onConferenceWillJoin: (url) {
          debugPrint('Conference will join: $url');
        },
        onConferenceJoined: (url) {
          debugPrint('Conference joined: $url');
          _callStateController.add(CallState.inProgress);
        },
        onConferenceTerminated: (url, error) {
          debugPrint('Conference terminated: $url, error: $error');
          if (_currentSession != null) {
            endCall();
          }
        },
        onError: (error) {
          debugPrint('Jitsi error: $error');
          _callStateController.add(CallState.failed);
        },
      ),
    );
  }

  /// Listen to call state changes from Firestore
  void _listenToCallState(String callId) {
    _callSubscription?.cancel();
    _callSubscription = _firestore
        .collection('calls')
        .doc(callId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      final state = CallState.values.firstWhere(
        (e) => e.name == data['state'],
        orElse: () => CallState.idle,
      );

      _callStateController.add(state);

      if (state == CallState.ended ||
          state == CallState.declined ||
          state == CallState.timeout) {
        _currentSession = null;
      }
    });
  }

  /// Cancel incoming call ringing (timeout)
  Future<void> cancelCall(String callId) async {
    await _firestore.collection('calls').doc(callId).update({
      'state': CallState.timeout.name,
      'endedAt': Timestamp.now(),
    });
    _callStateController.add(CallState.timeout);
    _currentSession = null;
  }

  /// Get call history for current user
  Stream<List<CallSession>> getCallHistory() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const Stream.empty();

    return _firestore
        .collection('calls')
        .where(Filter.or(
          Filter('callerId', isEqualTo: userId),
          Filter('receiverId', isEqualTo: userId),
        ))
        .orderBy('startTime', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((d) => CallSession.fromMap(d.data())).toList());
  }

  /// Dispose resources
  void dispose() {
    _callStateController.close();
    _incomingCallController.close();
    _callSubscription?.cancel();
    _jitsiMeet.hangUp();
  }
}
