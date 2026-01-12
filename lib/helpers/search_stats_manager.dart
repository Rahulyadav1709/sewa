
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SearchAnalyticsService {
  static const String _searchDataKey = 'weekly_search_data';

  // Save search data for a specific week
  Future<void> saveSearchData(DateTime date, int searchCount) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Retrieve existing data
    List<dynamic> existingData = json.decode(
      prefs.getString(_searchDataKey) ?? '[]'
    );

    // Find or create entry for the week
    bool updated = false;
    for (var entry in existingData) {
      if (_isSameWeek(DateTime.parse(entry['date']), date)) {
        entry['searchCount'] += searchCount;
        updated = true;
        break;
      }
    }

    // If no existing entry, add new entry
    if (!updated) {
      existingData.add({
        'date': date.toIso8601String(),
        'searchCount': searchCount
      });
    }

    // Limit to last 12 weeks of data
    if (existingData.length > 12) {
      existingData.removeAt(0);
    }

    // Save updated data
    await prefs.setString(_searchDataKey, json.encode(existingData));
  }

  // Retrieve search analytics data
  Future<List<dynamic>> getSearchAnalyticsData() async {
    final prefs = await SharedPreferences.getInstance();
    return json.decode(
      prefs.getString(_searchDataKey) ?? '[]'
    );
  }

  // Utility to check if two dates are in the same week
  bool _isSameWeek(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.weekOfYear == date2.weekOfYear;
  }
}

// Extension to get week of year
extension DateTimeExtension on DateTime {
  int get weekOfYear {
    final firstDayOfYear = DateTime(year, 1, 1);
    final firstWeekday = firstDayOfYear.weekday;
    final daysToAdd = firstWeekday <= DateTime.wednesday ? 1 - firstWeekday : 8 - firstWeekday;
    final firstWeekStart = firstDayOfYear.add(Duration(days: daysToAdd));
    final weekNumber = ((difference(firstWeekStart).inDays / 7) + 1).floor();
    return weekNumber;
  }
}
