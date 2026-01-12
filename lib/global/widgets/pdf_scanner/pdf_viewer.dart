import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sewa/controller/pdf_extractor_controller.dart';
import 'package:sewa/global/widgets/pdf_scanner/summary_bottom_sheet.dart';
import 'package:sewa/global/widgets/pdf_scanner/summary_buttom.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';


class PDFScreen extends StatelessWidget {
  final String pdfPath;
  final String fileName;
  final PdfController controller = Get.put(PdfController());

  PDFScreen({super.key, required this.pdfPath, required this.fileName});

  Future<void> _handleSummaryGeneration(BuildContext context) async {
    controller.setSelectedFile = File(pdfPath);
    await controller.extractText();
    
    if (controller.summary != null && context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SummaryBottomSheet(summary: controller.summary!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(fileName),
        actions: [
          GetBuilder<PdfController>(
            builder: (controller) => SummaryButton(
              onPressed: () => _handleSummaryGeneration(context),
              isLoading: controller.isLoading,
            ),
          ),
        ],
      ),
      body: SfPdfViewer.file(File(pdfPath)),
    );
  }
}