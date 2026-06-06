import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

import '../authstoreage/authstorage.dart';
import '../backend/dashboarapi.dart';
import '../poscalculator/constant/apptext.dart';
import '../poscalculator/constant/colors.dart';
import 'careports.dart';
import 'dashboardreportscreen.dart';




// ─────────────────────────────────────────────
// CONSTANTS — Colors


// ─────────────────────────────────────────────
// DASHBOARD SCREEN
// ─────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController
  dashboardController =
  Get.put(
    DashboardController(),
  );
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────
              const _Header(),
              SizedBox(height: 22.h),

              // ── Row 1: Today's Sales + Expenses ─
              Obx(() {

                final data =
                    dashboardController
                        .dashboardData.value;

                return Row(

                  children: [

                    // TODAY SALES
                    Expanded(

                      child: MetricCard(

                        onTap: () {

                          Get.to(

                                () => DashboardReportScreen(

                              type: "TodaySales",
                            ),
                          );
                        },

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
                        AppColors.textGreen,
                      ),
                    ),

                    SizedBox(width: 14.w),

                    // TODAY MARKET DUE
                    Expanded(

                      child: MetricCard(

                        onTap: () {

                          Get.to(

                                () => DashboardReportScreen(

                              type: "TodayExpense",
                            ),
                          );
                        },

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
                        AppColors.textRed,
                      ),
                    ),
                  ],
                );
              }),

              SizedBox(height: 14.h),

              // ── ROW 2 ─────────────────────
              Obx(() {

                final data =
                    dashboardController
                        .dashboardData.value;

                return Row(

                  children: [

                    // MONTH SALES
                    Expanded(

                      child: MetricCard(

                        onTap: () {

                          Get.to(

                                () => DashboardReportScreen(

                              type: "MonthSales",
                            ),
                          );
                        },

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
                        AppColors.textBlue,
                      ),
                    ),

                    SizedBox(width: 14.w),

                    // MONTH MARKET DUE
                    Expanded(

                      child: MetricCard(

                        onTap: () {

                          Get.to(

                                () => DashboardReportScreen(

                              type: "MonthExpense",
                            ),
                          );
                        },

                        bgColor:
                        AppColors.cardYellow,

                        icon:
                        Icons.donut_large_rounded,

                        iconColor:
                        AppColors.iconYellow,

                        label:
                        "THIS MONTH MARKET DUE",

                        value:
                        "₹${data?.monthMarketDue.toStringAsFixed(2) ?? "0"}",

                        valueColor:
                        AppColors.textRed,
                      ),
                    ),
                  ],
                );
              }),
              SizedBox(height: 14.h),

              // ── Top Selling Today ────────────────
              // const _TopSellingCard(),
              SizedBox(height: 14.h),

              // ── CA & Tax Reports CTA ─────────────
              const _CtaBanner(),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HEADER WIDGET
// ─────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard', style: AppText.heading()),
            Text('Business Overview', style: AppText.subHeading()),
          ],
        ),
        const Spacer(),
        // AI Insights chip
        // Container(
        //   padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        //   decoration: BoxDecoration(
        //     color: AppColors.aiChipBg,
        //     border: Border.all(color: AppColors.aiChipBorder, width: 1.2),
        //     borderRadius: BorderRadius.circular(20.r),
        //   ),
        //   child: Row(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Icon(Icons.auto_awesome_rounded,
        //           size: 14.sp, color: AppColors.aiChipText),
        //       SizedBox(width: 5.w),
        //       // Text('AI Insights', style: AppText.aiChip()),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// METRIC CARD WIDGET
// ─────────────────────────────────────────────
class MetricCard extends StatelessWidget {

  final Color bgColor;

  final IconData icon;

  final Color iconColor;

  final String label;

  final String value;

  final Color valueColor;

  final VoidCallback onTap;

  const MetricCard({

    super.key,

    required this.bgColor,

    required this.icon,

    required this.iconColor,

    required this.label,

    required this.value,

    required this.valueColor,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        padding: EdgeInsets.symmetric(

          horizontal: 14.w,

          vertical: 16.h,
        ),

        decoration: BoxDecoration(

          color: bgColor,

          borderRadius:
          BorderRadius.circular(16.r),
        ),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Row(

              children: [

                Icon(

                  icon,

                  size: 15.sp,

                  color: iconColor,
                ),

                SizedBox(width: 5.w),

                Flexible(

                  child: Text(

                    label,

                    style: AppText.cardLabel(),

                    maxLines: 1,

                    overflow:
                    TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            Text(

              value,

              style:
              AppText.cardValue(
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TOP SELLING TODAY CARD
// ─────────────────────────────────────────────


// ─────────────────────────────────────────────
// CA & TAX REPORTS CTA BANNER
// ─────────────────────────────────────────────
class _CtaBanner extends StatelessWidget {
  const _CtaBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.cardCta,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // Icon box
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.description_outlined,
              color: AppColors.textWhite,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTapDown: (_) {
                // optional tap effect
              },
              onTap: () {
               Get.to(CaTaxReportsScreen());
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(18.r),
                ),
            
                child: Row(
                  children: [
            
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CA & Tax Reports Hub',
                            style: AppText.ctaTitle(),
                          ),
            
                          SizedBox(height: 3.h),
            
                          Text(
                            'Export Sales, Purchase & Ledger in Excel',
                            style: AppText.ctaSubtitle(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.textWhite, size: 22.sp),
        ],
      ),
    );
  }
}