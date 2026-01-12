// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:loader_overlay/loader_overlay.dart';
// import 'package:taqa/controller/client_mgr_home_controller.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'dart:io';

// import 'package:taqa/controller/update_asset_controller.dart';

// class UpdateAssetImage extends StatelessWidget {
//   final String assetNumber;
//   final String recordNo;

//   const UpdateAssetImage({
//     super.key,
//     required this.assetNumber,
//     required this.recordNo,
//   });

//   final Color primaryColor = const Color(0xff264179);

//   Future<File?> _cropImage(File imageFile) async {
//     final croppedFile = await ImageCropper().cropImage(
//       sourcePath: imageFile.path,

//       uiSettings: [
//         AndroidUiSettings(
//           toolbarTitle: 'Crop Image',
//           toolbarColor: primaryColor,
//           toolbarWidgetColor: Colors.white,
//           initAspectRatio: CropAspectRatioPreset.original,
//           lockAspectRatio: false,
//         ),
//         IOSUiSettings(
//           title: 'Crop Image',
//         ),
//       ],
//     );

//     return croppedFile != null ? File(croppedFile.path) : null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<CreateAssetController>();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         title: const Text("Upload Attachment", style: TextStyle(color: Colors.white)),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: LoaderOverlay(
//         useDefaultLoading: true,
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.cloud_upload_rounded, size: 100, color: Colors.grey),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Upload your attachment here\nCamera (with crop) or PDF only',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 18),
//                 ),
//                 const SizedBox(height: 30),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: primaryColor,
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       onPressed: () async {
//                         final picker = ImagePicker();
//                         final pickedFile = await picker.pickImage(source: ImageSource.camera);
//                         if (pickedFile != null) {
//                           File imageFile = File(pickedFile.path);
//                           File? croppedFile = await _cropImage(imageFile);
//                           if (croppedFile != null) {
//                             await controller.uploadImageApi(
//                               file: croppedFile,
//                               recordNumber: recordNo,
//                               assetNumber: assetNumber,
//                               context: context,
//                               isImage: true,
//                             );
//                           }
//                         }
//                       },
//                       icon: const Icon(Icons.camera_alt, color: Colors.white),
//                       label: const Text("Camera", style: TextStyle(color: Colors.white)),
//                     ),
//                     const SizedBox(width: 16),
//                     ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: primaryColor,
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       onPressed: () async {
//                         FilePickerResult? result = await FilePicker.platform.pickFiles(
//                           type: FileType.custom,
//                           allowedExtensions: ['pdf'],
//                         );
//                         if (result != null && result.files.single.path != null) {
//                           File file = File(result.files.single.path!);
//                           await controller.uploadImageApi(
//                             file: file,
//                             recordNumber: recordNo,
//                             assetNumber: assetNumber,
//                             context: context,
//                             isImage: false,
//                           );
//                         }
//                       },
//                       icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
//                       label: const Text("PDF", style: TextStyle(color: Colors.white)),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }