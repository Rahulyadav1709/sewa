import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sewa/controller/pdf_extractor_controller.dart';
import 'package:sewa/view/home/asset_detail/tabs/pdf_summary_extractor/widgets/file_info.dart';
import 'package:sewa/view/home/asset_detail/tabs/pdf_summary_extractor/widgets/gemini_loader.dart';
import 'package:sewa/view/home/asset_detail/tabs/pdf_summary_extractor/widgets/summary_card.dart';
import 'package:sewa/view/home/asset_detail/tabs/pdf_summary_extractor/widgets/upload_button.dart';


class PdfSummaryScreen extends StatelessWidget {
  const PdfSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<PdfController>(
        init: PdfController(),
        builder: (controller) {
          return Center(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8F9FA),
                    Color(0xFFE9ECEF),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     const Center(
                       child: Text(
                        'AI Summary Extractor',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212529),
                        ),
                                           ),
                     ),
                      const SizedBox(height:10),
                      UploadButton(
                        onPressed: controller.isLoading ? null : controller.pickPDF,
                        isEnabled: !controller.isLoading,
                      ),
                      const SizedBox(height: 32),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: controller.isLoading
                            ? const GeminiLoader(height: 60,width: 60,)
                            : controller.selectedFile != null
                                ? Column(
                                    children: [
                                      FileInfo(
                                        fileName: controller.selectedFile!.path
                                            .split('/')
                                            .last,
                                      ),
                                      const SizedBox(height: 24),
                                      if (controller.summary != null)
                                        AnimatedOpacity(
                                          opacity: 1.0,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          child: SummaryCard(
                                            summary: controller.summary!,
                                          ),
                                        ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}