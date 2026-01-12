import 'package:flutter/material.dart';
import 'package:sewa/global/app_colors.dart';
import 'package:sewa/helpers/shared_preferences_helpers.dart';
import 'package:sewa/view/home/home_screen.dart';
import 'package:sewa/view/onboard%20screens/on_boarding.dart';

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOutBack),
      ),
    );

    _slideAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        checkLoginStatus();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  checkLoginStatus() async {
    bool isLoggedIn = await SharedPreferencesHelper.getIsLoggedIn();

    if (context.mounted) {
      isLoggedIn
          // ignore: use_build_context_synchronously
          ? Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                     HomeScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return Stack(
                    children: [
                      FadeTransition(opacity: animation, child: child),
                      // SlideTransition(
                      //   position: Tween<Offset>(
                      //     begin: const Offset(0.0, 0.0),
                      //     end: const Offset(-1.0, 0.0),
                      //   ).animate(animation),
                      //   child: Container(
                      //     color: Colors.white,
                      //     child: const Center(child: CircularProgressIndicator()),
                      //   ),
                      // ),
                    ],
                  );
                },
                transitionDuration: const Duration(milliseconds: 800),
              ),
            )
          : Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const OnboardingScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return Stack(
                    children: [
                      FadeTransition(opacity: animation, child: child),
                      // SlideTransition(
                      //   position: Tween<Offset>(
                      //     begin: const Offset(0.0, 0.0),
                      //     end: const Offset(0.0, -1.0),
                      //   ).animate(animation),
                      //   child: Container(
                      //     color: Colors.white,
                      //     child: const Center(child: CircularProgressIndicator()),
                      //   ),
                      // ),
                    ],
                  );
                },
                transitionDuration: const Duration(milliseconds: 800),
              ),
            );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [
          //     AppColors.blueShadeGradiant,
          //     Colors.white,
          //     Colors.blue.shade50,
          //   ],
          // ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                // Background animated circles
                // Positioned(
                //   top: 100,
                //   right: 50,
                //   child: AnimatedBuilder(
                //     animation: _rotateAnimation,
                //     builder: (context, child) {
                //       return Transform.rotate(
                //         angle: _rotateAnimation.value * 3.14,
                //         child: Container(
                //           width: 100,
                //           height: 100,
                //           decoration: BoxDecoration(
                //             shape: BoxShape.circle,
                //             gradient: RadialGradient(
                //               colors: [AppColors.blueShadeGradiant.withOpacity(0.2), Colors.transparent],
                //             ),
                //           ),
                //         ),
                //       );
                //     },
                //   ),
                // ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Main Logo Container
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blueShadeGradiant.withOpacity(0.3),
                                spreadRadius: 5,
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Rotating background effect
                              Transform.rotate(
                                angle: _rotateAnimation.value * 3.14,
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade300,
                                        Colors.blue.shade600,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Logo text
                              const Text(
                                'Pilog',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Loading indicator
                      Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              // SizedBox(
                              //   width: 60,
                              //   height: 60,
                              //   child: CircularProgressIndicator(
                              //     valueColor: AlwaysStoppedAnimation<Color>(
                              //       Colors.blue.shade600,
                              //     ),
                              //     strokeWidth: 6,
                              //   ),
                              // ),
                              const SizedBox(height: 20),
                              const Text(
                                'SEWA',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Loading...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue.shade400,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}