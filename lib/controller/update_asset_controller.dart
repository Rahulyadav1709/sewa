import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:sewa/helpers/api_services.dart';
import 'package:sewa/helpers/shared_preferences_helpers.dart';
import 'package:sewa/helpers/toasts.dart';


class CreateAssetController extends GetxController {
  // ignore: non_constant_identifier_names
  static late String host_url;

  @override
  void onInit() {
    super.onInit();
    host_url = dotenv.get("HOST_URL");
  }

  // New controllers for the updated fields
  final assetNoController = TextEditingController();
  final locationController = TextEditingController();
  final substationController = TextEditingController();
  final parentController = TextEditingController();
  final descriptionController = TextEditingController();
  final assetDescriptionController = TextEditingController();
  final failureCodeController = TextEditingController();
  final modelNoController = TextEditingController();
  final serialNumberController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  // Reset all field values
  void resetFields() {
    assetNoController.clear();
    locationController.clear();
    substationController.clear();
    parentController.clear();
    descriptionController.clear();
    assetDescriptionController.clear();
    failureCodeController.clear();
    modelNoController.clear();
    serialNumberController.clear();
    latitudeController.clear();
    longitudeController.clear();
  }

  @override
  void onClose() {
    // Dispose all controllers to prevent memory leaks
    assetNoController.dispose();
    locationController.dispose();
    substationController.dispose();
    parentController.dispose();
    descriptionController.dispose();
    assetDescriptionController.dispose();
    failureCodeController.dispose();
    modelNoController.dispose();
    serialNumberController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.onClose();
  }

  //update asset details api
  Future updateAssetDetails(
    BuildContext context, {
    required String recordNo,
  }) async {
    context.loaderOverlay.show();
    final String username =
        (await SharedPreferencesHelper.getUsername())!.toUpperCase();
    log(
      "${{
        "apiReqId": "E1A24EA08EE34313AF8CA81260F1B3E9",
        "apiReqOrgnId": "C4B60E7B81554CC984EA8864D4248CB0",
        "apiAttachFlag": "",
        "apiUpdateFalg": "Y",
        "apiInsertFalg": "",
        "apiDeleteFalg": "",
        "apiReqUserId": username,
        "E1A24EA08EE34313AF8CA81260F1B3E9": [
         {    "REGISTER_COLUMN6": assetNoController.text,
              "CUSTOM_DH_COLUMN15": locationController.text,
              "BU_CUST_COL32": substationController.text,
              "BU_DH_CUST_COL27": parentController.text,
              "BU_DH_CUST_COL32": modelNoController.text,
              "BU_DH_CUST_COL31": serialNumberController.text,
              "MASTER_COLUMN5": descriptionController.text,
              "BU_DH_CUST_COL37": assetDescriptionController.text,
              "BU_DH_CUST_COL30": failureCodeController.text,
              "BU_CUST_COL34": '${latitudeController.text},${longitudeController.text}',
              "RECORD_NO": recordNo,
              "EDIT_BY": username,},
        ],
      }}",
    );
    try {
      final response = await ApiServices().requestPostForApi(
        url: "${host_url}updateInsertApiRequestData",
        dictParameter: {
          "apiReqId": "E1A24EA08EE34313AF8CA81260F1B3E9",
          "apiReqOrgnId": "C4B60E7B81554CC984EA8864D4248CB0",
          "apiAttachFlag": "",
          "apiUpdateFalg": "Y",
          "apiInsertFalg": "",
          "apiDeleteFalg": "",
          "apiReqUserId": username,
          "E1A24EA08EE34313AF8CA81260F1B3E9": [
            {
              "REGISTER_COLUMN6": assetNoController.text,
              "CUSTOM_DH_COLUMN15": locationController.text,
              "BU_CUST_COL32": substationController.text,
              "BU_DH_CUST_COL27": parentController.text,
              "BU_DH_CUST_COL32": modelNoController.text,
              "BU_DH_CUST_COL31": serialNumberController.text,
              "MASTER_COLUMN5": descriptionController.text,
              "BU_DH_CUST_COL37": assetDescriptionController.text,
              "BU_DH_CUST_COL30": failureCodeController.text,
              "BU_CUST_COL34": '${latitudeController.text},${longitudeController.text}',
              "RECORD_NO": recordNo,
              "EDIT_BY": username,
              
            },
          ],
        },
        authToken: false,
      );

      log("status ${response?.statusCode}");
      if (response?.statusCode == 200) {
        if (context.mounted) {
          context.loaderOverlay.hide();
          ToastCustom.successToast(context, "Asset Updated");
            if (context.mounted) {
                  Navigator.pop(context);
                }
        }
      } else {
        // ignore: use_build_context_synchronously
        context.loaderOverlay.hide();
        return Future.error('Error: ${response?.statusCode}');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      context.loaderOverlay.hide();
      log("error $e");
      return Future.error(e.toString());
    }
  }

  // Upload image or PDF method
  Future<void> uploadImageApi({
    required File? file,
    required String recordNumber,
    required String assetNumber,
    required BuildContext context,
    required bool isImage,
    String? editedFileName,
  }) async {
    try {
      if (file == null) {
        if (context.mounted) {
          ToastCustom.errorToast(context, "No file selected");
        }
        return;
      }

      if (context.mounted) {
        context.loaderOverlay.show();
      }

      final String base64Content = base64Encode(await file.readAsBytes());
      final int randomNo = math.Random().nextInt(1000);
      final String extension = isImage ? "jpg" : "pdf";
      final String attachType = isImage ? "Image" : "Document";
      
      // Determine filename: use editedFileName if provided, otherwise generate default
      final String filename = editedFileName ?? 
        "${assetNumber}_${isImage ? 'img' : 'pdf'}_$randomNo.$extension";

      final Map<String, dynamic> requestBody = {
        "apiReqId": "855A9F8A5A0A43E1BCD2A5C12546AB91",
        "apiReqOrgnId": "C4B60E7B81554CC984EA8864D4248CB0",
        "apiAttachFalg": "Y",
        "apiUpdateFalg": "",
        "apiInsertFalg": "",
        "apiDeleteFalg": "",
        "apiReqUserId": "TAQA_MGR",
        "855A9F8A5A0A43E1BCD2A5C12546AB91": [
          {
            "ACTIVE_FLAG": "Y",
            "FILE_NAME": filename,
            "REGION": "IN",
            "LOCALE": "en_US",
            "DEFAULT_FLAG": "N",
            "ATTACH_TYPE": attachType,
            "CONTENT": base64Content,
            "ATTACH_EXTENSION": extension,
            "TYPE": "P",
            "RECORD_NO": recordNumber,
          },
        ],
      };

      final response = await http.post(
        Uri.parse('${host_url}updateInsertApiRequestData'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          ToastCustom.successToast(context, "Uploaded Successfully");
        }
      } else {
        if (context.mounted) {
          ToastCustom.errorToast(
            context,
            "Upload failed: ${response.reasonPhrase}",
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ToastCustom.errorToast(context, "Error uploading file: $e");
      }
      
      // ignore: avoid_print
      print("Error in uploadImageApi: $e");
    } finally {
      if (context.mounted) {
        context.loaderOverlay.hide();
      }
    }
  }
}