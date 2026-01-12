import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sewa/global/widgets/stacked_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedItemsPage extends StatefulWidget {
  const SavedItemsPage({super.key});

  @override
  State<SavedItemsPage> createState() => _SavedItemsPageState();
}

class _SavedItemsPageState extends State<SavedItemsPage> {
  List<CardItem> savedItems = [];

  @override
  void initState() {
    super.initState();
    _loadSavedItems();
  }

  Future<void> _loadSavedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList('favorites') ?? [];

    // Decode JSON strings into CardItem objects
    final items = favorites.map((item) {
      final jsonData = jsonDecode(item);
      return CardItem(
        title: jsonData['techId'] ?? 'Unknown Tech ID',
        date: jsonData['classTerm'] ?? 'No Date',
        subtitle: jsonData['equipmentNumber'] ?? 'No Equipment Number',
      );
    }).toList();

    setState(() {
      savedItems = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Items"),
      ),
      body: savedItems.isEmpty
          ? const Center(child: Text("No saved items available"))
          : StackCardToggle(items: savedItems),
    );
  }
}
