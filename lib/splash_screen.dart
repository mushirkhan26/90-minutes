import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/core/constants/app_constants.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/utils/utils.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  bool _isVideoInitialized = false;
  bool _hasStartedAuthCheck = false;
  bool _isLoading = false;
  bool _videoEnded = false;

  @override
  void initState() {
    super.initState();
    _initVideo();

    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.asset('assets/videos/splash.mp4');
    await _videoController.initialize();
    setState(() => _isVideoInitialized = true);

    _videoController.play();
    _videoController.setLooping(false);

    _videoController.addListener(() {
      final isCompleted = _videoController.value.position >= _videoController.value.duration;
      if (isCompleted && !_hasStartedAuthCheck) {
        _hasStartedAuthCheck = true;
        _videoEnded = true;
        _startAuthProcess();
      }
    });
  }

  Future<void> _startAuthProcess() async {
    setState(() => _isLoading = true);
    _pulseController.repeat(reverse: true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await Future.wait([authProvider.checkAuthState(), authProvider.fetchAndCacheEmployeeList()]);

    await _fadeController.forward();

    if (!mounted) return;

    if (authProvider.state == AuthState.authenticated) {
      context.go(AppRoutes.homeRoute);
    } else {
      context.go(AppRoutes.loginRoute);
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = Utils().width(context);
    final height = Utils().height(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🎬 Video plays first — nothing else shown
          if (!_videoEnded && _isVideoInitialized)
            Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: width * 0.8,
                  height: height * 0.3,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),

          // 🧭 After video completes → show logo + pulsing loading text
          if (_videoEnded)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(AppConstants.logo, width: width * 0.55, height: height * 0.22),
                  const SizedBox(height: 22),
                  FadeTransition(
                    opacity: _pulseAnimation,
                    child: const Text(
                      "Loading...",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 🌫 Smooth fade overlay while navigating
          if (_isLoading)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(color: Colors.white.withValues(alpha: 0.9)),
            ),
        ],
      ),
    );
  }
}
//   Future<void> _initAuthCheck() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);

//     // Slight delay so animation is visible
//     await Future.delayed(const Duration(seconds: 1));

//     // Check auth state and fetch employee list in parallel
//     final authCheck = authProvider.checkAuthState();
//     final employeeFetch = authProvider.fetchAndCacheEmployeeList();

//     await Future.wait([authCheck, employeeFetch]);

//     if (!mounted) return;

//     if (authProvider.state == AuthState.authenticated) {
//       context.go(AppRoutes.homeRoute);
//     } else {
//       context.go(AppRoutes.loginRoute);
//     }
//   }
