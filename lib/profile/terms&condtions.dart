import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../backend/showforms.dart';
import '../poscalculator/constant/apptext.dart';
import '../poscalculator/constant/colors.dart';
import '../widget/button.dart';

/// ================= CONTROLLER =================



/// ================= SCREEN =================

class TermsConditionScreen
    extends StatefulWidget {

  const TermsConditionScreen({
    super.key,
  });

  @override
  State<TermsConditionScreen>
  createState() =>
      _TermsConditionScreenState();
}

class _TermsConditionScreenState
    extends State<TermsConditionScreen> {

  final TermsController controller =
  Get.put(TermsController());

  @override
  void initState() {
    super.initState();

    /// API CALL
    controller.fetchTerms();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      AppColors.scaffold,

      body: SafeArea(

        child: Padding(

          padding:
          EdgeInsets.symmetric(
            horizontal: 16.w,
          ),

          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              SizedBox(height: 10.h),

              /// TOP BAR
              Row(

                children: [

                  InkWell(

                    borderRadius:
                    BorderRadius.circular(
                      10.r,
                    ),

                    onTap: () {
                      Navigator.pop(context);
                    },

                    child: Padding(

                      padding:
                      EdgeInsets.all(6.w),

                      child: Icon(

                        Icons.arrow_back_rounded,

                        size: 22.sp,

                        color:
                        AppColors.textDark,
                      ),
                    ),
                  ),

                  SizedBox(width: 6.w),

                  Text(

                    "Terms & Conditions",

                    style:
                    AppText.pageTitle(),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              /// MAIN CARD
              Expanded(

                child: Container(

                  width: double.infinity,

                  padding:
                  EdgeInsets.all(16.w),

                  decoration: BoxDecoration(

                    color:
                    AppColors.cardWhite,

                    borderRadius:
                    BorderRadius.circular(
                      20.r,
                    ),

                    boxShadow: [

                      BoxShadow(

                        color: Colors.black
                            .withOpacity(0.05),

                        blurRadius: 12,

                        offset:
                        const Offset(0, 5),
                      ),
                    ],
                  ),

                  child: Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      /// HEADER
                      Container(

                        width: double.infinity,

                        padding:
                        EdgeInsets.all(14.w),

                        decoration: BoxDecoration(

                          color:
                          const Color(0xFFEAF8EF),

                          borderRadius:
                          BorderRadius.circular(
                            16.r,
                          ),

                          border: Border.all(
                            color:
                            const Color(
                              0xFFD7F1E1,
                            ),
                          ),
                        ),

                        child: Row(

                          children: [

                            Container(

                              width: 42.w,
                              height: 42.w,

                              decoration:
                              BoxDecoration(

                                color:
                                AppColors.cardGreen,

                                borderRadius:
                                BorderRadius.circular(
                                  12.r,
                                ),
                              ),

                              child: Center(

                                child: Icon(

                                  Icons.gavel_rounded,

                                  color:
                                  AppColors.textGreen,

                                  size: 22.sp,
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

                                    "Terms & Conditions",

                                    style:
                                    AppText.staffName(),
                                  ),

                                  SizedBox(height: 2.h),

                                  Text(

                                    "Manage business policies & legal terms.",

                                    style:
                                    AppText.bodyRegular(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      Text(

                        "TERMS CONTENT",

                        style:
                        AppText.cardLabel()
                            .copyWith(
                          fontSize: 12.sp,
                        ),
                      ),

                      SizedBox(height: 10.h),

                      /// TEXT AREA
                      Expanded(

                        child: Container(

                          width: double.infinity,

                          padding:
                          EdgeInsets.all(14.w),

                          decoration:
                          BoxDecoration(

                            color:
                            const Color(
                              0xFFF7F7F7,
                            ),

                            borderRadius:
                            BorderRadius.circular(
                              16.r,
                            ),

                            border: Border.all(
                              color:
                              const Color(
                                0xFFE4E4E4,
                              ),
                            ),
                          ),

                          child: Obx(() {

                            if(controller
                                .isLoading
                                .value){

                              return const Center(
                                child:
                                CircularProgressIndicator(),
                              );
                            }

                            return TextField(

                              controller:
                              controller
                                  .termsCtrl,

                              maxLines: null,

                              expands: true,

                              style:
                              AppText.fieldValue()
                                  .copyWith(
                                height: 1.6,
                              ),

                              decoration:
                              InputDecoration(

                                border:
                                InputBorder.none,

                                hintText:
                                "No Data Found",

                                hintStyle:
                                AppText.hint()
                                    .copyWith(
                                  height: 1.7,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      /// BUTTON
                      AppButton(

                        text: "Save Terms",

                        color:
                        AppColors.textGreen,

                        textColor:
                        Colors.white,

                        height: 54.h,

                        icon:
                        Icons.save_rounded,

                        onTap: () {

                          Get.snackbar(

                            "Saved",

                            "Terms Saved Successfully",

                            backgroundColor:
                            Colors.green,

                            colorText:
                            Colors.white,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 14.h),
            ],
          ),
        ),
      ),
    );
  }
}