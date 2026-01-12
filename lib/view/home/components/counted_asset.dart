import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:sewa/view/home/components/asset_data_card.dart'; // Assuming this is your custom widget

class CountedAsset extends StatefulWidget {
  final List<AssetDataCard> assetDataCards;
  final String? count;
  const CountedAsset({super.key, required this.assetDataCards, this.count});

  @override
  State<CountedAsset> createState() => _CountedAssetState();
}

class _CountedAssetState extends State<CountedAsset> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background color for a subtle modern touch
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0, // Flat design
        backgroundColor: Colors.white, // A vibrant color for the app bar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.count ?? "Assets"} ', // Fallback if count is null
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true, // Centered title for symmetry
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Optional: Add a header or subtitle
              if (widget.assetDataCards.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0,left: 15),
                  child: Text(
                    'Total Items: ${widget.assetDataCards.length}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
          
              // List of asset cards
              Expanded(
                child: ListView.builder(
                  itemCount: widget.assetDataCards.length,
                  itemBuilder: (context, index) {
                    return DelayedDisplay(
                      delay: Duration(milliseconds: 100 * index), // Staggered animation
                      child: widget.assetDataCards[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Optional: Floating Action Button for additional functionality
      
    );
  }
}