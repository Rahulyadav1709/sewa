// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:taqa/helpers/search_stats_manager.dart';

// class SearchAnalyticsChart extends StatefulWidget {
//   final SearchAnalyticsService analyticsService;

//   const SearchAnalyticsChart({
//     super.key, 
//     required this.analyticsService
//   });

//   @override
//   _SearchAnalyticsChartState createState() => _SearchAnalyticsChartState();
// }

// class _SearchAnalyticsChartState extends State<SearchAnalyticsChart> {
//   List<dynamic> _searchData = [];
//   int _touchedIndex = -1;

//   @override
//   void initState() {
//     super.initState();
//     _loadSearchData();
//   }

//   Future<void> _loadSearchData() async {
//     final data = await widget.analyticsService.getSearchAnalyticsData();
//     setState(() {
//       _searchData = data;
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return PieChart(
//       PieChartData(
//         centerSpaceRadius: 40,
//         sections: _searchData.asMap().entries.map((entry) {
//           final count = entry.value['searchCount'];
//           final isTouched = entry.key == _touchedIndex;
//           final fontSize = isTouched ? 25.0 : 16.0;
//           final radius = isTouched ? 60.0 : 50.0;

//           return PieChartSectionData(
//             color: _getColorForIndex(entry.key),
//             value: count.toDouble(),
//             title: 'Week ${entry.key + 1}',
//             radius: radius,
//             titleStyle: TextStyle(
//               fontSize: fontSize, 
//               fontWeight: FontWeight.bold, 
//               color: Colors.white
//             ),
//           );
//         }).toList(),
//         sectionsSpace: 4,
//         pieTouchData: PieTouchData(
//           touchCallback: (FlTouchEvent event, pieTouchResponse) {
//             setState(() {
//               if (!event.isInterestedForInteractions) {
//                 _touchedIndex = -1;
//                 return;
//               }
//               _touchedIndex = pieTouchResponse?.touchedSection?.touchedSectionIndex ?? -1;
//             });
//           },
//         ),
//       ),
//     );
//   }

//   Color _getColorForIndex(int index) {
//     final colors = [
//       Colors.blue,
//       Colors.green,
//       Colors.red,
//       Colors.purple,
//       Colors.orange,
//       Colors.teal
//     ];
//     return colors[index % colors.length];
//   }
// }