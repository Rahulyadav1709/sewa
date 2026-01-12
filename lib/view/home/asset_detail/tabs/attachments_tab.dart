
import 'package:flutter/material.dart';
import 'package:sewa/controller/client_mgr_home_controller.dart';
import 'package:sewa/global/app_colors.dart';
import 'package:sewa/model/asset_image_model.dart';
import 'package:sewa/view/home/asset_detail/widgets/attachment_list.dart';
import 'package:sewa/view/home/asset_detail/widgets/upload_attachment_dialog.dart';


class AttachmentsTab extends StatefulWidget {
  final String recordNo;
  final ClientMgrHomeController controller;
  final String assetNumber;

  const AttachmentsTab({
    super.key,
    required this.recordNo,
    required this.controller,
    required this.assetNumber
  });

  @override
  _AttachmentsTabState createState() => _AttachmentsTabState();
}

class _AttachmentsTabState extends State<AttachmentsTab> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.absoluteWhite,
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {}); // Trigger a refresh of the FutureBuilder
          },
          child: FutureBuilder<AssetImageModel>(
            future:widget.controller. fetchImages(recordNo: widget.recordNo),
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.blueShadeGradiant,
                  ),
                );
              }

              // Error state
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Failed to load attachments',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blueShadeGradiant,
                        ),
                        onPressed: () => setState(() {}),
                        child: const Text(
                          "Retry", 
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // No data state
              if (!snapshot.hasData || snapshot.data!.apiDataArray!.isEmpty) {
                return _buildEmptyState(context);
              }

              // Data loaded successfully
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: AttachmentList(
                  controller: widget.controller, 
                  recordNo: widget.recordNo,
         
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.blueShadeGradiant,
          onPressed: () => showUploadAttachmentDialog(
            context, 
            widget.controller, 
            widget.recordNo,
            widget.assetNumber,
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'No attachments available', 
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueShadeGradiant,
            ),
            onPressed: () => showUploadAttachmentDialog(
              context, 
              widget.controller, 
              widget.recordNo,
              widget.assetNumber,
            ),
            child: const Text(
              "Add Attachments", 
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}