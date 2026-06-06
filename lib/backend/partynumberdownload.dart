// customer_excel_controller.dart

import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../widget/snakbar.dart';

class CustomerExcelController extends GetxController {

  var isLoading = false.obs;

  Future<void> downloadCustomerExcel({
    required String phone,
  }) async {

    try {

      isLoading.value = true;

      // 🔥 API URL
      String url =
          "https://smartpos.anklegaming.biz/APIs/APIs.asmx/DownloadCustomerListExcel"
          "?token=SLDFKAJELWJLKJLKSJK"
          "&Phone=$phone";

      print("API URL : $url");

      // 🔥 API CALL
      var response = await http.get(
        Uri.parse(url),
      );

      print("STATUS CODE : ${response.statusCode}");

      // 🔥 CHECK RESPONSE
      if (response.statusCode == 200) {

        Directory directory;

        if (Platform.isAndroid) {

          directory =
              Directory("/storage/emulated/0/Download");

        } else {

          directory =
          await getApplicationDocumentsDirectory();
        }

        // 🔥 CREATE FOLDER
        if (!await directory.exists()) {

          await directory.create(
            recursive: true,
          );
        }

        // 🔥 FILE PATH
        String filePath =
            "${directory.path}/CustomerList_${DateTime.now().millisecondsSinceEpoch}.xls";

        File file = File(filePath);

        // 🔥 SAVE FILE
        await file.writeAsBytes(
          response.bodyBytes,
          flush: true,
        );

        int fileSize = await file.length();

        print("FILE SIZE : $fileSize");

        if (fileSize <= 0) {

          NeuSnackbar.warning(
            "Downloaded File Empty",
          );

          return;
        }

        // 🔥 SUCCESS
        NeuSnackbar.success(
          "Excel Downloaded Successfully",
        );

        // 🔥 OPEN FILE
        await OpenFilex.open(filePath);

      } else {

        Get.snackbar(
          "Error",
          "Server Error : ${response.statusCode}",
        );
      }

    } catch (e) {

      print("DOWNLOAD ERROR : $e");

      Get.snackbar(
        "Error",
        e.toString(),
      );

    } finally {

      isLoading.value = false;
    }
  }
}