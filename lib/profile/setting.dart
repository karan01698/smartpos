import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../authstoreage/authstorage.dart';
import '../backend/showapi.dart';
import '../backend/update.dart';
import '../poscalculator/constant/apptext.dart';
import '../poscalculator/constant/colors.dart';
import '../widget/snakbar.dart';

// ─────────────────────────────────────────────
// COLORS (same as previous)


// ─────────────────────────────────────────────
// TEXT STYLES (same as previous)
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
// CONTROL SETTINGS SCREEN
// ─────────────────────────────────────────────
class ControlSettingsScreen extends StatefulWidget {
  const ControlSettingsScreen({super.key});

  @override
  State<ControlSettingsScreen> createState() => _ControlSettingsScreenState();
}

class _ControlSettingsScreenState extends State<ControlSettingsScreen> {
  final UserController userController =
  Get.put(UserController());

  final UpdateProfileController updateController =
  Get.put(UpdateProfileController());
  bool isPinHide = true;
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _gstCtrl =
  TextEditingController();
  String oldImageName = "";
  final _fissCtrl =
  TextEditingController();

  final _shopCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _upiCtrl = TextEditingController();
  File? selectedImage;

  final ImagePicker picker =
  ImagePicker();
  String _selectedRole = 'Staff';
  Future<String> convertImageToBase64(
      File imageFile,
      ) async {

    List<int> imageBytes =
    await imageFile.readAsBytes();

    return base64Encode(imageBytes);
  }
  // 🔥 REPLACE pickImage()

  Future<void> pickImage() async {

    showModalBottomSheet(

      context: context,

      builder: (context) {

        return SafeArea(

          child: Wrap(
            children: [

              ListTile(

                leading:
                const Icon(Icons.camera_alt),

                title: const Text("Camera"),

                onTap: () async {

                  Navigator.pop(context);

                  final XFile? image =
                  await picker.pickImage(

                    source: ImageSource.camera,

                    // 🔥 QUALITY LOW
                    imageQuality: 25,
                  );

                  if(image != null){

                    selectedImage =
                        File(image.path);

                    // 🔥 BASE64
                    imageName =
                    await convertImageToBase64(
                      selectedImage!,
                    );

                    setState(() {});
                  }
                },
              ),

              ListTile(

                leading:
                const Icon(Icons.photo),

                title: const Text("Gallery"),

                onTap: () async {

                  Navigator.pop(context);

                  final XFile? image =
                  await picker.pickImage(

                    source: ImageSource.gallery,

                    // 🔥 QUALITY LOW
                    imageQuality: 25,
                  );

                  if(image != null){

                    selectedImage =
                        File(image.path);

                    // 🔥 BASE64
                    imageName =
                    await convertImageToBase64(
                      selectedImage!,
                    );

                    setState(() {});
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
  // 🔥 IMAGE
  String imageName = "";
  String imageUrl = "";

  @override
  void initState() {
    super.initState();

    loadUser();
  }

  Future<void> loadUser() async {
    Future<String> networkImageToBase64(String imageUrl) async {

      final bytes =
      await NetworkAssetBundle(Uri.parse(imageUrl))
          .load(imageUrl);

      return base64Encode(
        bytes.buffer.asUint8List(),
      );
    }

    String? phone =
    await AuthStorage.getEmail();

    if(phone != null){

      await userController.getUser(
        phone: phone,
      );

      final user =
          userController.userData;

      _nameCtrl.text =
          user["Name"]?.toString() ?? "";

      _shopCtrl.text =
          user["ShopName"]?.toString() ?? "";

      _addressCtrl.text =
          user["Address"]?.toString() ?? "";

      _mobileCtrl.text =
          user["Phone"]?.toString() ?? "";
      _gstCtrl.text =
          user["Gst"]?.toString() ?? "";

      _fissCtrl.text =
          user["Fiss"]?.toString() ?? "";

      _pinCtrl.text =
          user["Password"]?.toString() ?? "";

      _upiCtrl.text =
          user["UpiID"]?.toString() ?? "";

      imageName =
          user["ShopImg"]?.toString() ?? "";
      oldImageName = imageName;

      imageUrl =
      "http://smartpos.anklegaming.biz/image/$imageName";
      if(imageName.isNotEmpty){

        imageName =
        await networkImageToBase64(imageUrl);
      }

      setState(() {});
    }
  }

  @override
  void dispose() {
    _gstCtrl.dispose();

    _fissCtrl.dispose();
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _pinCtrl.dispose();

    _shopCtrl.dispose();
    _addressCtrl.dispose();
    _upiCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 16.h,
                bottom: 100.h, // space for bottom button
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildManageStaffCard(),
                  SizedBox(height: 16.h),
                  // _buildPrinterSettingsCard(),
                  SizedBox(height: 16.h),
                  _buildShopDetailsCard(),
                ],
              ),
            ),
            _buildSaveButton(),
          ],
        ),

    );
  }

  // ── AppBar ────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.scaffold,
      elevation: 0,
      leadingWidth: 50.w,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.textDark, size: 20.sp),
        onPressed: () {
          Navigator.pop(
            context,
            true,
          );
        },
      ),
      title: Text('Control Settings', style: AppText.pageTitle()),
      // actions: [
      //   Container(
      //     margin: EdgeInsets.only(right: 12.w),
      //     padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      //     decoration: BoxDecoration(
      //       color: AppColors.cardWhite,
      //       borderRadius: BorderRadius.circular(20.r),
      //       border: Border.all(color: AppColors.filterBorder),
      //     ),
      //     child: Row(
      //       children: [
      //         // Icon(Icons.translate_rounded,
      //         //     size: 13.sp, color: AppColors.textGreen),
      //         // SizedBox(width: 4.w),
      //         // Text(
      //         //   'हिंदी में करें',
      //         //   style: GoogleFonts.poppins(
      //         //     fontSize: 11.sp,
      //         //     fontWeight: FontWeight.w500,
      //         //     color: AppColors.textDark,
      //         //   ),
      //         // ),
      //       ],
      //     ),
      //   ),
      // ],
    );
  }

  // ── MANAGE STAFF Card ─────────────────────────
  Widget _buildManageStaffCard() {
    return _SectionCard(
      icon: Icons.manage_accounts_outlined,
      title: 'MANAGE STAFF',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          // Name field
          _InputField(controller: _nameCtrl, hint: 'Name'),
          SizedBox(height: 8.h),
          // Mobile + PIN row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _InputField(controller: _mobileCtrl, hint: 'Mobile'),
              ),
              SizedBox(width: 8.w),
              // 🔥 REPLACE THIS PIN FIELD

              Expanded(
                flex: 2,

                child: TextField(

                  controller: _pinCtrl,

                  keyboardType: TextInputType.number,

                  obscureText: isPinHide,

                  style: AppText.fieldValue(),

                  decoration: InputDecoration(

                    hintText: "PIN",

                    hintStyle: AppText.hint(),

                    filled: true,

                    fillColor: AppColors.scaffold,

                    contentPadding:
                    EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),

                    // 🔥 EYE ICON
                    suffixIcon: IconButton(

                      onPressed: () {

                        setState(() {

                          isPinHide = !isPinHide;
                        });
                      },

                      icon: Icon(

                        isPinHide
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,

                        color: AppColors.textGrey,
                        size: 20.sp,
                      ),
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(8.r),

                      borderSide: BorderSide(
                        color: AppColors.inputBorder,
                        width: 1,
                      ),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(8.r),

                      borderSide: BorderSide(
                        color: AppColors.inputBorder,
                        width: 1,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(8.r),

                      borderSide: BorderSide(
                        color: AppColors.textGreen,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Role dropdown + Add button
          // Row(
          //   children: [
          //     Expanded(child: _RoleDropdown(
          //       value: _selectedRole,
          //       onChanged: (v) => setState(() => _selectedRole = v ?? 'Staff'),
          //     )),
          //     SizedBox(width: 8.w),
          //     _AddButton(),
          //   ],
          // ),

          // Staff entry
        ],
      ),
    );
  }

  // ── PRINTER SETTINGS Card ─────────────────────
  // Widget _buildPrinterSettingsCard() {
  //   return _SectionCard(
  //     icon: Icons.print_outlined,
  //     title: 'PRINTER SETTINGS',
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         SizedBox(height: 12.h),
  //         Text(
  //           'RECEIPT PAPER SIZE',
  //           style: GoogleFonts.poppins(
  //             fontSize: 10.sp,
  //             fontWeight: FontWeight.w700,
  //             color: AppColors.sectionLabel,
  //             letterSpacing: 0.8,
  //           ),
  //         ),
  //         SizedBox(height: 6.h),
  //         _DropdownField(value: '2 Inch (58mm) - Normal'),
  //         SizedBox(height: 6.h),
  //         Text(
  //           'Select your thermal printer paper size so bills print perfectly.',
  //           style: AppText.bodyRegular(),
  //         ),
  //         SizedBox(height: 4.h),
  //       ],
  //     ),
  //   );
  // }

  // ── SHOP DETAILS Card ─────────────────────────
  // 🔥 REPLACE FULL _buildShopDetailsCard()

  Widget _buildShopDetailsCard() {

    return _SectionCard(

      icon: Icons.storefront_outlined,
      title: 'SHOP DETAILS',

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          SizedBox(height: 12.h),

          // 🔥 SHOP NAME
          _InputField(
            controller: _shopCtrl,
            hint: 'Shop Name',
          ),

          SizedBox(height: 8.h),

          // 🔥 ADDRESS
          _InputField(
            controller: _addressCtrl,
            hint: 'Address',
          ),

          SizedBox(height: 8.h),

          // 🔥 UPI
          _InputField(
            controller: _upiCtrl,
            hint: 'Enter UPI ID',
          ),
          SizedBox(height: 8.h),

          _InputField(
            controller: _gstCtrl,
            hint: 'Enter GST Number',
          ),

          SizedBox(height: 8.h),

          _InputField(
            controller: _fissCtrl,
            hint: 'Enter FSSAI Number',
          ),
          SizedBox(height: 14.h),

          // ───────────────── SHOP LOGO ONLY ─────────────────

          Column(

            children: [

              Text(

                'SHOP LOGO',

                style: GoogleFonts.poppins(

                  fontSize: 10.sp,

                  fontWeight: FontWeight.w700,

                  color: AppColors.sectionLabel,

                  letterSpacing: 0.8,
                ),
              ),

              SizedBox(height: 10.h),

              GestureDetector(

                onTap: () {

                  pickImage();
                },

                child: Container(

                  width: 100.w,

                  height: 100.h,

                  decoration: BoxDecoration(

                    color: AppColors.scaffold,

                    borderRadius:
                    BorderRadius.circular(14.r),

                    border: Border.all(
                      color: AppColors.inputBorder,
                    ),
                  ),

                  child: ClipRRect(

                    borderRadius:
                    BorderRadius.circular(14.r),

                    child:

                    selectedImage != null

                        ? Image.file(

                      selectedImage!,

                      fit: BoxFit.cover,
                    )

                        : imageName.isNotEmpty

                        ? Image.network(

                      imageUrl,

                      fit: BoxFit.cover,

                      loadingBuilder:
                          (
                          context,
                          child,
                          progress,
                          ) {

                        if (progress == null) {
                          return child;
                        }

                        return Center(

                          child:
                          CircularProgressIndicator(
                            color:
                            AppColors.textGreen,
                          ),
                        );
                      },

                      errorBuilder:
                          (
                          context,
                          error,
                          stackTrace,
                          ) {

                        return Icon(

                          Icons.store,

                          size: 40.sp,

                          color:
                          AppColors.textGrey,
                        );
                      },
                    )

                        : Icon(

                      Icons.store,

                      size: 40.sp,

                      color:
                      AppColors.textGrey,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              Text(

                selectedImage != null

                    ? "Logo Selected"

                    : "Tap Logo",

                style: GoogleFonts.poppins(

                  fontSize: 11.sp,

                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),





          // 🔥 IMAGE SHOW


          SizedBox(height: 14.h),
        ],
      ),
    );
  }

  // ── Save Button (sticky bottom) ───────────────
// 🔥 REPLACE FULL _buildSaveButton()

  Widget _buildSaveButton() {

    return Positioned(

      left: 0,
      right: 0,
      bottom: 0,

      child: Container(

        color: AppColors.scaffold,

        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),

        child: Obx(
              () => GestureDetector(

            onTap: () {

              updateController.updateProfile(

                name: _nameCtrl.text.trim(),

                shopName:
                _shopCtrl.text.trim(),

                address:
                _addressCtrl.text.trim(),

                phone:
                _mobileCtrl.text.trim(),

                password:
                _pinCtrl.text.trim(),

                upiID:
                _upiCtrl.text.trim(),

                // 🔥 SAME IMAGE
                shopImg: selectedImage != null
                    ? imageName
                    : "", Gst: _gstCtrl.text.trim(), Fiss: _fissCtrl.text.trim(), QrImg: '',
              );
            },

            child: Container(

              width: double.infinity,
              height: 50.h,

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.buttonColor,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),

                borderRadius:
                BorderRadius.circular(12.r),
              ),

              child: Center(

                child:
                updateController.isLoading.value

                    ? SizedBox(
                  width: 22.w,
                  height: 22.w,

                  child:
                  const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )

                    : Text(
                  'Save All Settings',
                  style: AppText.saveBtn(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: AppColors.icon),
              SizedBox(width: 6.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.sectionLabel,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool obscure;

  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: AppText.fieldValue(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppText.hint(),
        filled: true,
        fillColor: AppColors.scaffold,
        contentPadding:
        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.inputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.inputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.textGreen, width: 1.5),
        ),
      ),
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _RoleDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      height: 44.h,
      decoration: BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: AppText.fieldValue(),
          icon: Icon(Icons.unfold_more_rounded,
              size: 18.sp, color: AppColors.textGrey),
          items: ['Staff', 'Admin', 'Manager']
              .map((r) => DropdownMenuItem(
            value: r,
            child: Text(r, style: AppText.fieldValue()),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: AppColors.textGreen,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            'Add',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textWhite,
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String value;

  const _DropdownField({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      height: 44.h,
      decoration: BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: AppText.fieldValue()),
          Icon(Icons.unfold_more_rounded,
              size: 18.sp, color: AppColors.textGrey),
        ],
      ),
    );
  }
}

class _StaticField extends StatelessWidget {
  final String value;
  final int maxLines;

  const _StaticField({required this.value, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Text(
        value,
        style: AppText.fieldValue(),
        maxLines: maxLines,
      ),
    );
  }
}

class _FilePickerField extends StatelessWidget {
  const _FilePickerField();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          Container(
            padding:
            EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Text(
              'Choose File',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Text('no file selected', style: AppText.hint()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────
void main() {
  runApp(const ControlSettingsScreen());
}