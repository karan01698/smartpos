// 🔥 dashboard_report_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';

import '../authstoreage/authstorage.dart';
import '../backend/showdashboardapi.dart';
import '../poscalculator/poscalculator.dart';
import '../widget/billshare.dart';

class DashboardReportScreen extends StatefulWidget {

  final String type;

  const DashboardReportScreen({
    super.key,
    required this.type,
  });

  @override
  State<DashboardReportScreen> createState() =>
      _DashboardReportScreenState();
}

class _DashboardReportScreenState
    extends State<DashboardReportScreen> {

  final DashboardReportController controller =
  Get.put(DashboardReportController());

  final ScreenshotController screenshotController =
  ScreenshotController();
  bool isPrinting = false;

  @override
  void initState() {

    super.initState();

    loadData();
  }

  void loadData() async {

    String? phone =
    await AuthStorage.getEmail();

    if (phone != null) {

      controller.fetchDashboardReport(

        phone: phone,
        type: widget.type,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(

        backgroundColor: Colors.white,

        elevation: 0,

        title: Text(

          widget.type,

          style: const TextStyle(

            color: Colors.black,

            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: Obx(() {

        if (controller.isLoading.value) {

          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.reportList.isEmpty) {

          return const Center(
            child: Text("No Data Found"),
          );
        }

        return ListView.separated(


          padding: EdgeInsets.only(

            left: 20.w,
            right: 20.w,
            top: 20.h,
            bottom: 0,
          ),

          itemCount:
          controller.reportList.length,

          separatorBuilder: (_, __) =>
              SizedBox(height: 12.h),

          itemBuilder: (_, i) {

            final item =
            controller.reportList[i];

            return GestureDetector(

              onTap: () {

                _showBill(item);
              },
              child: Container(


                padding: EdgeInsets.only(

                  left: 10.w,
                  right: 10.w,
                  top: 10.h,
                  bottom: 0,
                ),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(18.r),

                  boxShadow: [

                    BoxShadow(

                      color:
                      Colors.black.withOpacity(0.04),

                      blurRadius: 12,

                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Row(

                      children: [

                        CircleAvatar(

                          radius: 24.r,

                          backgroundColor:
                          Colors.green.shade100,

                          child: Text(

                            item.customer
                                .isNotEmpty

                                ? item.customer[0]
                                .toUpperCase()

                                : "C",

                            style:
                            GoogleFonts.poppins(

                              fontWeight:
                              FontWeight.w700,

                              color: Colors.green,
                            ),
                          ),
                        ),

                        SizedBox(width: 12.w),

                        Expanded(

                          child: Column(

                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              Text(

                                item.customer
                                    .isEmpty

                                    ? "No Customer"

                                    : item.customer,

                                style:
                                GoogleFonts.poppins(

                                  fontSize: 15.sp,

                                  fontWeight:
                                  FontWeight.w700,
                                ),
                              ),
                              Text(

                                item.mode.isEmpty
                                    ? "No Mode"
                                    : item.mode,

                                style: GoogleFonts.poppins(

                                  fontSize: 15.sp,

                                  // 🔥 CONDITION
                                  color: item.mode.toUpperCase() == "UDHAAR"
                                      ? Colors.red
                                      : Colors.green,

                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2.h),

                              Text(

                                item.mobile,

                                style:
                                GoogleFonts.poppins(

                                  fontSize: 12.sp,

                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 🔥 WHATSAPP
                        // 🔥 WHATSAPP BUTTON
                        GestureDetector(

                          onTap: () async {

                            // 🔥 MOBILE FORMAT
                            String phone =
                            item.mobile
                                .replaceAll("+", "")
                                .replaceAll(" ", "")
                                .replaceAll("-", "")
                                .trim();

                            if (!phone.startsWith("91")) {

                              phone = "91$phone";
                            }

                            // 🔥 TOTAL CALCULATE
                            double total = 0;

                            for (var e in item.parsedItems) {

                              total += double.tryParse(
                                e["Amount"].toString(),
                              ) ??
                                  0;
                            }

                            // 🔥 ITEMS TEXT
                            String itemsText = "";

                            try {

                              if (item.parsedItems is List) {

                                itemsText = item.parsedItems.map((e) {

                                  return
                                    "• ${e["Item"]} "
                                        "(${e["Qty"]} x ₹${e["Rate"]}) "
                                        "= ₹${e["Amount"]}";

                                }).join("\n");
                              }

                            } catch (e) {

                              itemsText = "";
                            }

                            // 🔥 WHATSAPP MESSAGE
                            final String message = '''
              
              नमस्कार ${item.customer} जी! 😊
              उम्मीद है आप कुशल होंगे।
              🧾 आपके खाते का विवरण नीचे दिया गया है:
              🏪 Shop: ${item.shopName}
              📅 Date: ${item.dates.split(" ")[0]}
              ⏰ Time: ${item.times}
              👤 Customer: ${item.customer}
              📱 Mobile: ${item.mobile}
              ━━━━━━━━━━━━━━━
              🛒 Items:
              $itemsText
              ━━━━━━━━━━━━━━━
              💰 Total Amount:₹ ${total.toStringAsFixed(2)}
              🧾 Payment Mode:${item.mode}
              ━━━━━━━━━━━━━━━
              जब भी आपको समय मिले,कृपया भुगतान कर दीजिएगा 🙏
              धन्यवाद 🤝
              ''';

                            // 🔥 WHATSAPP OPEN
                            final Uri whatsappUri = Uri.parse(

                              "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
                            );

                            await launchUrl(

                              whatsappUri,

                              mode: LaunchMode.externalApplication,
                            );
                          },

                          child: Container(

                            padding: EdgeInsets.all(10.r),

                            decoration: BoxDecoration(

                              color: Colors.green.shade50,

                              borderRadius:
                              BorderRadius.circular(12.r),
                            ),

                            child: Image.asset(

                              "assets/whatsapp.png",

                              height: 22,

                              width: 22,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 14.h),

                    // 🔥 VIEW BILL BUTTON

                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // 🔥 SHOW BILL
  void _showBill(dynamic item) {

    double total = 0;

    for (var e in item.parsedItems) {

      total += double.tryParse(
        e["Amount"].toString(),
      ) ??
          0;
    }

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (_) {

        return Screenshot(

          controller: screenshotController,

          child: Container(

            height:
            MediaQuery.of(context)
                .size
                .height *
                0.92,

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius:
              BorderRadius.vertical(

                top: Radius.circular(30.r),
              ),
            ),

            child: Column(

              children: [

                SizedBox(height: 14.h),

                Container(

                  width: 70.w,

                  height: 5.h,

                  decoration: BoxDecoration(

                    color:
                    Colors.grey.shade300,

                    borderRadius:
                    BorderRadius.circular(20.r),
                  ),
                ),

                SizedBox(height: 18.h),

                Text(

                  "Bill",

                  style:
                  GoogleFonts.poppins(

                    fontSize: 22.sp,

                    fontWeight:
                    FontWeight.w700,

                    color: Colors.green,
                  ),
                ),

                SizedBox(height: 12.h),

                // 🔥 MODE ICON
                Container(

                  padding:
                  EdgeInsets.all(14.r),

                  decoration: BoxDecoration(

                    color: item.mode == "UPI"

                        ? Colors.blue.shade50

                        : item.mode == "CASH"

                        ? Colors.green.shade50

                        : Colors.red.shade50,

                    shape: BoxShape.circle,
                  ),

                  child: Icon(

                    item.mode == "UPI"

                        ? Icons.account_balance_wallet

                        : item.mode == "CASH"

                        ? Icons.currency_rupee

                        : Icons.pending_actions,

                    size: 30.sp,

                    color: item.mode == "UPI"

                        ? Colors.blue

                        : item.mode == "CASH"

                        ? Colors.green

                        : Colors.red,
                  ),
                ),

                SizedBox(height: 10.h),

                Text(

                  item.mode,

                  style:
                  GoogleFonts.poppins(

                    fontWeight:
                    FontWeight.w700,

                    color: item.mode == "UPI"

                        ? Colors.blue

                        : item.mode == "CASH"

                        ? Colors.green

                        : Colors.red,
                  ),
                ),

                SizedBox(height: 12.h),

                Text(

                  "₹ ${total.toStringAsFixed(2)}",

                  style:
                  GoogleFonts.poppins(

                    fontSize: 30.sp,

                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                SizedBox(height: 4.h),

                Text(

                  "${item.dates.split(" ")[0]} | ${item.times}",

                  style:
                  GoogleFonts.poppins(

                    color: Colors.grey,
                  ),
                ),

                SizedBox(height: 20.h),

                // 🔥 CUSTOMER BOX
                Container(

                  margin:
                  EdgeInsets.symmetric(
                    horizontal: 18.w,
                  ),

                  padding:
                  EdgeInsets.all(14.w),

                  decoration: BoxDecoration(

                    border: Border.all(
                      color:
                      Colors.grey.shade300,
                    ),

                    borderRadius:
                    BorderRadius.circular(16.r),
                  ),

                  child: Row(

                    children: [

                      CircleAvatar(

                        radius: 24.r,

                        backgroundColor:
                        Colors.blue.shade50,

                        child: Text(

                          item.customer
                              .toString()
                              .isNotEmpty

                              ? item.customer[0]
                              .toUpperCase()

                              : "C",

                          style:
                          GoogleFonts.poppins(

                            fontWeight:
                            FontWeight.w700,

                            color: Colors.blue,
                          ),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      Expanded(

                        child: Column(

                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Text(

                              item.customer,

                              style:
                              GoogleFonts.poppins(

                                fontWeight:
                                FontWeight.w700,

                                fontSize: 15.sp,
                              ),
                            ),

                            SizedBox(height: 3.h),

                            Text(

                              item.mobile,

                              style:
                              GoogleFonts.poppins(

                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                Padding(

                  padding:
                  EdgeInsets.symmetric(
                    horizontal: 18.w,
                  ),

                  child: Row(

                    children: [

                      Expanded(

                        child: Text(

                          "Bill Details",

                          style:
                          GoogleFonts.poppins(

                            fontWeight:
                            FontWeight.w700,

                            fontSize: 16.sp,
                          ),
                        ),
                      ),

                      Text(

                        "₹${total.toStringAsFixed(2)}",

                        style:
                        GoogleFonts.poppins(

                          fontWeight:
                          FontWeight.w700,

                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                Expanded(

                  child: ListView.builder(

                    padding:
                    EdgeInsets.symmetric(
                      horizontal: 18.w,
                    ),

                    itemCount:
                    item.parsedItems.length,

                    itemBuilder: (_, index) {

                      final e =
                      item.parsedItems[index];

                      return Container(

                        margin:
                        EdgeInsets.only(
                          bottom: 12.h,
                        ),

                        padding:
                        EdgeInsets.all(14.w),

                        decoration:
                        BoxDecoration(

                          color:
                          const Color(
                              0xFFF8F8F8),

                          borderRadius:
                          BorderRadius.circular(
                            16.r,
                          ),
                        ),

                        child: Column(

                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            Row(

                              children: [

                                Expanded(

                                  child: Text(

                                    e["Item"],

                                    style:
                                    GoogleFonts
                                        .poppins(

                                      fontWeight:
                                      FontWeight
                                          .w700,
                                    ),
                                  ),
                                ),

                                Text(

                                  "₹${e["Amount"]}",

                                  style:
                                  GoogleFonts
                                      .poppins(

                                    fontWeight:
                                    FontWeight
                                        .w700,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 5.h),

                            Text(

                              "${e["Qty"]} × ₹${e["Rate"]}",

                              style:
                              GoogleFonts
                                  .poppins(

                                color:
                                Colors.grey,

                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 🔥 BOTTOM BUTTONS
                Padding(

                  padding:
                  EdgeInsets.all(18.w),

                  child: Row(

                    children: [

                      Expanded(

                        child: NeuButton(

                          onTap: () async {

                            // 🔥 LOADER START
                            if (isPrinting) return;

                            setState(() {
                              isPrinting = true;
                            });

                            try {

                              HapticFeedback.mediumImpact();

                              final image =
                              await screenshotController.capture(

                                delay: const Duration(
                                  milliseconds: 300,
                                ),
                              );

                              if (image == null) {

                                setState(() {
                                  isPrinting = false;
                                });

                                return;
                              }

                              await BillService.downloadBill(
                                image: image,
                              );

                            } catch (e) {

                              print(e.toString());

                            }

                            // 🔥 LOADER STOP
                            setState(() {
                              isPrinting = false;
                            });
                          },

                          borderRadius: 14,

                          color: Colors.orange,

                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),

                          child: Center(

                            child: isPrinting

                                ? const SizedBox(

                              height: 18,
                              width: 18,

                              child: CircularProgressIndicator(

                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )

                                : const Row(

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

                                    fontWeight:
                                    FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      Expanded(

                        child: GestureDetector(

                          onTap: () {

                            Navigator.pop(context);
                          },

                          child: Container(

                            height: 52.h,

                            decoration:
                            BoxDecoration(

                              color: Colors.green,

                              borderRadius:
                              BorderRadius.circular(
                                14.r,
                              ),
                            ),

                            child: Center(

                              child: Text(

                                "Done",

                                style:
                                GoogleFonts
                                    .poppins(

                                  color: Colors.white,

                                  fontWeight:
                                  FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}