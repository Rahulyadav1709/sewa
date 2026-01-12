import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:sewa/controller/client_mgr_home_controller.dart';

class InitServices {
 
  static injectDependencies() async {
    await injectdotEnv();
    Get.put(ClientMgrHomeController());
  }

  static injectdotEnv() async {
    await dotenv.load(fileName: ".env");
  }

}
