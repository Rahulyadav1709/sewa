import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WelcomeAnimation extends StatelessWidget {
  const WelcomeAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildLottieAnimation(
            'assets/images/welcome.json',
            height: MediaQuery.of(context).size.height * 0.30,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          _buildLottieAnimation(
            'assets/images/searchdoc.json',
            height: MediaQuery.of(context).size.height * 0.30,
          ),
        ],
      ),
    );
  }

  Widget _buildLottieAnimation(String assetPath, {required double height}) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Lottie.asset(
          assetPath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}