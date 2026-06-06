import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppText {
  AppText._();

  // ────────────────────────────────────────────
  // DASHBOARD STYLES
  // ────────────────────────────────────────────
  static TextStyle pageTitle() => GoogleFonts.poppins(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );
  static TextStyle bodyRegular() => GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textGrey,
  );
  static TextStyle saveBtn() => GoogleFonts.poppins(
    fontSize: 15.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );
  static TextStyle staffName() => GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
  static TextStyle heading() => GoogleFonts.poppins(
    fontSize: 26.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );
  static TextStyle hint() => GoogleFonts.poppins(
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textGrey,
  );
  static TextStyle subHeading() => GoogleFonts.poppins(
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textGrey,
  );

  static TextStyle cardLabel() => GoogleFonts.poppins(
    fontSize: 10.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: 0.5,
  );

  static TextStyle cardValue({Color color = AppColors.textGreen}) =>
      GoogleFonts.poppins(
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle topSellingLabel() => GoogleFonts.poppins(
    fontSize: 10.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textGreen,
    letterSpacing: 0.8,
  );

  static TextStyle topSellingValue() => GoogleFonts.poppins(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle ctaTitle() => GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
  );

  static TextStyle ctaSubtitle() => GoogleFonts.poppins(
    fontSize: 11.sp,
    fontWeight: FontWeight.w400,
    color: const Color(0xDDFFFFFF),
  );

  static TextStyle aiChip() => GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.aiChipText,
  );

  // ────────────────────────────────────────────
  // REPORT SCREEN STYLES
  // ────────────────────────────────────────────

  static TextStyle reportPageTitle() => GoogleFonts.poppins(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle reportPageSubtitle() => GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textGrey,
  );

  static TextStyle reportFilterActive() => GoogleFonts.poppins(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  static TextStyle reportFilterInactive() => GoogleFonts.poppins(
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static TextStyle reportCardTitle() => GoogleFonts.poppins(
    fontSize: 15.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle reportCardSubtitle() => GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textGrey,
    height: 1.4,
  );

  static TextStyle reportDownloadBtn({required Color color}) =>
      GoogleFonts.poppins(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle reportSectionLabel() => GoogleFonts.poppins(
    fontSize: 13.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.sectionLabel,
    letterSpacing: 0.6,
  );

  static TextStyle reportTipText() => GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.tipText,
    fontStyle: FontStyle.italic,
  );
  static TextStyle fieldValue() => GoogleFonts.poppins(
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static TextStyle staffPhone() => GoogleFonts.poppins(
    fontSize: 11.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textGrey,
  );
}
