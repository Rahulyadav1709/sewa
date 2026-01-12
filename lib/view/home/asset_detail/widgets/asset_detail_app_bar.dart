import 'package:flutter/material.dart';
import 'package:sewa/global/app_colors.dart';
import 'package:sewa/global/app_styles.dart';
import 'package:sewa/view/update%20asset/update_asset_screen.dart';

class AssetDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TabController tabController;
  final String recordNo;
  final String assetNumber;

  const AssetDetailAppBar({
    super.key,
    required this.title,
    required this.tabController,
    required this.recordNo, required this.assetNumber,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(title, style: AppStyles.black_20_600),
      backgroundColor: Colors.transparent,
      bottom: TabBar(
        controller: tabController,
        isScrollable: true,
        tabs: const [
          Tab(text: "Information"),
          Tab(text: "Attachments"),
          Tab(text: "Pdf Summary Extractor"),
          Tab(text: "Location(GPS)"),
        ],
        labelColor: AppColors.absoluteBlack,
        indicatorColor: AppColors.blueShadeGradiant,
      ),
      actions: [
       assetNumber.startsWith("NEW") == true||recordNo.startsWith("NEW")==true
            ? IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UpdateAssetScreen(recordNo: recordNo,assetNumber: assetNumber,)),
                );
              },
              icon: Icon(Icons.update),
            )
            : SizedBox(),
      ],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
}
