  import 'package:flutter/material.dart';

  import 'package:get/get.dart';
  import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

  import '../poscalculator/constant/colors.dart';




  // Example placeholders for your custom classes/constants

  class BalooSubtitleText extends StatelessWidget {
    final String text;
    final Color color;
    final double fontSize;
    final FontWeight fontWeight;

    const BalooSubtitleText({
      super.key,
      required this.text,
      required this.color,
      required this.fontSize,
      required this.fontWeight,
    });

    @override
    Widget build(BuildContext context) {
      return Text(
        text,
        style: GoogleFonts.baloo2(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      );
    }
  }

  // Dummy PushableButton
  class PushableButton extends StatelessWidget {
    final Widget child;
    final double height;
    final double elevation;
    final HSLColor hslColor;
    final BoxShadow shadow;
    final VoidCallback? onPressed;

    const PushableButton({
      super.key,
      required this.child,
      required this.height,
      required this.elevation,
      required this.hslColor,
      required this.shadow,
      this.onPressed,
    });

    @override
    Widget build(BuildContext context) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: hslColor.toColor(),
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: shadow.color,
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: child,
        ),
      );
    }
  }

  class SubscriptionScreen extends StatefulWidget {
    SubscriptionScreen({super.key});

    @override
    State<SubscriptionScreen> createState() => _SubscriptionScreenState();
  }

  class _SubscriptionScreenState extends State<SubscriptionScreen> {

    Future<void> openUPI() async {

      try {

        final Uri uri = Uri.parse(
          "upi://pay?pa=8527362876@axl&pn=AnkleGaming&am=1&cu=INR&tn=Subscription Payment",
        );

        print("🔥 URI = $uri");

        bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        print("✅ OPEN RESULT = $launched");

        if (launched) {

          Get.snackbar(
            "Success",
            "UPI Apps Opened",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

        } else {

          Get.snackbar(
            "Error",
            "Unable To Open UPI Apps",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }

      } catch (e) {

        print("❌ ERROR = $e");

        Get.snackbar(
          "Error",
          e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
    @override
    void dispose() {
      // Clear listeners and resources
      try {

      } catch (e) {
        print(e);
      }
      super.dispose();
    }
    @override
    Widget build(BuildContext context) {

      final subscriptions = [
        {"duration": "1 Month", "price": "₹99"},
        {"duration": "6 Months", "price": "₹594"},
        {"duration": "12 Months", "price": "₹1070"},
      ];

      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Subscriptions"),
          backgroundColor: Colors.green
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: subscriptions.map((plan) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.85,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events, size: 120, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      "${plan['duration']} Subscription",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Colors.white70),
                    const SizedBox(height: 8),
                    Text(
                      "Please subscribe to unlock the benefits.",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // White Box Details
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "BENEFITS",
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Upload your words or pictures freely. No limits, — just simple and easy for everyone with  ${plan['duration']} subscription.",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Divider(height: 24),
                          Text(
                            "DURATION",
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${plan['duration']} Subscription",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Divider(height: 24),
                          Text(
                            "PRICE",
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${plan['price']}",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Subscribe Button
                    PushableButton(
                      height: 40,
                      elevation: 8,
                      hslColor: HSLColor.fromAHSL(1.0, 120, 1.0, 0.37),
                      shadow: BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                      onPressed: () async {

                        final priceString =
                        plan['price']!.replaceAll('₹', '');

                        // final cleanAmount =
                        // priceString.replaceAll(',', '');
                        final cleanAmount = "1";
                        await openUPI();
                      },
                      // onPressed: () async{
                      //   //   var options = {
                      //   //     'key': 'rzp_test_1DP5mmOlF5G5ag',
                      //   //     'amount': 1000,
                      //   //     'name': 'Karan',
                      //   //     'description': 'Speak Book ',
                      //   //     'prefill': {
                      //   //       'contact': '7303298840',
                      //   //       'email': 'karansingh@gmail.com'
                      //   //     }
                      //   //   };
                      //   // razorpay.open(options);
                      //   // },
                      //
                      //   final priceString = plan['price']!.replaceAll('₹', '');
                      //   final int amount = int.tryParse(priceString) ?? 0;
                      //
                      //
                      // },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.notifications,
                              color: Colors.white, size: 30),
                          const SizedBox(width: 6),
                          BalooSubtitleText(
                            text: "SUBSCRIPTION",
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
  }
