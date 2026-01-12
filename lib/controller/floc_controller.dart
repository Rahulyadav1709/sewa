import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:sewa/helpers/api_services.dart';
import 'package:sewa/helpers/shared_preferences_helpers.dart';
import 'package:sewa/view/home/components/asset_data_card.dart';


class FlocController extends GetxController {


  static late String host_url;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseFirestore get firestore => _firestore;

  @override
  void onInit() {
    super.onInit();
    host_url = dotenv.get("HOST_URL");
    getUsername();
    loadRegionsFromFirebase();
  }

  // Region Management
  RxList<RegionData> regions = RxList<RegionData>();
  RxBool isLoadingRegions = RxBool(false);


String? username;
  void getUsername ()async{
    username= await SharedPreferencesHelper.getUsername();

  }
  // Load regions from Firebase
  Future<void> loadRegionsFromFirebase() async {
    try {
      isLoadingRegions.value = true;
      
      QuerySnapshot querySnapshot = await _firestore.collection('regions').get();
      
      List<RegionData> regionList = [];
      
      for (var doc in querySnapshot.docs) {
        // Get substations count for this region
        QuerySnapshot substationsSnapshot = await _firestore
            .collection('regions')
            .doc(doc.id)
            .collection('substations')
            .get();
        
        regionList.add(RegionData(
          id: doc.id,
          name: (doc.data() as Map<String, dynamic>?) != null 
              ? (doc.data() as Map<String, dynamic>)['name'] ?? doc.id
              : doc.id,
          substationCount: substationsSnapshot.docs.length,
        ));
      }
      
      regions.value = regionList;
      log('Loaded ${regionList.length} regions from Firebase');
      
    } catch (e) {
      log('Error loading regions from Firebase: $e');
      Get.snackbar('Error', 'Failed to load regions from Firebase');
    } finally {
      isLoadingRegions.value = false;
    }
  }

  // Substation Management
  RxList<String> currentRegionSubstations = RxList<String>();
  RxBool isLoadingSubstations = RxBool(false);
  RxString currentRegionId = RxString('');

  // Load substations for a specific region
  Future<List<String>> loadSubstationsForRegion(String regionId) async {
    try {
      isLoadingSubstations.value = true;
      currentRegionId.value = regionId;
      
      QuerySnapshot querySnapshot = await _firestore
          .collection('regions')
          .doc(regionId)
          .collection('substations')
          .get();
      
      List<String> substationsList = [];
      
      for (var doc in querySnapshot.docs) {
        substationsList.add(doc.id);
      }
      
      currentRegionSubstations.value = substationsList;
      log('Loaded ${substationsList.length} substations for region: $regionId');
      
      return substationsList;
      
    } catch (e) {
      log('Error loading substations for region $regionId: $e');
      Get.snackbar('Error', 'Failed to load substations');
      return [];
    } finally {
      isLoadingSubstations.value = false;
    }
  }

  // Add new substation to Firebase
  Future<bool> addSubstationToRegion(String regionId, String substationName) async {
    try {
      if (substationName.trim().isEmpty) {
        Get.snackbar('Error', 'Substation name cannot be empty');
        return false;
      }

      // Check if substation already exists
      DocumentSnapshot doc = await _firestore
          .collection('regions')
          .doc(regionId)
          .collection('substations')
          .doc(substationName.trim())
          .get();

      if (doc.exists) {
        Get.snackbar('Error', 'Substation already exists');
        return false;
      }

      // Add substation to Firebase
      await _firestore
          .collection('regions')
          .doc(regionId)
          .collection('substations')
          .doc(substationName.trim())
          .set({
        'name': substationName.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Refresh the substations list
      await loadSubstationsForRegion(regionId);
      
      // Update region count
      await loadRegionsFromFirebase();
      
      Get.snackbar('Success', 'Substation added successfully');
      log('Added substation: $substationName to region: $regionId');
      
      return true;
      
    } catch (e) {
      log('Error adding substation: $e');
      Get.snackbar('Error', 'Failed to add substation');
      return false;
    }
  }

  // Delete substation from Firebase
  Future<bool> deleteSubstationFromRegion(String regionId, String substationName) async {
    try {
      await _firestore
          .collection('regions')
          .doc(regionId)
          .collection('substations')
          .doc(substationName)
          .delete();

      // Refresh the substations list
      await loadSubstationsForRegion(regionId);
      
      // Update region count
      await loadRegionsFromFirebase();
      
      Get.snackbar('Success', 'Substation deleted successfully');
      log('Deleted substation: $substationName from region: $regionId');
      
      return true;
      
    } catch (e) {
      log('Error deleting substation: $e');
      Get.snackbar('Error', 'Failed to delete substation');
      return false;
    }
  }

  // Original FLOC API methods (keeping for backward compatibility)
  static final List<String> _flocIds = [];
  List<String> get flocIds => _flocIds;
  late Future<List<String>> getFlocIdsFuture;

  Future<List<String>> getFlocInfoApi() async {
    _flocIds.clear();
    try {
      final response = await ApiServices().requestPostForApi(
        url: "${host_url}getApiRequestResultsData",
        dictParameter: {
          "apiReqId": "42BF27F12E8BF9BDE0630400010A444B",
          "apiReqCols": "'' AS EMPTY_COL, RECORD_NO,BU_CUST_COL32",
          "apiReqWhereClause": "",
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
          _flocIds.add(object["BU_CUST_COL32"].toString());
        }
        return flocIds;
      } else {
        return Future.error('Error: ${response?.statusCode}');
      }
    } catch (e) {
      log("error $e");
      return Future.error(e.toString());
    }
  }

  // FLOC OPERATIONS
  RxList<MapEntry<String, int>> filteredFLOCEntries = RxList();
  String searchQuery = '';
  
  void filterFLOC(String query) {
    final Map<String, int> flocCount = {};

    for (var item in flocIds) {
      if (item.isNotEmpty) {
        String normalizedItem = item.trim().toLowerCase();
        flocCount[normalizedItem] = (flocCount[normalizedItem] ?? 0) + 1;
      }
    }

    final filteredMap = flocCount.entries
        .where((entry) => entry.key.contains(query.trim().toLowerCase()))
        .toList();

    filteredFLOCEntries.value = filteredMap;
    update();
  }

  // Helper function to safely parse coordinates
  List<String?> parseCoordinates(dynamic coordValue) {
    if (coordValue == null) return [null, null];
    
    String coordString = coordValue.toString().trim();
    if (coordString.isEmpty) return [null, null];
    
    List<String> parts = coordString.split(',');
    if (parts.length >= 2) {
      return [parts[0].trim(), parts[1].trim()];
    } else if (parts.length == 1) {
      return [parts[0].trim(), null];
    }
    return [null, null];
  }

  // Search record based on floc id
  late Future<List<AssetDataCard>> getFlocSearchResultFuture;
  List<AssetDataCard> assetCardList = [];

  Future<List<AssetDataCard>> getFlocData(String value) async {
    assetCardList.clear();
    String finalquery = "UPPER (BU_CUST_COL32) LIKE UPPER ('$value') AND RECORD_NO IS NOT NULL";
    
    try {
      final response = await ApiServices().requestPostForApi(
        url: "${host_url}getApiRequestResultsData",
        dictParameter: {
          "apiReqId": "7B105EDE59C442D585198D501FED3B51",
          "apiReqCols": "BU_DH_CUST_COL53,BU_DH_CUST_COL62, BU_DH_CUST_COL35, BU_CUST_COL32, BU_DH_CUST_COL32, BU_DH_CUST_COL27, BU_DH_CUST_COL31, CUSTOM_DH_COLUMN15, BU_DH_CUST_COL30, BU_DH_CUST_COL37, RECORD_NO, STATUS, MASTER_COLUMN5, REGISTER_COLUMN6, BU_CUST_COL34, FLOC_DESCRIPTION, CUSTOM_COLUMN12, BU_CUST_COL20, EDIT_BY, BU_CUST_COL22",
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
        
        if (result!['apiDataArray'] != null && result!['apiDataArray'].isNotEmpty) {
          for (var object in result!['apiDataArray']) {
            List<String?> updateCoords = parseCoordinates(object["BU_DH_CUST_COL35"]);
            List<String?> coords = parseCoordinates(object["BU_CUST_COL34"]);
            
            assetCardList.add(
              AssetDataCard(
                data: AssetData(
                  clientNumber: object["BU_DH_CUST_COL53"],
                  updateLat: updateCoords[0],
                  updateLong: updateCoords[1],
                  subSatationNumber: object["BU_CUST_COL32"],
                  modelNo: object["BU_DH_CUST_COL32"],
                  parent: object["BU_DH_CUST_COL27"],
                  serialNo: object["BU_DH_CUST_COL31"],
                  location: object["CUSTOM_DH_COLUMN15"],
                  failurecode: object["BU_DH_CUST_COL30"],
                  longDesc: object["BU_DH_CUST_COL37"],
                  recordNo: object["RECORD_NO"],
                  status: object["STATUS"],
                  shortDescription: object["MASTER_COLUMN5"],
                  equipmentNumber: object["BU_DH_CUST_COL53"],
                  assetNo: object["REGISTER_COLUMN6"],
                  lat: coords[0],
                  long: coords[1],
                  floc: object["BU_CUST_COL32"],
                  flocDesc: object["FLOC_DESCRIPTION"],
                  pilogComment: object["CUSTOM_COLUMN12"],
                  substationName: object["BU_CUST_COL20"],
                  editBy: object["EDIT_BY"],
                  assetCountNumber: object['BU_CUST_COL22'],
                   assetTaggingType: object["BU_DH_CUST_COL62"],
                ),
              ),
            );
          }
          log("Asset data loaded successfully");
          // log("$ass");
        }
        
        findPendingAssets(assetCardList);
        return assetCardList;
      } else {
        return Future.error('Error: ${response?.statusCode}');
      }
    } catch (e) {
      log("error $e");
      return Future.error(e.toString());
    }
  }

  // Find pending assets
  RxInt foundCount = RxInt(0);
  RxList<AssetDataCard> foundList = RxList();

  RxInt pendingCount = RxInt(0);
  RxList<AssetDataCard> pendingList = RxList();

  RxInt notFoundCount = RxInt(0);
  RxList<AssetDataCard> notFoundList = RxList();

  RxInt newlyfoundCount = RxInt(0);
  RxList<AssetDataCard> newlyfoundList = RxList();

  RxInt systemCount = RxInt(0);
  RxList<AssetDataCard> systemCountList = RxList();
  
  Future findPendingAssets(List<AssetDataCard> assetDataCard) async {
    foundCount.value = 0;
    foundList.clear();
    pendingCount.value = 0;
    pendingList.clear();
    notFoundCount.value = 0;
    notFoundList.clear();
    newlyfoundCount.value = 0;
    newlyfoundList.clear();
       systemCount.value = 0;
    systemCountList.clear();

    for (var object in assetDataCard) {
      String status = (object.data.status ?? "").trim().toLowerCase();
      
      if (status == "found") {
        foundCount.value++;
        foundList.add(object);
      } else if (status == "not found") {
        notFoundCount.value++;
        notFoundList.add(object);
      } else if (status == "newly found") {
        newlyfoundCount.value++;
        newlyfoundList.add(object);
      }else if (status == "system") {
        systemCount.value++;
        systemCountList.add(object);
      }  
      
      else {
        pendingCount.value++;
        pendingList.add(object);
      }
    }
    
    log("Found: ${foundCount.value}, Not Found: ${notFoundCount.value}, Newly Found: ${newlyfoundCount.value}, Pending: ${pendingCount.value}, System: ${systemCount.value}");
  }

  // Get sub station name
  RxString subStationName = RxString("");
  
  Future<String> getSubStationName(String? subStationId) async {
    try {
      final response = await ApiServices().requestPostForApi(
        url: "${host_url}getApiRequestResultsData",
        dictParameter: {
          "apiReqId": "7B105EDE59C442D585198D501FED3B51",
          "apiReqCols": "BU_CUST_COL32,BU_CUST_COL20",
          "apiReqWhereClause": "BU_CUST_COL32= '$subStationId'",
          "apiReqOrgnId": "C4B60E7B81554CC984EA8864D4248CB0",
          "apiReqUserId": "",
          "apiRetType": "JSON"
        },
        authToken: false,
      );

      log("status ${response?.statusCode}");
      if (response?.statusCode == 200) {
        var result = jsonDecode(response!.data.toString());
        
        if (result!['apiDataArray'] != null && result!['apiDataArray'].isNotEmpty) {
          subStationName.value = result!['apiDataArray'][0]["BU_CUST_COL20"] ?? "Unknown Station";
        } else {
          subStationName.value = "Unknown Station";
        }
        
        return subStationName.value;
      } else {
        return Future.error('Error: ${response?.statusCode}');
      }
    } catch (e) {
      log("error $e");
      return Future.error(e.toString());
    } 
  }
}

// Data class for Region
class RegionData {
  final String id;
  final String name;
  final int substationCount;

  RegionData({
    required this.id,
    required this.name,
    required this.substationCount,
  });
}