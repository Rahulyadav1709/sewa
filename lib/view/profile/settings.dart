import 'package:flutter/material.dart';
import 'package:sewa/controller/client_mgr_home_controller.dart';
import 'package:sewa/global/app_colors.dart';
import 'package:sewa/helpers/toasts.dart';
import 'package:sewa/helpers/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ignore: unused_field
  final bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading:     IconButton(
                            onPressed: () {Navigator.pop(context);},
                            icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        title: const Text('Settings',
            style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          
          SettingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () async {
              await urlLauncher(
                  "https://www.piloggroup.com/privacy-policy.php");
            },
          ),
          SettingsTile(
            icon: Icons.info_outline,
            title: 'About Us',
            onTap: () async {
              await urlLauncher(
                  "https://www.piloggroup.com");
            },
          ),
         
          SettingsTile(
            icon: Icons.security,
            title: 'Security',
            onTap: () {
              ToastCustom.infoToast(context, "Coming Soon..\nwe are continously working to enhance security");
            },
          ),
         
          SettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: ()async {
                   await urlLauncher(
                  "https://www.piloggroup.com/contact.php");
            },
          ),
          SettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              ClientMgrHomeController().onLogout(context);
              // Navigate to Help & Support screen
            },
          ),
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({super.key, 
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: AppColors.white,
      shadowColor: AppColors.white,

      child: ListTile(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
        leading: Icon(icon, color: AppColors.blueShadeGradiant),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        trailing: trailing ??
            const Icon(Icons.arrow_forward_ios,
                color:AppColors.blueShadeGradiant, size: 16),
        onTap: onTap,
      ),
    );
  }
}
