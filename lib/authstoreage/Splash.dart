import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smartpos/authstoreage/stafflogin.dart';
import '../poscalculator/bottombar.dart';
import '../poscalculator/constant/apptext.dart';
import 'authstorage.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    checkLogin();
  }

  Future<void> checkLogin() async {

    await Future.delayed(const Duration(seconds: 3));

    bool isLoggedIn =
    await AuthStorage.isLoggedIn();

    // 🔥 IF LOGIN
    if (isLoggedIn) {

      Get.offAll(
            () => const HomeScreen(),
      );

    } else {

      // 🔥 LOGIN SCREEN
      Get.offAll(
            () => const StaffLoginScreen(),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF4ED),
      body: Stack(
        children: [
          /// TOP GLOW
          Positioned(
            top: -120.h,
            right: -80.w,
            child: Container(
              width: 260.w,
              height: 260.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.10),
              ),
            ),
          ),

          /// BOTTOM GLOW
          Positioned(
            bottom: -120.h,
            left: -80.w,
            child: Container(
              width: 260.w,
              height: 260.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.08),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// LOGO BOX
                ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.7,
                    end: 1,
                  ).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeOutBack,
                    ),
                  ),

                  child: Container(
                    height: 130.h,
                    width: 130.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.18),
                          blurRadius: 30,
                          spreadRadius: 4,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Center(
                      child: Icon(
                        Icons.point_of_sale_rounded,
                        size: 72.sp,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                /// APP NAME
                FadeTransition(
                  opacity: _controller,
                  child: Text(
                    "SmartPOS",
                    style: AppText.heading().copyWith(
                      fontSize: 32.sp,
                      color: Colors.green.shade900,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                SizedBox(height: 10.h),

                Text(
                  "Smart Billing & Business Management",
                  style: AppText.subHeading().copyWith(
                    fontSize: 12.sp,
                    color: Colors.green.shade700,
                  ),
                ),

                SizedBox(height: 40.h),

                /// LOADER
                SizedBox(
                  height: 55.h,
                  width: 55.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),

          /// VERSION
          Positioned(
            bottom: 28.h,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Version 1.0.0",
                style: AppText.bodyRegular().copyWith(
                  fontSize: 11.sp,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}