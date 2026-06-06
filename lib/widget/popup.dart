import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

import '../authstoreage/authstorage.dart';
import '../authstoreage/stafflogin.dart';

class LogoutPopup {
  static Future<void> show({
    required BuildContext context,
    required VoidCallback onYes,
  }) {
    return showGeneralDialog(
      context: context,

      barrierDismissible: true,
      barrierLabel: "Logout",

      barrierColor: Colors.black.withOpacity(0.45),

      transitionDuration: const Duration(milliseconds: 320),

      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox();
      },

      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final scale = Tween<double>(
          begin: 0.8,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
        );

        final opacity = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(animation);

        return FadeTransition(
          opacity: opacity,

          child: ScaleTransition(
            scale: scale,

            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 6,
                sigmaY: 6,
              ),

              child: Center(
                child: Material(
                  color: Colors.transparent,

                  child: Container(
                    width: 320.w,

                    padding: EdgeInsets.all(22.w),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.r),

                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.18),
                          Colors.white.withOpacity(0.08),
                        ],

                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),

                      border: Border.all(
                        color: Colors.white.withOpacity(0.22),
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Container(
                            height: 72.h,
                            width: 72.w,

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.withOpacity(0.12),
                            ),

                            child: Icon(
                              Icons.logout_rounded,
                              color: Colors.redAccent,
                              size: 34.sp,
                            ),
                          ),

                          SizedBox(height: 18.h),

                          Text(
                            "Logout",

                            style: GoogleFonts.poppins(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: 8.h),

                          Text(
                            "Do you want to logout?",

                            textAlign: TextAlign.center,

                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              color: Colors.white.withOpacity(0.78),
                              height: 1.5,
                            ),
                          ),

                          SizedBox(height: 26.h),

                          Row(
                            children: [
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,

                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16.r),

                                    onTap: () {
                                      Navigator.pop(context);
                                    },

                                    child: Container(
                                      height: 52.h,

                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(16.r),

                                        color: Colors.white.withOpacity(0.08),

                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.12),
                                        ),
                                      ),

                                      child: Center(
                                        child: Text(
                                          "No",

                                          style: GoogleFonts.poppins(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(width: 14.w),

                              Expanded(
                                child: Material(
                                  color: Colors.transparent,

                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16.r),

                                    onTap: () async{
                                      Navigator.pop(context);
                                      await AuthStorage.logout();
                                      Get.offAll(() => StaffLoginScreen());
                                      onYes();
                                    },

                                    child: Container(
                                      height: 52.h,

                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(16.r),

                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFFF5F6D),
                                            Color(0xFFFF2D55),
                                          ],
                                        ),

                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                            Colors.red.withOpacity(0.35),

                                            blurRadius: 14,

                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),

                                      child: Center(
                                        child: Text(
                                          "Yes",

                                          style: GoogleFonts.poppins(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}