import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/navigation/app_routes.dart';
import 'package:hrtz_hrms/core/constants/app_constants.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/utils/utils.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     // Animation controller for logo and progress indicator
//     _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
//     _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
//     _controller.repeat(reverse: true);
//     _initAuthCheck();
//   }

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

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Animated Logo
//             FadeTransition(
//               opacity: _animation,
//               child: ScaleTransition(
//                 scale: _animation,
//                 child: Image.asset(
//                   AppConstants.logo, // your logo
//                   width: 250,
//                   height: 250,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             // Pulsing progress indicator
//             ScaleTransition(
//               scale: Tween<double>(begin: 0.8, end: 1.2).animate(_animation),
//               child: const CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//                 strokeWidth: 3,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isVideoInitialized = false;
  bool _hasStartedAuthCheck = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.asset('assets/videos/splash.mp4');
    await _videoController.initialize();
    setState(() => _isVideoInitialized = true);

    _videoController.play();
    _videoController.setLooping(false);

    // Detect when video finishes
    _videoController.addListener(() {
      if (!_hasStartedAuthCheck &&
          _videoController.value.position >= _videoController.value.duration) {
        _hasStartedAuthCheck = true;
        _startAuthProcess();
      }
    });
  }

  Future<void> _startAuthProcess() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final authCheck = authProvider.checkAuthState();
    final employeeFetch = authProvider.fetchAndCacheEmployeeList();

    await Future.wait([authCheck, employeeFetch]);

    // Start fade-out animation
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
          // 🎬 Centered video with controlled size
          if (_isVideoInitialized)
            Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: width * 0.8,
                  height: height * 0.3,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          else
            // fallback logo while video initializes
            Center(
              child: Image.asset(AppConstants.logo, width: width * 0.6, height: height * 0.25),
            ),

          // 🌫 Fade-out + Loading text overlay
          if (_isLoading)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                color: Colors.white,
                child: const Center(
                  child: Text(
                    "Loading...",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
