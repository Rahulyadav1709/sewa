import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sewa/global/app_colors.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFBottomSheet {
  static void show(BuildContext context, String googleDriveFileId) {
    // Convert Google Drive file ID to direct download link
    final pdfUrl = _getGoogleDriveDirectLink(googleDriveFileId);

    showCupertinoModalBottomSheet(enableDrag: false,
      context: context,backgroundColor: AppColors.white,
      builder: (context) => Material(
        child: SafeArea(
          child: Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              title: Text('User Manual'),
            ),
            body: SfPdfViewer.network(
              pdfUrl,
              onDocumentLoadFailed: (details) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to load PDF: ${details.error}')),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Convert Google Drive sharing link to direct download link
  static String _getGoogleDriveDirectLink(String fileId) {
    return 'https://drive.google.com/uc?export=download&id=$fileId';
  }
}