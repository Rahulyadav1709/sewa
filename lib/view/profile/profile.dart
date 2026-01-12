import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sewa/global/app_colors.dart';
import 'package:sewa/global/app_styles.dart';
import 'package:sewa/helpers/shared_preferences_helpers.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    getUserDetails();
    // TODO: implement initState
    super.initState();
  }

  String? userName;
  String? instance;
  String? role;
  String? region;

  RxList<String?> allResults = RxList();
  Future getUserDetails() async {
    // userName = await SharedPreferencesHelper.getUsername();
    // instance = await SharedPreferencesHelper.getInstance();
    // role = await SharedPreferencesHelper.getRole();
    // region = await SharedPreferencesHelper.getRegion();
    allResults.value = await Future.wait([
      SharedPreferencesHelper.getUsername(),
      SharedPreferencesHelper.getInstance(),
      SharedPreferencesHelper.getRole(),
      SharedPreferencesHelper.getRegion()
    ]);

    userName = allResults[0];
    instance = allResults[1];
    role = allResults[2];
    region = allResults[3];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading:     IconButton(
                            onPressed: () {Navigator.pop(context);},
                            icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        title: const Text('Profile',
            style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w600)),
      ),
      body: Obx(
        () => allResults.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: AppColors.blueShadeGradiant,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 110,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            userName!,
                            style: AppStyles.black_22_600,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ProfileInfoRow(
                            icon: Icons.location_on,
                            label: 'Region',
                            value: region!,
                          ),
                          ProfileInfoRow(
                            icon: Icons.language,
                            label: 'Locale',
                            value: 'en_US',
                          ),
                          ProfileInfoRow(
                            icon: Icons.person,
                            label: 'Username',
                            value: userName!,
                          ),
                          ProfileInfoRow(
                            icon: Icons.settings_applications,
                            label: 'Instance',
                            value: instance!,
                          ),
                          ProfileInfoRow(
                            icon: Icons.work,
                            label: 'Role',
                            value: role!,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileInfoRow(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color:  AppColors.blueShadeGradiant, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
