import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sewa/controller/client_mgr_home_controller.dart';
import 'package:sewa/global/app_colors.dart';
import 'package:sewa/view/home/asset_detail/tabs/location_tab.dart';
import 'package:sewa/view/home/asset_detail/tabs/pdf_summary_extractor/pdf_summary_screen.dart';
import 'tabs/information_tab.dart';
import 'tabs/attachments_tab.dart';
import 'widgets/asset_detail_app_bar.dart';

class AssetDetailScreen extends StatefulWidget {
  final String? failurecode;
  final String? recordNo;
  final String? shortDescription;
  final String? longDesc;
  final String? status;
  final String? imageName;
  final String? equipmentNo;
  final String? techID;
  final String? lat;
  final String? lng;
  final String? updatelat;
  final String? updatelng;
  final String? assetNo;
  final String? location;
  final String? parent;
  final String? modelNo;
  final String? serialNo;
  final String? subSatationNumber;
  final String? editBy;
  final String? pilogComment;
  final String? substationName;
  final String? clientNumber;
  final String? assetTaggingType;
  const AssetDetailScreen({
    super.key,
    this.recordNo,
    this.failurecode,
    this.shortDescription,
    this.longDesc,
    this.status,
    this.imageName,
    this.equipmentNo,
    this.techID,
    this.lat,
    this.lng,
    this.updatelat,
    this.updatelng,
    this.assetNo,
    this.location,
    this.parent,
    this.modelNo,
    this.serialNo,
    this.subSatationNumber,
    this.editBy,
    this.pilogComment,
    this.substationName,
    this.clientNumber,
    this.assetTaggingType
  });

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen>
    with SingleTickerProviderStateMixin {
  final ClientMgrHomeController controller =
      Get.find<ClientMgrHomeController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.absoluteWhite,
      appBar: AssetDetailAppBar(
        title: widget.failurecode ?? "Asset Details",
        assetNumber: widget.assetNo ?? "N/A",
        tabController: _tabController,
        recordNo: widget.recordNo!,
      ),
      body: LoaderOverlay(
        useDefaultLoading: true,
        child: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            InformationTab(
              pilogComment: widget.pilogComment,
              editBy: widget.editBy,
              modelNo: widget.modelNo,
              serialNo: widget.serialNo,
              parent: widget.parent,
              location: widget.location,
              assetNo: widget.assetNo,
              failurecode: widget.failurecode,
              recordNo: widget.recordNo,
              equipmentNo: widget.equipmentNo,
              techID: widget.techID,
              shortDescription: widget.shortDescription,
              longDesc: widget.longDesc,
              status: widget.status,
              subSatationNumber: widget.subSatationNumber,assetTaggingType:  widget.assetTaggingType,
            ),
            AttachmentsTab(
              recordNo: widget.recordNo ?? '',
              controller: controller,
              assetNumber: widget.assetNo ?? 'No_asset_number_found ',
            ),
            const PdfSummaryScreen(),
            LocationTab(
              updatelat: widget.updatelat,
              updatelong: widget.updatelng,
              onLocationSelected: (latitude, longitude) {},
              assetName: widget.failurecode,
              equipmentNo: widget.equipmentNo,
              lat: widget.lat,
              long: widget.lng,
              recordNo: widget.recordNo,
              status: widget.status,
            ),
          ],
        ),
      ),
    );
  }
}
