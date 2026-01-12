import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:sewa/helpers/api_services.dart';
import 'package:sewa/view/home/components/asset_data_card.dart';


class ParentController extends GetxController {
  static late String host_url;

  @override
  void onInit() {
    super.onInit();
    host_url = dotenv.get("HOST_URL");
  }

  //Parent api
  static final List<String> _ParentIds = [];
  List<String> get ParentIds => _ParentIds;
  late Future<List<String>> getParentIdsFuture;
  Future<List<String>> getParentInfoApi() async {
    _ParentIds.clear();
    try {
      final response = await ApiServices().requestPostForApi(
        url: "${host_url}getApiRequestResultsData",
        dictParameter: {
          "apiReqId": "7B105EDE59C442D585198D501FED3B51",
          "apiReqCols": "'' AS EMPTY_COL, RECORD_NO,BU_DH_CUST_COL27",
          "apiReqWhereClause": "",
          "apiReqOrgnId": "C4B60E7B81554CC984EA8864D4248CB0",
          "apiReqUserId": "",
          "apiRetType": "JSON",
        },
        authToken: false,
      );

      log("status ${response?.statusCode}");
      if (response?.statusCode == 200) {
        var result = jsonDecode(response!.data.toString());
        for (var object in result!['apiDataArray']) {
          _ParentIds.add(object["BU_DH_CUST_COL27"].toString());
        }
        return ParentIds;
      } else {
        return Future.error('Error: ${response?.statusCode}');
      }
    } catch (e) {
      log("error $e");
      return Future.error(e.toString());
    }
  }

  //Parent OPERATIONS
  // Method to filter the list based on the search query
  // To store the filtered list based on the search query
  RxList<MapEntry<String, int>> filteredParentEntries = RxList();
  // To keep track of the search query
  String searchQuery = '';
  void filterParent(String query) {
    // Create a map that stores the count of each Parent element, normalizing the strings
    final Map<String, int> ParentCount = {};

    // Count the occurrences of each Parent item from the controller
    for (var item in ParentIds) {
      if (item.isNotEmpty) {
        // Normalize Parent item by trimming and converting to lowercase
        String normalizedItem = item.trim().toLowerCase();
        ParentCount[normalizedItem] = (ParentCount[normalizedItem] ?? 0) + 1;
      }
    }

    // Filter the map based on the normalized search query
    final filteredMap =
        ParentCount.entries
            .where((entry) => entry.key.contains(query.trim().toLowerCase()))
            .toList();

    filteredParentEntries.value = filteredMap;
    update();
  }

  //search record based on Parent id
  late Future<List<AssetDataCard>> getParentSearchResultFuture;
  List<AssetDataCard> assetCardList = [];

  Future<List<AssetDataCard>> getParentData(String value) async {
    assetCardList.clear();
    String finalquery =
        "UPPER (BU_DH_CUST_COL27) LIKE UPPER ('$value') AND RECORD_NO IS NOT NULL";
    try {
      final response = await ApiServices().requestPostForApi(
        url: "${host_url}getApiRequestResultsData",
        dictParameter: {
          "apiReqId": "7B105EDE59C442D585198D501FED3B51",
          "apiReqCols": "",
          "apiReqWhereClause": finalquery,
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
