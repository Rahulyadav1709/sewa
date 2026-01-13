import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:sewa/controller/client_mgr_home_controller.dart';
import 'package:sewa/global/app_colors.dart';
import 'package:sewa/helpers/toasts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sewa/view/home/asset_detail/widgets/image_annotation_screen.dart';
import 'dart:typed_data';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:sewa/view/home/asset_detail/widgets/smart_camera_page.dart';

Future<void> showUploadAttachmentDialog(
  BuildContext context,
  ClientMgrHomeController controller,
  String? recordNo,
  String? assetNo,
) async {
  TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<File?> compressImage(File file, BuildContext callbackContext) async {
    try {
      final int originalSize = await file.length();
      debugPrint("📸 Original Image Size: ${(originalSize / 1024).toStringAsFixed(2)} KB");

      final tempDir = await getTemporaryDirectory();
      final String targetPath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
      );

      if (compressedFile != null) {
        final File compressed = File(compressedFile.path);
        final int compressedSize = await compressed.length();
        debugPrint("📉 Compressed Image Size: ${(compressedSize / 1024).toStringAsFixed(2)} KB");
        return compressed;
      } else {
        ToastCustom.errorToast(callbackContext, 'Failed to compress image');
        return null;
      }
    } catch (e) {
      ToastCustom.errorToast(callbackContext, 'Error during compression: $e');
      return null;
    }
  }

  // New function to show annotation screen
  Future<File?> showAnnotationScreen(File imageFile) async {
    final result = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (context) => ImageAnnotationScreen(
          imageFile: imageFile,
        ),
      ),
    );
    return result;
  }

  Future<void> takePicture() async {
    final XFile? image = await Navigator.push<XFile>(
      context,
      MaterialPageRoute(builder: (context) => const SmartCameraPage()),
    );

    if (image != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Images',
            toolbarColor: AppColors.blueShadeGradiant,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
        ],
      );

      if (croppedFile != null) {
        File file = File(croppedFile.path);
        
        // Show annotation screen
        File? annotatedFile = await showAnnotationScreen(file);
        
        if (annotatedFile != null) {
          File? compressedFile = await compressImage(annotatedFile, context);
          if (compressedFile != null) {
            await _uploadFile(
              context,
              controller,
              recordNo ?? '',
              assetNo ?? '',
              compressedFile,
              nameController.text,
              true,
            );
          }
        }
      }
    }
  }

  Future<void> pickSingleFile() async {
    const maxFileSize = 4 * 1024 * 1024; // 4MB limit
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      bool isImage = file.path.endsWith('.jpg') || file.path.endsWith('.jpeg');

      if (isImage) {
        // Show annotation screen for images
        File? annotatedFile = await showAnnotationScreen(file);
        
        if (annotatedFile != null) {
          File? compressedFile = await compressImage(annotatedFile, context);
          
          if (compressedFile != null) {
            if (await compressedFile.length() <= maxFileSize) {
              await _uploadFile(
                context,
                controller,
                recordNo ?? 'Data',
                assetNo ?? 'Data',
                compressedFile,
                nameController.text,
                isImage,
              );
            } else {
              ToastCustom.errorToast(
                context,
                'File size exceeds 4MB after compression',
              );
            }
          }
        }
      } else {
        // For PDFs, upload directly without annotation
        if (await file.length() <= maxFileSize) {
          await _uploadFile(
            context,
            controller,
            recordNo ?? 'Data',
            assetNo ?? 'Data',
            file,
            nameController.text,
            isImage,
          );
        } else {
          ToastCustom.errorToast(
            context,
            'File size exceeds 4MB',
          );
        }
      }
    } else {
      ToastCustom.infoToast(context, 'No file selected.');
    }
  }

  Future<void> pickMultipleImages() async {
    const maxFileSize = 4 * 1024 * 1024; // 4MB limit per file
    
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      List<File> validFiles = [];
      int skippedCount = 0;

      for (var fileResult in result.files) {
        if (fileResult.path != null) {
          File file = File(fileResult.path!);
          
          // Show annotation screen for each image
          File? annotatedFile = await showAnnotationScreen(file);
          
          if (annotatedFile != null) {
            // Compress the annotated image
            File? compressedFile = await compressImage(annotatedFile, context);
            
            if (compressedFile != null) {
              if (await compressedFile.length() <= maxFileSize) {
                validFiles.add(compressedFile);
              } else {
                skippedCount++;
              }
            } else {
              skippedCount++;
            }
          } else {
            // User cancelled annotation for this image
            skippedCount++;
          }
        }
      }

      if (validFiles.isNotEmpty) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Upload all valid files
        for (int i = 0; i < validFiles.length; i++) {
          await _uploadFile(
            context,
            controller,
            recordNo ?? 'Data',
            assetNo ?? 'Data',
            validFiles[i],
            nameController.text,
            true,
          );
        }

        // Close loading indicator
        Navigator.pop(context);

        ToastCustom.successToast(
          context,
          'Uploaded ${validFiles.length} image(s) successfully',
        );

        if (skippedCount > 0) {
          ToastCustom.infoToast(
            context,
            '$skippedCount file(s) skipped',
          );
        }
      } else {
        ToastCustom.errorToast(
          context,
          'No valid images to upload.',
        );
      }
    } else {
      ToastCustom.infoToast(context, 'No files selected.');
    }
  }

  await showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Upload Attachment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: nameController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(
                  labelText: 'Enter file name (optional for multiple)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a file name';
                  }
                  if (value.startsWith(' ')) {
                    return 'Space not allowed at start';
                  }
                  if (value.endsWith(' ')) {
                    return 'Space not allowed at end';
                  }
                  if (value.length < 3) {
                    return 'At least 3 characters required';
                  }
                  final validCharacters = RegExp(r'^[a-zA-Z0-9 \-/.]+$');
                  if (!validCharacters.hasMatch(value)) {
                    return 'Only alphabets, numbers, spaces, and date separators (-, /, .) are allowed';
                  }
                  if (RegExp(r'^\d+$').hasMatch(value)) {
                    return 'File name cannot be only digits';
                  }
                  return null;
                },
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      await takePicture();
                    }
                  },
                  icon: const Icon(Icons.camera_alt, color: Colors.black),
                  label: const Text(
                    'Camera',
                    style: TextStyle(color: AppColors.absoluteBlack),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      await pickSingleFile();
                    }
                  },
                  icon: const Icon(Icons.file_upload, color: Colors.black),
                  label: const Text(
                    'Single',
                    style: TextStyle(color: AppColors.absoluteBlack),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await pickMultipleImages();
                },
                icon: const Icon(Icons.collections, color: Colors.black),
                label: const Text(
                  'Multiple Images',
                  style: TextStyle(color: AppColors.absoluteBlack),
                ),
              ),
            ),
          ],
        ),
      ),
    ),)
  );
}

Future<void> _uploadFile(
  BuildContext context,
  ClientMgrHomeController controller,
  String recordNo,
  String assetNo,
  File file,
  String fileName,
  bool isImage,
) async {
  // If fileName is empty, use a default timestamp-based name
  String finalFileName = fileName.trim();
  if (finalFileName.isEmpty) {
    finalFileName = "Attachment_${DateTime.now().millisecondsSinceEpoch}";
  }

  await controller.uploadImageApi(
    file: file,
    recordNumber: recordNo,
    assetNumber: assetNo,
    context: context,
    isImage: isImage,
    editedFileName: fileName,
  );
}