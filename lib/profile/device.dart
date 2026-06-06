import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../poscalculator/constant/colors.dart';

// ─────────────────────────────────────────────
// COLORS (same as previous)

// ─────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────


// ─────────────────────────────────────────────
// CONNECTED DEVICES SCREEN
// ─────────────────────────────────────────────
class ConnectedDevicesScreen extends StatefulWidget {
  const ConnectedDevicesScreen({super.key});
  @override
  State<ConnectedDevicesScreen> createState() => _ConnectedDevicesScreenState();
}

class _ConnectedDevicesScreenState extends State<ConnectedDevicesScreen> {
  bool _scaleConnected    = false;
  bool _printerConnected  = false;
  bool _cashConnected     = false;
  bool _displayConnected  = false;

  void _showConnectDialog(String device, VoidCallback onConnect) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Connect $device',
          style: GoogleFonts.poppins(
              fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        content: Text(
          'Make sure your $device is powered on and in pairing mode.',
          style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(
                    fontSize: 13.sp, color: AppColors.textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
            onPressed: () {
              Navigator.pop(context);
              onConnect();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('$device connected successfully!'),
                backgroundColor: AppColors.textGreen,
              ));
            },
            child: Text('Connect',
                style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDisconnectDialog(String device, VoidCallback onDisconnect) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Disconnect $device',
            style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        content: Text('Are you sure you want to disconnect $device?',
            style: GoogleFonts.poppins(
                fontSize: 13.sp, color: AppColors.textGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(
                    fontSize: 13.sp, color: AppColors.textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
            onPressed: () {
              Navigator.pop(context);
              onDisconnect();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('$device disconnected.'),
                backgroundColor: AppColors.textRed,
              ));
            },
            child: Text('Disconnect',
                style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.scaffold,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark, size: 20.sp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Connected Devices',
          style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        children: [
          // ── 1. Hardware Barcode Scanner (Always Active) ──
          _DeviceCard(
            icon: Icons.qr_code_scanner_rounded,
            iconBgColor: AppColors.aiChipBg,
            iconColor: AppColors.aiChipText,
            title: 'Hardware Barcode Scanner',
            statusText: 'STATUS: ALWAYS ACTIVE',
            statusColor: AppColors.textGreen,
            isAlwaysActive: true,
            description:
            'Plug your USB or Bluetooth barcode scanner into your device. '
                'Go to the POS screen and scan any product. The item will be '
                'added automatically to the cart without any manual setup.',
          ),

          SizedBox(height: 12.h),

          // ── 2. Weighing Scale ──
          // _DeviceCard(
          //   icon: Icons.monitor_weight_outlined,
          //   iconBgColor: const Color(0xFFF0F0F0),
          //   iconColor: AppColors.textGrey,
          //   title: 'Weighing Scale',
          //   statusText: _scaleConnected ? 'Connected' : 'Not Connected',
          //   statusColor: _scaleConnected ? AppColors.textGreen : AppColors.textGrey,
          //   isAlwaysActive: false,
          //   isConnected: _scaleConnected,
          //   buttonLabel: _scaleConnected ? 'Disconnect Scale' : 'Pair New Scale',
          //   buttonColor: _scaleConnected ? AppColors.textRed : AppColors.textBlue,
          //   onButtonTap: () {
          //     if (_scaleConnected) {
          //       _showDisconnectDialog(
          //           'Weighing Scale', () => setState(() => _scaleConnected = false));
          //     } else {
          //       _showConnectDialog(
          //           'Weighing Scale', () => setState(() => _scaleConnected = true));
          //     }
          //   },
          // ),

          SizedBox(height: 12.h),

          // ── 3. Thermal Printer ──
          _DeviceCard(
            icon: Icons.print_outlined,
            iconBgColor: const Color(0xFFF0F0F0),
            iconColor: AppColors.textGrey,
            title: 'Thermal Printer',
            statusText: _printerConnected ? 'Connected' : 'Not Connected',
            statusColor:
            _printerConnected ? AppColors.textGreen : AppColors.textGrey,
            isAlwaysActive: false,
            isConnected: _printerConnected,
            buttonLabel:
            _printerConnected ? 'Disconnect Printer' : 'Add Bluetooth Printer',
            buttonColor:
            _printerConnected ? AppColors.textRed : AppColors.textBlue,
            onButtonTap: () {
              if (_printerConnected) {
                _showDisconnectDialog('Thermal Printer',
                        () => setState(() => _printerConnected = false));
              } else {
                _showConnectDialog('Thermal Printer',
                        () => setState(() => _printerConnected = true));
              }
            },
          ),

          SizedBox(height: 12.h),

          // // ── 4. Cash Drawer ──
          // _DeviceCard(
          //   icon: Icons.point_of_sale_outlined,
          //   iconBgColor: const Color(0xFFFFF3EB),
          //   iconColor: const Color(0xFFFF8C42),
          //   title: 'Cash Drawer',
          //   statusText: _cashConnected ? 'Connected' : 'Not Connected',
          //   statusColor:
          //   _cashConnected ? AppColors.textGreen : AppColors.textGrey,
          //   isAlwaysActive: false,
          //   isConnected: _cashConnected,
          //   buttonLabel:
          //   _cashConnected ? 'Disconnect Drawer' : 'Connect Cash Drawer',
          //   buttonColor:
          //   _cashConnected ? AppColors.textRed : AppColors.textBlue,
          //   onButtonTap: () {
          //     if (_cashConnected) {
          //       _showDisconnectDialog('Cash Drawer',
          //               () => setState(() => _cashConnected = false));
          //     } else {
          //       _showConnectDialog('Cash Drawer',
          //               () => setState(() => _cashConnected = true));
          //     }
          //   },
          // ),

          SizedBox(height: 12.h),

          // ── 5. Customer Display ──
          // _DeviceCard(
          //   icon: Icons.monitor_outlined,
          //   iconBgColor: const Color(0xFFEBF0FF),
          //   iconColor: AppColors.textBlue,
          //   title: 'Customer Display',
          //   statusText: _displayConnected ? 'Connected' : 'Not Connected',
          //   statusColor:
          //   _displayConnected ? AppColors.textGreen : AppColors.textGrey,
          //   isAlwaysActive: false,
          //   isConnected: _displayConnected,
          //   buttonLabel: _displayConnected
          //       ? 'Disconnect Display'
          //       : 'Setup Customer Display',
          //   buttonColor:
          //   _displayConnected ? AppColors.textRed : AppColors.textBlue,
          //   onButtonTap: () {
          //     if (_displayConnected) {
          //       _showDisconnectDialog('Customer Display',
          //               () => setState(() => _displayConnected = false));
          //     } else {
          //       _showConnectDialog('Customer Display',
          //               () => setState(() => _displayConnected = true));
          //     }
          //   },
          // ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DEVICE CARD WIDGET
// ─────────────────────────────────────────────
class _DeviceCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String statusText;
  final Color statusColor;
  final bool isAlwaysActive;
  final bool isConnected;
  final String? description;
  final String? buttonLabel;
  final Color? buttonColor;
  final VoidCallback? onButtonTap;

  const _DeviceCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.statusText,
    required this.statusColor,
    required this.isAlwaysActive,
    this.isConnected = false,
    this.description,
    this.buttonLabel,
    this.buttonColor,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: iconColor, size: 24.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          if (isConnected || isAlwaysActive)
                            Container(
                              width: 7.w,
                              height: 7.w,
                              margin: EdgeInsets.only(right: 5.w),
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Text(
                            statusText,
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Connected check icon
                if (isConnected)
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF8EF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded,
                        color: AppColors.textGreen, size: 14.sp),
                  ),
              ],
            ),

            // ── Description (only for always active) ──
            if (description != null) ...[
              SizedBox(height: 12.h),
              Text(
                description!,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textGrey,
                  height: 1.5,
                ),
              ),
            ],

            // ── Action Button ──
            if (buttonLabel != null && onButtonTap != null) ...[
              SizedBox(height: 14.h),
              SizedBox(
                width: double.infinity,
                height: 46.h,
                child: ElevatedButton(
                  onPressed: onButtonTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    buttonLabel!,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
