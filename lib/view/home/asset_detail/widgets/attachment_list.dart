import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sewa/controller/client_mgr_home_controller.dart';
import 'package:sewa/global/app_styles.dart';
import 'package:sewa/model/asset_image_model.dart';

class AttachmentList extends StatelessWidget {
  final ClientMgrHomeController controller;
  final String recordNo;

  const AttachmentList({
    super.key,
    required this.controller,
    required this.recordNo,
  });

  void _showDeleteConfirmation(BuildContext context, ApiDataArray item, int originalIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Attachment'),
          content: const Text(
            'Are you sure you want to delete this attachment?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                
                await controller.imageDeleteApi(
                  auditID: item.aUDITID!,
                  recordNo: recordNo,
                  context: context,
                  index: originalIndex,
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Filter to show only images (not PDFs)
      final imageItems = controller.imageList.where((item) {
        if (item.cONTENT == null) return false;
        return controller.isImageOrPdf(item.cONTENT!) == true;
      }).toList();

      // If no images found
      if (imageItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                "No images found",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(height: 5),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: imageItems.length,
        itemBuilder: (context, index) {
          final item = imageItems[index];
          // Get the original index from the full list
          final originalIndex = controller.imageList.indexOf(item);
          
          return ListTile(
            onLongPress: () => _showDeleteConfirmation(context, item, originalIndex),
            onTap: () {
              controller.showImages(
                context,
                item.cONTENT!,
                item.fILENAME ?? 'No name',
              );
            },
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            leading: _buildAttachmentIcon(item),
            title: Text(
              "File Name: ${item.fILENAME ?? 'Unknown'}",
              style: AppStyles.black_14_400,
            ),
            subtitle: Text(
              "Create Date: ${item.cREATEDATE?.toString() ?? '-'}",
              style: AppStyles.black_12_400,
            ),
          );
        },
      );
    });
  }

  Widget _buildAttachmentIcon(ApiDataArray item) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.memory(
          base64Decode(item.cONTENT!),
          fit: BoxFit.cover,
          width: 50,
          height: 50,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.broken_image,
              color: Colors.grey,
              size: 40,
            );
          },
        ),
      ),
    );
  }
}