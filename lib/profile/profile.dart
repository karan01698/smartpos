import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartpos/profile/party.dart';
import 'package:smartpos/profile/setting.dart';
import 'package:smartpos/profile/terms&condtions.dart';

import '../authstoreage/authstorage.dart';
import '../backend/showapi.dart';
import '../dashboard/careports.dart';
import '../dashboard/sbuscriptions.dart';
import '../poscalculator/constant/colors.dart';
import '../widget/button.dart';
import '../widget/livesupport.dart';
import '../widget/popup.dart';
import 'apisetup.dart';
import 'device.dart';
import 'inventories.dart';


class ProfileScreen extends StatefulWidget {


  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserController controller =
  Get.put(UserController());

  @override
  void initState() {
    super.initState();

    loadUser();
  }

  void loadUser() async {

    String? phone =
    await AuthStorage.getEmail();

    if(phone != null){

      controller.getUser(
        phone: phone,
      );
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              SizedBox(height: 16.h),
              _buildShopCard(),
              SizedBox(height: 24.h),
              _buildSectionLabel('MANAGEMENT'),
              SizedBox(height: 12.h),
              _buildManagementGrid(),
              SizedBox(height: 24.h),
              _buildSectionLabel('OTHERS'),
              SizedBox(height: 8.h),
              _buildOthersSection(),
              SizedBox(height: 8.h),
              Center(
                child: AppButton(
                  text: "Log Out",
                  color: Colors.red,
                  textColor: Colors.white,

                  width: 300.w,
                  height: 50.h,

                  icon: Icons.logout_rounded,
                  onTap: () {
                    LogoutPopup.show(
                      context: context,

                      onYes: () {
                        // Logout code here

                        // Example:
                        // Get.offAll(() => LoginScreen());

                        print("Logged Out");
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top Bar ──────────────────────────────────
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Menu',
          style: GoogleFonts.poppins(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        // Container(
        //   padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        //   decoration: BoxDecoration(
        //     color: AppColors.cardWhite,
        //     borderRadius: BorderRadius.circular(20.r),
        //     border: Border.all(color: const Color(0xFFDDE3EE)),
        //   ),
        //   child: Row(
        //     children: [
        //       Icon(Icons.translate_rounded,
        //           size: 14.sp, color: AppColors.textGreen),
        //       SizedBox(width: 4.w),
        //       Text(
        //         'हिंदी में करें',
        //         style: GoogleFonts.poppins(
        //           fontSize: 11.sp,
        //           fontWeight: FontWeight.w500,
        //           color: AppColors.textDark,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  // ── Shop Card ─────────────────────────────────
  Widget _buildShopCard() {

    return Obx(() {

      final user = controller.userData;

      String name =
          user["Name"]?.toString() ?? "";

      String phone =
          user["Phone"]?.toString() ?? "";

      String image =
          user["ShopImg"]?.toString() ?? "";

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 14.h,
        ),

        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(14.r),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        child: Row(
          children: [

            // 🔥 IMAGE / LOADER / ICON
            Container(
              width: 50.w,
              height: 50.w,

              decoration: BoxDecoration(
                color: AppColors.cardGreen,
                shape: BoxShape.circle,
              ),

              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(100.r),

                child: controller.isLoading.value

                // 🔥 ONLY CIRCLE LOADER
                    ? Center(
                  child: SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textGreen,
                    ),
                  ),
                )

                    : image.isNotEmpty

                    ? Image.network(

                  "http://smartpos.anklegaming.biz/image/$image",

                  fit: BoxFit.cover,

                  errorBuilder:
                      (context, error, stackTrace) {

                    return Icon(
                      Icons.person,
                      color: AppColors.textGreen,
                      size: 28.sp,
                    );
                  },
                )

                    : Icon(
                  Icons.person,
                  color: AppColors.textGreen,
                  size: 28.sp,
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // 🔥 NAME + PHONE
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(
                    controller.isLoading.value
                        ? "Loading..."
                        : name,

                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),

                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 2.h),

                  Text(
                    controller.isLoading.value
                        ? "Please wait..."
                        : phone,

                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),

            // 🔥 EDIT BUTTON
            // InkWell(
            //   borderRadius:
            //   BorderRadius.circular(10.r),
            //
            //   onTap: () {},
            //
            //   child: Container(
            //     width: 34.w,
            //     height: 34.w,
            //
            //     decoration: BoxDecoration(
            //       color: AppColors.cardWhite,
            //       borderRadius:
            //       BorderRadius.circular(10.r),
            //
            //       boxShadow: [
            //         BoxShadow(
            //           color:
            //           Colors.white.withOpacity(0.9),
            //           offset: const Offset(-2, -2),
            //           blurRadius: 6,
            //         ),
            //
            //         BoxShadow(
            //           color:
            //           Colors.black.withOpacity(0.08),
            //           offset: const Offset(2, 2),
            //           blurRadius: 6,
            //         ),
            //       ],
            //     ),
            //
            //     child: Center(
            //       child: Icon(
            //         Icons.edit_outlined,
            //         size: 18.sp,
            //         color: AppColors.textGrey,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    });
  }

  // ── Section Label ─────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.sectionLabel,
        letterSpacing: 1.0,
      ),
    );
  }

  // ── Management Grid ───────────────────────────
  Widget _buildManagementGrid() {
    final List<_MenuItem> items = [
      _MenuItem(
          icon: Icons.storefront_outlined,
          label: 'Settings',
          color: AppColors.icon,
          onTap: () {
      Get.to(() =>  ControlSettingsScreen());
    },
      ),


      // _MenuItem(
      //     icon: Icons.send_outlined,
      //     label: 'API Setup',
      //     color: AppColors.icon,
      //   onTap: () {
      //     Get.to(() => const ApiSetupScreen());
      //   },
      // ),
      // _MenuItem(
      //     icon: Icons.devices_outlined,
      //     label: 'Devices',
      //     color: AppColors.icon,
      //   onTap: () {
      //     Get.to(() => const ConnectedDevicesScreen());
      //   },
      //
      // ),
      _MenuItem(
          icon: Icons.people_outline,
          label: 'Party',
          color: AppColors.textGreen,
          isHighlighted: true,
        onTap: () {
          Get.to(() => const PartyTabBarScreen ());
        },
      ),
      _MenuItem(
          icon: Icons.description_outlined,
          label: 'CA Reports',
          color: AppColors.icon,
        onTap: () {
          Get.to(() => const CaTaxReportsScreen());
        },
      ),
      _MenuItem(
          icon: Icons.inventory_2_outlined,
          label: 'Inventory',
          color: AppColors.icon,
        onTap: () {
          Get.to(() => const InventoryScreen());
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildMenuCard(items[index]),
    );
  }

  Widget _buildMenuCard(_MenuItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),

        // 👇 YE IMPORTANT HAI
        onTap: item.onTap,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 26.sp,
              color: item.color,
            ),

            SizedBox(height: 6.h),

            Text(
              item.label,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: item.isHighlighted
                    ? FontWeight.w600
                    : FontWeight.w500,
                color: item.isHighlighted
                    ? AppColors.textGreen
                    : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Others Section ────────────────────────────
  Widget _buildOthersSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOthersRow(
            icon: Icons.headset_mic_outlined,
            label: 'Live Support',
            isFirst: true,

            onTap: () {

              LiveSupportService.openWhatsApp(

                number: "9079073800",

                message:
                "Hello 👋\nHow may we help you?",
              );
            },
          ),

          Divider(
              height: 1,
              thickness: 0.5,
              indent: 16.w,
              endIndent: 16.w,
              color: const Color(0xFFEEEEEE)),
          _buildOthersRow(
            icon: Icons.settings_outlined,
            label: 'Control Settings',
            isLast: true,
            onTap: () {
              Get.to(() => ControlSettingsScreen ());
            },

          ),
          // _buildOthersRow(
          //   icon: Icons.workspace_premium_rounded,
          //   label: 'Rate Us',
          //   isFirst: true,
          //   onTap: () {
          //     Get.to(() => const ());
          //   },
          // ),
          Divider(
              height: 1,
              thickness: 0.5,
              indent: 16.w,
              endIndent: 16.w,
              color: const Color(0xFFEEEEEE)),
          _buildOthersRow(
            icon: Icons.description_outlined,
            label: 'Terms & Conditions',
            isLast: true,
            onTap: () {
              Get.to(() => TermsConditionScreen ());
            },

          ),
          _buildOthersRow(
            icon: Icons.card_giftcard_rounded,
            label: 'Refer & Earn',
            isFirst: true,

            onTap: () {

            },
          ),
          _buildOthersRow(
            icon: Icons.card_giftcard_rounded,
            label: 'Subscription',
            isFirst: true,

            onTap: () {
              Get.to(SubscriptionScreen());

            },
          ),



        ],
      ),
    );
  }

  Widget _buildOthersRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? Radius.circular(14.r) : Radius.zero,
        bottom: isLast ? Radius.circular(14.r) : Radius.zero,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: AppColors.textGrey),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20.sp, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────
class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isHighlighted = false,
  });
}

// ─────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────
