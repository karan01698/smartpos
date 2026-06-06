import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../authstoreage/register.dart';
import '../backend/login.dart';
import '../poscalculator/constant/apptext.dart';
import '../poscalculator/constant/colors.dart';
import '../widget/button.dart';

class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key});

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {

  final LoginController controller =
  Get.put(LoginController());

  final TextEditingController mobileCtrl =
  TextEditingController();

  final TextEditingController passCtrl =
  TextEditingController();

  bool isHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),

            child: Container(
              width: double.infinity,

              padding: EdgeInsets.symmetric(
                horizontal: 22.w,
                vertical: 28.h,
              ),

              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(22.r),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // ICON
                  Container(
                    width: 70.w,
                    height: 70.w,

                    decoration: BoxDecoration(
                      color: AppColors.cardGreen,
                      shape: BoxShape.circle,
                    ),

                    child: Center(
                      child: Icon(
                        Icons.manage_accounts_outlined,
                        color: AppColors.iconGreen,
                        size: 34.sp,
                      ),
                    ),
                  ),

                  SizedBox(height: 18.h),

                  // TITLE
                  Text(
                    "STAFF LOGIN",
                    style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      letterSpacing: 0.5,
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // MOBILE FIELD
                  Container(
                    height: 54.h,

                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(14.r),

                      border: Border.all(
                        color: AppColors.textGreen,
                        width: 1.3,
                      ),
                    ),

                    child: TextField(
                      controller: mobileCtrl,
                      style: AppText.fieldValue(),

                      decoration: InputDecoration(

                        prefixIcon: Icon(
                          Icons.phone_android_rounded,
                          color: AppColors.textGreen,
                          size: 20.sp,
                        ),

                        hintText: "Enter Your Mobile Number",
                        hintStyle: AppText.hint(),

                        border: InputBorder.none,

                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 15.h,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // PIN FIELD
                  Container(
                    height: 54.h,

                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(14.r),

                      border: Border.all(
                        color: const Color(0xFFE4E4E4),
                      ),
                    ),

                    child: TextField(
                      controller: passCtrl,
                      obscureText: isHidden,
                      style: AppText.fieldValue(),

                      decoration: InputDecoration(

                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.textGrey,
                          size: 20.sp,
                        ),

                        // 👇 SHOW HIDE
                        suffixIcon: IconButton(

                          onPressed: () {

                            setState(() {

                              isHidden = !isHidden;
                            });
                          },

                          icon: Icon(

                            isHidden
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,

                            color: AppColors.textGrey,
                            size: 20.sp,
                          ),
                        ),

                        hintText: "PIN",
                        hintStyle: AppText.hint(),

                        border: InputBorder.none,

                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 15.h,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // LOGIN BUTTON
                  Obx(
                        () => AppButton(

                      text: controller.isLoading.value
                          ? "Please Wait..."
                          : "Login",

                      color: AppColors.textGreen,
                      textColor: Colors.white,

                      width: double.infinity,
                      height: 52.h,

                      icon: Icons.login,

                      onTap: () {

                        controller.loginUser(

                          phone: mobileCtrl.text.trim(),

                          password: passCtrl.text.trim(),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 5.h),

                  // REGISTER BUTTON
                  AppButton(
                    text: "Don't have an account",

                    color: AppColors.textGreen.withOpacity(0.2),
                    textColor: Colors.white,

                    width: double.infinity,
                    height: 30.h,

                    icon: Icons.app_registration,

                    onTap: () {

                      Get.to(
                            () => const RegisterScreen(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}