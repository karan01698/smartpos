import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smartpos/poscalculator/bottombar.dart';
import 'package:smartpos/poscalculator/poscalculator.dart';

import 'authstoreage/Splash.dart';
import 'authstoreage/stafflogin.dart';

void main() {
  runApp(const SmartPOSApp());
}

const Color kBg = Color(0xFFF5F5F5);
const Color kGreen = Color(0xFF00C853);

class SmartPOSApp extends StatelessWidget {
  const SmartPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SmartPOS',

          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: kBg,

            colorScheme: ColorScheme.fromSeed(
              seedColor: kGreen,
            ),
          ),

          home: SplashScreen(),
        );
      },
    );
  }
}