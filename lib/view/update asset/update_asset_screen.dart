import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sewa/controller/update_asset_controller.dart';
import 'package:sewa/global/app_colors.dart';
import 'package:sewa/global/app_styles.dart';
import 'package:sewa/view/update%20asset/add_location.dart';

class UpdateAssetScreen extends StatefulWidget {
  final String recordNo;
  final String assetNumber;
  const UpdateAssetScreen({
    super.key,
    required this.recordNo,
    required this.assetNumber,
  });

  @override
  _UpdateAssetScreenState createState() => _UpdateAssetScreenState();
}

class _UpdateAssetScreenState extends State<UpdateAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final createAssetController = Get.put(CreateAssetController());

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      useDefaultLoading: true,
      child: Scaffold(
        backgroundColor: AppColors.white,
        persistentFooterButtons: buildButtons(),
        persistentFooterAlignment: AlignmentDirectional.center,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          title: Text('Update Asset', style: AppStyles.black_20_600),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildTextField(
                  'Asset No',
                  createAssetController.assetNoController,
                  true,
                ),
                _buildTextField(
                  'Location',
                  createAssetController.locationController,
                  true,
                ),
                _buildTextField(
                  'Substation',
                  createAssetController.substationController,
                  true,
                ),
                _buildTextField(
                  'Parent',
                  createAssetController.parentController,
                  true,
                ),
                _buildTextField(
                  'Description',
                  createAssetController.descriptionController,
                  true,
                ),
                _buildTextField(
                  'Asset Description',
                  createAssetController.assetDescriptionController,
                  true,
                ),
                _buildTextField(
                  'Failure Code',
                  createAssetController.failureCodeController,
                  true,
                ),
                _buildTextField(
                  'Model No',
                  createAssetController.modelNoController,
                  true,
                ),
                _buildTextField(
                  'Serial Number',
                  createAssetController.serialNumberController,
                  true,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Latitude',
                        createAssetController.latitudeController,
                        true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        'Longitude',
                        createAssetController.longitudeController,
                        true,
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder:
                                  (_) => GoogleMapScreen(
                                    onLocationSelected: (latitude, longitude) {
                                      setState(() {
                                        createAssetController
                                            .latitudeController
                                            .text = latitude.toString();
                                        createAssetController
                                            .longitudeController
                                            .text = longitude.toString();
                                      });
                                    },
                                  ),
                            ),
                          );
                        },
                        icon: Icon(Icons.location_on),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildButtons() {
    return [
      ElevatedButton(
        onPressed: () {
          createAssetController.resetFields();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.black,
          padding: const EdgeInsets.symmetric(horizontal: 40),
        ),
        child: Text('Reset', style: AppStyles.white_15_400),
      ),
      const SizedBox(width: 50),
      const SizedBox(width: 50),
      ElevatedButton(
        onPressed: () {
          createAssetController
              .updateAssetDetails(context, recordNo: widget.recordNo);
             
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.black,
          padding: const EdgeInsets.symmetric(horizontal: 40),
        ),
        child: Text('Update', style: AppStyles.white_15_400),
      ),
    ];
  }


  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool enabled,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                labelStyle: AppStyles.black_16_600,
                labelText: label,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
