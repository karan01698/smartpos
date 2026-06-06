import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:whatsapp_share2/whatsapp_share2.dart';

class PosLiveSupportService {

  static Future<void> openWhatsApp({

    required String number,

    required Uint8List image,

    String message =
    "🧾 Your SmartPOS Bill",

  }) async {

    try {

      // REMOVE SPACES
      number = number.replaceAll(" ", "");

      // INDIA CODE
      if (!number.startsWith("91")) {

        number = "91$number";
      }

      // SAVE IMAGE
      final dir =
      await getTemporaryDirectory();

      final file = File(
        '${dir.path}/bill.png',
      );

      await file.writeAsBytes(image);

      // DIRECT WHATSAPP SEND
      await WhatsappShare.shareFile(

        phone: number,

        filePath: [file.path],

        text: message,
      );

    } catch (e) {

      print(
        "WHATSAPP ERROR => $e",
      );
    }
  }
}