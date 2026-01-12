import 'package:flutter/material.dart';
import 'package:sewa/controller/client_mgr_home_controller.dart';
import 'package:sewa/global/app_colors.dart';
import 'package:sewa/helpers/search_stats_manager.dart';
import 'package:sewa/helpers/toasts.dart';

class AnimatedSearchBar extends StatelessWidget {
  final ClientMgrHomeController controller;
   final SearchAnalyticsService analyticsService;

  const AnimatedSearchBar({super.key, required this.controller, required this.analyticsService});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 300),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: _buildSearchField(context),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        onSubmitted: (_) => _handleSearch(context),
        decoration: InputDecoration(
          hintText: 'Search assets...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              'assets/images/PiLog Logo.png',
              width: 24,
              height: 24,
              color: AppColors.blueShadeGradiant,
            ),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search_rounded,
                color: AppColors.blueShadeGradiant),
            onPressed: () => _handleSearch(context),
          ),
        ),
      ),
    );
  }

  void _handleSearch(BuildContext context) async {
    if (controller.searchController.text.isNotEmpty) {
    // Save search analytics
      analyticsService.saveSearchData(
        DateTime.now(), 
        1  // Increment search count by 1
      );
      controller.onTapSearch();
      // Log search count
    } else {
      ToastCustom.infoToast(context, "Please enter search query");
    }
  }
}
