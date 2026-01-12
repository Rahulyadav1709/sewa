import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sewa/controller/client_mgr_home_controller.dart';
import 'package:sewa/helpers/shared_preferences_helpers.dart';

import '../widgets/detail_field.dart';

class InformationTab extends StatefulWidget {
  final String? failurecode;
  final String? recordNo;
  final String? shortDescription;
  final String? longDesc;
  final String? status;
  final String? equipmentNo;
  final String? techID;
  final String? assetNo;
  final String? location;
  final String? parent;
  final String? modelNo;
  final String? serialNo;
  final String? subSatationNumber;
  final Function(String)? onStatusChanged;
  final Function(String, String)? onCommentsSubmitted;
  final String? editBy;
  final String? pilogComment;
  final String? assetTaggingType;

  const InformationTab({
    super.key,
    this.failurecode,
    this.recordNo,
    this.shortDescription,
    this.longDesc,
    this.status,
    this.equipmentNo,
    this.techID,
    this.onStatusChanged,
    this.onCommentsSubmitted,
    this.assetNo,
    this.location,
    this.parent,
    this.modelNo,
    this.serialNo,
    this.subSatationNumber,
    this.editBy,
    this.pilogComment,
    this.assetTaggingType,
  });

  @override
  State<InformationTab> createState() => _InformationTabState();
}

class _InformationTabState extends State<InformationTab> {
  String? currentStatus;
  String? currentAssetTaggingType;
  bool isCustomStatus = false;
  TextEditingController customStatusController = TextEditingController();
  ClientMgrHomeController clientMgrHomeController =
      Get.find<ClientMgrHomeController>();

  Future<String?> username() async {
    return await SharedPreferencesHelper.getUsername();
  }

  @override
  void initState() {
    super.initState();
    currentStatus = null;
    currentAssetTaggingType = widget.assetTaggingType;

    if (widget.status != null &&
        !statusOptions.contains(widget.status) &&
        widget.status!.isNotEmpty) {
      isCustomStatus = true;
      currentStatus = "Others";
      customStatusController.text = widget.status!;
    }
  }

  @override
  void dispose() {
    customStatusController.dispose();
    super.dispose();
  }

  final List<String> statusOptions = [
    "Found",
    "Not Found",
    "Newly Found",
    "Others",
    "System",
  ];

  final List<String> assetTaggingTypeOptions = ["Hang", "Stick"];

  @override
  Widget build(BuildContext context) {
    if (widget.status != null &&
        statusOptions.contains(widget.status) &&
        currentStatus == null) {
      currentStatus = widget.status;
    }

    log("edit_by : ${widget.editBy}");

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FAFC), Color(0xFFFFFFFF)],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Asset Information",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "View and manage asset details",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            // General Information Card
            _buildModernInfoCard(
              title: "General Information",
              icon: Icons.info_outline,
              children: [
                DetailField(
                  label: "Failure Code",
                  value: widget.failurecode,
                  prefixIcon: Icons.error_outline,
                ),
                DetailField(
                  label: "Record No",
                  value: widget.recordNo,
                  prefixIcon: Icons.receipt_long,
                ),
                DetailField(
                  label: "Asset No",
                  value: widget.assetNo,
                  prefixIcon: Icons.inventory,
                ),
                DetailField(
                  label: "Short Description",
                  value: widget.shortDescription,
                  prefixIcon: Icons.description,
                ),
                DetailField(
                  label: "Long Description",
                  value: widget.longDesc,
                  maxLines: 3,
                  prefixIcon: Icons.notes,
                ),
                DetailField(
                  label: "Location",
                  value: widget.location,
                  prefixIcon: Icons.location_on,
                ),
                DetailField(
                  label: "Asset Type",
                  value: widget.assetTaggingType,
                ),
                DetailField(
                  label: "Sub-Station Number",
                  value: widget.subSatationNumber,
                  prefixIcon: Icons.electrical_services,
                ),
                DetailField(
                  label: "Model Number",
                  value: widget.modelNo,
                  prefixIcon: Icons.model_training,
                ),
                DetailField(
                  label: "Serial Number",
                  value: widget.serialNo,
                  prefixIcon: Icons.qr_code,
                ),
                DetailField(
                  label: "Parent",
                  value: widget.parent,
                  prefixIcon: Icons.account_tree,
                ),
                DetailField(
                  label: "Pilog Comment",
                  value: widget.pilogComment,
                  maxLines: 2,
                  prefixIcon: Icons.comment,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Status Management Card
            _buildModernInfoCard(
              title: "Status Management",
              icon: Icons.track_changes,
              children: [
                _buildModernDropdown(),
                if (isCustomStatus) _buildCustomStatusField(),
              ],
            ),

            const SizedBox(height: 24),

            // Asset Tagging Type Card
            _buildModernInfoCard(
              title: "Asset Tagging Type",
              icon: Icons.local_offer,
              children: [_buildAssetTaggingTypeDropdown()],
            ),

            const SizedBox(height: 24),

            // Comments Card
            _buildModernInfoCard(
              title: "Comments & Updates",
              icon: Icons.comment_bank,
              children: [
                _buildModernTextField(
                  label: "PILOG Comments",
                  controller: clientMgrHomeController.pilogCommentsController,
                  hintText: "Enter PILOG comments...",
                  prefixIcon: Icons.comment,
                ),
                _buildModernTextField(
                  label: "SEWA Comments",
                  controller: clientMgrHomeController.taqaCommentsController,
                  hintText: "Enter SEWA comments...",
                  prefixIcon: Icons.rate_review,
                ),
                DetailField(
                  label: "Edited By",
                  value: widget.editBy ?? "",
                  prefixIcon: Icons.person,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Submit Button
            _buildModernSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildModernDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text(
              "Status",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
                letterSpacing: 0.1,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: currentStatus,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.flag,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF3B82F6),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              hint: const Text(
                "Select Status",
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w400,
                ),
              ),
              items: statusOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  currentStatus = newValue;
                  isCustomStatus = newValue == "Others";

                  if (!isCustomStatus) {
                    customStatusController.clear();
                    if (widget.onStatusChanged != null && newValue != null) {
                      widget.onStatusChanged!(newValue);
                    }
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetTaggingTypeDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text(
              "Asset Tagging Type",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
                letterSpacing: 0.1,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: currentAssetTaggingType,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.local_offer,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF3B82F6),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              hint: const Text(
                "Select Tagging Type",
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w400,
                ),
              ),
              items: assetTaggingTypeOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      // Icon(
                      //   value == "Hand" ? Icons.pan_tool : Icons.construction,
                      //   color: const Color(0xFF6B7280),
                      //   size: 18,
                      // ),
                      const SizedBox(width: 8),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  currentAssetTaggingType = newValue;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomStatusField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text(
              "Custom Status",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
                letterSpacing: 0.1,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: customStatusController,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: "Enter custom status...",
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: const Icon(
                  Icons.edit,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF3B82F6),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                if (widget.onStatusChanged != null) {
                  widget.onStatusChanged!(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    int maxLines = 3,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
                letterSpacing: 0.1,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              minLines: 1,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  prefixIcon,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF3B82F6),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          final String? rawUsername =
              await SharedPreferencesHelper.getUsername();

          if (rawUsername == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Username not found"),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            return;
          }

          final String username = rawUsername.toUpperCase();
          final String finalStatus = isCustomStatus
              ? customStatusController.text
              : currentStatus ?? "";

          clientMgrHomeController.updateAssetDetails(
            assetTaggingType: currentAssetTaggingType ?? "",
            context,
            recordNo: widget.recordNo ?? "",
            clientComment: clientMgrHomeController.taqaCommentsController.text,
            pilogComment: clientMgrHomeController.pilogCommentsController.text,
            status: finalStatus,
            username: username,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.save, color: Colors.white, size: 20),
        label: Text(
          "Submit Changes",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
