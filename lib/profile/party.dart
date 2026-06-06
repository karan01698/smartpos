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
import '../backend/partynumberdownload.dart';
import '../backend/patyapi/insertapi.dart';
import '../backend/patyapi/partydeleteapi.dart';
import '../backend/showsales.dart';
import '../backend/udharecel.dart';
import '../ledger/udhaar.dart';
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
    ) ?? 0;
    final discount = double.tryParse(
      map['Discount'].toString(),
    ) ?? 0;

    final rate = double.tryParse(
      map['Rate'].toString(),
    ) ?? 0;

    final amount = double.tryParse(
      map['Amount'].toString(),
    ) ?? 0;

    return _BillItem(
      name: map['Name'] ??
          map['Item'] ??
          map['ProductName'] ??
          'Item',

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
class PartyScreen extends StatefulWidget {
  final int selectedTab;

  const PartyScreen({

    super.key,

    required this.selectedTab,
  });

  @override
  State<PartyScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<PartyScreen> {
  // Controller inject
  final LedgerController _ctrl = Get.put(LedgerController());

  final _searchCtrl = TextEditingController();
  // final _filters = ['All', 'Cash', 'UPI', 'Credit'];
  final  CustomerExcelController excelController = Get.put(CustomerExcelController());
  final ShowPartyController partyController = Get.put(ShowPartyController());
  @override
  void initState() {
    super.initState();
    // Phone number apna daal do ya dynamic pass karo
    loadUser();
  }
  void loadUser() async {
    String? phone = await AuthStorage.getEmail();

    if (phone != null) {

      _ctrl.fetchLedger(phone:phone);
      partyController.fetchParty(

        type: widget.selectedTab == 0
            ? "Customer"
            : "Supplier",

        venPhone: phone!,
      );
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
    return  SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              // ── LIST ──
              Expanded(
                child: Obx(() {

                  if (partyController
                      .isLoading.value &&
                      partyController
                          .partyList.isEmpty) {

                    return const Center(
                      child:
                      CircularProgressIndicator(),
                    );
                  }

                  final list =
                  partyController
                      .filteredList
                      .toList();

                  if (list.isEmpty) {

                    return Center(

                      child: Text(

                        'No Party Found',

                        style: GoogleFonts.poppins(

                          fontSize: 14.sp,

                          color:
                          AppColors.textGrey,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(

                    itemCount: list.length,

                    separatorBuilder: (_, __) =>
                        SizedBox(height: 10.h),

                    itemBuilder: (_, i) {

                      final item = list[i];

                      return GestureDetector(
                        onTap: () {

                          Get.to(

                                () => UdharScreen(

                              mobile: item.phone,

                              phone: item.venPhone,
                            ),
                          );
                        },
                        child: Container(
                        
                          padding: EdgeInsets.symmetric(
                        
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                        
                          decoration: BoxDecoration(
                        
                            color: Colors.white,
                        
                            borderRadius:
                            BorderRadius.circular(18.r),
                        
                            boxShadow: [
                        
                              BoxShadow(
                        
                                color: Colors.black
                                    .withOpacity(0.04),
                        
                                blurRadius: 14,
                        
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        
                          child: Row(
                        
                            children: [
                        
                              // PROFILE
                              Container(
                        
                                height: 44.h,
                                width: 44.w,
                        
                                decoration: BoxDecoration(
                        
                                  color:
                                  const Color(0xFFE7F8EC),
                        
                                  borderRadius:
                                  BorderRadius.circular(14.r),
                                ),
                        
                                child: Center(
                        
                                  child: Text(
                        
                                    item.name
                                        .isNotEmpty
                        
                                        ? item.name[0]
                                        .toUpperCase()
                        
                                        : "A",
                        
                                    style:
                                    GoogleFonts.poppins(
                        
                                      fontSize: 18.sp,
                        
                                      fontWeight:
                                      FontWeight.w700,
                        
                                      color:
                                      const Color(0xFF22C55E),
                                    ),
                                  ),
                                ),
                              ),
                        
                              SizedBox(width: 12.w),
                        
                              // NAME + MOBILE
                              Expanded(
                        
                                child: Column(
                        
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                        
                                  children: [
                        
                                    Text(
                        
                                      item.name,
                        
                                      maxLines: 1,
                        
                                      overflow:
                                      TextOverflow.ellipsis,
                        
                                      style:
                                      GoogleFonts.poppins(
                        
                                        fontSize: 15.sp,
                        
                                        fontWeight:
                                        FontWeight.w700,
                        
                                        color:
                                        const Color(0xFF1F2937),
                                      ),
                                    ),
                        
                                    SizedBox(height: 2.h),

                                    Text(

                                      item.phone,

                                      style:
                                      GoogleFonts.poppins(

                                        fontSize: 12.sp,

                                        color:
                                        const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        
                              SizedBox(width: 10.w),
                              SizedBox(width: 10.w),
                        
                              GestureDetector(
                        
                                onTap: () async {
                                  final DeletePartyController
                                  deleteController =
                                  Get.put(DeletePartyController());
                        
                                  String? phone =
                                  await AuthStorage.getEmail();
                        
                                  if (phone != null) {
                        
                                    deleteController.deleteParty(
                        
                                      id: item.id,
                        
                                      type: item.type,
                        
                                      venPhone: phone,
                                    );
                                  }
                                },
                        
                                child: Container(
                        
                                  padding: EdgeInsets.all(8.r),
                        
                                  decoration: BoxDecoration(
                        
                                    color: Colors.red
                                        .withOpacity(0.10),
                        
                                    borderRadius:
                                    BorderRadius.circular(12.r),
                                  ),
                        
                                  child: Icon(
                        
                                    Icons.delete_outline_rounded,
                        
                                    color: Colors.red,
                        
                                    size: 20.sp,
                                  ),
                                ),
                              ),
                        
                              // Container(
                              //
                              //   padding:
                              //   EdgeInsets.symmetric(
                              //
                              //     horizontal: 10.w,
                              //     vertical: 6.h,
                              //   ),
                              //
                              //   decoration: BoxDecoration(
                              //
                              //     color: item.type ==
                              //         "Supplier"
                              //
                              //         ? Colors.orange
                              //         .withOpacity(0.12)
                              //
                              //         : Colors.green
                              //         .withOpacity(0.12),
                              //
                              //     borderRadius:
                              //     BorderRadius.circular(30.r),
                              //   ),
                              //
                              //   child: Text(
                              //
                              //     item.type,
                              //
                              //     style:
                              //     GoogleFonts.poppins(
                              //
                              //       fontSize: 11.sp,
                              //
                              //       fontWeight:
                              //       FontWeight.w600,
                              //
                              //       color: item.type ==
                              //           "Supplier"
                              //
                              //           ? Colors.orange
                              //           : Colors.green,
                              //     ),
                              //   ),
                              // ),
                              SizedBox(width: 5,),
                              GestureDetector(

                                onTap: () async {

                                  String phone = item.phone
                                      .replaceAll("+", "")
                                      .replaceAll(" ", "")
                                      .replaceAll("-", "")
                                      .trim();

                                  // 🔥 INDIA CODE
                                  if (!phone.startsWith("91")) {

                                    phone = "91$phone";
                                  }

                                  final Uri whatsappUri = Uri.parse(

                                    "https://wa.me/$phone",
                                  );

                                  await launchUrl(

                                    whatsappUri,

                                    mode: LaunchMode.externalApplication,
                                  );
                                },

                                child: Container(

                                  padding: EdgeInsets.all(8.r),

                                  decoration: BoxDecoration(

                                    color: Colors.green.withOpacity(0.10),

                                    borderRadius: BorderRadius.circular(12.r),
                                  ),

                                  child: Image.asset(

                                    "assets/whatsapp.png",

                                    height: 20,

                                    width: 20,
                                  ),
                                ),
                              ),

                              SizedBox(width: 10.w),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),


              SizedBox(width: 10),
              SizedBox(height: 16.h),
            ],
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
  final DeleteSalesController
  deleteController =
  Get.put(
    DeleteSalesController(),
  );

  final LedgerController
  _ctrl =
  Get.put(
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
    final datePart = entry.dates.contains(' ')
        ? entry.dates.split(' ')[0]
        : entry.dates;
    final rawTime = entry.times; // "13:48:05" ya "13:48"
    final timePart = rawTime.length >= 5 ? rawTime.substring(0, 5) : rawTime;

    final modeColor = _modeColor(entry.mode);

    return GestureDetector(
        onTap: () {

      Get.to(

            () => UdharScreen(

          mobile: entry.mobile,

          phone: entry.phone,
        ),);},

      child: Container(
      
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 12.h,
        ),
      
        decoration: BoxDecoration(
      
          color: Colors.white,
      
          borderRadius:
          BorderRadius.circular(18.r),
      
          boxShadow: [
      
            BoxShadow(
      
              color: Colors.black
                  .withOpacity(0.04),
      
              blurRadius: 14,
      
              offset: const Offset(0, 4),
            ),
          ],
        ),
      
        child: Row(
      
          children: [
      
            // PROFILE
            Container(
      
              height: 44.h,
      
              width: 44.w,
      
              decoration: BoxDecoration(
      
                color: const Color(0xFFE7F8EC),
      
                borderRadius:
                BorderRadius.circular(14.r),
              ),
      
              child: Center(
      
                child: Text(
      
                  entry.customer
                      .isNotEmpty
      
                      ? entry.customer[0]
                      .toUpperCase()
      
                      : "A",
      
                  style: GoogleFonts.poppins(
      
                    fontSize: 18.sp,
      
                    fontWeight:
                    FontWeight.w700,
      
                    color:
                    const Color(0xFF22C55E),
                  ),
                ),
              ),
            ),
      
            SizedBox(width: 12.w),
      
            // NAME + MOBILE
            Expanded(
      
              child: Column(
      
                crossAxisAlignment:
                CrossAxisAlignment.start,
      
                children: [
      
                  Text(
      
                    entry.customer,
      
                    maxLines: 1,
      
                    overflow:
                    TextOverflow.ellipsis,
      
                    style:
                    GoogleFonts.poppins(
      
                      fontSize: 15.sp,
      
                      fontWeight:
                      FontWeight.w700,
      
                      color:
                      const Color(0xFF1F2937),
                    ),
                  ),
      
                  SizedBox(height: 2.h),
      
                  Text(
      
                    entry.mobile,
      
                    style:
                    GoogleFonts.poppins(
      
                      fontSize: 12.sp,
      
                      color:
                      const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
      
            SizedBox(width: 10.w),
      
            // STATUS
            
      
            SizedBox(width: 12.w),
      
            // DELETE
            Icon(
      
              Icons.delete_outline_rounded,
      
              color: Colors.red.shade300,
      
              size: 20.sp,
            ),
          ],
        ),
      ),
    );;
  }
}

// ─────────────────────────────────────────────
// BILL SHEET — Ab LedgerModel + parsed items
// ─────────────────────────────────────────────
class BillSheet extends StatelessWidget {
  final LedgerModel entry;
  final List<_BillItem> billItems;

  BillSheet({super.key, required this.entry, required this.billItems});
  final ScreenshotController screenshotController =  ScreenshotController();
  @override
  Widget build(BuildContext context) {
    final subtotal =
    billItems.fold(0.0, (s, i) => s + i.amount);
    final datePart = entry.dates.contains(' ')
        ? entry.dates.split(' ')[0]
        : entry.dates;
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
                      entry.shopName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark),
                    ),
                  ),
                  Center(
                    child: Text(
                      entry.address,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 10.sp, color: AppColors.textGrey),
                    ),
                  ),
                  Center(
                    child: Text(
                      'GST: TASTDEMO  FSSAI: TASTDEMO',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 9.sp, color: AppColors.textGrey),
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
                          _metaText('Time: ${entry.times}'),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _metaText('Cashier: ${entry.cashier}'),
                          _metaText('Mode: ${entry.mode}'),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  _metaText('Cust: ${entry.customer}'),
                  _metaText('Mobile: ${entry.mobile}'),
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
                  ...billItems.map((item) => Padding(
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
                      Text('₹${entry.totalAmount.toStringAsFixed(2)}',
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
                            Icons.download_rounded,
                            size: 16,
                            color: Colors.white,
                          ),

                          SizedBox(width: 6),

                          Text(
                            'Download',

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
      style: GoogleFonts.poppins(
          fontSize: 10.sp, color: AppColors.textGrey));

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
          border:
          borderColor != null ? Border.all(color: borderColor) : null,
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



class PartyTabBarScreen extends StatefulWidget {

  const PartyTabBarScreen({super.key});

  @override
  State<PartyTabBarScreen> createState() =>
      _PartyTabBarScreenState();
}

class _PartyTabBarScreenState
    extends State<PartyTabBarScreen> {
  final InsertPartyController
  partyController =
  Get.put(InsertPartyController());
  final ShowPartyController showpartyController = Get.put(ShowPartyController());
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(

        elevation: 0,

        backgroundColor: Colors.white,

        title: const Text(

          "Party",

          style: TextStyle(

            color: Colors.black,

            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // FLOATING BUTTON
      floatingActionButton: GestureDetector(

        onTap: () {

          showModalBottomSheet(

            context: context,

            isScrollControlled: true,

            backgroundColor: Colors.transparent,

            builder: (_) {

              final nameCtrl =
              TextEditingController();

              final mobileCtrl =
              TextEditingController();

              return Container(

                padding: EdgeInsets.only(

                  left: 20,
                  right: 20,
                  top: 20,

                  bottom:
                  MediaQuery.of(context)
                      .viewInsets
                      .bottom +
                      20,
                ),

                decoration: const BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                  BorderRadius.vertical(

                    top: Radius.circular(28),
                  ),
                ),

                child: Column(

                  mainAxisSize:
                  MainAxisSize.min,

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    // TOP HANDLE
                    Center(

                      child: Container(

                        width: 50,

                        height: 5,

                        decoration: BoxDecoration(

                          color: Colors.grey.shade300,

                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // TITLE
                    Text(

                      selectedTab == 0

                          ? "Add Customer"

                          : "Add Supplier",

                      style: const TextStyle(

                        fontSize: 22,

                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // NAME FIELD
                    TextField(

                      controller: nameCtrl,

                      decoration: InputDecoration(

                        hintText: selectedTab == 0

                            ? "Customer Name"

                            : "Supplier Name",

                        filled: true,

                        fillColor:
                        const Color(0xFFF5F5F5),

                        border:
                        OutlineInputBorder(

                          borderRadius:
                          BorderRadius.circular(16),

                          borderSide:
                          BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // MOBILE FIELD
                    TextField(

                      controller: mobileCtrl,

                      keyboardType:
                      TextInputType.phone,

                      decoration: InputDecoration(

                        hintText: "Mobile Number",

                        filled: true,

                        fillColor:
                        const Color(0xFFF5F5F5),

                        border:
                        OutlineInputBorder(

                          borderRadius:
                          BorderRadius.circular(16),

                          borderSide:
                          BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // BUTTON
                    SizedBox(

                      width: double.infinity,

                      height: 55,

                      child: ElevatedButton(

                        onPressed: () async{
                          String? phone = await AuthStorage.getEmail();
                          partyController.insertParty(

                            name: nameCtrl.text,

                            phone: mobileCtrl.text,

                            type: selectedTab == 0
                                ? "Customer"
                                : "Supplier",

                            venPhone: phone!,
                          );

                          print(nameCtrl.text);

                          print(mobileCtrl.text);

                          Navigator.pop(context);
                        },

                        style:
                        ElevatedButton.styleFrom(

                          backgroundColor:
                          const Color(0xFF22C55E),

                          elevation: 0,

                          shape:
                          RoundedRectangleBorder(

                            borderRadius:
                            BorderRadius.circular(18),
                          ),
                        ),

                        child: Text(

                          selectedTab == 0

                              ? "Add Customer"

                              : "Add Supplier",

                          style: const TextStyle(

                            fontSize: 15,

                            fontWeight:
                            FontWeight.w700,

                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },

        child: Container(

          height: 64,

          width: 64,

          decoration: BoxDecoration(

            shape: BoxShape.circle,

            color: const Color(0xFF22C55E),

            boxShadow: [

              BoxShadow(

                color: Colors.green
                    .withOpacity(0.35),

                blurRadius: 14,

                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: Icon(

            selectedTab == 0

                ? Icons.person_add_alt_1_rounded

                : Icons.person_add_alt_1_rounded,

            color: Colors.white,

            size: 30,
          ),
        ),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            // TAB BAR
            Container(

              height: 50,

              padding: const EdgeInsets.all(4),

              decoration: BoxDecoration(

                color: const Color(0xFFF1F1F1),

                borderRadius:
                BorderRadius.circular(14),
              ),

              child: Row(

                children: [

                  // CUSTOMERS
                  Expanded(

                    child: GestureDetector(

                      onTap: () async {

                        setState(() {

                          selectedTab = 0;
                        });

                        String? phone =
                        await AuthStorage.getEmail();

                        if (phone != null) {

                          showpartyController.fetchParty(

                            type: "Customer",

                            venPhone: phone,
                          );
                        }
                      },

                      child: AnimatedContainer(

                        duration: const Duration(
                          milliseconds: 250,
                        ),

                        decoration: BoxDecoration(

                          color: selectedTab == 0

                              ? const Color(0xFF22C55E)

                              : Colors.transparent,

                          borderRadius:
                          BorderRadius.circular(12),
                        ),

                        child: Center(

                          child: Text(

                            "Customers",

                            style: TextStyle(

                              fontSize: 13,

                              fontWeight:
                              FontWeight.w600,

                              color: selectedTab == 0

                                  ? Colors.white

                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // SUPPLIERS
                  Expanded(

                    child: GestureDetector(

                      onTap: () async {

                        setState(() {

                          selectedTab = 1;
                        });

                        String? phone =
                        await AuthStorage.getEmail();

                        if (phone != null) {

                          showpartyController.fetchParty(

                            type: "Supplier",

                            venPhone: phone,
                          );
                        }
                      },

                      child: AnimatedContainer(

                        duration: const Duration(
                          milliseconds: 250,
                        ),

                        decoration: BoxDecoration(

                          color: selectedTab == 1

                              ? const Color(0xFF22C55E)

                              : Colors.transparent,

                          borderRadius:
                          BorderRadius.circular(12),
                        ),

                        child: Center(

                          child: Text(

                            "Suppliers",

                            style: TextStyle(

                              fontSize: 13,

                              fontWeight:
                              FontWeight.w600,

                              color: selectedTab == 1

                                  ? Colors.white

                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // CSV BUTTON
                  GestureDetector(

                    onTap: () async {
                      final PartyExcelDownloadController
                      excelController =
                      Get.put(
                        PartyExcelDownloadController(),
                      );
                      String? phone =
                      await AuthStorage.getEmail();

                      if (phone != null) {


                        excelController
                            .downloadPartyExcel(

                          type: selectedTab == 0
                              ? "Customer"
                              : "Supplier",

                          venPhone: phone,
                        );
                      }
                    },

                    child: Container(

                      padding:
                      const EdgeInsets.symmetric(

                        horizontal: 14,
                        vertical: 10,
                      ),

                      decoration: BoxDecoration(

                        color: Colors.white,

                        borderRadius:
                        BorderRadius.circular(12),
                      ),

                      child: Row(

                        children: [

                          Icon(

                            Icons.download_rounded,

                            size: 16.sp,

                            color: Colors.green,
                          ),

                          SizedBox(width: 4.w),

                          Text(

                            "CSV",

                            style: TextStyle(

                              fontSize: 12.sp,

                              fontWeight:
                              FontWeight.w600,

                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // BODY
            Expanded(

              child: selectedTab == 0

                  ? PartyScreen(selectedTab: selectedTab,)

                  : PartyScreen(selectedTab: selectedTab,)
            ),
          ],
        ),
      ),
    );
  }
}