import 'dart:convert';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';

import '../authstoreage/appinventry.dart';
import '../authstoreage/authstorage.dart';
import '../backend/delete&editcontroller.dart';
import '../backend/showapi.dart';
import '../backend/showinventries.dart';
import '../poscalculator/constant/apptext.dart';
import '../poscalculator/constant/colors.dart';
import '../poscalculator/poscalculator.dart';
import '../widget/billshare.dart';
import '../widget/button.dart';
import '../widget/snakbar.dart';

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
// APP BUTTON
// ─────────────────────────────────────────────


// ─────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
// INVENTORY SCREEN
// ─────────────────────────────────────────────
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _itemNameCtrl = TextEditingController();
  final _mrpCtrl = TextEditingController();
  final _saleRateCtrl = TextEditingController();
  final _initialStockCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  String _unit = 'Per Ltr';
  final AddInventoryController controller =
  Get.put(AddInventoryController());
  final ShowInventoryController showController = Get.put(ShowInventoryController(),);
  final UserController userController = Get.put(UserController());
  String taxType = "inclusive";
  final TextEditingController
  searchCtrl =
  TextEditingController();
  String _gst = '0%';

  String generateBarcode() {

    final now = DateTime.now();

    return
      "${now.year}"
          "${now.month}"
          "${now.day}"
          "${now.hour}"
          "${now.minute}"
          "${now.second}";
  }

  @override
  void initState() {
    super.initState();
    loadUser();
    loadInventory();
  }
  void clearAllFields() {

    _itemNameCtrl.clear();

    _mrpCtrl.clear();

    _saleRateCtrl.clear();

    _initialStockCtrl.clear();

    _barcodeCtrl.clear();

    setState(() {

      _unit = 'Per Ltr';
    });
  }
  Future<void> loadInventory() async {

    String? phone =
    await AuthStorage.getEmail();

    if(phone != null){

      await showController.getInventory(
        phone: phone,
      );
    }
  }
  void _addItem() async {

    // 🔥 GET VALUES
    final name =
    _itemNameCtrl.text.trim();

    final mrp =
        double.tryParse(
          _mrpCtrl.text,
        ) ?? 0;

    final sale =
        double.tryParse(
          _saleRateCtrl.text,
        ) ?? 0;

    final stock =
        int.tryParse(
          _initialStockCtrl.text,
        ) ?? 0;

    // 🔥 VALIDATION
    if (name.isEmpty) {

      NeuSnackbar.error(
        "Enter Item Name",
      );

      return;
    }

    if (_mrpCtrl.text.trim().isEmpty) {

      NeuSnackbar.error(
        "Enter MRP",
      );

      return;
    }

    if (_saleRateCtrl.text.trim().isEmpty) {

      NeuSnackbar.error(
        "Enter Sale Rate",
      );

      return;
    }

    if (_initialStockCtrl.text.trim().isEmpty) {

      NeuSnackbar.error(
        "Enter Initial Stock",
      );

      return;
    }

    // 🔥 AUTO BARCODE
    final barcode =
    _barcodeCtrl.text.isEmpty

        ? generateBarcode()

        : _barcodeCtrl.text;

    // 🔥 PHONE
    String? phone =
    await AuthStorage.getEmail();

    // 🔥 API CALL
    await controller.addInventory(

      itemName: name,

      mrpOld:
      mrp.toString(),

      salePrice:
      sale.toString(),

      type:
      _unit.replaceAll(
        'Per ',
        '',
      ),

      intialStock:
      stock.toString(),

      barcode: barcode,

      phone:
      phone ?? "",

      gst:
      _gst.replaceAll("%", ""),
    );

    // 🔥 RELOAD INVENTORY
    await loadInventory();

    // 🔥 CLEAR
    _itemNameCtrl.clear();

    _mrpCtrl.clear();

    _saleRateCtrl.clear();

    _initialStockCtrl.clear();

    _barcodeCtrl.clear();

    // 🔥 RESET UNIT
    setState(() {

      _unit = 'Per Ltr';
    });
  }
  void loadUser() async {

    String? phone =
    await AuthStorage.getEmail();

    if(phone != null){

      userController.getUser(
        phone: phone,
      );
    }
  }
  void _openPrintSheet(_InventoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PrintLabelSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.scaffold,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textDark,
            size: 20.sp,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Inventory & Stock', style: AppText.pageTitle()),
        centerTitle: false,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        children: [
          // ── ADD NEW ITEM CARD ──
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                searchBar(

                  controller: searchCtrl,

                  onChanged: (v) {


                    showController
                        .filterInventory(v);
                  },
                ),
                SizedBox(height: 15.w),
                Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        color: AppColors.textGreen, size: 18.sp),
                    SizedBox(width: 6.w),
                    Text(
                      'ADD NEW ITEM',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textGreen,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _inputField('Item Name', _itemNameCtrl),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(child: _inputField('Rate(₹)', _mrpCtrl, isNumber: true)),
                    SizedBox(width: 10.w),
                    Expanded(child: _inputField('MRP(₹)*', _saleRateCtrl, isNumber: true)),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _unitDropdown(),

                    SizedBox(width: 10.w),
                    Expanded(child: _inputField('Initial Stock', _initialStockCtrl, isNumber: true)),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Text("%",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),),
                    SizedBox(width: 2.h),
                    Text("GST Setting",style: TextStyle(fontWeight: FontWeight.bold),),
                  ],
                ),

                SizedBox(height: 10.h),
                _gstTabs(),
                SizedBox(height: 10.h),
                _inputField('Barcode ID (Leave empty to Auto-Gen)', _barcodeCtrl),
                SizedBox(height: 14.h),
                Row(

                  children: [

                    /// CLEAR ALL
                    Expanded(

                      child: GestureDetector(

                        onTap: clearAllFields,

                        child: Container(

                          height: 48.h,

                          decoration: BoxDecoration(

                            color: Colors.white,

                            borderRadius:
                            BorderRadius.circular(12.r),

                            border: Border.all(

                              color:
                              AppColors.inputBorder,
                            ),
                          ),

                          child: Center(

                            child: Text(

                              "Clear All",

                              style:
                              GoogleFonts.poppins(

                                fontSize: 14.sp,

                                fontWeight:
                                FontWeight.w600,

                                color:
                                AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 10.w),

                    /// SAVE BUTTON
                    Expanded(

                      flex: 2,

                      child: Obx(

                            () => GestureDetector(

                          onTap:
                          controller.isLoading.value

                              ? null

                              : _addItem,

                          child: Container(

                            height: 48.h,

                            decoration: BoxDecoration(

                              color:
                              AppColors.textGreen,

                              borderRadius:
                              BorderRadius.circular(
                                12.r,
                              ),
                            ),

                            child: Center(

                              child: Text(

                                controller.isLoading.value

                                    ? "Please Wait..."

                                    : "Save",

                                style:
                                GoogleFonts.poppins(

                                  fontSize: 14.sp,

                                  fontWeight:
                                  FontWeight.w700,

                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Obx(
                //       () => AppButton(
                //
                //     text:
                //     controller.isLoading.value
                //         ? "Please Wait..."
                //         : 'Save',
                //
                //     color: AppColors.textGreen,
                //     textColor: Colors.white,
                //
                //     width: double.infinity,
                //     height: 48.h,
                //
                //     icon:
                //     controller.isLoading.value
                //         ? null
                //         : Icons.add_rounded,
                //
                //     onTap: _addItem,
                //   ),
                // )
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // ── ITEM LIST ──
          Obx(() {

            final InventoryActionController
            actionController =
            Get.put(
              InventoryActionController(),
            );

            if(showController.isLoading.value){

              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if(showController.inventoryList.isEmpty){

              return Padding(

                padding: EdgeInsets.only(top: 40.h),

                child: Center(
                  child: Text(

                    "No Inventory Found",

                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
              );
            }

            return Column(

              children:

              List.generate(

                // showController.inventoryList.length,
                showController.filteredList.length,

                    (index) {

                  final item =
                  // showController.inventoryList[index];
                  showController.filteredList[index];

                  final inventoryItem =
                  _InventoryItem(

                    id:
                    item["id"].toString(),

                    name:
                    item["ItemName"]
                        .toString(),

                    mrp:
                    double.tryParse(
                      item["MrpOld"]
                          .toString(),
                    ) ??
                        0,

                    saleRate:
                    double.tryParse(
                      item["SalePrice"]
                          .toString(),
                    ) ??
                        0,

                    unit:
                    item["Type"]
                        .toString(),

                    stock:
                    int.tryParse(
                      item["IntialStock"]
                          .toString(),
                    ) ??
                        0,

                    barcode:
                    item["Barcode"]
                        .toString(),
                    gst:
                      item["Gst"].toString(),
                  );

                  final isDeleting =

                      actionController
                          .deletingId
                          .value

                          ==

                          inventoryItem.id;

                  return _ItemCard(

                    item: inventoryItem,

                    isDeleting:
                    isDeleting,

                    // 🔥 PRINT
                    onPrint: () {

                      _openPrintSheet(
                        inventoryItem,
                      );
                    },

                    // 🔥 DELETE
                    onDelete: () async {

                      bool? confirm =
                      await showDialog(

                        context: context,

                        builder: (_) {

                          return AlertDialog(

                            shape:
                            RoundedRectangleBorder(

                              borderRadius:
                              BorderRadius.circular(16.r),
                            ),

                            title: const Text(
                              "Delete Item",
                            ),

                            content: const Text(

                              "Are you sure you want to delete this item?",
                            ),

                            actions: [

                              TextButton(

                                onPressed: () {

                                  Navigator.pop(
                                    context,
                                    false,
                                  );
                                },

                                child:
                                const Text("No"),
                              ),

                              ElevatedButton(

                                style:
                                ElevatedButton.styleFrom(

                                  backgroundColor:
                                  Colors.red,
                                ),

                                onPressed: () {

                                  Navigator.pop(
                                    context,
                                    true,
                                  );
                                },

                                child:
                                const Text(

                                  "Yes",

                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {

                        bool deleted =

                        await actionController
                            .deleteInventory(

                          id:
                          inventoryItem.id,
                        );

                        if (deleted) {

                          showController
                              .inventoryList
                              .removeAt(index);
                        }
                      }
                    },

                    // 🔥 EDIT
                    onEdit: () {

                      _itemNameCtrl.text =
                          inventoryItem.name;

                      _mrpCtrl.text =
                          inventoryItem.mrp
                              .toString();

                      _saleRateCtrl.text =
                          inventoryItem.saleRate
                              .toString();

                      _initialStockCtrl.text =
                          inventoryItem.stock
                              .toString();

                      _barcodeCtrl.text =
                          inventoryItem.barcode;

                      _unit =
                      "Per ${inventoryItem.unit}";

                      /// GST LOAD
                      _gst =
                      "${inventoryItem.gst}%";

                      showModalBottomSheet(

                        context: context,

                        isScrollControlled: true,

                        backgroundColor:
                        Colors.transparent,

                        builder: (_) {

                          String taxType = "exclusive";
                          return StatefulBuilder(

                            builder:
                                (context, modalSetState) {

                              return Padding(

                                padding: EdgeInsets.only(

                                  bottom:
                                  MediaQuery.of(context)
                                      .viewInsets
                                      .bottom,
                                ),

                                child: Container(

                                  padding:
                                  EdgeInsets.all(16.w),

                                  decoration: BoxDecoration(

                                    color:
                                    AppColors.cardWhite,

                                    borderRadius:
                                    BorderRadius.vertical(

                                      top:
                                      Radius.circular(24.r),
                                    ),
                                  ),

                                  child:
                                  SingleChildScrollView(

                                    child: Column(

                                      mainAxisSize:
                                      MainAxisSize.min,

                                      children: [

                                        /// ITEM NAME
                                        _inputField(
                                          'Item Name',
                                          _itemNameCtrl,
                                        ),

                                        SizedBox(height: 10.h),

                                        /// MRP
                                        _inputField(
                                          'MRP',
                                          _mrpCtrl,
                                          isNumber: true,
                                        ),

                                        SizedBox(height: 10.h),

                                        /// SALE PRICE
                                        _inputField(
                                          'Sale Price',
                                          _saleRateCtrl,
                                          isNumber: true,
                                        ),

                                        SizedBox(height: 10.h),

                                        /// UNIT + STOCK
                                        Row(

                                          children: [

                                            Expanded(

                                              child:
                                              _editunitDropdown(
                                                modalSetState,
                                              ),
                                            ),

                                            SizedBox(width: 1.w),

                                            SizedBox(

                                              width: 120.w,

                                              child: _inputField(

                                                'Stock',

                                                _initialStockCtrl,

                                                isNumber: true,
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 14.h),

                                        /// GST BOX
                                        Container(

                                          width:
                                          double.infinity,

                                          padding:
                                          EdgeInsets.symmetric(

                                            horizontal: 12.w,
                                            vertical: 12.h,
                                          ),

                                          decoration:
                                          BoxDecoration(

                                            color:
                                            const Color(
                                              0xFFF8F9FA,
                                            ),

                                            borderRadius:
                                            BorderRadius.circular(
                                              14.r,
                                            ),

                                            border:
                                            Border.all(

                                              color:
                                              AppColors
                                                  .inputBorder,
                                            ),
                                          ),

                                          child: Column(

                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,

                                            children: [

                                              /// TITLE
                                              Row(

                                                children: [

                                                  Icon(

                                                    Icons
                                                        .percent_rounded,

                                                    color:
                                                    AppColors
                                                        .textGreen,

                                                    size: 18.sp,
                                                  ),

                                                  SizedBox(
                                                    width: 6.w,
                                                  ),

                                                  Text(

                                                    "Update GST",

                                                    style:
                                                    GoogleFonts
                                                        .poppins(

                                                      fontSize:
                                                      13.sp,

                                                      fontWeight:
                                                      FontWeight
                                                          .w700,

                                                      color:
                                                      AppColors
                                                          .textDark,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              SizedBox(
                                                height: 14.h,
                                              ),

                                              /// GST TABS
                                              Container(
                                                padding: EdgeInsets.all(14.w),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF3F3F3),
                                                  borderRadius: BorderRadius.circular(16.r),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    /// TITLE
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.percent_rounded,
                                                          size: 18.sp,
                                                          color: Colors.grey.shade700,
                                                        ),
                                                        SizedBox(width: 6.w),
                                                        Text(
                                                          "GST Setting",
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 13.sp,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.grey.shade800,
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    SizedBox(height: 14.h),

                                                    /// GST BUTTONS
                                                    Row(
                                                      children: [
                                                        '0%',
                                                        '5%',
                                                        '12%',
                                                        '18%',
                                                      ].map((g) {

                                                        final selected = _gst == g;

                                                        return Expanded(
                                                          child: GestureDetector(

                                                            onTap: () {

                                                              modalSetState(() {

                                                                _gst = g;
                                                              });
                                                            },

                                                            child: AnimatedContainer(

                                                              duration: const Duration(
                                                                milliseconds: 250,
                                                              ),

                                                              margin: EdgeInsets.symmetric(
                                                                horizontal: 4.w,
                                                              ),

                                                              padding: EdgeInsets.symmetric(
                                                                vertical: 12.h,
                                                              ),

                                                              decoration: BoxDecoration(

                                                                gradient: selected

                                                                    ? const LinearGradient(

                                                                  colors: [

                                                                    Color(0xFF2563EB),

                                                                    Color(0xFF3B82F6),
                                                                  ],

                                                                  begin: Alignment.topLeft,

                                                                  end: Alignment.bottomRight,
                                                                )

                                                                    : null,

                                                                color: selected
                                                                    ? null
                                                                    : Colors.white,

                                                                borderRadius:
                                                                BorderRadius.circular(12.r),

                                                                border: Border.all(

                                                                  color: selected

                                                                      ? const Color(0xFF2563EB)

                                                                      : Colors.grey.shade300,

                                                                  width: 1.2,
                                                                ),

                                                                boxShadow: [

                                                                  BoxShadow(

                                                                    color: selected

                                                                        ? const Color(0xFF2563EB)
                                                                        .withOpacity(0.25)

                                                                        : Colors.black.withOpacity(0.03),

                                                                    blurRadius: selected ? 12 : 6,

                                                                    offset: const Offset(0, 3),
                                                                  ),
                                                                ],
                                                              ),

                                                              child: Center(

                                                                child: AnimatedDefaultTextStyle(

                                                                  duration: const Duration(
                                                                    milliseconds: 250,
                                                                  ),

                                                                  style: GoogleFonts.poppins(

                                                                    fontSize: selected ? 13.sp : 12.sp,

                                                                    fontWeight: FontWeight.w700,

                                                                    color: selected

                                                                        ? Colors.white

                                                                        : Colors.black87,
                                                                  ),

                                                                  child: Text(g),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),

                                                    SizedBox(height: 12.h),

                                                    /// TAX EXCLUSIVE
                                                    GestureDetector(
                                                      onTap: () {
                                                        modalSetState(() {
                                                          taxType = "exclusive";
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.symmetric(
                                                          horizontal: 12.w,
                                                          vertical: 12.h,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: taxType == "exclusive"
                                                              ? const Color(0xFF22C55E)
                                                              : Colors.white,
                                                          borderRadius: BorderRadius.circular(10.r),
                                                          border: Border.all(
                                                            color: taxType == "exclusive"
                                                                ? const Color(0xFF22C55E)
                                                                : Colors.grey.shade300,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.check_circle,
                                                              size: 18.sp,
                                                              color: taxType == "exclusive"
                                                                  ? Colors.white
                                                                  : Colors.grey,
                                                            ),

                                                            SizedBox(width: 8.w),

                                                            Text(
                                                              "Tax Exclusive (Added on top)",
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 12.sp,
                                                                fontWeight: FontWeight.w500,
                                                                color: taxType == "exclusive"
                                                                    ? Colors.white
                                                                    : Colors.black87,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),

                                                    SizedBox(height: 10.h),

                                                    /// TAX INCLUSIVE
                                                    GestureDetector(
                                                      onTap: () {
                                                        modalSetState(() {
                                                          taxType = "inclusive";
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.symmetric(
                                                          horizontal: 12.w,
                                                          vertical: 12.h,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: taxType == "inclusive"
                                                              ? const Color(0xFF22C55E)
                                                              : Colors.white,
                                                          borderRadius: BorderRadius.circular(10.r),
                                                          border: Border.all(
                                                            color: taxType == "inclusive"
                                                                ? const Color(0xFF22C55E)
                                                                : Colors.grey.shade300,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.check_circle_outline,
                                                              size: 18.sp,
                                                              color: taxType == "inclusive"
                                                                  ? Colors.white
                                                                  : Colors.grey,
                                                            ),

                                                            SizedBox(width: 8.w),

                                                            Text(
                                                              "Tax Inclusive (In price)",
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 12.sp,
                                                                fontWeight: FontWeight.w500,
                                                                color: taxType == "inclusive"
                                                                    ? Colors.white
                                                                    : Colors.black87,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                              // Row(
                                              //
                                              //   children: [
                                              //     '0%',
                                              //     '5%',
                                              //     '12%',
                                              //     '18%',
                                              //
                                              //   ].map((g) {
                                              //
                                              //     final selected =
                                              //         _gst == g;
                                              //
                                              //     return Expanded(
                                              //
                                              //       child:
                                              //       GestureDetector(
                                              //
                                              //         onTap: () {
                                              //
                                              //           modalSetState(() {
                                              //
                                              //             _gst = g;
                                              //           });
                                              //         },
                                              //
                                              //         child:
                                              //         AnimatedContainer(
                                              //
                                              //           duration:
                                              //           const Duration(
                                              //             milliseconds:
                                              //             250,
                                              //           ),
                                              //
                                              //           margin:
                                              //           EdgeInsets.symmetric(
                                              //             horizontal:
                                              //             3.w,
                                              //           ),
                                              //
                                              //           padding:
                                              //           EdgeInsets.symmetric(
                                              //             vertical:
                                              //             12.h,
                                              //           ),
                                              //
                                              //           decoration:
                                              //           BoxDecoration(
                                              //
                                              //             color:
                                              //             selected
                                              //
                                              //                 ? Colors.green
                                              //
                                              //                 : Colors.white,
                                              //
                                              //             borderRadius:
                                              //             BorderRadius.circular(
                                              //               10.r,
                                              //             ),
                                              //
                                              //             border:
                                              //             Border.all(
                                              //
                                              //               color:
                                              //               selected
                                              //
                                              //                   ? Colors.green
                                              //
                                              //                   : AppColors.inputBorder,
                                              //             ),
                                              //
                                              //             boxShadow:
                                              //             selected
                                              //
                                              //                 ? [
                                              //
                                              //               BoxShadow(
                                              //
                                              //                 color:
                                              //                 Colors.green.withOpacity(
                                              //                   0.20,
                                              //                 ),
                                              //
                                              //                 blurRadius:
                                              //                 8,
                                              //
                                              //                 offset:
                                              //                 const Offset(
                                              //                   0,
                                              //                   3,
                                              //                 ),
                                              //               ),
                                              //             ]
                                              //
                                              //                 : [],
                                              //           ),
                                              //
                                              //           child:
                                              //           Center(
                                              //
                                              //             child:
                                              //             Text(
                                              //
                                              //               g,
                                              //
                                              //               style:
                                              //               GoogleFonts.poppins(
                                              //
                                              //                 fontSize:
                                              //                 11.sp,
                                              //
                                              //                 fontWeight:
                                              //                 FontWeight.w700,
                                              //
                                              //                 color:
                                              //                 selected
                                              //
                                              //                     ? Colors.white
                                              //
                                              //                     : AppColors.textDark,
                                              //               ),
                                              //             ),
                                              //           ),
                                              //         ),
                                              //       ),
                                              //     );
                                              //   }).toList(),
                                              // ),
                                            ],
                                          ),
                                        ),

                                        SizedBox(height: 14.h),

                                        /// BARCODE
                                        _inputField(
                                          'Barcode',
                                          _barcodeCtrl,
                                        ),

                                        SizedBox(height: 20.h),

                                        /// UPDATE BUTTON
                                        Obx(() {

                                          return AppButton(

                                            text:
                                            actionController
                                                .isLoading
                                                .value

                                                ? "Updating..."

                                                : "Update Item",

                                            color:
                                            AppColors.textGreen,

                                            textColor:
                                            Colors.white,

                                            width:
                                            double.infinity,

                                            height: 48.h,

                                            onTap: () async {

                                              final barcode =
                                              _barcodeCtrl
                                                  .text
                                                  .isEmpty

                                                  ? generateBarcode()

                                                  : _barcodeCtrl
                                                  .text;

                                              _barcodeCtrl.text =
                                                  barcode;

                                              String? phone =
                                              await AuthStorage
                                                  .getEmail();

                                              bool updated =

                                              await actionController
                                                  .updateInventory(

                                                id:
                                                inventoryItem.id,

                                                itemName:
                                                _itemNameCtrl
                                                    .text,

                                                mrpOld:
                                                _mrpCtrl.text,

                                                salePrice:
                                                _saleRateCtrl
                                                    .text,

                                                type:
                                                _unit.replaceAll(
                                                  "Per ",
                                                  "",
                                                ),

                                                intialStock:
                                                _initialStockCtrl
                                                    .text,

                                                barcode:
                                                barcode,

                                                phone:
                                                phone ?? "",

                                                gst:
                                                _gst.replaceAll(
                                                  "%",
                                                  "",
                                                ),
                                              );

                                              if (updated) {

                                                clearAllFields();

                                                Navigator.pop(
                                                  context,
                                                );

                                                loadInventory();
                                              }
                                            },
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            );
          })
        ],
      ),
    );
  }

  Widget _inputField(String hint, TextEditingController ctrl,
      {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: AppText.fieldValue(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppText.hint(),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding:
        EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide:
          BorderSide(color: AppColors.textGreen, width: 1.5),
        ),
      ),
    );
  }
  Widget searchBar({

    required TextEditingController controller,

    Function(String)? onChanged,
  }) {

    return Container(

      height: 48.h,

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(12.r),

        border: Border.all(

          color:
          const Color(0xFFE5E7EB),
        ),

        boxShadow: [

          BoxShadow(

            color:
            Colors.black.withOpacity(0.03),

            blurRadius: 8,

            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: TextField(

        controller: controller,

        onChanged: onChanged,

        style: GoogleFonts.poppins(

          fontSize: 13.sp,

          fontWeight: FontWeight.w500,

          color: AppColors.textDark,
        ),

        decoration: InputDecoration(

          hintText:
          "Search items or barcode...",

          hintStyle:
          GoogleFonts.poppins(

            fontSize: 12.sp,

            color: Colors.grey,
          ),

          prefixIcon: Icon(

            Icons.search_rounded,

            color: Colors.grey,

            size: 20.sp,
          ),



          border:
          InputBorder.none,

          contentPadding:
          EdgeInsets.symmetric(

            vertical: 13.h,
          ),
        ),
      ),
    );
  }
  Widget _gstTabs() {

    final gstList = [
      '0%',
      '5%',
      '12%',
      '18%',
    ];

    final mrp =
        double.tryParse(_mrpCtrl.text) ?? 0;

    final gstValue =
        double.tryParse(
          _gst.replaceAll("%", ""),
        ) ?? 0;

    double gstAmount = 0;

    if (taxType == "exclusive") {

      gstAmount =
          (mrp * gstValue) / 100;

    } else {

      gstAmount =
          mrp -
              (mrp / (1 + gstValue / 100));
    }

    final finalPrice =
    taxType == "exclusive"

        ? mrp + gstAmount

        : mrp;

    return Container(

      decoration: BoxDecoration(

        color:
        Colors.green.withOpacity(0.1),

        borderRadius:
        BorderRadius.circular(20.r),
      ),

      padding: EdgeInsets.all(12.w),

      child: Column(

        children: [

          /// GST %
          Row(

            children: gstList.map((g) {

              final selected =
                  _gst == g;

              return Expanded(

                child: GestureDetector(

                  onTap: () {

                    setState(() {

                      _gst = g;
                    });
                  },

                  child: AnimatedContainer(

                    duration:
                    const Duration(
                      milliseconds: 250,
                    ),

                    margin: EdgeInsets.only(

                      right:
                      g == gstList.last

                          ? 0

                          : 6.w,
                    ),

                    padding:
                    EdgeInsets.symmetric(
                      vertical: 12.h,
                    ),

                    decoration:
                    BoxDecoration(

                      color: selected

                          ? const Color(
                        0xFF2563EB,
                      )

                          : Colors.white,

                      borderRadius:
                      BorderRadius.circular(
                        10.r,
                      ),

                      border: Border.all(

                        color: selected

                            ? const Color(
                          0xFF2563EB,
                        )

                            : AppColors
                            .inputBorder,
                      ),
                    ),

                    child: Center(

                      child: Text(

                        g,

                        style: TextStyle(

                          fontSize: 12.sp,

                          fontWeight:
                          FontWeight.w700,

                          color: selected

                              ? Colors.white

                              : AppColors
                              .textDark,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 10.h),

          /// TAX EXCLUSIVE
          GestureDetector(

            onTap: () {

              setState(() {

                taxType = "exclusive";
              });
            },

            child: Container(

              width: double.infinity,

              padding:
              EdgeInsets.symmetric(

                horizontal: 12.w,
                vertical: 14.h,
              ),

              decoration:
              BoxDecoration(

                color:
                taxType == "exclusive"

                    ? Colors.green

                    : Colors.white,

                borderRadius:
                BorderRadius.circular(
                  10.r,
                ),

                border: Border.all(

                  color:
                  taxType == "exclusive"

                      ? Colors.green

                      : AppColors.inputBorder,
                ),
              ),

              child: Row(

                children: [

                  Icon(

                    taxType == "exclusive"

                        ? Icons.check_circle

                        : Icons
                        .radio_button_unchecked,

                    color:
                    taxType == "exclusive"

                        ? Colors.white

                        : Colors.grey,

                    size: 16.sp,
                  ),

                  SizedBox(width: 8.w),

                  Expanded(

                    child: Text(

                      "Tax Exclusive (Added on top)",

                      style:
                      GoogleFonts.poppins(

                        fontSize: 12.sp,

                        fontWeight:
                        FontWeight.w500,

                        color:
                        taxType == "exclusive"

                            ? Colors.white

                            : AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 8.h),

          /// TAX INCLUSIVE
          GestureDetector(

            onTap: () {

              setState(() {

                taxType = "inclusive";
              });
            },

            child: Container(

              width: double.infinity,

              padding:
              EdgeInsets.symmetric(

                horizontal: 12.w,
                vertical: 14.h,
              ),

              decoration:
              BoxDecoration(

                color:
                taxType == "inclusive"

                    ? Colors.green

                    : Colors.white,

                borderRadius:
                BorderRadius.circular(
                  10.r,
                ),

                border: Border.all(

                  color:
                  taxType == "inclusive"

                      ? Colors.green

                      : AppColors.inputBorder,
                ),
              ),

              child: Row(

                children: [

                  Icon(

                    taxType == "inclusive"

                        ? Icons.check_circle

                        : Icons
                        .radio_button_unchecked,

                    color:
                    taxType == "inclusive"

                        ? Colors.white

                        : Colors.grey,

                    size: 16.sp,
                  ),

                  SizedBox(width: 8.w),

                  Expanded(

                    child: Text(

                      "Tax Inclusive (In price)",

                      style:
                      GoogleFonts.poppins(

                        fontSize: 12.sp,

                        fontWeight:
                        FontWeight.w500,

                        color:
                        taxType == "inclusive"

                            ? Colors.white

                            : AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 12.h),

          /// GST INFO
          Container(

            width: double.infinity,

            padding: EdgeInsets.all(10.w),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius:
              BorderRadius.circular(10.r),
            ),

            child: Text(

              taxType == "exclusive"

                  ? "Price ₹${mrp.toStringAsFixed(0)} + GST ₹${gstAmount.toStringAsFixed(2)} = Final ₹${finalPrice.toStringAsFixed(2)}"

                  : "Price ₹${mrp.toStringAsFixed(0)} Includes GST. Base Price ₹${(mrp - gstAmount).toStringAsFixed(2)}",

              style: GoogleFonts.poppins(

                fontSize: 11.sp,

                fontWeight: FontWeight.w600,

                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _unitDropdown() {

    final units = [

      'KG',
      'Ltr',
      'PCS',
      'GM',
      'ML',
      'Box',
    ];

    return Container(

      padding: EdgeInsets.all(1.w),

      decoration: BoxDecoration(

        color: AppColors.inputFill,

        borderRadius:
        BorderRadius.circular(12.r),

        border: Border.all(

          color:
          AppColors.inputBorder,
        ),
      ),

      child: Row(

        mainAxisSize:
        MainAxisSize.min,

        children: units.map((u) {

          final selected =

              _unit.replaceAll(
                "Per ",
                "",
              ) == u;

          return GestureDetector(

            onTap: () {

              setState(() {

                _unit = "Per $u";
              });
            },

            child: AnimatedContainer(

              duration:
              const Duration(
                milliseconds: 250,
              ),

              margin: EdgeInsets.only(
                right: 4.w,
              ),

              padding:
              EdgeInsets.symmetric(

                horizontal: 5.w,
                vertical: 8.h,
              ),

              decoration:
              BoxDecoration(

                color: selected

                    ? Colors.green

                    : Colors.transparent,

                borderRadius:
                BorderRadius.circular(
                  8.r,
                ),
              ),

              child: Text(

                u,

                style:
                GoogleFonts.poppins(

                  fontSize: 11.sp,

                  fontWeight:
                  FontWeight.w600,

                  color: selected

                      ? Colors.white

                      : AppColors.textDark,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  Widget _editunitDropdown(

      StateSetter modalSetState,
      ) {

    final units = [

      'KG',
      'Ltr',
      'PCS',
      'GM',
      'ML',
      'Box',
    ];

    return Container(

      padding: EdgeInsets.all(1.w),

      decoration: BoxDecoration(

        color: AppColors.inputFill,

        borderRadius:
        BorderRadius.circular(12.r),

        border: Border.all(

          color:
          AppColors.inputBorder,
        ),
      ),

      child: Row(

        mainAxisSize:
        MainAxisSize.min,

        children: units.map((u) {

          final selected =

              _unit.replaceAll(
                "Per ",
                "",
              ) == u;

          return GestureDetector(

            onTap: () {

              modalSetState(() {

                _unit = "Per $u";
              });
            },

            child: AnimatedContainer(

              duration:
              const Duration(
                milliseconds: 250,
              ),

              margin: EdgeInsets.only(
                right: 4.w,
              ),

              padding:
              EdgeInsets.symmetric(

                horizontal: 5.w,
                vertical: 8.h,
              ),

              decoration:
              BoxDecoration(

                color: selected

                    ? Colors.green

                    : Colors.transparent,

                borderRadius:
                BorderRadius.circular(
                  8.r,
                ),
              ),

              child: Text(

                u,

                style:
                GoogleFonts.poppins(

                  fontSize: 11.sp,

                  fontWeight:
                  FontWeight.w600,

                  color: selected

                      ? Colors.white

                      : AppColors.textDark,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ITEM CARD
// ─────────────────────────────────────────────
class _ItemCard extends StatelessWidget {

  final _InventoryItem item;

  final VoidCallback onPrint;

  final VoidCallback onDelete;

  final VoidCallback onEdit;

  final bool isDeleting;

  const _ItemCard({

    required this.item,

    required this.onPrint,

    required this.onDelete,

    required this.onEdit,

    required this.isDeleting,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      margin: EdgeInsets.only(
        bottom: 12.h,
      ),

      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 14.h,
      ),

      decoration: BoxDecoration(

        color: AppColors.cardWhite,

        borderRadius:
        BorderRadius.circular(16.r),

        boxShadow: [

          BoxShadow(

            color: Colors.black
                .withOpacity(0.04),

            blurRadius: 10,

            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          /// TOP ROW
          Row(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              /// ITEM NAME
              Expanded(

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(

                      item.name,

                      maxLines: 2,

                      overflow:
                      TextOverflow.ellipsis,

                      style: AppText
                          .staffName()
                          .copyWith(

                    fontWeight: FontWeight.bold,
                        fontSize: 18

                      ),
                    ),

                    SizedBox(height: 2.h),

                    Row(
                      children: [
                        Container(

                          padding:
                          EdgeInsets.symmetric(

                            horizontal: 10.w,

                            vertical: 5.h,
                          ),

                          decoration: BoxDecoration(

                            color:
                            const Color(0xFFEAF8EF),

                            borderRadius:
                            BorderRadius.circular(8.r),
                          ),

                          child: Row(

                            mainAxisSize:
                            MainAxisSize.min,

                            children: [


                              SizedBox(width: 4.w),



                              Text(

                                '${item.stock} ${item.unit}',

                                style:
                                GoogleFonts.poppins(

                                  fontSize: 11.sp,

                                  fontWeight:
                                  FontWeight.w700,

                                  color:
                                  AppColors.textGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
SizedBox(width: 2,),


                        if (item.gst != null &&
                            item.gst.toString().isNotEmpty &&
                            item.gst.toString() != "0" &&
                            item.gst.toString() != "0%" &&
                            item.gst.toString().toLowerCase() != "null")
                          Container(

                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 5.h,
                            ),

                            decoration: BoxDecoration(

                              color: const Color(0xFFB5B5B5).withOpacity(0.2),

                              borderRadius: BorderRadius.circular(8.r),
                            ),

                            child: Row(

                              mainAxisSize: MainAxisSize.min,

                              children: [

                                SizedBox(width: 2.w),

                                Text(

                                  'GST ${item.gst}%',

                                  style: GoogleFonts.poppins(

                                    fontSize: 11.sp,

                                    fontWeight: FontWeight.w700,

                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // SizedBox(width: 2,),
                        // GestureDetector(
                        //
                        //   onTap: () async {
                        //
                        //     String? phone =
                        //     await AuthStorage.getEmail();
                        //
                        //     if (phone != null) {
                        //
                        //       await Clipboard.setData(
                        //
                        //         ClipboardData(
                        //           text: phone,
                        //         ),
                        //       );
                        //
                        //       NeuSnackbar.success(
                        //         "Phone Copied",
                        //       );
                        //     }
                        //   },
                        //
                        //   child: Container(
                        //
                        //     padding: EdgeInsets.symmetric(
                        //
                        //       horizontal: 10.w,
                        //
                        //       vertical: 5.h,
                        //     ),
                        //
                        //     decoration: BoxDecoration(
                        //
                        //       color:
                        //       const Color(0xFF0826E6)
                        //           .withOpacity(0.2),
                        //
                        //       borderRadius:
                        //       BorderRadius.circular(8.r),
                        //     ),
                        //
                        //     child: Row(
                        //
                        //       mainAxisSize:
                        //       MainAxisSize.min,
                        //
                        //       children: [
                        //
                        //         Icon(
                        //
                        //           Icons.copy_rounded,
                        //
                        //           size: 12.sp,
                        //
                        //           color: Colors.blue,
                        //         ),
                        //
                        //         SizedBox(width: 4.w),
                        //
                        //         FutureBuilder<String?>(
                        //
                        //           future:
                        //           AuthStorage.getEmail(),
                        //
                        //           builder: (context, snapshot) {
                        //
                        //             final phone =
                        //                 snapshot.data ?? "";
                        //
                        //             return Text(
                        //
                        //               phone.length > 5
                        //
                        //                   ? '${phone.substring(0, 5)}...'
                        //
                        //                   : phone,
                        //
                        //               style:
                        //               GoogleFonts.poppins(
                        //
                        //                 fontSize: 11.sp,
                        //
                        //                 fontWeight:
                        //                 FontWeight.w700,
                        //
                        //                 color: Colors.blue,
                        //               ),
                        //             );
                        //           },
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),

                  ],
                ),
              ),

              SizedBox(width: 12.w),

              /// PRICE SIDE
              Column(

                crossAxisAlignment:
                CrossAxisAlignment.end,

                children: [
                  Text(

                    '₹${item.saleRate.toStringAsFixed(0)} / ${item.unit}',

                    style:
                    GoogleFonts.poppins(

                      fontSize: 16.sp,

                      fontWeight:
                      FontWeight.w700,

                      color:
                      AppColors.textGreen,
                    ),
                  ),

                  Text(

                    'MRP ₹${item.mrp.toStringAsFixed(0)}',

                    style:
                    GoogleFonts.poppins(

                      fontSize: 11.sp,

                      fontWeight:
                      FontWeight.w400,

                      color:
                      AppColors.textGrey,

                      decoration:
                      TextDecoration.lineThrough,
                    ),
                  ),

                  SizedBox(height: 4.h),


                ],
              ),
            ],
          ),

          SizedBox(height: 4.h),

          /// BOTTOM ROW
          Row(

            children: [

              /// STOCK CHIP
              _chipWidget(

                icon:
                Icons.inventory_2_outlined,

                label:
                '+Stock:',

                color:
                AppColors.textGreen,

                bgColor:
                const Color(0xFFEAF8EF),
              ),

              SizedBox(width: 2.w),

              /// PRINT BUTTON
              GestureDetector(

                onTap: onPrint,

                child: Container(

                  padding:
                  EdgeInsets.symmetric(

                    horizontal: 12.w,

                    vertical: 6.h,
                  ),

                  decoration: BoxDecoration(

                    color:
                    AppColors.printBlueBg,

                    borderRadius:
                    BorderRadius.circular(8.r),

                    border: Border.all(

                      color:
                      AppColors.printBlue
                          .withOpacity(0.3),
                    ),
                  ),

                  child: Row(

                    children: [

                      Icon(

                        Icons.print_outlined,

                        color:
                        AppColors.printBlue,

                        size: 14.sp,
                      ),

                      SizedBox(width: 4.w),

                      Text(

                        'Bar Code',

                        style:
                        GoogleFonts.poppins(

                          fontSize: 10.sp,

                          fontWeight:
                          FontWeight.w600,

                          color:
                          AppColors.printBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),


              SizedBox(width: 3.w),
              /// EDIT
              GestureDetector(

                onTap: onEdit,

                child: Container(

                  padding: EdgeInsets.symmetric(

                    horizontal: 12.w,
                    vertical: 4.h,
                  ),

                  decoration: BoxDecoration(

                    color:
                    const Color(0xFFE8FFF1),

                    borderRadius:
                    BorderRadius.circular(30.r),

                    border: Border.all(
                      color: Colors.green,
                      width: 1,
                    ),
                  ),

                  child: Row(

                    mainAxisSize:
                    MainAxisSize.min,

                    children: [

                      Icon(

                        Icons.edit_outlined,

                        color: Colors.green,

                        size: 14.sp,
                      ),

                      SizedBox(width: 4.w),

                      Text(

                        "Edit",

                        style:
                        GoogleFonts.poppins(

                          fontSize: 11.sp,

                          fontWeight:
                          FontWeight.w600,

                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 10.w),

              /// DELETE
              GestureDetector(

                onTap: onDelete,

                child: Container(

                  padding:
                  EdgeInsets.all(8.w),

                  decoration: BoxDecoration(

                    color:
                    Colors.red.shade50,

                    borderRadius:
                    BorderRadius.circular(10.r),
                  ),

                  child:
                  isDeleting

                      ? SizedBox(

                    height: 18.h,
                    width: 18.w,

                    child:
                    const CircularProgressIndicator(

                      strokeWidth: 2,

                      color: Colors.red,
                    ),
                  )

                      : Icon(

                    Icons.delete_rounded,

                    color: Colors.red,

                    size: 13.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chipWidget({

    required IconData icon,

    required String label,

    required Color color,

    required Color bgColor,
  }) {

    return Container(

      padding: EdgeInsets.symmetric(

        horizontal: 10.w,

        vertical: 6.h,
      ),

      decoration: BoxDecoration(

        color: bgColor,

        borderRadius:
        BorderRadius.circular(8.r),
      ),

      child: Row(

        children: [

          Icon(

            icon,

            color: color,

            size: 13.sp,
          ),

          SizedBox(width: 4.w),

          Text(

            label,

            style:
            GoogleFonts.poppins(

              fontSize: 11.sp,

              fontWeight:
              FontWeight.w600,

              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class PrintLabelSheet extends StatefulWidget {
  final _InventoryItem item;
  const PrintLabelSheet({super.key, required this.item});

  @override
  State<PrintLabelSheet> createState() => _PrintLabelSheetState();
}

class _PrintLabelSheetState extends State<PrintLabelSheet> {
  int _copies = 1;
  final ScreenshotController screenshotController =  ScreenshotController();
  void _increment() => setState(() => _copies++);
  void _decrement() {
    if (_copies > 1) setState(() => _copies--);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle ──
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.inputBorder,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            SizedBox(height: 20.h),

            // ── Title ──
            Text(
              'Download Supermart Label',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 20.h),

            // ── HOW MANY COPIES ──
            // Text(
            //   'HOW MANY COPIES?',
            //   style: GoogleFonts.poppins(
            //     fontSize: 11.sp,
            //     fontWeight: FontWeight.w700,
            //     color: AppColors.textGrey,
            //     letterSpacing: 0.8,
            //   ),
            // ),
            // SizedBox(height: 14.h),
            //
            // // Counter Row
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     _counterBtn(Icons.remove, _decrement),
            //     SizedBox(width: 28.w),
            //     Text(
            //       '$_copies',
            //       style: GoogleFonts.poppins(
            //         fontSize: 26.sp,
            //         fontWeight: FontWeight.w700,
            //         color: AppColors.textDark,
            //       ),
            //     ),
            //     SizedBox(width: 28.w),
            //     _counterBtn(Icons.add, _increment),
            //   ],
            // ),
            SizedBox(height: 20.h),

            // ── LIVE PREVIEW LABEL ──
            Text(
              'LIVE PREVIEW',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 10.h),

            // Label Preview Box
            Screenshot(
              controller: screenshotController,
              child: Container(
                width: double.infinity,
                padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(

                      Get.find<UserController>()
                          .userData["ShopName"]
                          ?.toString() ??

                          "SMART POS",

                          textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      '${widget.item.name} • 1 ${widget.item.unit}',
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGrey,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Barcode simulation
                    _BarcodeWidget(barcode: widget.item.barcode),
                    SizedBox(height: 4.h),
                    Text(
                      widget.item.barcode,
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        color: AppColors.textGrey,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MRP: ₹${widget.item.mrp.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textGrey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Text(
                          'SALE: ₹${widget.item.saleRate.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),

              child: Row(

                children: [

                  // DOWNLOAD
                  Expanded(
                    child: NeuButton(

                      onTap: () async {

                        HapticFeedback.mediumImpact();

                        final image =
                        await screenshotController.capture();

                        if (image == null) return;

                        await BillService.downloadBill(
                          image: image,
                        );
                      },

                      borderRadius: 14,

                      color: kOrange,

                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),

                      child: const Center(
                        child: Row(

                          mainAxisAlignment:
                          MainAxisAlignment.center,

                          children: [

                            Icon(
                              Icons.print,
                              size: 16,
                              color: Colors.white,
                            ),

                            SizedBox(width: 6),

                            Text(
                              'Print',

                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 10.w),

                  // SHARE
                  Expanded(
                    child: NeuButton(

                      onTap: () async {

                        HapticFeedback.mediumImpact();

                        final image =
                        await screenshotController.capture();

                        if (image == null) return;

                        await BillService.shareBill(
                          image: image,
                        );
                        // await BillService.shareBillWhatsapp(
                        //
                        //   image: image,
                        //
                        //   mobile: widget.custMob,
                        // );
                      },

                      borderRadius: 14,

                      color: kBlue,

                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),

                      child: const Center(
                        child: Row(

                          mainAxisAlignment:
                          MainAxisAlignment.center,

                          children: [

                            Icon(
                              Icons.share_rounded,
                              size: 16,
                              color: Colors.white,
                            ),

                            SizedBox(width: 6),

                            Text(
                              'Share',

                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── BUTTONS ──
            // Row(
            //   children: [
            //     Expanded(
            //       child: OutlinedButton(
            //         onPressed: () => Navigator.pop(context),
            //         style: OutlinedButton.styleFrom(
            //           side: BorderSide(color: AppColors.inputBorder),
            //           shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(12.r)),
            //           padding: EdgeInsets.symmetric(vertical: 14.h),
            //         ),
            //         child: Text(
            //           'Cancel',
            //           style: GoogleFonts.poppins(
            //             fontSize: 14.sp,
            //             fontWeight: FontWeight.w600,
            //             color: AppColors.textDark,
            //           ),
            //         ),
            //       ),
            //     ),
            //     SizedBox(width: 12.w),
            //     Expanded(
            //       flex: 2,
            //       child: ElevatedButton.icon(
            //         onPressed: () {
            //           Navigator.pop(context);
            //           ScaffoldMessenger.of(context).showSnackBar(
            //             SnackBar(
            //               content: Text(
            //                   'Printing $_copies ${_copies == 1 ? 'copy' : 'copies'} of ${widget.item.name}'),
            //               backgroundColor: AppColors.textGreen,
            //             ),
            //           );
            //         },
            //         icon: Icon(Icons.print_rounded,
            //             color: Colors.white, size: 18.sp),
            //         label: Text(
            //           'Print ($_copies)',
            //           style: GoogleFonts.poppins(
            //             fontSize: 14.sp,
            //             fontWeight: FontWeight.w600,
            //             color: Colors.white,
            //           ),
            //         ),
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: AppColors.textGreen,
            //           elevation: 0,
            //           shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(12.r)),
            //           padding: EdgeInsets.symmetric(vertical: 14.h),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppColors.scaffold,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Icon(icon, color: AppColors.textDark, size: 20.sp),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BARCODE WIDGET (Visual simulation)
// ─────────────────────────────────────────────
// 🔥 REPLACE FULL _BarcodeWidget CLASS

class _BarcodeWidget extends StatelessWidget {

  final String barcode;

  const _BarcodeWidget({
    required this.barcode,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(

      width: double.infinity,
      height: 60.h,

      child: BarcodeWidget(

        // 🔥 REAL BARCODE
        barcode: Barcode.code128(),

        // 🔥 API BARCODE
        data: barcode,

        // 🔥 HIDE TEXT
        drawText: false,

        // 🔥 BAR COLOR
        color: Colors.black,

        // 🔥 BG
        backgroundColor: Colors.white,

        // 🔥 ERROR
        errorBuilder:
            (context, error) {

          return Center(
            child: Text(

              "Invalid Barcode",

              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────
class _InventoryItem {
  final String name;
  final double mrp;
  final double saleRate;
  final String unit;
  final int stock;
  final String barcode;
  final String id;
  final String gst;

  _InventoryItem({
    required this.name,
    required this.mrp,
    required this.saleRate,
    required this.unit,
    required this.stock,
    required this.barcode,
    required this.id,
    required this.gst,
  });
}