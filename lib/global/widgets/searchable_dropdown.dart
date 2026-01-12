import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sewa/global/app_colors.dart';

// ignore: must_be_immutable
class SearchableDropdown extends StatefulWidget {
  final RxBool isItemLoaded; // Indicates whether items are loaded
  final Icon? prefixIcon;
  final String? hintText;
  final String? searchBoxHintText;
  final RxList<String> items;
  final String? Function(String?)? validator;
  String? selectedValue;
  void Function(String?)? onChanged;
  final bool isRequired;

  SearchableDropdown({
    super.key,
    required this.isItemLoaded,
    this.searchBoxHintText,
    this.prefixIcon,
    this.hintText,
    required this.items,
    required this.selectedValue,
    this.validator,
    required this.onChanged,
    required this.isRequired,
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          child: Row(
            children: [
              Flexible(
                child: DropdownSearch<String>(
                  enabled: widget.isItemLoaded.value, // Disable when items not loaded
                  popupProps: PopupProps.menu(
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: widget.searchBoxHintText ?? "Search...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    showSearchBox: true,
                    showSelectedItems: true,
                    menuProps: MenuProps(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      backgroundColor:
                          isDarkMode ? Colors.grey[800] : Colors.white,
                    ),
                  ),
                  items: widget.items,
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      suffixIconConstraints: const BoxConstraints(
                        minHeight: 50,
                        minWidth: 4,
                      ),
                      prefixIcon: widget.prefixIcon,
                      suffixIcon: widget.isItemLoaded.value
                          ? Icon(Icons.arrow_drop_down, color: isDarkMode ? Colors.white70 : AppColors.appColor)
                          : const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.appColor,
                              ),
                            ),
                      hintStyle: TextStyle(
                          color: isDarkMode ? Colors.white70 : const Color(0xFF6CA8F1)),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                            color: isDarkMode
                                ? Colors.grey[600]!
                                : AppColors.grey300,
                            width: 2),
                      ),
                      labelText: widget.hintText,
                      isDense: true,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? Colors.blueAccent
                              : AppColors.appColor,
                          width: 2,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: widget.isItemLoaded.value && widget.items.isEmpty
                          ? (isDarkMode
                              ? Colors.grey[600]
                              : AppColors.chineseGrey)
                          : (isDarkMode
                              ? Colors.grey[800]
                              : AppColors.chineseGrey),
                    ),
                  ),
                  onChanged: widget.onChanged,
                  selectedItem: widget.selectedValue,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: widget.isRequired
                      ? Colors.red
                      : (isDarkMode ? Colors.grey[600] : AppColors.grey300),
                ),
                height: 47,
                width: 4,
              ),
            ],
          ),
        ));
  }
}
