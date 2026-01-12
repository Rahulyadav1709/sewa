import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:sewa/helpers/api_services.dart';
import 'package:sewa/view/home/components/asset_data_card.dart';
import 'package:sewa/view/parametric%20search/paramertic_search_result.dart';


class ParametricSearchController extends GetxController {
  // ignore: non_constant_identifier_names
  static late String host_url;

  @override
  void onInit() {
    super.onInit();
    host_url = dotenv.get("HOST_URL");
    getMdrmNumber("RECORD_NO", mdrmNumbers, isMdrmNumbersLoaded);

    getMdrmNumber(
      "REGISTER_COLUMN6",
      equipmentNumbers,
      isequipmentNumbersLoaded,
    );
    getMdrmNumber("BU_DH_CUST_COL31", serialNumber, isserialNumberLoaded);
    getMdrmNumber("BU_DH_CUST_COL32", modelNumber, ismodelNumberLoaded);
  }

  // Dummy data for dropdown fields
  RxList<String> mdrmNumbers = RxList();
  RxList<String> equipmentNumbers = RxList();

  RxList<String> serialNumber = RxList();
  RxList<String> modelNumber = RxList();

  // Operators including the new ones
  final List<String> operators = [
    '',
    '=',
    'LIKE',
    'IN',
    'NOT IN',
    'IS',
    'IS NOT',
    'NOT LIKE',
  ];

  // Selected values
  var selectedMdrmOperator = ''.obs;
  var selectedEquipmentOperator = ''.obs;

  var selectedSerialNumberOperator = ''.obs;
  var selectedModelNumberOperator = ''.obs;

  var selectedMdrmValue = ''.obs;
  var selectedEquipmentValue = ''.obs;

  var selectedSerialNumberValue = ''.obs;
  var selectedModelNumberValue = ''.obs;

  // Text controllers for manual input
  var mdrmTextController = TextEditingController();
  var equipmentTextController = TextEditingController();

  var serialNumberTextController = TextEditingController();
  var modelNumberTextController = TextEditingController();

  RxBool isMdrmNumbersLoaded =
      false.obs; // Used to determine if items are loaded
  RxBool isequipmentNumbersLoaded = false.obs;
  RxBool isserialNumberLoaded = false.obs;
  RxBool ismodelNumberLoaded = false.obs;

  // Search function
  void performSearch(BuildContext context) {
    sQLQuery = '';
    Navigator.push(
      context,
      CupertinoPageRoute<bool>(
        builder: (_) => const ParametricSearchResultScreen(),
      ),
    );
    //   generateSQLQuery();
  }

  //bar code scanner function
  final TextEditingController _barcodeController = TextEditingController();
  TextEditingController get barcodeScannerController => _barcodeController;
  // Future<void> scanBarcodeNormal(BuildContext context) async {
  //   String barcodeScanRes;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
  //         '#ff6666', 'Cancel', true, ScanMode.BARCODE);
  //     print(barcodeScanRes);
  //   } on PlatformException {
  //     barcodeScanRes = 'Failed to get platform version.';
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!context.mounted) return;

  //     //_scanBarcode = barcodeScanRes;
  //     barcodeScannerController.text = barcodeScanRes;

  // }

  //get dropdown value for mrdm number
  Future<List<String>> getMdrmNumber(
    String columnName,
    RxList<String> items,
    RxBool isItemLoaded,
  ) async {
    try {
      final response = await ApiServices().requestPostForApi(
        url: "${host_url}getApiRequestResultsData",
        dictParameter: {
          "apiReqId": "42BF27F12E8BF9BDE0630400010A444B",
          "apiReqCols": "'' AS EMPTY_COL ,$columnName",
          "apiReqWhereClause": "",
          "apiReqOrgnId": "42BF27F12E88F9BDE0630400010A444B",
          "apiReqUserId": "TAQA_MGR",
          "apiRetType": "JSON",
        },
        authToken: false,
      );

      log("status ${response?.statusCode}");
      if (response?.statusCode == 200) {
        var result = jsonDecode(response!.data.toString());
        for (var object in result!['apiDataArray']) {
          items.add(object[columnName].toString());
        }
        isItemLoaded.value = true;
        update();
        return items;
      } else {
        return Future.error('Error: ${response?.statusCode}');
      }
    } catch (e) {
      log("error $e");
      return Future.error(e.toString());
    }
  }

  //generate SQL Query
  List<String> whereConditions = [];
  String? finalQuery;
  String whereClause = "1";
  int offset = 0;
  int rows = 10;
  String generateSQLQuery() {
    finalQuery = "";
    whereConditions.clear();
    whereClause = '1';
    if (mdrmTextController.text != "") {
      if (!(selectedMdrmOperator.value != "")) {
        whereConditions.add(
          "  UPPER(RECORD_NO)  LIKE  UPPER( '%${mdrmTextController.text}%')",
        );
      } else if (selectedMdrmOperator.value != "" &&
          selectedMdrmOperator.value == "LIKE") {
        whereConditions.add(
          "  UPPER(RECORD_NO) ${selectedMdrmOperator.value}  UPPER( '%${mdrmTextController.text}%')",
        );
      } else if (selectedMdrmOperator.value != "" &&
          selectedMdrmOperator.value == "NOT LIKE") {
        whereConditions.add(
          "  UPPER(RECORD_NO) ${selectedMdrmOperator.value}  UPPER( '%${mdrmTextController.text}%')",
        );
      } else if (selectedMdrmOperator.value != "" &&
          selectedMdrmOperator.value == "=") {
        whereConditions.add(
          "  UPPER(RECORD_NO) ${selectedMdrmOperator.value}  UPPER( '${mdrmTextController.text}')",
        );
      } else if (selectedMdrmOperator.value != "" &&
          selectedMdrmOperator.value == "Beginning With") {
        whereConditions.add(
          "  UPPER(RECORD_NO) LIKE  UPPER( '${mdrmTextController.text}%')",
        );
      } else if (selectedMdrmOperator.value != "" &&
          selectedMdrmOperator.value == "Ending With") {
        whereConditions.add(
          "  UPPER(RECORD_NO) LIKE  UPPER( '%${mdrmTextController.text}')",
        );
      } else if (selectedMdrmOperator.value != "" &&
          selectedMdrmOperator.value == "IS") {
        whereConditions.add("  UPPER(RECORD_NO) IS NULL");
      } else if (selectedMdrmOperator.value != "" &&
          selectedMdrmOperator.value == "IS NOT") {
        whereConditions.add("  UPPER(RECORD_NO) IS NOT NULL");
      } else if (selectedMdrmOperator.value != "" &&
          selectedMdrmOperator.value == "IS NOT") {
        whereConditions.add("  UPPER(RECORD_NO) IS NOT NULL");
      } else {
        whereConditions.add(
          "  UPPER(RECORD_NO) ${selectedMdrmOperator.value}  UPPER( '${mdrmTextController.text}')",
        );
      }
    }

    if (equipmentTextController.text != "") {
      if (!(selectedEquipmentOperator.value != "")) {
        whereConditions.add(
          "  UPPER(REGISTER_COLUMN6)  LIKE  UPPER( '%${equipmentTextController.text}%')",
        );
      } else if (selectedEquipmentOperator.value != "" &&
          selectedEquipmentOperator.value == "LIKE") {
        whereConditions.add(
          "  UPPER(REGISTER_COLUMN6) ${selectedEquipmentOperator.value}  UPPER( '%${equipmentTextController.text}%')",
        );
      } else if (selectedEquipmentOperator.value != "" &&
          selectedEquipmentOperator.value == "NOT LIKE") {
        whereConditions.add(
          "  UPPER(REGISTER_COLUMN6) ${selectedEquipmentOperator.value}  UPPER( '%${equipmentTextController.text}%')",
        );
      } else if (selectedEquipmentOperator.value != "" &&
          selectedEquipmentOperator.value == "=") {
        whereConditions.add(
          "  UPPER(REGISTER_COLUMN6) ${selectedEquipmentOperator.value}  UPPER( '${equipmentTextController.text}')",
        );
      } else if (selectedEquipmentOperator.value != "" &&
          selectedEquipmentOperator.value == "Beginning With") {
        whereConditions.add(
          "  UPPER(REGISTER_COLUMN6) LIKE  UPPER( '${equipmentTextController.text}%')",
        );
      } else if (selectedEquipmentOperator.value != "" &&
          selectedEquipmentOperator.value == "Ending With") {
        whereConditions.add(
          "  UPPER(REGISTER_COLUMN6) LIKE  UPPER( '%${equipmentTextController.text}')",
        );
      } else if (selectedEquipmentOperator.value != "" &&
          selectedEquipmentOperator.value == "IS") {
        whereConditions.add("  UPPER(REGISTER_COLUMN6) IS NULL");
      } else if (selectedEquipmentOperator.value != "" &&
          selectedEquipmentOperator.value == "IS NOT") {
        whereConditions.add("  UPPER(REGISTER_COLUMN6) IS NOT NULL");
      } else if (selectedEquipmentOperator.value != "" &&
          selectedEquipmentOperator.value == "IS NOT") {
        whereConditions.add("  UPPER(REGISTER_COLUMN6) IS NOT NULL");
      } else {
        whereConditions.add(
          "  UPPER(REGISTER_COLUMN6) ${selectedEquipmentOperator.value}  UPPER( '${equipmentTextController.text}')",
        );
      }
    }

    ///////// serial
    if (serialNumberTextController.text != "") {
      if (!(selectedSerialNumberOperator.value != "")) {
        whereConditions.add(
          "  UPPER(BU_DH_CUST_COL31)  LIKE  UPPER( '%${serialNumberTextController.text}%')",
        );
      } else if (selectedSerialNumberOperator.value != "" &&
          selectedSerialNumberOperator.value == "LIKE") {
        whereConditions.add(
          "  UPPER(BU_DH_CUST_COL31) ${selectedSerialNumberOperator.value}  UPPER( '%${serialNumberTextController.text}%')",
        );
      } else if (selectedSerialNumberOperator.value != "" &&
          selectedSerialNumberOperator.value == "NOT LIKE") {
        whereConditions.add(
          "  UPPER(BU_DH_CUST_COL31) ${selectedSerialNumberOperator.value}  UPPER( '%${serialNumberTextController.text}%')",
        );
      } else if (selectedSerialNumberOperator.value != "" &&
          selectedSerialNumberOperator.value == "=") {
        whereConditions.add(
          "  UPPER(BU_DH_CUST_COL31) ${selectedSerialNumberOperator.value}  UPPER( '${serialNumberTextController.text}')",
        );
      } else if (selectedSerialNumberOperator.value != "" &&
          selectedSerialNumberOperator.value == "Beginning With") {
        whereConditions.add(
          "  UPPER(BU_DH_CUST_COL31) LIKE  UPPER( '${serialNumberTextController.text}%')",
        );
      } else if (selectedSerialNumberOperator.value != "" &&
          selectedSerialNumberOperator.value == "Ending With") {
        whereConditions.add(
          "  UPPER(BU_DH_CUST_COL31) LIKE  UPPER( '%${serialNumberTextController.text}')",
        );
      } else if (selectedSerialNumberOperator.value != "" &&
          selectedSerialNumberOperator.value == "IS") {
        whereConditions.add("  UPPER(BU_DH_CUST_COL31) IS NULL");
      } else if (selectedSerialNumberOperator.value != "" &&
          selectedSerialNumberOperator.value == "IS NOT") {
        whereConditions.add("  UPPER(BU_DH_CUST_COL31) IS NOT NULL");
      } else if (selectedSerialNumberOperator.value != "" &&
          selectedSerialNumberOperator.value == "IS NOT") {
        whereConditions.add("  UPPER(BU_DH_CUST_COL31) IS NOT NULL");
      } else {
        whereConditions.add(
          "  UPPER(BU_DH_CUST_COL31) ${selectedSerialNumberOperator.value}  UPPER( '${serialNumberTextController.text}')",
        );
      }
    }
    if (modelNumberTextController.text != "") {
      if (!(selectedModelNumberOperator.value != "")) {
        whereConditions.add(
          "  UPPER(BU_DH_CUST_COL32)  LIKE  UPPER( '%${modelNumberTextController.text}%')",
        );
      } else if (selectedModelNumberOperator.value != "" &&
          selectedModelNumberOperator.value == "LIKE") {
        whereConditions.add(
          "  UPPER(BU_DH_CUST_COL32) ${selectedModelNumberOperator.value}  UPPER( '%${modelNumberTextController.text}%')",
        );
      } else if (selectedModelNumberOperator.value != "" &&
          selectedModelNumberOperator.value == "NOT LIKE") {
        whereConditions.add(
          "  UPPER(BU_DH_CUST_COL32) ${selectedModelNumberOperator.value}  UPPER( '%${modelNumberTextController.text}%')",
        );
      } else if (selectedModelNumberOperator.value != "" &&
          selectedModelNumberOperator.value == "=") {
        whereConditions.add(
          "  UPPER(BU_DH_CUST_COL32) ${selectedModelNumberOperator.value}  UPPER( '${modelNumberTextController.text}')",
        );
      } else if (selectedModelNumberOperator.value != "" &&
          selectedModelNumberOperator.value == "Beginning With") {
        whereConditions.add(
          "  UPPER(BU_DH_CUST_COL32) LIKE  UPPER( '${modelNumberTextController.text}%')",
        );
      } else if (selectedModelNumberOperator.value != "" &&
          selectedModelNumberOperator.value == "Ending With") {
        whereConditions.add(
          "  UPPER(BU_DH_CUST_COL32) LIKE  UPPER( '%${modelNumberTextController.text}')",
        );
      } else if (selectedModelNumberOperator.value != "" &&
          selectedModelNumberOperator.value == "IS") {
        whereConditions.add("  UPPER(BU_DH_CUST_COL32) IS NULL");
      } else if (selectedModelNumberOperator.value != "" &&
          selectedModelNumberOperator.value == "IS NOT") {
        whereConditions.add("  UPPER(BU_DH_CUST_COL32) IS NOT NULL");
      } else if (selectedModelNumberOperator.value != "" &&
          selectedModelNumberOperator.value == "IS NOT") {
        whereConditions.add("  UPPER(BU_DH_CUST_COL32) IS NOT NULL");
      } else {
        whereConditions.add(
          "  UPPER(BU_DH_CUST_COL32) ${selectedModelNumberOperator.value}  UPPER( '${modelNumberTextController.text}')",
        );
      }
    }
    if (whereConditions.isNotEmpty) {
      whereClause = whereConditions.join(" AND ").toUpperCase();
    }

    finalQuery = "${whereClause}AND RECORD_NO IS NOT NULL";

    return finalQuery ?? "";
  }

  //parametric search api
  late Future<List<AssetDataCard>> getParametricSearchResultFuture;
  final List<AssetDataCard> assetCardList = [];
  String sQLQuery = '';
  Future<List<AssetDataCard>> parametricSearch() async {
    sQLQuery = generateSQLQuery();
    assetCardList.clear();
    try {
      final response = await ApiServices().requestPostForApi(
        url: "${host_url}getApiRequestResultsData",
        dictParameter: {
          "apiReqId": "42BF27F12E8BF9BDE0630400010A444B",
          "apiReqCols": "",
          "apiReqWhereClause": sQLQuery,
          "apiReqOrgnId": "42BF27F12E88F9BDE0630400010A444B",
          "apiReqUserId": "TAQA_MGR",
          "apiRetType": "JSON",
        },
        authToken: false,
      );

      log("status ${response?.statusCode}");
      if (response?.statusCode == 200) {
        var result = jsonDecode(response!.data.toString());
        for (var object in result!['apiDataArray']) {
          assetCardList.add(
            AssetDataCard(
              data: AssetData(
                clientNumber: object["BU_DH_CUST_COL53"],
                updateLat:
                    object["BU_DH_CUST_COL35"] == null
                        ? null
                        : object["BU_DH_CUST_COL35"].toString().split(',')[0],
                updateLong:
                    object["BU_DH_CUST_COL35"] == null
                        ? null
                        : object["BU_DH_CUST_COL35"].toString().split(',')[1],
                subSatationNumber: object["BU_CUST_COL32"],
                modelNo: object["BU_DH_CUST_COL32"],
                parent: object["BU_DH_CUST_COL27"],
                serialNo: object["BU_DH_CUST_COL31"],
                location: object["CUSTOM_DH_COLUMN15"],
                assetNo: object["REGISTER_COLUMN6"],
                failurecode: object["BU_DH_CUST_COL30"],
                longDesc: object["BU_DH_CUST_COL37"],
                recordNo: object["RECORD_NO"],
                status: object["STATUS"],
                shortDescription: object["MASTER_COLUMN5"],
                equipmentNumber: object["BU_DH_CUST_COL53"],
                techId: object["REGISTER_COLUMN6"],
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
                pilogComment: object["CUSTOM_COLUMN12"],
                editBy: object["EDIT_BY"],
                 assetTaggingType: object["BU_DH_CUST_COL62"],
              ),
            ),
          );
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
}
