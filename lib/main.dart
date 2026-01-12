import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sewa/helpers/init_services.dart';
import 'package:sewa/view/onboard%20screens/app_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:toastification/toastification.dart';

// Firebase imports
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  
  await InitServices.injectDependencies();
  runApp(const MyApp());
}
SharedPreferences? logindata;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: ToastificationWrapper(
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: Colors.purple,
          ),
          title: "Login App",
          home: AppLoader(),
        ),
      ),
    );
  }
}