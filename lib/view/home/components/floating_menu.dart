import 'package:flutter/material.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:sewa/controller/client_mgr_home_controller.dart';
import 'package:sewa/view/floc%20search/sub_station_search.dart';
import 'package:sewa/view/parametric%20search/parametric_screen.dart';


class FloatingMenu extends StatelessWidget {
  final ClientMgrHomeController controller;
  final Animation<double> animation;
  final VoidCallback onLogout;

  const FloatingMenu({
    super.key,
    required this.controller,
    required this.animation,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionBubble(
      items: _buildMenuItems(context),
      animation: animation,
      onPress: controller.toggleAnimation,
      iconColor: const Color(0xff7165E3),
      iconData: Icons.menu,
      backGroundColor: Colors.white,
    );
  }

  List<Bubble> _buildMenuItems(BuildContext context) {
    return [
      _buildBubbleItem(
        title: "Parametric Search",
        icon: Icons.document_scanner,
        onTap: () => _navigateToScreen(context, const ParametricSearchScreen()),
      ),
      _buildBubbleItem(
        title: "FLOC Search",
        icon: Icons.location_city_rounded,
        onTap: () => _navigateToScreen(context, const FLOCOperation()),
      ),
      _buildBubbleItem(
        title: "Logout",
        icon: Icons.logout,
        color: Colors.red,
        onTap: onLogout,
      ),
    ];
  }

  Bubble _buildBubbleItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color color = const Color(0xff7165E3),
  }) {
    return Bubble(
      title: title,
      iconColor: Colors.white,
      bubbleColor: color,
      icon: icon,
      titleStyle: const TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      onPress: onTap,
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}