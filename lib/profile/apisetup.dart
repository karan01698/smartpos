import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../poscalculator/constant/apptext.dart';
import '../poscalculator/constant/colors.dart';
import '../widget/button.dart';

class ApiSetupScreen extends StatelessWidget {
  const ApiSetupScreen({super.key});

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

              SizedBox(height: 10.h),

              // TOP BAR
              Row(
                children: [

                  InkWell(
                    borderRadius: BorderRadius.circular(10.r),
                    onTap: () {
                      Navigator.pop(context);
                    },

                    child: Padding(
                      padding: EdgeInsets.all(6.w),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 22.sp,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),

                  SizedBox(width: 6.w),

                  Text(
                    "API Setup",
                    style: AppText.pageTitle(),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // MAIN CARD
              Expanded(
                child: Container(
                  width: double.infinity,

                  padding: EdgeInsets.all(16.w),

                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(20.r),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),

                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // HEADER BOX
                        Container(
                          width: double.infinity,

                          padding: EdgeInsets.all(14.w),

                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF2FF),
                            borderRadius: BorderRadius.circular(16.r),

                            border: Border.all(
                              color: const Color(0xFFD5E3FF),
                            ),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Row(
                                children: [

                                  Icon(
                                    Icons.send_rounded,
                                    color: AppColors.textBlue,
                                    size: 18.sp,
                                  ),

                                  SizedBox(width: 8.w),

                                  Text(
                                    "WhatsApp API Config",
                                    style: AppText.staffName().copyWith(
                                      color: AppColors.textBlue,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 6.h),

                              Text(
                                "Connect your auto-messaging Webhooks here. Bills will be sent automatically.",
                                style: AppText.bodyRegular(),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 18.h),

                        // WEBHOOK FIELD
                        _buildField(
                          hint: "API Webhook URL (https://...)",
                          icon: Icons.link_rounded,
                        ),

                        SizedBox(height: 14.h),

                        // TOKEN FIELD
                        _buildField(
                          hint: "Bearer Token / API Key",
                          icon: Icons.key_rounded,
                        ),

                        SizedBox(height: 22.h),

                        // LABEL
                        Text(
                          "MESSAGE TEMPLATE",
                          style: AppText.cardLabel().copyWith(
                            fontSize: 12.sp,
                          ),
                        ),

                        SizedBox(height: 10.h),

                        // TEMPLATE BOX
                        Container(
                          width: double.infinity,
                          height: 250.h,

                          padding: EdgeInsets.all(14.w),

                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(16.r),

                            border: Border.all(
                              color: const Color(0xFFE4E4E4),
                            ),
                          ),

                          child: TextField(
                            maxLines: null,
                            expands: true,

                            style: AppText.fieldValue(),

                            decoration: InputDecoration(
                              border: InputBorder.none,

                              hintText:
                              "✨ Subtotal: ₹{{subtotal}}\n🎁 Discount: ₹{{discount}}\n✅ Total Amount: ₹{{totalAmount}}\n💳 Payment Mode: {{paymentMode}}\n\n🙏 Thank you for shopping with us!\n📍 Visit again: {{shopAddress}}\n📞 Order on WhatsApp: {{ownerPhone}}\n\n🌿 Pure & Healthy Oils for your Family",

                              hintStyle: AppText.hint().copyWith(
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 10.h),

                        Text(
                          "Variables: {{shopName}} {{ownerName}} {{phone}} {{billNo}} {{items}} {{subtotal}} {{discount}} {{totalAmount}} {{paymentMode}} {{shopAddress}} {{ownerPhone}}",
                          style: AppText.bodyRegular().copyWith(
                            fontSize: 10.sp,
                          ),
                        ),

                        SizedBox(height: 26.h),

                        // SAVE BUTTON
                        AppButton(
                          text: "Save Configuration",

                          color: AppColors.textBlue,
                          textColor: Colors.white,

                          height: 54.h,

                          icon: Icons.save_rounded,

                          onTap: () {

                          },
                        ),
                      ],
                    ),
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

  Widget _buildField({
    required String hint,
    required IconData icon,
  }) {
    return Container(
      height: 54.h,

      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14.r),

        border: Border.all(
          color: const Color(0xFFE4E4E4),
        ),
      ),

      child: TextField(
        style: AppText.fieldValue(),

        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: AppColors.textGrey,
            size: 20.sp,
          ),

          hintText: hint,
          hintStyle: AppText.hint(),

          border: InputBorder.none,

          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 15.h,
          ),
        ),
      ),
    );
  }
}