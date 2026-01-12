import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sewa/controller/Parent_controller.dart';
import 'package:sewa/view/home/components/asset_data_card.dart';
import 'package:sewa/view/home/components/home_loading_shimmer.dart';

class ParentSearchResultScreen extends StatefulWidget {
  final String ParentID;
  const ParentSearchResultScreen({super.key, required this.ParentID});

  @override
  State<ParentSearchResultScreen> createState() => _ParentSearchResultScreenState();
}

class _ParentSearchResultScreenState extends State<ParentSearchResultScreen> {
  ParentController? controller;
  final TextEditingController _searchController = TextEditingController();
  List<AssetDataCard> _allAssets = [];
  List<AssetDataCard> _filteredAssets = [];

  @override
  void initState() {
    controller = Get.find<ParentController>();
    controller?.getParentSearchResultFuture =
        controller!.getParentData(widget.ParentID);
    
    // Add listener to populate assets once they're loaded
    controller?.getParentSearchResultFuture.then((assets) {
      setState(() {
        _allAssets = assets;
        _filteredAssets = assets;
      });
    });

    super.initState();
  }

  void _filterAssets(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAssets = _allAssets;
      } else {
        _filteredAssets = _allAssets.where((asset) {
          // Search across multiple fields
          return (asset.data.assetNo?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                 (asset.data.recordNo?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                 (asset.data.shortDescription?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                 (asset.data.parent?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title with subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Parent Search',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find parent assets',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar with Premium Shadow
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterAssets,
                  decoration: InputDecoration(
                    hintText: 'Search assets...',
                    hintStyle: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.black54,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _filterAssets('');
                            },
                            child: Icon(
                              Icons.clear,
                              color: Colors.black54,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // Search Results
            Expanded(
              child: FutureBuilder<List<AssetDataCard>>(
                future: controller?.getParentSearchResultFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: loadingShimmer());
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Image(image: AssetImage('assets/images/not_found.png'))
                    );
                  } else {
                    // Check if filtered assets is empty
                    if (_filteredAssets.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'No assets found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                _filterAssets('');
                              },
                              child: const Text(
                                'Clear Search',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    }

                    // ListView of filtered assets
                    return ListView(
                       children: () {
                              _filteredAssets.sort((a, b) {
                                int aCount =
                                    int.tryParse(
                                      a.data.clientNumber ?? '',
                                    ) ??
                                    0;
                                int bCount =
                                    int.tryParse(
                                      b.data.clientNumber ?? '',
                                    ) ??
                                    0;
                                return aCount.compareTo(bCount); // ascending
                              });

                              return _filteredAssets.map<Widget>((item) {
                                return GestureDetector(
                                  onTap: () {},
                                  child: DelayedDisplay(
                                    child: Column(children: [item]),
                                  ),
                                );
                              }).toList();
                            }(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget loadingShimmer() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(child: AssetDataCardShimmer()),
          SizedBox(child: AssetDataCardShimmer()),
          SizedBox(child: AssetDataCardShimmer()),
        ],
      ),
    );
  }
}