
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:sewa/global/app_colors.dart';
import 'package:sewa/view/auth%20screens/login_screen.dart';


class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(globalBackgroundColor: AppColors.white,
      pages: [
        PageViewModel(
          title: "Welcome to SEWA App",
          body: "Explore our latest features and stay up to date with our services.",
          image: const Center(child: Icon(Icons.business, size: 100, color: Colors.blue)),
          decoration: PageDecoration(
            pageColor: AppColors.white,
            titleTextStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            bodyTextStyle: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        PageViewModel(
          title: "Latest Publications",
          body: "Read our latest articles and insights into the industry.",
          image: const Center(child: Icon(Icons.article, size: 100, color: Colors.green)),
          decoration: PageDecoration(
    pageColor: AppColors.white,
            titleTextStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
            bodyTextStyle: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        PageViewModel(
          title: "Our Services",
          body: "Learn about the wide range of services we provide.",
          image: const Center(child: Icon(Icons.design_services, size: 100, color: Colors.orange)),
          decoration: PageDecoration(
           pageColor: AppColors.white,
            titleTextStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
            bodyTextStyle: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
      onDone: () {
        // Navigate to the main app screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
      onSkip: () {
        // Skip the onboarding and go to the main screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
      showSkipButton: true,curve: Curves.bounceInOut,
      skip:  Text("Skip",style: const TextStyle(color: AppColors.blueShadeGradiant),),
      next: const Icon(Icons.arrow_forward_ios_rounded,color: AppColors.blueShadeGradiant,),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600,color: AppColors.blueShadeGradiant)),
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        activeSize: const Size(22.0, 10.0),
        activeColor: AppColors.blueShadeGradiant,
        color: Colors.grey,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }
}