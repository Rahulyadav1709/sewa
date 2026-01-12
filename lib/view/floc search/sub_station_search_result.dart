import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sewa/controller/floc_controller.dart';
import 'package:sewa/view/home/components/asset_data_card.dart';
import 'package:sewa/view/home/components/home_loading_shimmer.dart';

class FlocSearchResultScreen extends StatefulWidget {
  final String flocID;
  const FlocSearchResultScreen({super.key, required this.flocID});

  @override
  State<FlocSearchResultScreen> createState() => _FlocSearchResultScreenState();
}

class _FlocSearchResultScreenState extends State<FlocSearchResultScreen> {
  FlocController? controller;
  final TextEditingController _searchController = TextEditingController();
  List<AssetDataCard> _allAssets = [];
  List<AssetDataCard> _filteredAssets = [];

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<FlocController>()
        ? Get.find<FlocController>()
        : Get.put(FlocController());

    controller?.getFlocSearchResultFuture = controller!.getFlocData(
      widget.flocID,
    );

    controller!.getSubStationName(widget.flocID);

    // Add listener to populate assets once they're loaded
    controller?.getFlocSearchResultFuture.then((assets) {
      if (mounted) {
        setState(() {
          _allAssets = assets;
          _filteredAssets = assets;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _allAssets = [];
          _filteredAssets = [];
        });
      }
    });
  }

  void _filterAssets(String query) {
    if (!mounted) return;

    setState(() {
      if (query.isEmpty) {
        _filteredAssets = _allAssets;
      } else {
        _filteredAssets = _allAssets.where((asset) {
          return (asset.data.assetNo?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false) ||
              (asset.data.recordNo?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false) ||
              (asset.data.shortDescription?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false) ||
              (asset.data.floc?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false) ||
              (asset.data.substationName?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false) ||
              (asset.data.clientNumber?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false);
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header with Gradient
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Header Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    child: Row(
                      children: [
                        // Modern Back Button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Title Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(
                                () => Text(
                                  controller!.subStationName.value.isEmpty
                                      ? "Loading..."
                                      : controller!.subStationName.value,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'FLOC: ${widget.flocID}',
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Search Bar - Integrated in Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterAssets,
                        decoration: InputDecoration(
                          hintText: 'Search assets, descriptions, numbers...',
                          hintStyle: const TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF667EEA),
                            size: 22,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    _filterAssets('');
                                  },
                                  child: const Icon(
                                    Icons.clear_rounded,
                                    color: Colors.black54,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: FutureBuilder<List<AssetDataCard>>(
                future: controller?.getFlocSearchResultFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  } else if (snapshot.hasError) {
                    return _buildErrorState();
                  } else {
                    return _buildContentState();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        // Loading shimmer for count cards - Now shows 5 cards
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: List.generate(3, (index) => _buildLoadingCountCard()),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildLoadingCountCard(),
                  _buildLoadingCountCard(),
                  Expanded(child: Container()), // Empty space for alignment
                ],
              ),
            ],
          ),
        ),
        // Loading shimmer for asset cards
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(5, (index) => const AssetDataCardShimmer()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCountCard() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF667EEA),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Failed to load data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check your connection and try again',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                controller?.getFlocSearchResultFuture = controller!.getFlocData(widget.flocID);
              });
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentState() {
    if (_filteredAssets.isEmpty && _searchController.text.isNotEmpty) {
      return _buildNoSearchResults();
    } else if (_allAssets.isEmpty) {
      return _buildNoDataState();
    }

    return Column(
      children: [
        // Compact Count Cards - Now with 5 cards in 2 rows
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Obx(
            () => controller == null
                ? const SizedBox.shrink()
                : 
                      Row(
                        children: [
                          _buildModernCountCard(
                            "Found",
                            controller!.foundCount.toString(),
                            controller!.foundList,
                            const Color(0xFF10B981),
                            Icons.check_circle_rounded,
                          ),
                          _buildModernCountCard(
                            "Pending",
                            controller!.pendingCount.toString(),
                            controller!.pendingList,
                            const Color(0xFFF59E0B),
                            Icons.schedule_rounded,
                          ),
                          _buildModernCountCard(
                            "Not Found",
                            controller!.notFoundCount.toString(),
                            controller!.notFoundList,
                            const Color(0xFFEF4444),
                            Icons.cancel_rounded,
                          ),
                             _buildModernCountCard(
                            "New",
                            controller!.newlyfoundCount.toString(),
                            controller!.newlyfoundList,
                            const Color(0xFF8B5CF6),
                            Icons.new_releases_rounded,
                          ),
                          _buildModernCountCard(
                            "System",
                            controller!.systemCount.toString(),
                            controller!.systemCountList,
                            const Color(0xFF06B6D4),
                            Icons.settings_rounded,
                          ),
                        ],
                      ),
                     
                    
                  
          ),
        ),
        
        // Assets List
        Expanded(
          child: _filteredAssets.isEmpty
              ? _buildNoDataState()
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: _filteredAssets.length,
                  itemBuilder: (context, index) {
                    // Sort assets by client number
                    _filteredAssets.sort((a, b) {
                      int aCount = int.tryParse(a.data.clientNumber ?? '0') ?? 0;
                      int bCount = int.tryParse(b.data.clientNumber ?? '0') ?? 0;
                      return aCount.compareTo(bCount);
                    });

                    return _filteredAssets[index];
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildModernCountCard(
    String title,
    String count,
    List<AssetDataCard> assetDataCount,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _navigateToScreen(
            context,
            AssetCategoryScreen(
              assetDataCards: assetDataCount, 
              categoryTitle: title,
              categoryColor: color,
              categoryIcon: icon,
            ),
            const Offset(0.0, 1.0),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with background
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(height: 8),
              // Count
              Text(
                count,
                style: TextStyle(
                  fontSize: 18,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No matching assets found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              _filterAssets('');
            },
            icon: const Icon(Icons.clear_all_rounded),
            label: const Text('Clear Search'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No assets available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'There are no assets in this location',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen, Offset offset) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween = Tween(
            begin: offset,
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOutCubic));

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }
}

// New Asset Category Screen
class AssetCategoryScreen extends StatefulWidget {
  final List<AssetDataCard> assetDataCards;
  final String categoryTitle;
  final Color categoryColor;
  final IconData categoryIcon;

  const AssetCategoryScreen({
    super.key,
    required this.assetDataCards,
    required this.categoryTitle,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  State<AssetCategoryScreen> createState() => _AssetCategoryScreenState();
}

class _AssetCategoryScreenState extends State<AssetCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<AssetDataCard> _filteredAssets = [];

  @override
  void initState() {
    super.initState();
    _filteredAssets = widget.assetDataCards;
  }

  void _filterAssets(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAssets = widget.assetDataCards;
      } else {
        _filteredAssets = widget.assetDataCards.where((asset) {
          return (asset.data.assetNo?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false) ||
              (asset.data.recordNo?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false) ||
              (asset.data.shortDescription?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false) ||
              (asset.data.floc?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false) ||
              (asset.data.substationName?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false) ||
              (asset.data.clientNumber?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false);
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header with category info
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.categoryColor.withOpacity(0.1),
                    widget.categoryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Header Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    child: Row(
                      children: [
                        // Modern Back Button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: widget.categoryColor.withOpacity(0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.categoryColor.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: widget.categoryColor,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Category Icon and Title
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: widget.categoryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  widget.categoryIcon,
                                  color: widget.categoryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.categoryTitle,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${widget.assetDataCards.length} assets',
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.7),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: widget.categoryColor.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterAssets,
                        decoration: InputDecoration(
                          hintText: 'Search in ${widget.categoryTitle.toLowerCase()}...',
                          hintStyle: const TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: widget.categoryColor,
                            size: 22,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    _filterAssets('');
                                  },
                                  child: const Icon(
                                    Icons.clear_rounded,
                                    color: Colors.black54,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Assets List
            Expanded(
              child: _filteredAssets.isEmpty && _searchController.text.isNotEmpty
                  ? _buildNoSearchResults()
                  : _filteredAssets.isEmpty
                      ? _buildNoDataState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredAssets.length,
                          itemBuilder: (context, index) {
                            // Sort assets by client number
                            _filteredAssets.sort((a, b) {
                              int aCount = int.tryParse(a.data.clientNumber ?? '0') ?? 0;
                              int bCount = int.tryParse(b.data.clientNumber ?? '0') ?? 0;
                              return aCount.compareTo(bCount);
                            });

                            return _filteredAssets[index];
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: widget.categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 64,
              color: widget.categoryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No matching assets found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try searching with different keywords',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              _filterAssets('');
            },
            icon: const Icon(Icons.clear_all_rounded),
            label: const Text('Clear Search'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.categoryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: widget.categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              widget.categoryIcon,
              size: 64,
              color: widget.categoryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No ${widget.categoryTitle.toLowerCase()} assets',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'There are no assets in this category',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}