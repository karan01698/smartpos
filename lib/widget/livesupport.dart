
import 'package:url_launcher/url_launcher.dart';

class LiveSupportService {

  static Future<void> openWhatsApp({

    required String number,

    String message =
    "Hello 👋\nHow may we help you?",

  }) async {

    final Uri uri = Uri.parse(

      "https://wa.me/$number?text=${Uri.encodeComponent(message)}",
    );

    await launchUrl(

      uri,

      mode: LaunchMode.externalApplication,
    );
  }
}


