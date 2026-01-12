import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sewa/controller/client_mgr_home_controller.dart';
import 'package:sewa/helpers/search_stats_manager.dart';
import 'package:sewa/view/home/components/home_loading_shimmer.dart';
import 'animated_search_bar.dart';
import 'asset_grid.dart';
import 'welcome_animation.dart';

class HomeContent extends StatelessWidget {
    final SearchAnalyticsService analyticsService;
  const HomeContent({
    super.key, required this.analyticsService,
  });

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return PopScope(
        canPop: true,
        child: GetBuilder<ClientMgrHomeController>(
            init: ClientMgrHomeController(),
            builder: (controller) {
              return Scaffold(
                   backgroundColor: Colors.grey[50],
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  toolbarHeight: 80,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: SafeArea(
                    child: Row(
                      children: [
                         Padding(
                           padding: const EdgeInsets.only(left: 8),
                           child: GestureDetector(
                                       onTap: () {
                                         Navigator.pop(context);
                                       },
                                       child: Container(
                                         padding: const EdgeInsets.all(12),
                                         decoration: BoxDecoration(
                                           color: Colors.white,
                                           borderRadius: BorderRadius.circular(12),
                                           boxShadow: [
                                             BoxShadow(
                                               color: Colors.black.withOpacity(0.04),
                                               blurRadius: 5,
                                               offset: const Offset(0, 2),
                                             ),
                                           ],
                                         ),
                                         child: const Icon(
                                           Icons.arrow_back_ios_new_rounded,
                                           color: Colors.black87,
                                           size: 20,
                                         ),
                                       ),
                                     ),
                         ),
                        AnimatedSearchBar(controller: controller, analyticsService: analyticsService),
                      ],
                    ),
                  ),
                ),
                body: Obx(
                  () => controller.isAssetDataLoaded.value
                      ? _buildAssetData(context, isTablet, controller)
                      : const WelcomeAnimation(),
                ),
              );
            }));
  }

  Widget _buildAssetData(
      BuildContext context, bool isTablet, ClientMgrHomeController controller) {
    return FutureBuilder(
      future: controller.getAssetdataFuture,
      initialData: const WelcomeAnimation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingShimmer();
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        return AssetGrid(
          data: snapshot.data,
          isTablet: isTablet,
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AssetDataCardShimmer(),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Image(
        image: AssetImage('assets/images/not_found.png'),
        fit: BoxFit.contain,
      ),
    );
  }
}
