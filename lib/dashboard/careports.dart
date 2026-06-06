import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:share_plus/share_plus.dart';
import '../authstoreage/authstorage.dart';
import '../backend/dashboarapi.dart';
import '../backend/download.dart';
import '../poscalculator/constant/apptext.dart';
import '../poscalculator/constant/colors.dart';
import 'Dashboard.dart';     // <-- apna path change karo

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────
class ReportItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color btnBorderColor;
  final Color btnBgColor;
  final Color btnTextColor;

  const ReportItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.btnBorderColor,
    required this.btnBgColor,
    required this.btnTextColor,
  });
}

const List<ReportItem> kReports = [
  ReportItem(
    icon: Icons.receipt_long_rounded,
    iconColor: AppColors.iconGreen,
    title: 'Sales Report',
    subtitle: 'Date, Bill No, GST Details, Sales Amount, Payment Mode.',
    btnBorderColor: AppColors.btnGreenBorder,
    btnBgColor: AppColors.btnGreenBg,
    btnTextColor: AppColors.textGreen,
  ),

];



// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class CaTaxReportsScreen extends StatefulWidget {
  const CaTaxReportsScreen({super.key});

  @override
  State<CaTaxReportsScreen> createState() => _CaTaxReportsScreenState();
}

// REMOVE THIS
// const List<String> kFilters = ['Today', 'Month', 'Year', 'All'];

class _CaTaxReportsScreenState extends State<CaTaxReportsScreen> {
  final DashboardController dashboardController = Get.put(DashboardController());

  @override
  void initState() {
    super.initState();
    // Phone number apna daal do ya dynamic pass karo
    loadUser();
  }
  void loadUser() async {
    String? phone = await AuthStorage.getEmail();

    if (phone != null) {

      dashboardController.fetchDashboard(
        phone: phone,
      );
    }
  }
  DateTime? fromDate;
  DateTime? tillDate;

  Future<void> pickDate({
    required bool isFrom,
  }) async {

    DateTime initial =
    DateTime.now();

    final picked =
    await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {

      setState(() {

        if (isFrom) {

          fromDate = picked;

        } else {

          tillDate = picked;
        }
      });
    }
  }

  String formatDate(
      DateTime? date,
      ) {

    if (date == null) {
      return "Select Date";
    }

    return
      "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      AppColors.scaffold,

      body: SafeArea(

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            _AppBarSection(),

            SizedBox(height: 16.h),

            // DATE FIELDS
            Padding(

              padding:
              EdgeInsets.symmetric(
                horizontal: 10.w,
              ),

              child: Row(

                children: [

                  Expanded(

                    child: GestureDetector(

                      onTap: () =>
                          pickDate(
                            isFrom: true,
                          ),

                      child: Container(

                        padding:
                        EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 14.h,
                        ),

                        decoration:
                        BoxDecoration(

                          color:
                          AppColors.cardWhite,

                          borderRadius:
                          BorderRadius.circular(
                            12.r,
                          ),

                          border: Border.all(
                            color: AppColors
                                .filterBorder,
                          ),
                        ),

                        child: Column(

                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Text(
                              "From Date",
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight:
                                FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),

                            SizedBox(
                              height: 4.h,
                            ),

                            Text(
                              formatDate(
                                fromDate,
                              ),
                              style: AppText
                                  .reportCardTitle(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  Expanded(

                    child: GestureDetector(

                      onTap: () =>
                          pickDate(
                            isFrom: false,
                          ),

                      child: Container(

                        padding:
                        EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 14.h,
                        ),

                        decoration:
                        BoxDecoration(

                          color:
                          AppColors.cardWhite,

                          borderRadius:
                          BorderRadius.circular(
                            12.r,
                          ),

                          border: Border.all(
                            color: AppColors
                                .filterBorder,
                          ),
                        ),

                        child: Column(

                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Text(
                              "Till Date",
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight:
                                FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),

                            SizedBox(
                              height: 4.h,
                            ),

                            Text(
                              formatDate(
                                tillDate,
                              ),
                              style: AppText
                                  .reportCardTitle(),
                            ),


                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.h),
            Obx(() {

              final data =
                  dashboardController
                      .dashboardData.value;

              return Row(

                children: [

                  Expanded(
                    child: MetricCard(

                      bgColor:
                      AppColors.cardGreen,

                      icon:
                      Icons.currency_rupee_rounded,

                      iconColor:
                      AppColors.iconGreen,

                      label:
                      "TODAY'S SALES",

                      value:
                      "₹${data?.todaySales.toStringAsFixed(2) ?? "0"}",

                      valueColor:
                      AppColors.textGreen, onTap: () {  },
                    ),
                  ),

                  SizedBox(width: 14.w),

                  Expanded(
                    child: MetricCard(

                      bgColor:
                      AppColors.cardPink,

                      icon:
                      Icons.remove_circle_outline_rounded,

                      iconColor:
                      AppColors.iconOrange,

                      label:
                      "TODAY'S Market Due",

                      value:
                      "₹${data?.todayMarketDue.toStringAsFixed(2) ?? "0"}",

                      valueColor:
                      AppColors.textRed, onTap: () {  },
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: 14.h),

            // ── Row 2: This Month + Market Due ──
            Obx(() {

              final data =
                  dashboardController
                      .dashboardData.value;

              return Row(

                children: [

                  Expanded(
                    child: MetricCard(

                      bgColor:
                      AppColors.cardBlue,

                      icon:
                      Icons.calendar_today_outlined,

                      iconColor:
                      AppColors.iconBlue,

                      label:
                      "THIS MONTH",

                      value:
                      "₹${data?.monthSales.toStringAsFixed(2) ?? "0"}",

                      valueColor:
                      AppColors.textBlue, onTap: () {  },
                    ),
                  ),

                  SizedBox(width: 14.w),

                  Expanded(
                    child: MetricCard(

                      bgColor:
                      AppColors.cardYellow,

                      icon:
                      Icons.donut_large_rounded,

                      iconColor:
                      AppColors.iconYellow,

                      label:
                      "This Month MARKET DUE",

                      value:
                      "₹${data?.monthMarketDue.toStringAsFixed(2) ?? "0"}",

                      valueColor:
                      AppColors.textRed, onTap: () {  },
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: 14.h),

            Expanded(
              child:
              SingleChildScrollView(
                padding:
                EdgeInsets.symmetric(
                  horizontal: 18.w,
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    ...kReports.map(

                          (r) => Padding(

                        padding: EdgeInsets.only(
                          bottom: 14.h,
                        ),

                        child: _ReportCard(

                          item: r,

                          fromDate: fromDate,

                          tillDate: tillDate,
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
final SalesExcelController reportController = Get.put(SalesExcelController(),);

String apiDate(
    DateTime? date,
    ) {

  if (date == null) {
    return "";
  }

  return
    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}
class _AppBarSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 18.w, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 20.sp, color: AppColors.textDark),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CA & Tax Reports Hub',
                  style: AppText.reportPageTitle()),
              Text('Download Excel Reports for Accounting',
                  style: AppText.reportPageSubtitle()),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FILTER ROW
// ─────────────────────────────────────────────


// ─────────────────────────────────────────────
// REPORT CARD
// ─────────────────────────────────────────────
class _ReportCard extends StatelessWidget {
  final ReportItem item;

  final DateTime? fromDate;
  final DateTime? tillDate;

  const _ReportCard({
    required this.item,
    required this.fromDate,
    required this.tillDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: item.iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(item.icon,
                    size: 20.sp, color: item.iconColor),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(item.title,
                    style: AppText.reportCardTitle()),
              ),
              Icon(item.icon,
                  size: 42.sp,
                  color: item.iconColor.withOpacity(0.08)),
            ],
          ),
          SizedBox(height: 8.h),
          Text(item.subtitle, style: AppText.reportCardSubtitle()),
          SizedBox(height: 14.h),
          GestureDetector(
            // BUTTON onTap

            onTap: () async {

              if (fromDate == null ||
                  tillDate == null) {

                Get.snackbar(
                  "Error",
                  "Select Dates",
                );

                return;
              }

              String? phone =
              await AuthStorage.getEmail();

              // 🔥 NULL CHECK
              if (phone == null ||
                  phone.isEmpty) {

                Get.snackbar(
                  "Error",
                  "Phone Not Found",
                );

                return;
              }

              await reportController
                  .downloadExcel(

                phone: phone,

                fromDate:
                apiDate(fromDate),

                toDate:
                apiDate(tillDate),
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.green,
                border: Border.all(
                    color: item.btnBorderColor, width: 1.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_rounded,
                      size: 16.sp, color:Colors.white),
                  SizedBox(width: 6.w),
                  Text(
                    'Export Excel(Csv)',
                    style: AppText.reportDownloadBtn(
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),
          GestureDetector(
            // BUTTON onTap

            onTap: () async {

              if (fromDate == null ||
                  tillDate == null) {

                Get.snackbar(
                  "Error",
                  "Select Dates",
                );

                return;
              }

              String? phone =
              await AuthStorage.getEmail();

              if (phone == null ||
                  phone.isEmpty) {

                Get.snackbar(
                  "Error",
                  "Phone Not Found",
                );

                return;
              }

              // DOWNLOAD FILE
              String? filePath =
              await reportController.downloadExcel(

                phone: phone,

                fromDate: apiDate(fromDate),

                toDate: apiDate(tillDate),
              );

              // NULL CHECK
              if (filePath == null ||
                  filePath.isEmpty) {

                Get.snackbar(
                  "Error",
                  "File Not Found",
                );

                return;
              }

              // DIRECT SHARE
              await Share.shareXFiles(

                [XFile(filePath)],

                text: "Sales Excel Report",
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.green,
                border: Border.all(
                    color: item.btnBorderColor, width: 1.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon( Icons.chat_rounded,
                      size: 18.sp, color: Colors.white),
                  SizedBox(width: 6.w),
                  Text(
                    'Share Summary to CA via Whatsapp',
                    style: AppText.reportDownloadBtn(
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
