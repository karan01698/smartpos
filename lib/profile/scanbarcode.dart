import 'package:barcode_widget/barcode_widget.dart'as bw;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../backend/barcodescanner.dart';


class BarcodeScannerScreen
    extends StatefulWidget {

  const BarcodeScannerScreen({
    super.key,
  });

  @override
  State<BarcodeScannerScreen>
  createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState
    extends State<BarcodeScannerScreen> {

  final MobileScannerController
  controller =
  MobileScannerController(

    detectionSpeed:
    DetectionSpeed.normal,

    facing:
    CameraFacing.back,
  );

  final ShowBarcodeInventoryController
  barcodeController =
  Get.put(
    ShowBarcodeInventoryController(),
  );

  final TextEditingController
  searchCtrl =
  TextEditingController();

  bool hasPermission = false;

  bool isScanned = false;

  @override
  void initState() {

    super.initState();

    askPermission();
  }
  @override
  void dispose() {

    // 🔥 CLEAR DATA
    barcodeController
        .barcodeItem
        .value = null;

    searchCtrl.clear();

    controller.dispose();

    super.dispose();
  }
  Future<void> askPermission() async {

    var status =
    await Permission.camera.request();

    if(status.isGranted){

      setState(() {

        hasPermission = true;
      });
    }
  }

  Future<void> fetchBarcode(
      String code,
      ) async {

    await barcodeController
        .getBarcodeItem(

      barcode: code,
    );
  }

  Widget buildInfoCard({

    required String title,

    required String value,

    required Color color,

  }) {

    return Container(

      padding:
      EdgeInsets.symmetric(

        horizontal: 12.w,

        vertical: 14.h,
      ),

      decoration: BoxDecoration(

        color:
        color.withOpacity(0.08),

        borderRadius:
        BorderRadius.circular(14.r),
      ),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(

            title,

            style: TextStyle(

              fontSize: 11.sp,

              fontWeight:
              FontWeight.w700,

              color: color,
            ),
          ),

          SizedBox(height: 6.h),

          Text(

            value,

            style: TextStyle(

              fontSize: 16.sp,

              fontWeight:
              FontWeight.bold,

              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> pickBarcodeImage() async {

    final picker =
    ImagePicker();

    final XFile? image =
    await picker.pickImage(

      source:
      ImageSource.gallery,
    );

    if(image != null){

      Get.snackbar(

        "Gallery",

        "Barcode image selected",
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      Colors.black,

      appBar: AppBar(

        backgroundColor:
        Colors.black,



        title: const Text(
          "Barcode Scanner",
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        actions: [

          IconButton(

            onPressed: () {

              pickBarcodeImage();
            },

            icon: const Icon(

              Icons.photo,

              color: Colors.white,
            ),
          ),
        ],
      ),

      body:
      hasPermission == false

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : Stack(

        children: [

          // 🔥 CAMERA
          MobileScanner(

            controller:
            controller,

            onDetect: (capture) async {

              if(isScanned) return;

              final barcode =
                  capture
                      .barcodes
                      .first;

              final code =
                  barcode.rawValue;

              if(code != null){

                isScanned = true;

                searchCtrl.text =
                    code;

                await fetchBarcode(
                  code,
                );

                Future.delayed(

                  const Duration(
                    seconds: 2,
                  ),

                      () {

                    isScanned = false;
                  },
                );
              }
            },
          ),

          // 🔥 TOP SEARCH
          Positioned(

            top: 20,

            left: 16,

            right: 16,

            child: Row(

              children: [

                Expanded(

                  child: Container(

                    decoration: BoxDecoration(

                      color: Colors.white,

                      borderRadius:
                      BorderRadius.circular(14),
                    ),

                    child: TextField(

                      controller:
                      searchCtrl,

                      style: const TextStyle(
                        color: Colors.black,
                      ),

                      decoration: InputDecoration(

                        hintText:
                        "Enter Barcode",

                        border:
                        InputBorder.none,

                        contentPadding:
                        EdgeInsets.symmetric(

                          horizontal: 14.w,

                          vertical: 14.h,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 10.w),

                GestureDetector(

                  onTap: () async {

                    if(searchCtrl.text
                        .trim()
                        .isEmpty) return;

                    await fetchBarcode(

                      searchCtrl.text
                          .trim(),
                    );
                  },

                  child: Container(

                    padding:
                    EdgeInsets.all(14),

                    decoration: BoxDecoration(

                      color: Colors.green,

                      borderRadius:
                      BorderRadius.circular(14),
                    ),

                    child: const Icon(

                      Icons.search,

                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔥 PRODUCT CARD
          Positioned(

            top: 90,

            left: 16,

            right: 16,

            child: Obx(() {

              final item =

                  barcodeController
                      .barcodeItem
                      .value;

              if(item == null){

                return const SizedBox();
              }

              return Container(

                padding:
                EdgeInsets.all(16.w),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(20.r),

                  boxShadow: [

                    BoxShadow(

                      color:
                      Colors.black
                          .withOpacity(0.08),

                      blurRadius: 12,

                      offset:
                      const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    // 🔥 HEADER
                    Row(

                      children: [

                        Container(

                          padding:
                          EdgeInsets.all(10.w),

                          decoration: BoxDecoration(

                            color:
                            Colors.green
                                .shade50,

                            borderRadius:
                            BorderRadius.circular(14.r),
                          ),

                          child: Icon(

                            Icons.inventory_2_rounded,

                            color: Colors.green,

                            size: 24.sp,
                          ),
                        ),

                        SizedBox(width: 12.w),

                        Expanded(

                          child: Column(

                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              Text(

                                item.itemName,

                                style: TextStyle(

                                  fontSize: 18.sp,

                                  fontWeight:
                                  FontWeight.bold,

                                  color: Colors.black,
                                ),
                              ),

                              SizedBox(height: 2.h),

                              Text(

                                "Inventory Product",

                                style: TextStyle(

                                  fontSize: 12.sp,

                                  color:
                                  Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 18.h),

                    // 🔥 PRICE ROW
                    Row(

                      children: [

                        Expanded(

                          child: buildInfoCard(

                            title: "MRP",

                            value:
                            "₹${item.mrpOld}",

                            color: Colors.red,
                          ),
                        ),

                        SizedBox(width: 10.w),

                        Expanded(

                          child: buildInfoCard(

                            title:
                            "SALE PRICE",

                            value:
                            "₹${item.salePrice}",

                            color:
                            Colors.green,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    // 🔥 STOCK ROW
                    Row(

                      children: [

                        Expanded(

                          child: buildInfoCard(

                            title: "STOCK",

                            value:
                            item.intialStock,

                            color: Colors.blue,
                          ),
                        ),

                        SizedBox(width: 10.w),

                        Expanded(

                          child: buildInfoCard(

                            title: "TYPE",

                            value:
                            item.type,

                            color:
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 18.h),

                    // 🔥 BARCODE
                    Container(

                      width: double.infinity,

                      padding:
                      EdgeInsets.symmetric(

                        horizontal: 14.w,

                        vertical: 14.h,
                      ),

                      decoration: BoxDecoration(

                        color:
                        Colors.grey.shade100,

                        borderRadius:
                        BorderRadius.circular(14.r),
                      ),

                      child: Column(

                        children: [

                          Text(

                            "BARCODE",

                            style: TextStyle(

                              fontSize: 11.sp,

                              fontWeight:
                              FontWeight.w700,

                              letterSpacing: 1,

                              color:
                              Colors.grey,
                            ),
                          ),

                          SizedBox(height: 10.h),

                          SizedBox(

                            height: 70.h,

                            width:
                            double.infinity,

                            child:bw.BarcodeWidget(

                              barcode:
                              bw.Barcode.code128(),

                              data:
                              item.barcode,

                              drawText: false,

                              color:
                              Colors.black,

                              backgroundColor:
                              Colors.white,
                            ),
                          ),

                          SizedBox(height: 8.h),

                          Text(

                            item.barcode,

                            style: TextStyle(

                              fontSize: 14.sp,

                              fontWeight:
                              FontWeight.bold,

                              letterSpacing: 1.2,

                              color:
                              Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          // 🔥 SCAN BOX
          Obx(() {

            final item =

                barcodeController
                    .barcodeItem
                    .value;

            // 🔥 DATA AA GAYA
            if(item != null){

              return const SizedBox();
            }

            return Center(

              child: Container(

                width: 280,

                height: 140,

                decoration: BoxDecoration(

                  border: Border.all(

                    color: Colors.green,

                    width: 4,
                  ),

                  borderRadius:
                  BorderRadius.circular(20),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}



class PoBarcodeScannerScreen
    extends StatefulWidget {

  const PoBarcodeScannerScreen({
    super.key,
  });

  @override
  State<PoBarcodeScannerScreen>
  createState() =>
      _PoBarcodeScannerScreenState();
}

class _PoBarcodeScannerScreenState
    extends State<PoBarcodeScannerScreen> {

  final MobileScannerController
  controller =
  MobileScannerController(

    detectionSpeed:
    DetectionSpeed.normal,

    facing:
    CameraFacing.back,
  );

  final ShowBarcodeInventoryController
  barcodeController =
  Get.put(
    ShowBarcodeInventoryController(),
  );

  final TextEditingController
  searchCtrl =
  TextEditingController();

  bool hasPermission = false;

  bool isScanned = false;

  @override
  void initState() {

    super.initState();

    askPermission();
  }
  @override
  void dispose() {

    // 🔥 CLEAR DATA
    barcodeController
        .barcodeItem
        .value = null;

    searchCtrl.clear();

    controller.dispose();

    super.dispose();
  }
  Future<void> askPermission() async {

    var status =
    await Permission.camera.request();

    if(status.isGranted){

      setState(() {

        hasPermission = true;
      });
    }
  }

  Future<void> fetchBarcode(
      String code,
      ) async {

    await barcodeController
        .getBarcodeItem(

      barcode: code,
    );
  }

  Widget buildInfoCard({

    required String title,

    required String value,

    required Color color,

  }) {

    return Container(

      padding:
      EdgeInsets.symmetric(

        horizontal: 12.w,

        vertical: 14.h,
      ),

      decoration: BoxDecoration(

        color:
        color.withOpacity(0.08),

        borderRadius:
        BorderRadius.circular(14.r),
      ),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(

            title,

            style: TextStyle(

              fontSize: 11.sp,

              fontWeight:
              FontWeight.w700,

              color: color,
            ),
          ),

          SizedBox(height: 6.h),

          Text(

            value,

            style: TextStyle(

              fontSize: 16.sp,

              fontWeight:
              FontWeight.bold,

              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> pickBarcodeImage() async {

    final picker =
    ImagePicker();

    final XFile? image =
    await picker.pickImage(

      source:
      ImageSource.gallery,
    );

    if(image != null){

      Get.snackbar(

        "Gallery",

        "Barcode image selected",
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      Colors.black,

      appBar: AppBar(

        backgroundColor:
        Colors.black,



        title: const Text(
          "Barcode Scanner",
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        // actions: [
        //
        //   IconButton(
        //
        //     onPressed: () {
        //
        //       pickBarcodeImage();
        //     },
        //
        //     icon: const Icon(
        //
        //       Icons.photo,
        //
        //       color: Colors.white,
        //     ),
        //   ),
        // ],
      ),

      body:
      hasPermission == false

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : Stack(

        children: [

          // 🔥 CAMERA
          // 🔥 CAMERA
          MobileScanner(

            controller: controller,

            onDetect: (capture) async {

              // 🔥 DOUBLE SCAN STOP
              if (isScanned) return;

              final barcode =
                  capture.barcodes.first;

              final code =
                  barcode.rawValue;

              // 🔥 VALID BARCODE
              if (code != null &&
                  code.isNotEmpty) {

                isScanned = true;

                // 🔥 TEXT FIELD FILL
                searchCtrl.text = code;

                // 🔥 API HIT
                await fetchBarcode(code);

                // 🔥 ITEM FOUND
                if (barcodeController
                    .barcodeItem.value !=
                    null) {

                  // 🔥 CAMERA STOP
                  await controller.stop();

                  // 🔥 SCREEN CLOSE
                  Get.back(

                    result:
                    barcodeController
                        .barcodeItem.value,
                  );

                } else {

                  // 🔥 NOT FOUND
                  Get.snackbar(

                    "Not Found",

                    "No Item Found",
                  );

                  // 🔥 RESCAN ALLOW
                  Future.delayed(

                    const Duration(
                      seconds: 2,
                    ),

                        () {

                      isScanned = false;
                    },
                  );
                }
              }
            },
          ),

          // 🔥 TOP SEARCH
          // Positioned(
          //
          //   top: 20,
          //
          //   left: 16,
          //
          //   right: 16,
          //
          //   child: Row(
          //
          //     children: [
          //
          //       Expanded(
          //
          //         child: Container(
          //
          //           decoration: BoxDecoration(
          //
          //             color: Colors.white,
          //
          //             borderRadius:
          //             BorderRadius.circular(14),
          //           ),
          //
          //           child: TextField(
          //
          //             controller:
          //             searchCtrl,
          //
          //             style: const TextStyle(
          //               color: Colors.black,
          //             ),
          //
          //             decoration: InputDecoration(
          //
          //               hintText:
          //               "Enter Barcode",
          //
          //               border:
          //               InputBorder.none,
          //
          //               contentPadding:
          //               EdgeInsets.symmetric(
          //
          //                 horizontal: 14.w,
          //
          //                 vertical: 14.h,
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //
          //       SizedBox(width: 10.w),
          //
          //       GestureDetector(
          //
          //         onTap: () async {
          //
          //           if(searchCtrl.text
          //               .trim()
          //               .isEmpty) return;
          //
          //           await fetchBarcode(
          //
          //             searchCtrl.text
          //                 .trim(),
          //           );
          //         },
          //
          //         child: Container(
          //
          //           padding:
          //           EdgeInsets.all(14),
          //
          //           decoration: BoxDecoration(
          //
          //             color: Colors.green,
          //
          //             borderRadius:
          //             BorderRadius.circular(14),
          //           ),
          //
          //           child: const Icon(
          //
          //             Icons.search,
          //
          //             color: Colors.white,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // 🔥 PRODUCT CARD
          Positioned(

            top: 90,

            left: 16,

            right: 16,

            child: Obx(() {

              final item =

                  barcodeController
                      .barcodeItem
                      .value;

              if(item == null){

                return const SizedBox();
              }

              return Container(

                padding:
                EdgeInsets.all(16.w),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(20.r),

                  boxShadow: [

                    BoxShadow(

                      color:
                      Colors.black
                          .withOpacity(0.08),

                      blurRadius: 12,

                      offset:
                      const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    // 🔥 HEADER
                    Row(

                      children: [

                        Container(

                          padding:
                          EdgeInsets.all(10.w),

                          decoration: BoxDecoration(

                            color:
                            Colors.green
                                .shade50,

                            borderRadius:
                            BorderRadius.circular(14.r),
                          ),

                          child: Icon(

                            Icons.inventory_2_rounded,

                            color: Colors.green,

                            size: 24.sp,
                          ),
                        ),

                        SizedBox(width: 12.w),

                        Expanded(

                          child: Column(

                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              Text(

                                item.itemName,

                                style: TextStyle(

                                  fontSize: 18.sp,

                                  fontWeight:
                                  FontWeight.bold,

                                  color: Colors.black,
                                ),
                              ),

                              SizedBox(height: 2.h),

                              Text(

                                "Inventory Product",

                                style: TextStyle(

                                  fontSize: 12.sp,

                                  color:
                                  Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 18.h),

                    // 🔥 PRICE ROW
                    Row(

                      children: [

                        Expanded(

                          child: buildInfoCard(

                            title: "MRP",

                            value:
                            "₹${item.mrpOld}",

                            color: Colors.red,
                          ),
                        ),

                        SizedBox(width: 10.w),

                        Expanded(

                          child: buildInfoCard(

                            title:
                            "SALE PRICE",

                            value:
                            "₹${item.salePrice}",

                            color:
                            Colors.green,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    // 🔥 STOCK ROW
                    Row(

                      children: [

                        Expanded(

                          child: buildInfoCard(

                            title: "STOCK",

                            value:
                            item.intialStock,

                            color: Colors.blue,
                          ),
                        ),

                        SizedBox(width: 10.w),

                        Expanded(

                          child: buildInfoCard(

                            title: "TYPE",

                            value:
                            item.type,

                            color:
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 18.h),

                    // 🔥 BARCODE
                    Container(

                      width: double.infinity,

                      padding:
                      EdgeInsets.symmetric(

                        horizontal: 14.w,

                        vertical: 14.h,
                      ),

                      decoration: BoxDecoration(

                        color:
                        Colors.grey.shade100,

                        borderRadius:
                        BorderRadius.circular(14.r),
                      ),

                      child: Column(

                        children: [

                          Text(

                            "BARCODE",

                            style: TextStyle(

                              fontSize: 11.sp,

                              fontWeight:
                              FontWeight.w700,

                              letterSpacing: 1,

                              color:
                              Colors.grey,
                            ),
                          ),

                          SizedBox(height: 10.h),

                          SizedBox(

                            height: 70.h,

                            width:
                            double.infinity,

                            child:bw.BarcodeWidget(

                              barcode:
                              bw.Barcode.code128(),

                              data:
                              item.barcode,

                              drawText: false,

                              color:
                              Colors.black,

                              backgroundColor:
                              Colors.white,
                            ),
                          ),

                          SizedBox(height: 8.h),

                          Text(

                            item.barcode,

                            style: TextStyle(

                              fontSize: 14.sp,

                              fontWeight:
                              FontWeight.bold,

                              letterSpacing: 1.2,

                              color:
                              Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          // 🔥 SCAN BOX
          Obx(() {

            final item =

                barcodeController
                    .barcodeItem
                    .value;

            // 🔥 DATA AA GAYA
            if(item != null){

              return const SizedBox();
            }

            return Center(

              child: Container(

                width: 280,

                height: 140,

                decoration: BoxDecoration(

                  border: Border.all(

                    color: Colors.green,

                    width: 4,
                  ),

                  borderRadius:
                  BorderRadius.circular(20),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}










