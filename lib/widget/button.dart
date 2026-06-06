import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../poscalculator/constant/apptext.dart';


class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  final double? width;
  final double? height;

  final Color color;
  final Color textColor;
  final Color shadowColor;

  final double radius;

  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    required this.onTap,

    this.width,
    this.height,

    required this.color,

    this.textColor = Colors.white,
    this.shadowColor = const Color(0x22000000),

    this.radius = 16,

    this.icon,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: isPressed ? 0.96 : 1,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            isPressed = true;
          });
        },

        onTapUp: (_) {
          setState(() {
            isPressed = false;
          });

          widget.onTap();
        },

        onTapCancel: () {
          setState(() {
            isPressed = false;
          });
        },

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),

          width: widget.width ?? double.infinity,
          height: widget.height ?? 52.h,

          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(widget.radius.r),

            boxShadow: [
              BoxShadow(
                color: widget.shadowColor,
                blurRadius: isPressed ? 4 : 10,
                offset: Offset(0, isPressed ? 2 : 5),
              ),
            ],
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: widget.textColor,
                  size: 18.sp,
                ),

                SizedBox(width: 8.w),
              ],

              Text(
                widget.text,
                style: AppText.saveBtn().copyWith(
                  color: widget.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}