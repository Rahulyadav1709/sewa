import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sewa/view/home/asset_detail/asset_detail_screen.dart';

// Split into separate model class for better organization
class AssetData {
  final String? failurecode, recordNo, shortDescription, longDesc, status;
  final String? imageName, equipmentNumber, techId, lat, long, floc, flocDesc;
  final String? updateLat, updateLong;
  final String? assetNo;
  final String? location;
  final String? parent;
  final String? modelNo;
  final String? serialNo;
  final String? subSatationNumber;
  final String? editBy;
  final String? pilogComment;
  final String? substationName;
  final String? assetCountNumber;
  final String? clientNumber;
  final String? assetTaggingType;
  
  AssetData({
    this.failurecode,
    this.assetCountNumber,
    this.serialNo,
    this.recordNo,
    this.shortDescription,
    this.longDesc,
    this.status,
    this.imageName,
    this.equipmentNumber,
    this.techId,
    this.lat,
    this.long,
    this.floc,
    this.flocDesc,
    this.updateLat,
    this.updateLong,
    this.assetNo,
    this.location,
    this.parent,
    this.modelNo,
    this.subSatationNumber,
    this.editBy,
    this.pilogComment,
    this.substationName,
    this.clientNumber,
    this.assetTaggingType
  });

  Map<String, dynamic> toJson() => {
    'failurecode': failurecode,
    'recordNo': recordNo,
    'techId': techId,
    // ... other fields
  };
}

// Main display widget - Compact Modern Design
class AssetDataCard extends StatefulWidget {
  final AssetData data;
  final DisplayType displayType;

  const AssetDataCard({
    super.key,
    required this.data,
    this.displayType = DisplayType.list,
  });

  @override
  State<AssetDataCard> createState() => _AssetDataCardState();
}

enum DisplayType { list, grid, table }

class _AssetDataCardState extends State<AssetDataCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Get status color based on status
  Color _getStatusColor() {
    switch (widget.data.status?.toLowerCase()) {
      case 'found':
        return const Color(0xFF10B981); // Green
      case 'not found':
        return const Color(0xFFEF4444); // Red
      case 'pending':
        return const Color(0xFFF59E0B); // Amber
      case 'newly found':
        return const Color(0xFF8B5CF6); // Purple
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  // Get status icon based on status
  IconData _getStatusIcon() {
    switch (widget.data.status?.toLowerCase()) {
      case 'found':
        return Icons.check_circle;
      case 'not found':
        return Icons.cancel;
      case 'pending':
        return Icons.schedule;
      case 'newly found':
        return Icons.new_releases;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: _buildCompactModernCard(),
          ),
        );
      },
    );
  }

  Widget _buildCompactModernCard() {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      onTap: () => _navigateToDetail(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(isPressed ? 0.98 : 1.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Status Header - Compact
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.06),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(),
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.data.status?.toUpperCase() ?? 'PENDING',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Client Number
                    if (widget.data.recordNo != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "${widget.data.recordNo}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Main Content - Only Asset Number and Description
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Asset Number Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.tag,
                            size: 16,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Asset Number',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.data.assetNo ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Description Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.description,
                            size: 16,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.data.shortDescription ?? 'No description available',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail() {
    Navigator.push(
      context,
      CupertinoPageRoute<bool>(
        builder: (_) => AssetDetailScreen(
          clientNumber: widget.data.clientNumber,
          pilogComment: widget.data.pilogComment,
          editBy: widget.data.editBy,
          subSatationNumber: widget.data.subSatationNumber,
          modelNo: widget.data.modelNo,
          serialNo: widget.data.serialNo,
          parent: widget.data.parent,
          location: widget.data.location,
          assetNo: widget.data.assetNo,
          updatelat: widget.data.updateLat,
          updatelng: widget.data.updateLong,
          failurecode: widget.data.failurecode,
          longDesc: widget.data.longDesc,
          recordNo: widget.data.recordNo,
          shortDescription: widget.data.shortDescription,
          status: widget.data.status,
          imageName: widget.data.imageName,
          equipmentNo: widget.data.equipmentNumber,
          lat: widget.data.lat,
          lng: widget.data.long,
         assetTaggingType: widget.data.assetTaggingType,
        ),
      ),
    );
  }
}