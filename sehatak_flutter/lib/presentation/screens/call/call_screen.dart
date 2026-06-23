import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/call_service.dart';

/// Call screen for video/audio calls using Jitsi Meet
class CallScreen extends StatefulWidget {
  final String callId;
  final String? receiverId;
  final String? receiverName;
  final String? receiverPhoto;
  final bool isVideoCall;
  final bool isIncoming;

  const CallScreen({
    Key? key,
    required this.callId,
    this.receiverId,
    this.receiverName,
    this.receiverPhoto,
    this.isVideoCall = true,
    this.isIncoming = false,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with SingleTickerProviderStateMixin {
  final CallService _callService = CallService();

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  CallState _callState = CallState.connecting;
  Timer? _callTimer;
  int _callDuration = 0;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;

  StreamSubscription? _callStateSubscription;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _listenToCallState();

    if (!widget.isIncoming) {
      _startCall();
    } else {
      setState(() => _callState = CallState.ringing);
    }

    // Lock to portrait for call UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _listenToCallState() {
    _callStateSubscription = _callService.callStateStream.listen((state) {
      setState(() => _callState = state);

      if (state == CallState.inProgress) {
        _startCallTimer();
      } else if (state == CallState.ended ||
          state == CallState.failed ||
          state == CallState.declined ||
          state == CallState.timeout) {
        _endCallAndNavigateBack();
      }
    });
  }

  Future<void> _startCall() async {
    if (widget.receiverId == null) return;

    try {
      await _callService.startCall(
        receiverId: widget.receiverId!,
        receiverName: widget.receiverName ?? 'مستخدم',
        receiverPhoto: widget.receiverPhoto,
        type: widget.isVideoCall ? CallType.video : CallType.audio,
      );
    } catch (e) {
      debugPrint('CallScreen: Failed to start call: $e');
      setState(() => _callState = CallState.failed);
    }
  }

  void _acceptCall() async {
    await _callService.acceptCall(widget.callId);
    if (_callService.currentSession != null) {
      await _callService.joinJitsiMeeting(_callService.currentSession!);
    }
  }

  void _declineCall() async {
    await _callService.declineCall(widget.callId);
    _navigateBack();
  }

  void _endCall() async {
    await _callService.endCall();
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _callDuration++);
    });
  }

  void _endCallAndNavigateBack() {
    _callTimer?.cancel();
    Future.delayed(const Duration(seconds: 1), _navigateBack);
  }

  void _navigateBack() {
    // Restore orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Navigator.of(context).pop();
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _callTimer?.cancel();
    _callStateSubscription?.cancel();

    // Restore orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _endCall();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1B5E20).withOpacity(0.8),
                    Colors.black,
                  ],
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Receiver avatar with pulse animation
                  _buildAvatar(),

                  const SizedBox(height: 32),

                  // Receiver name
                  Text(
                    widget.receiverName ?? 'مستخدم',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Call state text
                  Text(
                    _getStateText(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      fontFamily: 'Cairo',
                    ),
                  ),

                  // Call duration (when in progress)
                  if (_callState == CallState.inProgress)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _formatDuration(_callDuration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Cairo',
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),

                  const Spacer(flex: 3),

                  // Call controls
                  if (_callState == CallState.ringing && widget.isIncoming)
                    _buildIncomingCallControls()
                  else if (_callState == CallState.inProgress)
                    _buildInCallControls()
                  else
                    _buildConnectingControls(),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final isRinging = _callState == CallState.ringing;
        final scale = isRinging ? _pulseAnimation.value : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade800,
              border: Border.all(
                color: _getStateColor(),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getStateColor().withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: widget.receiverPhoto != null
                ? ClipOval(
                    child: Image.network(
                      widget.receiverPhoto!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultAvatar(),
                    ),
                  )
                : _buildDefaultAvatar(),
          ),
        );
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return const Icon(
      Icons.person,
      size: 60,
      color: Colors.white54,
    );
  }

  Widget _buildIncomingCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Decline button
        _buildControlButton(
          icon: Icons.call_end,
          color: Colors.red,
          label: 'رفض',
          onTap: _declineCall,
        ),
        const SizedBox(width: 48),
        // Accept button
        _buildControlButton(
          icon: widget.isVideoCall ? Icons.videocam : Icons.call,
          color: Colors.green,
          label: 'رد',
          onTap: _acceptCall,
        ),
      ],
    );
  }

  Widget _buildInCallControls() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mute
            _buildControlButton(
              icon: _isMuted ? Icons.mic_off : Icons.mic,
              color: _isMuted ? Colors.orange : Colors.white,
              label: _isMuted ? 'صامت' : 'ميكروفون',
              onTap: () => setState(() => _isMuted = !_isMuted),
            ),
            const SizedBox(width: 24),
            // Camera toggle
            if (widget.isVideoCall)
              _buildControlButton(
                icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                color: _isCameraOff ? Colors.orange : Colors.white,
                label: _isCameraOff ? 'كاميرا مغلقة' : 'كاميرا',
                onTap: () => setState(() => _isCameraOff = !_isCameraOff),
              ),
            const SizedBox(width: 24),
            // Speaker
            _buildControlButton(
              icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
              color: _isSpeakerOn ? Colors.white : Colors.orange,
              label: 'مكبر الصوت',
              onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // End call button
        _buildControlButton(
          icon: Icons.call_end,
          color: Colors.red,
          label: 'إنهاء',
          size: 70,
          onTap: _endCall,
        ),
      ],
    );
  }

  Widget _buildConnectingControls() {
    return _buildControlButton(
      icon: Icons.call_end,
      color: Colors.red,
      label: 'إلغاء',
      onTap: _endCall,
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required String label,
    double size = 60,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Icon(
              icon,
              color: color,
              size: size * 0.4,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  String _getStateText() {
    switch (_callState) {
      case CallState.idle:
        return '...';
      case CallState.connecting:
        return 'جاري الاتصال...';
      case CallState.ringing:
        return widget.isIncoming ? 'مكالمة واردة' : 'يرن...';
      case CallState.inProgress:
        return 'جاري المكالمة';
      case CallState.ended:
        return 'انتهت المكالمة';
      case CallState.failed:
        return 'فشل الاتصال';
      case CallState.declined:
        return 'تم الرفض';
      case CallState.timeout:
        return 'انتهى الوقت';
    }
  }

  Color _getStateColor() {
    switch (_callState) {
      case CallState.inProgress:
        return Colors.green;
      case CallState.ringing:
        return widget.isIncoming ? Colors.green : Colors.orange;
      case CallState.failed:
      case CallState.declined:
        return Colors.red;
      default:
        return Colors.white;
    }
  }
}
