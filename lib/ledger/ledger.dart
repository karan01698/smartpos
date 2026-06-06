import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';

import '../authstoreage/authstorage.dart';
import '../backend/deletesales.dart';
import '../backend/showapi.dart';
import '../backend/showsales.dart';
import '../backend/updateshowsalesapi.dart';
import '../poscalculator/constant/colors.dart';
import '../poscalculator/poscalculator.dart';

import '../widget/billshare.dart';
import '../widget/deletealert.dart';
import '../widget/snakbar.dart';
// <-- apna path yahan lagao

// ─────────────────────────────────────────────
// MODELS (Bill ke liye local only)
// ─────────────────────────────────────────────
class _BillItem {
  final String name;
  final int qty;
  final double rate;
  final double amount;
  final double discount;

  _BillItem({
    required this.name,
    required this.qty,
    required this.rate,
    required this.amount,
    required this.discount,
  });

  // API ke parsed item map se banana
  factory _BillItem.fromMap(Map<String, dynamic> map) {
    final qty = double.tryParse(
          map['Qty'].toString(),
        ) ??
        0;
    final discount = double.tryParse(
          map['Discount'].toString(),
        ) ??
        0;

    final rate = double.tryParse(
          map['Rate'].toString(),
        ) ??
        0;

    final amount = double.tryParse(
          map['Amount'].toString(),
        ) ??
        0;

    return _BillItem(
      name: map['Name'] ?? map['Item'] ?? map['ProductName'] ?? 'Item',
      qty: qty.toInt(),
      rate: rate,
      amount: amount,
      discount: discount,
    );
  }
}

// ─────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
// LEDGER SCREEN
// ─────────────────────────────────────────────
class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  // Controller inject
  final LedgerController _ctrl = Get.put(LedgerController());

  final _searchCtrl = TextEditingController();

  // final _filters = ['All', 'Cash', 'UPI', 'Credit'];

  @override
  void initState() {
    super.initState();
    // Phone number apna daal do ya dynamic pass karo
    loadUser();
  }

  void loadUser() async {
    String? phone = await AuthStorage.getEmail();

    if (phone != null) {
      _ctrl.fetchLedger(phone: phone);
    }
  }

  void _openBill(LedgerModel entry) {
    // API items parse karo
    final List<_BillItem> billItems = (entry.parsedItems)
        .whereType<Map<String, dynamic>>()
        .map((m) => _BillItem.fromMap(m))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BillSheet(
        entry: entry,
        billItems: billItems,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 14.h),

              // ── HEADER ──
              Row(
                children: [
                  Icon(Icons.menu_book_rounded,
                      color: AppColors.textGreen, size: 24.sp),
                  SizedBox(width: 8.w),
                  Text('Ledger',
                      style: GoogleFonts.poppins(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const Spacer(),
                  // Container(
                  //   padding: EdgeInsets.symmetric(
                  //       horizontal: 14.w, vertical: 8.h),
                  //   decoration: BoxDecoration(
                  //     color: AppColors.aiChipBg,
                  //     borderRadius: BorderRadius.circular(20.r),
                  //     border: Border.all(color: AppColors.aiChipBorder),
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.auto_awesome_rounded,
                  //           color: AppColors.aiChipText, size: 14.sp),
                  //       SizedBox(width: 5.w),
                  //       Text('AI Report',
                  //           style: GoogleFonts.poppins(
                  //               fontSize: 13.sp,
                  //               fontWeight: FontWeight.w600,
                  //               color: AppColors.aiChipText)),
                  //     ],
                  //   ),
                  // ),
                ],
              ),

              SizedBox(height: 14.h),

              // ── SEARCH + FILTER ROW ──
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46.h,
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => _ctrl.searchLedger(v),
                        style: GoogleFonts.poppins(
                            fontSize: 13.sp, color: AppColors.textDark),
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: GoogleFonts.poppins(
                              fontSize: 13.sp, color: AppColors.textGrey),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: AppColors.textGrey, size: 18.sp),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 13.h),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  // Container(
                  //   height: 46.h,
                  //   padding: EdgeInsets.symmetric(horizontal: 12.w),
                  //   decoration: BoxDecoration(
                  //     color: AppColors.cardWhite,
                  //     borderRadius: BorderRadius.circular(12.r),
                  //     border: Border.all(color: AppColors.inputBorder),
                  //   ),
                  //   child: DropdownButtonHideUnderline(
                  //     child: DropdownButton<String>(
                  //       value: _ctrl.selectedFilter.value,
                  //       style: GoogleFonts.poppins(
                  //           fontSize: 13.sp,
                  //           fontWeight: FontWeight.w500,
                  //           color: AppColors.textDark),
                  //       icon: Icon(Icons.unfold_more_rounded,
                  //           size: 16.sp, color: AppColors.textGrey),
                  //       items: _filters
                  //           .map((f) => DropdownMenuItem(
                  //           value: f, child: Text(f)))
                  //           .toList(),
                  //       onChanged: (v) => _ctrl.applyFilter(v!),
                  //     ),
                  //   ),
                  // ),
                ],
              ),

              SizedBox(height: 14.h),

              // ── LIST ──
              Expanded(
                child: Obx(() {
                  if (_ctrl.isLoading.value && _ctrl.ledgerList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final list = _ctrl.filteredList.toList();

                  if (list.isEmpty) {
                    return Center(
                      child: Text('No entries found',
                          style: GoogleFonts.poppins(
                              fontSize: 14.sp, color: AppColors.textGrey)),
                    );
                  }

                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (_, i) => _LedgerCard(
                      entry: list[i],
                      onBillTap: () => _openBill(list[i]),
                    ),
                  );
                }),
              ),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LEDGER CARD — Ab LedgerModel use karta hai
// ─────────────────────────────────────────────
class _LedgerCard extends StatelessWidget {
  final LedgerModel entry;
  final VoidCallback onBillTap;

  _LedgerCard({required this.entry, required this.onBillTap});

  final DeleteSalesController deleteController = Get.put(
    DeleteSalesController(),
  );

  final LedgerController _ctrl = Get.put(
    LedgerController(),
  );

  // Mode ke hisaab se color
  Color _modeColor(String mode) {
    switch (mode.toUpperCase()) {
      case 'UPI':
        return const Color(0xFF6C63FF);
      case 'CASH':
        return const Color(0xFF2DB560);
      case 'CREDIT':
        return const Color(0xFFE65100);
      default:
        return const Color(0xFF607D8B);
    }
  }

  IconData _modeIcon(String mode) {
    switch (mode.toUpperCase()) {
      case 'UPI':
        return Icons.smartphone_rounded;
      case 'CASH':
        return Icons.payments_rounded;
      case 'CREDIT':
        return Icons.credit_card_rounded;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Date aur Time alag karo
    // entry.dates  = "4/5/2026"
    // entry.times  = "13:48:05"  (API se jo bhi format aaye)
    final datePart =
        entry.dates.contains(' ') ? entry.dates.split(' ')[0] : entry.dates;
    final rawTime = entry.times; // "13:48:05" ya "13:48"
    final timePart = rawTime.length >= 5 ? rawTime.substring(0, 5) : rawTime;

    final modeColor = _modeColor(entry.mode);

    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── LEFT: Info ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Customer Name:" label + value
                    Row(
                      children: [
                        Text(
                          'Customer: ',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: AppColors.textGrey,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            entry.customer,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // Date row
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 12.sp, color: AppColors.textGrey),
                        SizedBox(width: 4.w),

                        Text(
                          datePart,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: AppColors.textGrey,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Time row
                      ],
                    ),

                    SizedBox(height: 6.h),

                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 12.sp, color: AppColors.textGrey),
                        SizedBox(width: 4.w),
                        Text(
                          '$timePart',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Icon(Icons.person_outline_rounded,
                            size: 12.sp, color: AppColors.textGrey),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            'By: ${entry.cashier}',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    // Mode badge — colorful pill
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: modeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20.r),
                            border:
                                Border.all(color: modeColor.withOpacity(0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_modeIcon(entry.mode),
                                  size: 12.sp, color: modeColor),
                              SizedBox(width: 4.w),
                              Text(
                                entry.mode.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: modeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 3.w,
                        ),
                        GestureDetector(
                          onTap: () async {
                            bool? confirm = await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text("Delete Item"),
                                  content: const Text(
                                    "Are you sure you want to delete this item?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                      child: const Text("No"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: const Text(
                                        "Yes",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              bool deleted = await deleteController.deleteSale(
                                id: entry.id.toString(),
                              );

                              if (deleted) {
                                String? phone = await AuthStorage.getEmail();

                                if (phone != null && phone.isNotEmpty) {
                                  await _ctrl.fetchLedger(
                                    phone: phone,
                                  );
                                }
                              }
                            }
                          },
                          child: Obx(() {
                            final isCurrentDeleting =
                                deleteController.deletingId.value ==
                                    entry.id.toString();

                            return AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 250,
                              ),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: isCurrentDeleting
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.red,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.delete_rounded,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                            );
                          }),
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        GestureDetector(
                          onTap: () async {
                            String phone = entry.mobile
                                .replaceAll("+", "")
                                .replaceAll(" ", "")
                                .replaceAll("-", "")
                                .trim();

                            // 🔥 INDIA CODE
                            if (!phone.startsWith("91")) {
                              phone = "91$phone";
                            }

                            /// 🔥 ITEMS TEXT
                            String itemsText = "";

                            try {
                              final decodedItems = jsonDecode(entry.items);

                              if (decodedItems is List) {
                                itemsText = decodedItems.map((e) {
                                  return "• ${e["Item"]} (${e["Qty"]} x ₹${e["Rate"]}) = ₹${e["Amount"]}";
                                }).join("\n");
                              }
                            } catch (e) {
                              itemsText = "";
                            }

                            /// 🔥 WHATSAPP MESSAGE
                            final String message = '''

नमस्कार ${entry.customer} जी! 😊

उम्मीद है आप कुशल होंगे।

आपके ${entry.shopName} के खाते का संक्षिप्त विवरण (Summary) नीचे दिया गया है:
📅 Date: ${datePart}

🛒 Items:
$itemsText

🧮 आपका कुल बकाया (Balance): ₹ ${entry.totalAmount.toStringAsFixed(2)}

जब भी आपको समय मिले, इस सप्ताह में अपनी सुविधानुसार भुगतान कर दीजिएगा।

आप कब तक आ रहे हैं या ऑनलाइन पे कर रहे हैं, एक बार बता देंगे तो हमारे लिए हिसाब मिलाना आसान हो जाएगा।

धन्यवाद! 🤝
''';

                            final Uri whatsappUri = Uri.parse(
                              "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
                            );

                            await launchUrl(
                              whatsappUri,
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              "assets/whatsapp.png",
                              height: 20,
                              width: 20,
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 8.w,
                        ),
                        // 🔥 UPDATE BUTTON
                        // 🔥 UPDATE BUTTON
                        GestureDetector(

                          onTap: () {

                            final customerCtrl = TextEditingController(
                              text: entry.customer,
                            );

                            String selectedMode = entry.mode;

                            showModalBottomSheet(

                              context: context,

                              isScrollControlled: true,

                              useSafeArea: true,

                              enableDrag: true,

                              backgroundColor: Colors.transparent,

                              builder: (_) {

                                return SafeArea(

                                  child: StatefulBuilder(

                                    builder: (context, setState) {

                                      return Padding(

                                        padding: EdgeInsets.only(

                                          bottom:
                                          MediaQuery.of(context)
                                              .viewInsets
                                              .bottom,
                                        ),

                                        child: Container(

                                          padding: EdgeInsets.only(

                                            left: 20.w,
                                            right: 20.w,
                                            top: 20.h,
                                            bottom: 25.h,
                                          ),

                                          decoration: BoxDecoration(

                                            color: Colors.white,

                                            borderRadius:
                                            BorderRadius.vertical(

                                              top: Radius.circular(28.r),
                                            ),
                                          ),

                                          child: SingleChildScrollView(

                                            child: Column(

                                              mainAxisSize: MainAxisSize.min,

                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,

                                              children: [

                                                // 🔥 HANDLE
                                                Center(

                                                  child: Container(

                                                    width: 50.w,

                                                    height: 5.h,

                                                    decoration: BoxDecoration(

                                                      color: Colors.grey.shade300,

                                                      borderRadius:
                                                      BorderRadius.circular(20.r),
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(height: 20.h),

                                                Text(

                                                  "Update Sale",

                                                  style: TextStyle(

                                                    fontSize: 22.sp,

                                                    fontWeight:
                                                    FontWeight.w700,
                                                  ),
                                                ),

                                                SizedBox(height: 20.h),

                                                // 🔥 CUSTOMER NAME
                                                TextField(

                                                  controller: customerCtrl,

                                                  readOnly: true,

                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                  ),

                                                  decoration: InputDecoration(

                                                    hintText: "Customer Name",

                                                    filled: true,

                                                    fillColor:
                                                    const Color(0xFFF5F5F5),

                                                    contentPadding:
                                                    EdgeInsets.symmetric(

                                                      horizontal: 16.w,
                                                      vertical: 16.h,
                                                    ),

                                                    border: OutlineInputBorder(

                                                      borderRadius:
                                                      BorderRadius.circular(16.r),

                                                      borderSide:
                                                      BorderSide.none,
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(height: 16.h),

                                                // 🔥 MODE DROPDOWN
                                                Container(

                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 16.w,
                                                  ),

                                                  decoration: BoxDecoration(

                                                    color:
                                                    const Color(0xFFF5F5F5),

                                                    borderRadius:
                                                    BorderRadius.circular(16.r),
                                                  ),

                                                  child: DropdownButtonHideUnderline(

                                                    child: DropdownButton<String>(

                                                      value: selectedMode,

                                                      isExpanded: true,

                                                      style: TextStyle(

                                                        fontSize: 14.sp,
                                                        color: Colors.black,
                                                      ),

                                                      items: [

                                                        "CASH",
                                                        "UPI",
                                                        "UDHAAR",
                                                        "CARD",

                                                      ].map((e) {

                                                        return DropdownMenuItem(

                                                          value: e,

                                                          child: Text(
                                                            e,
                                                            style: TextStyle(
                                                              fontSize: 14.sp,
                                                            ),
                                                          ),
                                                        );

                                                      }).toList(),

                                                      onChanged: (value) {

                                                        setState(() {

                                                          selectedMode = value!;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(height: 24.h),

                                                // 🔥 UPDATE BUTTON
                                                SizedBox(

                                                  width: double.infinity,

                                                  height: 55.h,

                                                  child: ElevatedButton(

                                                    onPressed: () async {

                                                      final UpdateSalesController
                                                      updateController = Get.put(

                                                        UpdateSalesController(),
                                                      );

                                                      bool updated =
                                                      await updateController
                                                          .updateSale(

                                                        id: entry.id.toString(),

                                                        phone: entry.phone,

                                                        shopName:
                                                        entry.shopName,

                                                        address:
                                                        entry.address,

                                                        dates:
                                                        entry.dates,

                                                        times:
                                                        entry.times,

                                                        cashier:
                                                        entry.cashier,

                                                        mode:
                                                        selectedMode,

                                                        customer:
                                                        entry.customer,

                                                        mobile:
                                                        entry.mobile,

                                                        items: jsonEncode(
                                                          entry.parsedItems,
                                                        ),

                                                        status: '',
                                                      );

                                                      if (updated) {

                                                        Navigator.pop(context);

                                                        NeuSnackbar.success(
                                                          "Updated Successfully",
                                                        );

                                                        String? phone =
                                                        await AuthStorage.getEmail();

                                                        if (phone != null &&
                                                            phone.isNotEmpty) {

                                                          await _ctrl.fetchLedger(
                                                            phone: phone,
                                                          );
                                                        }
                                                      }
                                                    },

                                                    style:
                                                    ElevatedButton.styleFrom(

                                                      backgroundColor:
                                                      Colors.green,

                                                      elevation: 0,

                                                      shape:
                                                      RoundedRectangleBorder(

                                                        borderRadius:
                                                        BorderRadius.circular(18.r),
                                                      ),
                                                    ),

                                                    child: Text(

                                                      "Update Sale",

                                                      style: TextStyle(

                                                        fontSize: 15.sp,

                                                        fontWeight:
                                                        FontWeight.w700,

                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(height: 10.h),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },

                          child: Container(

                            padding: EdgeInsets.all(8.r),

                            decoration: BoxDecoration(

                              color: Colors.blue.withOpacity(0.10),

                              borderRadius:
                              BorderRadius.circular(12.r),
                            ),

                            child: Icon(

                              Icons.edit_rounded,

                              color: Colors.blue,

                              size: 20.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 10.w),

              // ── RIGHT: Amount + Bill button ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+₹${entry.totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textGreen,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: onBillTap,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: AppColors.textBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                            color: AppColors.textBlue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              color: AppColors.textBlue, size: 14.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'Bill',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BILL SHEET — Ab LedgerModel + parsed items
// ─────────────────────────────────────────────
class BillSheet extends StatefulWidget {
  final LedgerModel entry;
  final List<_BillItem> billItems;

  BillSheet({super.key, required this.entry, required this.billItems});

  @override
  State<BillSheet> createState() => _BillSheetState();
}

class _BillSheetState extends State<BillSheet> {
  final ScreenshotController screenshotController = ScreenshotController();

  final UserController userController = Get.put(UserController());

  @override
  void initState() {
    super.initState();

    loadUser();
  }

  void loadUser() async {
    String? phone = await AuthStorage.getEmail();

    if (phone != null) {
      userController.getUser(
        phone: phone,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.billItems.fold(0.0, (s, i) => s + i.amount);
    final datePart = widget.entry.dates.contains(' ')
        ? widget.entry.dates.split(' ')[0]
        : widget.entry.dates;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          SizedBox(height: 16.h),

          // ── RECEIPT ──
          Screenshot(
            controller: screenshotController,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop name from API
                  Center(
                    child: Text(
                      widget.entry.shopName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark),
                    ),
                  ),
                  Center(
                    child: Text(
                      widget.entry.address,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 10.sp, color: AppColors.textGrey),
                    ),
                  ),

                  Center(
                    child: Text(
                      'GST: ${userController.userData["Gst"]?.toString() ?? ""}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Fssi: ${userController.userData["Fiss"]?.toString() ?? ""}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _dottedDivider(),
                  SizedBox(height: 8.h),

                  // Date / Time / Cashier / Mode
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _metaText('Date: $datePart'),
                          _metaText('Time: ${widget.entry.times}'),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _metaText('Cashier: ${widget.entry.cashier}'),
                          _metaText('Mode: ${widget.entry.mode}'),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  _metaText('Cust: ${widget.entry.customer}'),
                  _metaText('Mobile: ${widget.entry.mobile}'),
                  SizedBox(height: 10.h),
                  _dottedDivider(),
                  SizedBox(height: 8.h),

                  // Items header
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text('ITEM',
                            style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textGrey)),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('QTY X RATE',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textGrey)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('AMT',
                            textAlign: TextAlign.right,
                            style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textGrey)),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Items list
                  ...widget.billItems.map((item) => Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(item.name,
                                  style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textDark)),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                '${item.qty} x ${item.rate.toStringAsFixed(0)}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    fontSize: 11.sp, color: AppColors.textGrey),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'DIS:${item.discount}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    fontSize: 11.sp, color: AppColors.textGrey),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                item.amount.toStringAsFixed(2),
                                textAlign: TextAlign.right,
                                style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark),
                              ),
                            ),
                          ],
                        ),
                      )),

                  SizedBox(height: 6.h),
                  _dottedDivider(),
                  SizedBox(height: 8.h),

                  // Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal:',
                          style: GoogleFonts.poppins(
                              fontSize: 12.sp, color: AppColors.textGrey)),
                      Text('₹${subtotal.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textGrey)),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  _dottedDivider(),
                  SizedBox(height: 8.h),

                  // Grand Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('GRAND TOTAL:',
                          style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark)),
                      Text('₹${widget.entry.totalAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark)),
                    ],
                  ),
                  Text('Gst Included:',
                      style: GoogleFonts.poppins(
                          fontSize: 12.sp, color: AppColors.textGrey)),
                  SizedBox(height: 10.h),
                  _dottedDivider(),
                  SizedBox(height: 12.h),

                  Center(
                    child: Text('Thank You! Visit Again 🙏',
                        style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark)),
                  ),
                  Center(
                    child: Text('Software by SmartPOS',
                        style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: AppColors.textGrey,
                            fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // ── BOTTOM BUTTONS ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                // DOWNLOAD
                Expanded(
                  child: NeuButton(
                    onTap: () async {
                      HapticFeedback.mediumImpact();

                      final image = await screenshotController.capture();

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
                        mainAxisAlignment: MainAxisAlignment.center,
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

                      final image = await screenshotController.capture();

                      if (image == null) return;

                      await BillService.shareBill(
                        image: image,
                      );
                    },
                    borderRadius: 14,
                    color: kBlue,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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

          SizedBox(height: 12.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C3E),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r)),
                ),
                child: Text('Done',
                    style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _dottedDivider() {
    return LayoutBuilder(builder: (_, c) {
      final count = (c.maxWidth / 6).floor();
      return Row(
        children: List.generate(
          count,
          (_) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              height: 1,
              color: AppColors.inputBorder,
            ),
          ),
        ),
      );
    });
  }

  Widget _metaText(String t) => Text(t,
      style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textGrey));

  Widget _sheetBtn({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 16.sp),
            SizedBox(width: 5.w),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
          ],
        ),
      ),
    );
  }
}
