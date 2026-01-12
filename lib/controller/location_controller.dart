import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:sewa/helpers/api_services.dart';
import 'package:sewa/view/home/components/asset_data_card.dart';


class LocationController extends GetxController {
  static late String host_url;

  @override
  void onInit() {
    super.onInit();
    host_url = dotenv.get("HOST_URL");
  }

  //Location api
  static final List<String> _LocationIds = [];
  List<String> get LocationIds => _LocationIds;
  late Future<List<String>> getLocationIdsFuture;
  Future<List<String>> getLocationInfoApi() async {
    _LocationIds.clear();
    try {
      final response = await ApiServices().requestPostForApi(
        url: "${host_url}getApiRequestResultsData",
        dictParameter: {
          "apiReqId": "7B105EDE59C442D585198D501FED3B51",
          "apiReqCols": "'' AS EMPTY_COL, RECORD_NO,CUSTOM_DH_COLUMN15",
          "apiReqWhereClause": "",
          "apiReqOrgnId": "C4B60E7B81554CC984EA8864D4248CB0",
          "apiReqUserId": "",
          "apiRetType": "JSON"
        },
        authToken: false,
      );

      log("status ${response?.statusCode}");
      if (response?.statusCode == 200) {
        var result = jsonDecode(response!.data.toString());
        for (var object in result!['apiDataArray']) {
          _LocationIds.add(object["CUSTOM_DH_COLUMN15"].toString());
        }
        return LocationIds;
      } else {
        return Future.error('Error: ${response?.statusCode}');
      }
    } catch (e) {
      log("error $e");
      return Future.error(e.toString());
    }
  }

  //Location OPERATIONS
  // Method to filter the list based on the search query
  // To store the filtered list based on the search query
  RxList<MapEntry<String, int>> filteredLocationEntries = RxList();
  // To keep track of the search query
  String searchQuery = '';
  void filterLocation(String query) {
    // Create a map that stores the count of each Location element, normalizing the strings
    final Map<String, int> LocationCount = {};

    // Count the occurrences of each Location item from the controller
    for (var item in LocationIds) {
      if (item.isNotEmpty) {
        // Normalize Location item by trimming and converting to lowercase
        String normalizedItem = item.trim().toLowerCase();
        LocationCount[normalizedItem] = (LocationCount[normalizedItem] ?? 0) + 1;
      }
    }

    // Filter the map based on the normalized search query
    final filteredMap = LocationCount.entries
        .where((entry) => entry.key.contains(query.trim().toLowerCase()))
        .toList();

    filteredLocationEntries.value = filteredMap;
    update();
  }

  //search record based on Location id
  late Future<List<AssetDataCard>> getLocationSearchResultFuture;
  List<AssetDataCard> assetCardList = [];

  Future<List<AssetDataCard>> getLocationData(String value) async {
    assetCardList.clear();
    String finalquery =
        "UPPER (CUSTOM_DH_COLUMN15) LIKE UPPER ('$value') AND RECORD_NO IS NOT NULL";
    try {
      final response = await ApiServices().requestPostForApi(
        url: "${host_url}getApiRequestResultsData",
        dictParameter: {
          "apiReqId": "7B105EDE59C442D585198D501FED3B51",
          "apiReqCols": "",
          "apiReqWhereClause": finalquery,
          "apiReqOrgnId": "C4B60E7B81554CC984EA8864D4248CB0",
          "apiReqUserId": "TAQA_MGR",
          "apiRetType": "JSON"
        },
        authToken: false,
      );

      log("status ${response?.statusCode}");
      if (response?.statusCode == 200) {
        var result = jsonDecode(response!.data.toString());
        for (var object in result!['apiDataArray']) {
          assetCardList.add(AssetDataCard(
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
              lat: object["BU_CUST_COL34"] == null
                  ? null
                  : object["BU_CUST_COL34"].toString().split(',')[0],
              long: object["BU_CUST_COL34"] == null
                  ? null
                  : object["BU_CUST_COL34"].toString().split(',')[1],
              floc: object["BU_CUST_COL32"],
              flocDesc: object["FLOC_DESCRIPTION"],
               pilogComment: object["CUSTOM_COLUMN12"],
               editBy: object["EDIT_BY"],
                assetTaggingType: object["BU_DH_CUST_COL62"],
            ),
          ));
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
