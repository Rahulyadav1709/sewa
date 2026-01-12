import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferencesHelper {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _ssOrgId = "ssOrgId";
  static const String _ssUserName = "ssUserName";
  static const String _ssRole = "ssRole";
  static const String _ssRegion = "ssRegion";
  static const String _ssInstance = "ssInstance";
  static const String _searchKeywords = "searchKeywords";

  static Future<void> setIsLoggedIn(bool isLoggedIn) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  static Future<bool> getIsLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> setUsername(String username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ssUserName, username);
  }

  static Future<String?> getUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ssUserName);
  }

  static Future<void> setOrgId(String orgId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ssOrgId, orgId);
  }

  static Future<String?> getOrgId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ssOrgId);
  }

  static Future<void> setRegion(String region) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ssRegion, region);
  }

  static Future<String?> getRegion() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ssRegion);
  }

  static Future<void> setInstance(String instance) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ssInstance, instance);
  }

  static Future<String?> getInstance() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ssInstance);
  }

  static Future<void> setRole(String ssRole) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ssRole, ssRole);
  }

  static Future<String?> getRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ssRole);
  }

  // Save a search keyword with date and time
  static Future<void> addSearchKeyword(String keyword) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> searchMap = json.decode(prefs.getString(_searchKeywords) ?? '{}');
    searchMap[keyword] = DateTime.now().toIso8601String();
    await prefs.setString(_searchKeywords, json.encode(searchMap));
  }

  // Get all search keywords with date and time
  static Future<Map<String, String>> getSearchKeywords() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return Map<String, String>.from(json.decode(prefs.getString(_searchKeywords) ?? '{}'));
  }

  // Clear all search keywords
  static Future<void> clearSearchKeywords() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchKeywords);
  }

  static Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
