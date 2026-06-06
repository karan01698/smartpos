import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

import '../backend/registerapi.dart';
import '../poscalculator/constant/apptext.dart';
import '../poscalculator/constant/colors.dart';
import '../widget/snakbar.dart';
import 'authstorage.dart';

// ─────────────────────────────────────────────
// REGISTER SCREEN
// ─────────────────────────────────────────────
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl        = TextEditingController();
  final _shopNameCtrl    = TextEditingController();
  final _mobileCtrl      = TextEditingController();
  final _passCtrl        = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _address1Ctrl    = TextEditingController();
  final RegisterController controller = Get.put(RegisterController());

  bool _passVisible        = false;
  bool _confirmPassVisible = false;
  bool _loading            = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _shopNameCtrl.dispose();
    _mobileCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _address1Ctrl.dispose();

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.scaffold,
            useMaterial3: true,
          ),
          home: Scaffold(
            backgroundColor: AppColors.scaffold,
            body: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 100.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── HEADER ──────────────────────────────────────
                          SizedBox(height: 12.h),
                          Text(
                            'Create Account',
                            style: AppText.pageTitle(),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Register your shop on SmartPOS',
                            style: AppText.bodyRegular(),
                          ),
                          SizedBox(height: 28.h),

                          // ── SECTION: Personal Info ───────────────────────
                          _sectionLabel('PERSONAL INFO'),
                          SizedBox(height: 10.h),
                          _buildField(
                            controller: _nameCtrl,
                            hint: 'Your Full Name',
                            icon: Icons.person_outline_rounded,
                            validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Name required' : null,
                          ),
                          SizedBox(height: 10.h),
                          _buildField(
                            controller: _mobileCtrl,
                            hint: 'Mobile Number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Mobile required';
                              if (v.length < 10) return 'Enter valid 10-digit mobile';
                              return null;
                            },
                          ),
                          SizedBox(height: 24.h),

                          // ── SECTION: Shop Info ───────────────────────────
                          _sectionLabel('SHOP DETAILS'),
                          SizedBox(height: 10.h),
                          _buildField(
                            controller: _shopNameCtrl,
                            hint: 'Shop / Business Name',
                            icon: Icons.storefront_outlined,
                            validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Shop name required' : null,
                          ),
                          SizedBox(height: 10.h),
                          _buildField(
                            controller: _address1Ctrl,
                            hint: 'Enter Your Shop Address',
                            icon: Icons.location_on_outlined,
                            validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Address required' : null,
                          ),
                          SizedBox(height: 10.h),

                          SizedBox(height: 24.h),

                          // ── SECTION: Security ────────────────────────────
                          _sectionLabel('SECURITY'),
                          SizedBox(height: 10.h),
                          _buildPasswordField(
                            controller: _passCtrl,
                            hint: 'Enter Your Pin Number',
                            visible: _passVisible,
                            onToggle: () =>
                                setState(() => _passVisible = !_passVisible),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Password required';
                              if (v.length < 6) return 'Min 6 characters';
                              return null;
                            },
                          ),
                          SizedBox(height: 10.h),
                          _buildPasswordField(
                            controller: _confirmPassCtrl,
                            hint: 'Confirm Pin Number',
                            visible: _confirmPassVisible,
                            onToggle: () => setState(
                                  () => _confirmPassVisible = !_confirmPassVisible,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Please confirm password';
                              if (v != _passCtrl.text) return 'Passwords do not match';
                              return null;
                            },
                          ),
                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                  ),

                  // ── REGISTER BUTTON (sticky bottom) ─────────────────────
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: AppColors.scaffold,
                      padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                      child: Obx(
                            () => GestureDetector(

                          onTap: controller.isLoading.value
                              ? null
                              : () {

                            if (_formKey.currentState!.validate()) {

                              controller.registerUser(

                                name: _nameCtrl.text.trim(),

                                shopName: _shopNameCtrl.text.trim(),

                                address: _address1Ctrl.text.trim(),

                                phone: _mobileCtrl.text.trim(),

                                password: _passCtrl.text.trim(),
                              );
                            }
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
                              borderRadius: BorderRadius.circular(12.r),
                            ),

                            child: Center(

                              child: controller.isLoading.value

                                  ? SizedBox(
                                width: 22.w,
                                height: 22.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )

                                  : Text(
                                'Create Account',
                                style: AppText.saveBtn(),
                              ),
                            ),
                          ),
                        ),
                      )
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Section Label ─────────────────────────────
  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 10.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.sectionLabel,
        letterSpacing: 1.0,
      ),
    );
  }

  // ── Normal Input Field ────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: AppText.fieldValue(),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppText.hint(),
        prefixIcon: Icon(icon, size: 18.sp, color: AppColors.textGrey),
        counterText: '',
        filled: true,
        fillColor: AppColors.cardWhite,
        contentPadding:
        EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.inputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.inputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.textGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  // ── Password Field ────────────────────────────
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool visible,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      style: AppText.fieldValue(),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppText.hint(),
        prefixIcon:
        Icon(Icons.lock_outline_rounded, size: 18.sp, color: AppColors.textGrey),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            visible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 18.sp,
            color: AppColors.textGrey,
          ),
        ),
        filled: true,
        fillColor: AppColors.cardWhite,
        contentPadding:
        EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.inputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.inputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.textGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}