import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smartpos/widget/snakbar.dart';
import 'package:url_launcher/url_launcher.dart';

class BillService {

  // ─────────────────────────────────────
  // DOWNLOAD BILL
  // ─────────────────────────────────────
  static Future<void> downloadBill({

    required Uint8List image,

  }) async {

    try {

      final pdf = pw.Document();

      final pwImage =
      pw.MemoryImage(image);

      pdf.addPage(

        pw.Page(

          build: (pw.Context context) {

            return pw.Center(

              child: pw.Image(
                pwImage,
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );

      // PDF SAVE
      await Printing.layoutPdf(

        onLayout: (format) async =>
            pdf.save(),
      );

      NeuSnackbar.info(
        "Print / Save PDF Opened",
      );

    } catch (e) {

      debugPrint(
        e.toString(),
      );
    }
  }
  // static Future<void> downloadBill({
  //
  //   required Uint8List image,
  //
  // }) async {
  //
  //   try {
  //
  //     await ImageGallerySaverPlus.saveImage(image);
  //
  //
  //     NeuSnackbar.info("Bill Downloaded",);
  //   } catch (e) {
  //
  //     debugPrint(
  //       e.toString(),
  //     );
  //   }
  // }

  // ─────────────────────────────────────
  // SHARE BILL
  // ─────────────────────────────────────

  static Future<void> shareBill({

    required Uint8List image,

  }) async {

    try {

      final dir =
      await getTemporaryDirectory();

      final file = File(

        '${dir.path}/bill_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await file.writeAsBytes(
        image,
      );

      await Share.shareXFiles(

        [
          XFile(file.path),
        ],

        text:
        "🧾 SmartPOS Bill",
      );

    } catch (e) {

      debugPrint(
        e.toString(),
      );
    }
  }
  static Future<void> shareBillWhatsapp({

    required Uint8List image,
    required String mobile,

  }) async {

    try {
print ("mobileno $mobile");
      final dir =
      await getTemporaryDirectory();

      final file = File(
        '${dir.path}/bill.png',
      );

      await file.writeAsBytes(image);

      String phone = "91$mobile";

      final url =
          "whatsapp://send?phone=$phone&text=🧾 Your Bill";

      // DIRECT WHATSAPP CHAT OPEN
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );

      // IMAGE DIRECT SHARE TO WHATSAPP
      await Share.shareXFiles(

        [XFile(file.path)],

        text: "🧾 Your Bill",

        sharePositionOrigin:
        const Rect.fromLTWH(0, 0, 1, 1),
      );

    } catch (e) {

      debugPrint(e.toString());
    }
  }

  static Future<void> textshareBillWhatsapp({

    required String mobile,
    required String shopName,

    required String customerName,
    required String customerMobile,

    required String cashierName,
    required String cashierMobile,

    required String paymentMode,
    required double total,
    required List billItems,

  }) async {

    try {

      // PHONE CLEAN
      String phone = mobile
          .replaceAll("+", "")
          .replaceAll(" ", "")
          .replaceAll("-", "")
          .trim();

      // ADD INDIA CODE
      if (!phone.startsWith("91")) {

        phone = "91$phone";
      }

      // RANDOM BILL NO
      final random = Random();

      String billNo =
          "#SM${100000 + random.nextInt(999999)}";

      // DATE & TIME
      final now = DateTime.now();

      final date =
          "${now.day}/${now.month}/${now.year}";

      final time =
          "${now.hour.toString().padLeft(2, '0')}:"
          "${now.minute.toString().padLeft(2, '0')}";

      // ITEMS
      String itemsText = "";

      int index = 1;

      for (var item in billItems) {

        itemsText +=
        "$index. ${item.name}: "
            "${item.qty} x ₹${item.rate} = ₹${item.finalAmt}\n";

        index++;
      }

      // MESSAGE FORMAT
      String message = """

🧾 *𝗠𝗬 𝗦𝗛𝗢𝗣: $shopName*
📅 Date: $date 
🆔 Bill No: $billNo
👤 *Customer Details*
👤 Customer: $customerName
📞 Contact: $customerMobile
🧑‍💼 *Cashier Details*
🧑‍💼 Cashier: $cashierName
📱 Cashier Mobile: $cashierMobile
🛒 *Items Purchased*
$itemsText
💰 *Bill Summary*
◈ Subtotal: ₹${total.toStringAsFixed(2)}
◈ Total Amount: ₹${total.toStringAsFixed(2)}
◈ Payment Mode: $paymentMode
🙏 Thank you for shopping with us!
""";

      print("MESSAGE => $message");

      // WHATSAPP URL
      final Uri whatsappUri = Uri.parse(

        "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
      );

      // OPEN WHATSAPP
      await launchUrl(

        whatsappUri,

        mode: LaunchMode.externalApplication,
      );

    } catch (e) {

      debugPrint(
        "WhatsApp Share Error: $e",
      );
    }
  }

}