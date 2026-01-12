import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sewa/helpers/pdf_viewer_goggle_drive_link.dart';
import 'package:sewa/helpers/search_stats_manager.dart';
import 'package:sewa/helpers/shared_preferences_helpers.dart';
import 'package:sewa/view/floc%20search/sub%20station%20by%20region/sub_station_by_region.dart';
import 'package:sewa/view/floc%20search/sub_station_search.dart';
import 'package:sewa/view/home/components/home_content.dart';
import 'package:sewa/view/location%20search/location_search_operation.dart';
import 'package:sewa/view/parametric%20search/parametric_screen.dart';
import 'package:sewa/view/parent%20search/parent_search_operation.dart';
import 'package:sewa/view/profile/profile.dart';
import 'package:sewa/view/profile/settings.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final SearchAnalyticsService analyticsService = SearchAnalyticsService();

  Future<String?> username() async {
    return await SharedPreferencesHelper.getUsername();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              _buildGeneralSearchCard(context),
              _buildNavigationGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FutureBuilder<String?>(
        future: username(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final userName = snapshot.data ?? 'User';
          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello,',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      userName,
                      style: GoogleFonts.poppins(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Make your day easy with our tool',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    PDFBottomSheet.show(
                      context,
                      '1PVeLE8B7TnZrZwv8hHBAXwT7XgWVEPlZ',
                    );
                  },
                  icon: Icon(
                    Icons.info_outline_rounded,
                    size: 24,
                    color: Colors.blue[600],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGeneralSearchCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20.0),
      child: ModernNavigationCard(
        title: 'General Search',
        iconPath: "assets/icons/general_search.png",
        isLarge: true,
        onTap: () => _navigateToScreen(
          context,
          HomeContent(analyticsService: analyticsService),
          const Offset(1.0, 0.0),
        ),
      ),
    );
  }

  Widget _buildNavigationGrid(BuildContext context) {
    final gridItems = [
      _GridItem(
        title: 'Parametric Search',
        iconPath: "assets/icons/parametric_search.png",
        screen: const ParametricSearchScreen(),
        offset: const Offset(1.0, 0.0),
      ),
      // _GridItem(
      //   title: 'Station Search',
      //   iconPath: "assets/icons/functional_location.png",
      //   screen: const FLOCOperation(),
      //   offset: const Offset(0.0, 1.0),
      // ),
      // _GridItem(
      //   title: 'Sub-Station by Region',
      //   iconPath: "assets/icons/sub_station_by_region.png",
      //   screen: const SubStationByRegion(),
      //   offset: const Offset(1.0, 0.0),
      //   iconHeight: 45,
      //   iconWidth: 45,
      // ),
      // _GridItem(
      //   title: 'Location Search',
      //   iconPath: "assets/icons/location_search.png",
      //   screen: const LocationOperation(),
      //   offset: const Offset(0.0, 1.0),
      // ),
      // _GridItem(
      //   title: 'Parent Search',
      //   iconPath: "assets/icons/parent_search.png",
      //   screen: const ParentOperation(),
      //   offset: const Offset(0.0, 1.0),
      //   iconHeight: 40,
      //   iconWidth: 40,
      // ),
      _GridItem(
        title: 'Profile',
        iconPath: "assets/icons/profile.png",
        screen: const ProfileScreen(),
        offset: const Offset(-1.0, 0.0),
      ),
      _GridItem(
        title: 'Settings',
        iconPath: "assets/icons/settings.png",
        screen: const SettingsScreen(),
        offset: const Offset(0.0, -1.0),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: gridItems.length,
        itemBuilder: (context, index) {
          final item = gridItems[index];
          return ModernNavigationCard(
            title: item.title,
            iconPath: item.iconPath,
            iconHeight: item.iconHeight,
            iconWidth: item.iconWidth,
            onTap: () => _navigateToScreen(
              context,
              item.screen,
              item.offset,
            ),
          );
        },
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

class _GridItem {
  final String title;
  final String iconPath;
  final Widget screen;
  final Offset offset;
  final double? iconHeight;
  final double? iconWidth;

  _GridItem({
    required this.title,
    required this.iconPath,
    required this.screen,
    required this.offset,
    this.iconHeight,
    this.iconWidth,
  });
}

class ModernNavigationCard extends StatefulWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;
  final double? iconHeight;
  final double? iconWidth;
  final bool isLarge;

  const ModernNavigationCard({
    super.key,
    required this.title,
    required this.iconPath,
    required this.onTap,
    this.iconHeight,
    this.iconWidth,
    this.isLarge = false,
  });

  @override
  State<ModernNavigationCard> createState() => _ModernNavigationCardState();
}

class _ModernNavigationCardState extends State<ModernNavigationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    
    _elevationAnimation = Tween<double>(
      begin: 8.0,
      end: 4.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: widget.isLarge ? 120 : null,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: _elevationAnimation.value,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: widget.isLarge
                ? _buildLargeCardContent()
                : _buildRegularCardContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeCardContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Image.asset(
              widget.iconPath,
              height: 40,
              width: 40,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to search',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey[600],
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildRegularCardContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Image.asset(
              widget.iconPath,
              height: widget.iconHeight ?? 32,
              width: widget.iconWidth ?? 32,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.title,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}