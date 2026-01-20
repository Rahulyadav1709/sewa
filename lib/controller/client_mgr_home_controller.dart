import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sewa/global/widgets/pdf_scanner/pdf_viewer.dart';
import 'package:sewa/global/widgets/stacked_card.dart';
import 'package:sewa/helpers/api_services.dart';
import 'package:sewa/helpers/shared_preferences_helpers.dart';
import 'package:sewa/helpers/toasts.dart';
import 'package:sewa/model/asset_image_model.dart';
import 'package:sewa/model/image_upload_response_model.dart';
import 'package:sewa/view/auth%20screens/login_screen.dart';
import 'package:sewa/view/home/components/asset_data_card.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ClientMgrHomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static late String host_url;
  // Animation controllers
  late Animation<double> animation;
  late AnimationController animationController;

  // Text editing controller
  final TextEditingController pilogCommentsController = TextEditingController();
  final TextEditingController taqaCommentsController = TextEditingController();
  

  TextEditingController searchController = TextEditingController();
  RxDouble updateLatitude = 0.0.obs;
  RxDouble updateLongitude = 0.0.obs;
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;

  GoogleMapController? mapController;

  Rx<LocationPermission> locationPermission = LocationPermission.denied.obs;

  // Flag to prevent concurrent location requests
  RxBool isLocationLoading = false.obs;

  // Method to get the user's current location
  Future<void> getLocation({bool requestIfNeeded = true}) async {
    // Prevent concurrent calls
    if (isLocationLoading.value) return;

    bool serviceEnabled;
    LocationPermission permission;

    try {
      isLocationLoading.value = true;

      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled
        isLocationLoading.value = false;
        return;
      }

      // Check current permission status
      permission = await Geolocator.checkPermission();
      print("Current permission status: $permission");
      
      // Request permission only if requested and status is denied
      if (requestIfNeeded && permission == LocationPermission.denied) {
        print("Requesting location permission...");
        permission = await Geolocator.requestPermission();
        print("Permission after request: $permission");
      }

      // Update the reactive variable once at the end of decision logic
      locationPermission.value = permission;

      // If permissions are denied, stop here
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        print("Permission denied or permanently denied: $permission");
        isLocationLoading.value = false;
        return;
      }

      // Fetch the current position if permission is granted
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Update latitude and longitude
      latitude.value = position.latitude;
      longitude.value = position.longitude;

      // Update map if controller is available
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(LatLng(latitude.value, longitude.value)),
        );
      }
    } catch (e) {
      print("Error in getLocation: $e");
    } finally {
      isLocationLoading.value = false;
    }
  }

  Future<void> openSettings({BuildContext? context}) async {
    try {
      bool opened = await Geolocator.openAppSettings();
      print("📱 Settings opened: $opened");
      if (!opened && context != null) {
        ToastCustom.errorToast(context, "Could not open settings automatically. Please open them manually via your device settings.");
      }
    } catch (e) {
      print("❌ Error opening settings: $e");
      if (context != null) {
        ToastCustom.errorToast(context, "Error: $e");
      }
    }
  }

  void setGoogleMapController(GoogleMapController controller) {
    mapController = controller;
  }

  void updateMarkerPosition(LatLng newPosition) {
    latitude.value = newPosition.latitude;
    longitude.value = newPosition.longitude;
  }

  // Method to animate the camera to a specific position
  void animateCameraTo(LatLng position, double zoom) {
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: zoom),
        ),
      );
    }
    update();
  }

  // Bools
  RxBool isAssetDataLoaded = RxBool(false);
  late Future getAssetdataFuture;
  late Future getImgFuture;
  var logindata;

  @override
  void onInit() {
    super.onInit();
    host_url = dotenv.get("HOST_URL");
    loadSavedItems();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation = CurvedAnimation(
      curve: Curves.easeInOut,
      parent: animationController,
    );
    animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  @override
  void dispose() {
    taqaCommentsController.dispose();
    pilogCommentsController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  void toggleAnimation() {
    if (animationController.isCompleted) {
      animationController.reverse();
    } else {
      animationController.forward();
    }
  }

  void onParametricSearch(context) {
    toggleAnimation();
  }

  void onLogout(BuildContext context) {
    //  toggleAnimation();
    logoutAPI(context);
    // Handle Logout action here
  }

  onTapSearch() async {
    String? username = await SharedPreferencesHelper.getRole();
    isAssetDataLoaded.value = true;
    log("shared : $username");
    getAssetdataFuture = getAssetData(
      offset: 0,
      rows: 10,
      value: searchController.text,
    );
    update();
  }

  //check base64 string for pdf and image

  bool isImageOrPdf(String base64String) {
    // Remove MIME type prefix if present
    final regex = RegExp(r'^data:([a-zA-Z0-9]+/[a-zA-Z0-9-.+]+).*,');
    String cleanBase64 = base64String.replaceAll(regex, '');

    // Decode the Base64 string to bytes
    Uint8List bytes = base64.decode(cleanBase64);

    // Check the first few bytes for common file signatures
    if (bytes.length >= 4) {
      // PDF files typically start with "%PDF"
      if (bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46) {
        print('This is a PDF file.');
        return false;
      }
      // JPEG files typically start with "FFD8" and PNG files with "89504E47"
      else if ((bytes[0] == 0xFF && bytes[1] == 0xD8) ||
          (bytes[0] == 0x89 &&
              bytes[1] == 0x50 &&
              bytes[2] == 0x4E &&
              bytes[3] == 0x47)) {
        print('This is an image file.');
        return true;
      }
    }
    print('Unknown file type.');
    return false; // Return null or throw an error if the type can't be determined
  }

  //show pdf
  Future<void> showPDF(
    BuildContext context,
    String base64Pdf,
    String fileName,
  ) async {
    final bytes = base64.decode(base64Pdf);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/temp.pdf');
    await file.writeAsBytes(bytes);
    if (context.mounted) {
      Navigator.push(
        context,
        CupertinoPageRoute<bool>(
          builder:
              (_) => PDFScreen(
                pdfPath: file.path,
                fileName: fileName,
                //   fileName: fileName,
              ),
        ),
      );
    }
  }

  //show images
  showImages(BuildContext context, String base64String, String title) {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: PhotoView(
                enablePanAlways: true,
                imageProvider: MemoryImage(base64Decode(base64String)),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              ),
            ),
          ],
        );
      },
    );
  }

  // APIS
  List<Widget> assetCardList = [];
  Future getAssetData({
    required String value,
    required int offset,
    required int rows,
  }) async {
    assetCardList.clear();
    String finalquery =
        "UPPER (REGISTER_COLUMN6) LIKE UPPER ('$value') OR UPPER (CUSTOM_DH_COLUMN15) LIKE UPPER ('$value') OR UPPER (BU_DH_CUST_COL27) LIKE UPPER ('$value') OR UPPER (RECORD_NO) LIKE UPPER ('$value') AND RECORD_NO IS NOT NULL OFFSET $offset ROWS FETCH NEXT $rows ROWS ONLY";
// ignore: avoid_print
print("data$finalquery");
    // if (role == 'PM_FAR_IDAM_CLIENT_MGR') {
    //   reqid = "FEC608B8AA8BB026E0538400000AFD69";
    // } else if (role == 'PM_FAR_IDAM_CLIENT_QC') {
    //   reqid = 'FEC608B8AA89B026E0538400000AFD69';
    // }

    try {
      final response = await ApiServices().requestPostForApi(
        url: "${host_url}getApiRequestResultsData",
        dictParameter: {
          "apiReqId": "42BF27F12E8BF9BDE0630400010A444B",
          "apiReqCols": "STG_NO,STG_COLUMN1,ERP_NO,CLASS_TERM,STG_COLUMN8,STG_COLUMN9,STG_COLUMN5,STG_COLUMN6,STG_COLUMN7,BATCH_ID,STG_COLUMN2,STG_COLUMN3,CREATE_DATE,CREATE_BY,EDIT_DATE,EDIT_BY,AUDIT_ID,STG_COLUMN12,DOMAIN,STG_COLUMN11,STG_COLUMN10,REGISTER_COLUMN8,STG_TYPE,ORGN_ID,CONCEPT_ID,MASTER_COLUMN10,RECORD_NO,STATUS,APPROVED_BY,CUSTOM_COLUMN5,ERPSFD,PURCHASE,F_ERPSFD,F_PURCHASE,FULL_PO,REGISTER_COLUMN7,REGISTER_COLUMN5,P_CNT,CUSTOM_COLUMN15,CUSTOM_COLUMN6,ABBREVIATION,MASTER_COLUMN9,MASTER_COLUMN15,REGISTER_COLUMN15,REGISTER_COLUMN13,TEST_CERT_COMMENT,TEST_CERTIFICATE,DR_ID5,DR_ID4,DR_ID3,CUSTOM_COLUMN8,CUSTOM_COLUMN13,CUSTOM_COLUMN11,BU_CUST_COL35,CUSTOM_COLUMN14,CUSTOM_COLUMN12,BU_CUST_COL33,DR_ID2,BU_CUST_COL31,REGISTER_COLUMN9,REGISTER_COLUMN10,BU_CUST_COL16,BU_CUST_COL17,BU_CUST_COL18,BU_CUST_COL19,BU_CUST_COL20,BU_CUST_COL21,BU_CUST_COL22,BU_CUST_COL23,BU_CUST_COL24,BU_CUST_COL25,BU_CUST_COL26,BU_CUST_COL27,BU_CUST_COL28,BUSINESS_UNIT,BU_CUST_COL34,BU_CUST_COL29,BU_CUST_COL30,PROJECT,BU_CUST_COL32,CUSTOM_COLUMN9,MASTER_COLUMN5,MASTER_COLUMN6,REGISTER_COL_DESC,MODIFY_FLAG,ENRICH_IND,CUSTOM_COLUMN7,CUSTOM_COLUMN10,REGISTER_COLUMN6,REGISTER_COLUMN11,REGISTER_COLUMN12,MASTER_COLUMN7,MASTER_COLUMN8,MASTER_COLUMN11,MASTER_COLUMN12,MASTER_COLUMN13,MASTER_COLUMN14,REGISTER_COLUMN14,HSN_CODE,SAC_CODE,CUSTOM_DH_COLUMN5,CUSTOM_DH_COLUMN6,CUSTOM_DH_COLUMN7,CUSTOM_DH_COLUMN8,CUSTOM_DH_COLUMN9,CUSTOM_DH_COLUMN10,CUSTOM_DH_COLUMN11,CUSTOM_DH_COLUMN12,CUSTOM_DH_COLUMN13,CUSTOM_DH_COLUMN14,CUSTOM_DH_COLUMN15,BU_DH_CUST_COL16,BU_DH_CUST_COL17,BU_DH_CUST_COL18,BU_DH_CUST_COL19,BU_DH_CUST_COL20,BU_DH_CUST_COL21,BU_DH_CUST_COL22,BU_DH_CUST_COL23,BU_DH_CUST_COL24,BU_DH_CUST_COL25,BU_DH_CUST_COL26,BU_DH_CUST_COL27,BU_DH_CUST_COL28,BU_DH_CUST_COL29,BU_DH_CUST_COL30,BU_DH_CUST_COL31,BU_DH_CUST_COL32,BU_DH_CUST_COL33,BU_DH_CUST_COL34,BU_DH_CUST_COL35,BU_DH_CUST_COL37,BU_DH_CUST_COL38,BU_DH_CUST_COL39,BU_DH_CUST_COL40,BU_DH_CUST_COL41,BU_DH_CUST_COL42,BU_DH_CUST_COL43,BU_DH_CUST_COL44,BU_DH_CUST_COL45,BU_DH_CUST_COL46,BU_DH_CUST_COL47,BU_DH_CUST_COL48,BU_DH_CUST_COL49,DISCIPLINE,BU_DH_CUST_COL51,BU_DH_CUST_COL52,BU_DH_CUST_COL53,BU_DH_CUST_COL54,BU_DH_CUST_COL55,BU_DH_CUST_COL56,BU_DH_CUST_COL57,BU_DH_CUST_COL58,BU_DH_CUST_COL59,BU_DH_CUST_COL60,BU_DH_CUST_COL61,BU_DH_CUST_COL62,BU_DH_CUST_COL63,BU_DH_CUST_COL64,BU_DH_CUST_COL65,PRIORITY_IND,VS_APPROVED,UNSPSC_CODE,UNSPSC_DESC",
          "apiReqWhereClause": finalquery,
          "apiReqOrgnId": "42BF27F12E88F9BDE0630400010A444B",
          "apiReqUserId": "SEWA_MGR",
          "apiRetType": "JSON",
        },
        authToken: false,
      );

      log("status ${response?.statusCode}");
      if (response?.statusCode == 200) {
        var result = jsonDecode(response!.data.toString());
        for (var object in result!['apiDataArray']) {
          if (object['STATUS'] != "Newly Found") {
            assetCardList.add(
              AssetDataCard(
                data: AssetData(
                  clientNumber: object["BU_DH_CUST_COL53"],
                  substationName: object["BU_CUST_COL20"],
                  pilogComment: object["CUSTOM_COLUMN12"],
                  editBy: object["EDIT_BY"],
                  subSatationNumber: object["BU_CUST_COL32"],
                  modelNo: object["BU_DH_CUST_COL32"],
                  parent: object["BU_DH_CUST_COL27"],
                  serialNo: object["BU_DH_CUST_COL31"],
                  location: object["CUSTOM_DH_COLUMN15"],
                  assetNo: object["REGISTER_COLUMN6"],
                  updateLat:
                      object["BU_DH_CUST_COL35"] == null
                          ? null
                          : object["BU_DH_CUST_COL35"].toString().split(',')[0],
                  updateLong:
                      object["BU_DH_CUST_COL35"] == null
                          ? null
                          : object["BU_DH_CUST_COL35"].toString().split(',')[1],
                  failurecode: object["BU_DH_CUST_COL30"],
                  longDesc: object["BU_DH_CUST_COL37"],
                  recordNo: object["RECORD_NO"],
                  status: object["STATUS"],
                  shortDescription: object["MASTER_COLUMN5"],
                  equipmentNumber: object["BU_DH_CUST_COL53"],
                  lat:
                      object["BU_CUST_COL34"] == null
                          ? null
                          : object["BU_CUST_COL34"].toString().split(',')[0],
                  long:
                      object["BU_CUST_COL34"] == null
                          ? null
                          : object["BU_CUST_COL34"].toString().split(',')[1],
                  floc: object["BU_CUST_COL32"],
                  flocDesc: object["FLOC_DESCRIPTION"],
                  assetTaggingType: object["BU_DH_CUST_COL62"],
                ),
              ),
            );
          }
        }
        log("adataaaaaa ${result!['apiDataArray'][0]["RECORD_NO"]}");
        return assetCardList;
      } else {
        return Future.error('Error: ${response?.statusCode}');
      }
    } catch (e) {
      log("error $e");
      return Future.error(e.toString());
    }
  }

  // Future<void> updateClientMgrQcRecord({
  //   required String recordNo,
  //   required String masterColumn14,
  //   required String masterColumn13,
  // }) async {
  //   const String hostUrl = "https://ifar.pilogcloud.com/";
  //   const String reqid = "FEC608B8AA8EB026E0538400000AFD69";
  //   const String orgnId = "C1F5CFB03F2E444DAE78ECCEAD80D27D";
  //   final String username =
  //       (await SharedPreferencesHelper.getUsername())!.toUpperCase();

  //   var headers = {'Content-Type': 'application/json'};
  //   var body = json.encode({
  //     "apiReqId": reqid,
  //     "apiReqCols": {
  //       "RECORD_NO": recordNo,
  //       "MASTER_COLUMN14": masterColumn14,
  //       "MASTER_COLUMN13": masterColumn13,
  //     },
  //     "apiReqWhereClause": "RECORD_NO='$recordNo'",
  //     "apiReqOrgnId": orgnId,
  //     "apiReqUserId": username,
  //     "apiRetType": "JSON",
  //   });

  //   var response = await http.post(
  //     Uri.parse("${hostUrl}updateApiRequestResultsData"),
  //     headers: headers,
  //     body: body,
  //   );

  //   if (response.statusCode == 200) {
  //     var result = jsonDecode(response.body);
  //     log("Update Successful: $result");
  //   } else {
  //     log("Error: ${response.statusCode}");
  //   }
  // }

  // //fetch image
  // RxList<ApiDataArray> imageList = RxList();
  // Future<AssetImageModel> fetchImage({required String recordNo}) async {
  //   log("executed");
  //   imageList.clear();
  //   AssetImageModel? imageData;
  //   try {
  //     final response = await ApiServices().requestPostForApi(
  //       url: "${host_url}getApiRequestResultsData",
  //       dictParameter: {
  //         "apiReqId": "6085DAB947664BEAB39921AC425BB71A",
  //         "apiReqCols": "",
  //         "apiReqWhereClause": "RECORD_NO = '$recordNo'",
  //         "apiReqOrgnId": "C4B60E7B81554CC984EA8864D4248CB0",
  //         "apiReqUserId": "TAQA_MGR",
  //         "apiRetType": "JSON",
  //       },
  //       authToken: false,
  //     );

  //     if (response?.statusCode == 200) {
  //       imageData = AssetImageModel.fromJson(response!.data);
  //       imageList.add(imageData.apiDataArray);

  //     }

  //     //   try {
  //     //     Finaldata = jsonDecode(response.body);
  //     //     imageData = AssetImageModel.fromJson(Finaldata);
  //     //     log("Image Data: ${imageData.apiDataArray!.length}");
  //     //     update();
  //     //     return imageData;
  //     //   } catch (e) {
  //     //     log("JSON decode error: $e");
  //     //     return imageData!;
  //     //   }
  //     // } else {
  //     //   log("Error: ${response.reasonPhrase}");
  //     //   return imageData!;
  //     // }
  //   } catch (error) {}
  // }

  // Reactive list to manage images
  final RxList<ApiDataArray> imageList = RxList<ApiDataArray>();

  // Method to fetch images
  // Function to fetch images based on a record number
  Future<AssetImageModel> fetchImages({required String recordNo}) async {
    try {
      final response = await ApiServices().requestPostForApi(
        url: "${host_url}getApiRequestResultsData",
        dictParameter: {
          "apiReqId": "955A9F8A5A0A43E1BCD2A5C12546AB91",
          "apiReqCols": "",
          "apiReqWhereClause": "RECORD_NO = '$recordNo'",
          "apiReqOrgnId": "42BF27F12E88F9BDE0630400010A444B",
          "apiReqUserId": "SEWA_MGR",
          "apiRetType": "JSON",
        },
        authToken: false,
      );

      if (response?.statusCode == 200) {
        final initialData = json.decode(response!.data);
        final imageModel = AssetImageModel.fromJson(initialData);

        // Update the image list
        imageList.value = imageModel.apiDataArray ?? [];
        return imageModel;
      } else {
        throw Exception('Failed to load images');
      }
    } catch (error) {
      log("Error fetching images: $error");
      throw Exception('Failed to load images');
    }
  }

  // Upload image method
  Future<void> uploadImageApi({
    required File? file,
    required String recordNumber,
    required String assetNumber,
    required BuildContext context,
    required bool isImage,
    String? editedFileName, // New optional parameter
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

      // Determine filename: use editedFileName if provided, otherwise generate default
      final String filename =
          editedFileName ??
          "${assetNumber}_${isImage ? 'img' : 'pdf'}_$randomNo.$extension";

      final Map<String, dynamic> requestBody = {

        "apiReqId": "955A9F8A5A0A43E1BCD2A5C12546AB91",
        "apiReqOrgnId": "42BF27F12E88F9BDE0630400010A444B",
        "apiAttachFalg": "Y",
        "apiUpdateFalg": "",
        "apiInsertFalg": "",
        "apiDeleteFalg": "",
        "apiReqUserId": "SEWA_MGR",
        "955A9F8A5A0A43E1BCD2A5C12546AB91": [
          {
            "ACTIVE_FLAG": "Y",
            "FILE_NAME": filename,
            "REGION": "IN",
            "LOCALE": "en_US",
            "DEFAULT_FLAG": "N",
            "ATTACH_TYPE": "Image",
            "CONTENT": base64Content,
            "ATTACH_EXTENSION": "jpg",
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
        final responseData = json.decode(response.body);
        // ignore: unused_local_variable
        final uploadResponse = ImageUploadResponseModel.fromJson(responseData);

        // Refresh the image list
        // ignore: unused_local_variable
        final updatedImages = await fetchImages(recordNo: recordNumber);

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
      print("Error in uploadImageApi: $e");
    } finally {
      if (context.mounted) {
        context.loaderOverlay.hide();
      }
    }
  }
  
  // Delete image method
  Future<void> imageDeleteApi({
    required String auditID,
    required String recordNo,
    required BuildContext context,
    required int index,
  }) async {
    try {
      var dictParameter = {
        "apiReqId": "42BF27F12E8BF9BDE0630400010A444B",
        "apiReqOrgnId": "42BF27F12E88F9BDE0630400010A444B",
        "apiAttachFlag": "",
        "apiUpdateFalg": "",
        "apiInsertFalg": "",
        "apiDeleteFalg": "Y",
        "apiReqUserId": "TAQA_MGR",
        "42BF27F12E8BF9BDE0630400010A444B": [
          {"AUDIT_ID": auditID, "RECORD_NO": recordNo},
        ],
      };

      // Call the API
      var response = await ApiServices().requestPostForApi(
        url: '${host_url}updateInsertApiRequestData',
        dictParameter: dictParameter,
        authToken: false,
      );

      if (response != null && response.statusCode == 200) {
        // Refresh the image list after successful deletion
        await fetchImages(recordNo: recordNo);

        ToastCustom.successToast(context, "Deleted Successfully");
      } else {
        ToastCustom.errorToast(context, "Failed to delete");

        log("Delete operation failed");
      }
    } catch (e) {
      ToastCustom.errorToast(context, "Error deleting file: $e");

      log("Error in imageDeleteApi: $e");
    }
  }

  //logout api
  Future<void> logoutAPI(BuildContext context) async {
    Get.deleteAll();
    await SharedPreferencesHelper.clearAll();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute<bool>(builder: (_) => const LoginScreen()),
      );
      ToastCustom.infoToast(context, "Logged out");
    }
  }

  Future updateAssetLocation(
    BuildContext context, {
    required String recordNo,
    required String latitude,
    required String longitude,
    required String status,
    required String username,
  }) async {
    context.loaderOverlay.show();
    log(
      "${{
        "apiReqId": "42BF27F12E8BF9BDE0630400010A444B",
        "apiReqOrgnId": "42BF27F12E88F9BDE0630400010A444B",
        "apiAttachFlag": "",
        "apiUpdateFalg": "Y",
        "apiInsertFalg": "",
        "apiDeleteFalg": "",
        "apiReqUserId": username,
        "42BF27F12E8BF9BDE0630400010A444B": [
          {"RECORD_NO": recordNo, "BU_DH_CUST_COL35": "$latitude,$longitude", "STATUS": status},
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
              "RECORD_NO": recordNo,
              "BU_DH_CUST_COL35": "$latitude,$longitude",

              "STATUS": status,
            },
          ],
        },
        authToken: false,
      );

      log("status ${response?.statusCode}");
      if (response?.statusCode == 200) {
        if (context.mounted) {
          context.loaderOverlay.hide();
          ToastCustom.successToast(context, "Location Updated");
        }
        return;
      } else {
        context.loaderOverlay.hide();

        return Future.error('Error: ${response?.statusCode}');
      }
    } catch (e) {
      context.loaderOverlay.hide();

      log("error $e");
      return Future.error(e.toString());
    }
  }

  //get equipment and tech id list
  RxList<CardItem> savedItems = RxList();
  Future<void> loadSavedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList('favorites') ?? [];

    // Decode JSON strings into CardItem objects
    final items =
        favorites.map((item) {
          final jsonData = jsonDecode(item);
          return CardItem(
            title: jsonData['techId'] ?? 'Unknown Tech ID',
            date: jsonData['failurecode'] ?? 'No Date',
            subtitle: jsonData['equipmentNumber'] ?? 'No Equipment Number',
          );
        }).toList();

    savedItems.value = items;
    update();
  }

  List<CardItem> cardItems = [];
  Future<List<CardItem>> getMdrmNumber(
    String columnName,
    RxList<String> items,
    RxBool isItemLoaded,
  ) async {
    try {
      final response = await ApiServices().requestPostForApi(
        url: "${host_url}getApiRequestResultsData",
        dictParameter: {
          "apiReqId": "7B105EDE59C442D585198D501FED3B51",
          "apiReqCols": "'' AS EMPTY_COL ,$columnName",
          "apiReqWhereClause": "",
          "apiReqOrgnId": "C4B60E7B81554CC984EA8864D4248CB0",
          "apiReqUserId": "TAQA_MGR",
          "apiRetType": "JSON",
        },
        authToken: false,
      );

      log("status ${response?.statusCode}");
      if (response?.statusCode == 200) {
        var result = jsonDecode(response!.data.toString());
        for (var object in result!['apiDataArray']) {
          cardItems.add(object[columnName]);
        }
        log("adataaaaaa ${cardItems.length}");
        isItemLoaded.value = true;
        update();
        return cardItems;
      } else {
        return Future.error('Error: ${response?.statusCode}');
      }
    } catch (e) {
      log("error $e");
      return Future.error(e.toString());
    }
  }

  //update asset detalis api
  Future updateAssetDetails(
    BuildContext context, {
    required String recordNo,
    required String clientComment,
    required String pilogComment,
    required String status,
    required String username,
    required String assetTaggingType,
  }) async {
    context.loaderOverlay.show();
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
          {"RECORD_NO": recordNo, "STATUS": status, "BU_DH_CUST_COL60 ": taqaCommentsController.text, "CUSTOM_COLUMN12": pilogCommentsController.text, "EDIT_BY": username,"BU_DH_CUST_COL62":assetTaggingType},
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
              "RECORD_NO": recordNo,
              "STATUS": status,
              "BU_DH_CUST_COL60 ": taqaCommentsController.text,
              "CUSTOM_COLUMN12": pilogCommentsController.text,
              "EDIT_BY": username,
              "BU_DH_CUST_COL62": assetTaggingType,
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
        }
        return;
      } else {
        context.loaderOverlay.hide();

        return Future.error('Error: ${response?.statusCode}');
      }
    } catch (e) {
      context.loaderOverlay.hide();

      log("error $e");
      return Future.error(e.toString());
    }
  }
}
