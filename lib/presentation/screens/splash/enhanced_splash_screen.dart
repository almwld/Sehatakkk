import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EnhancedSplashScreen extends StatefulWidget {
  const EnhancedSplashScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedSplashScreen> createState() => _EnhancedSplashScreenState();
}

class _EnhancedSplashScreenState extends State<EnhancedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 2),
  );

  double _progressValue = 0.0;
  String _loadingText = 'جاري التحميل...';
  bool _showVersion = false;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startLoading();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.3, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    )..addListener(() {
        setState(() {
          _progressValue = _progressAnimation.value;
        });
      });

    _mainController.forward();
  }

  Future<void> _startLoading() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _loadingText = 'جاري تهيئة التطبيق...');

    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _loadingText = 'جاري التحقق من التحديثات...');

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      final maintenanceMode = remoteConfig.getBool('maintenance_mode');

      if (maintenanceMode) {
        setState(() {
          _loadingText = 'التطبيق في وضع الصيانة';
        });
        await Future.delayed(const Duration(seconds: 2));
        _showMaintenanceDialog();
        return;
      }
    } catch (e) {
      debugPrint('Remote config check failed: $e');
    }

    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _loadingText = 'جاري التحقق من الجلسة...';
      _showVersion = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isReady = true;
      _loadingText = 'جاهز!';
    });

    _confettiController.play();

    await Future.delayed(const Duration(milliseconds: 800));
    _navigateToNext();
  }

  void _navigateToNext() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.of(context).pushReplacementNamed('/main');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _showMaintenanceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.build, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text('صيانة'),
          ],
        ),
        content: Text(
          FirebaseRemoteConfig.instance.getString('maintenance_message'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              SystemNavigator.pop();
            },
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
              Color(0xFF43A047),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            ...List.generate(20, (index) => _buildParticle(index, size)),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    particleDrag: 0.05,
                    emissionFrequency: 0.05,
                    numberOfParticles: 30,
                    gravity: 0.2,
                    colors: const [
                      Colors.white,
                      Color(0xFF81C784),
                      Color(0xFF4CAF50),
                      Color(0xFFA5D6A7),
                      Colors.yellow,
                    ],
                  ),
                  const Spacer(flex: 2),
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _mainController,
                      _pulseController,
                    ]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value * _pulseAnimation.value,
                        child: Transform.rotate(
                          angle: _rotationAnimation.value * pi,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildLogo(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  AnimatedBuilder(
                    animation: _mainController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildAppName(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _mainController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _mainController,
                          curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
                        ),
                        child: _buildTagline(),
                      );
                    },
                  ),
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _mainController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _mainController,
                          curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
                        ),
                        child: _buildProgressSection(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _loadingText,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Cairo',
                    ),
                  ).animate().fadeIn(duration: 500.ms).then(delay: 200.ms),
                  const SizedBox(height: 8),
                  if (_showVersion)
                    const Text(
                      'الإصدار 2.0.0',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontFamily: 'Cairo',
                      ),
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.5, end: 0),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF43A047).withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.medical_services_rounded,
        size: 80,
        color: Color(0xFF2E7D32),
      ),
    );
  }

  Widget _buildAppName() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.white, Color(0xFFC8E6C9)],
      ).createShader(bounds),
      child: const Text(
        'صحتك',
        style: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Cairo',
          letterSpacing: 2,
          shadows: [
            Shadow(
              offset: Offset(0, 4),
              blurRadius: 15,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: const Text(
        'الرعاية الصحية اليمنية الشاملة',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white70,
          fontFamily: 'Cairo',
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return SizedBox(
      width: 250,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progressValue,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _isReady ? Colors.white : Colors.white.withOpacity(0.8),
              ),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_progressValue * 100).toInt()}%',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticle(int index, Size screenSize) {
    final random = Random(index);
    final size = random.nextDouble() * 8 + 2;
    final x = random.nextDouble() * screenSize.width;
    final duration = random.nextDouble() * 4 + 3;
    final delay = random.nextDouble() * 2;
    final opacity = random.nextDouble() * 0.3 + 0.1;

    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final progress = ((_particleController.value + delay) % 1.0);
        final y = screenSize.height - (progress * screenSize.height);

        return Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: opacity * (1 - progress),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(size / 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: size,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
