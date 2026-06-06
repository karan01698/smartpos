// udhar_excel_controller.dart

import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../widget/snakbar.dart';

class UdharExcelController
    extends GetxController {

  var isLoading = false.obs;

  Future<void> downloadUdharExcel({

    required String phone,
    required String mobile,

  }) async {

    try {

      isLoading.value = true;

      // 🔥 API URL
      String url =
          "https://smartpos.anklegaming.biz/APIs/APIs.asmx/DownloadUdharExcel"
          "?token=SLDFKAJELWJLKJLKSJK"
          "&Mobile=$mobile"
          "&Phone=$phone";

      print(url);

      // 🔥 API CALL
      var response =
      await http.get(
        Uri.parse(url),
      );

      print(
          "STATUS : ${response.statusCode}");

      if (response.statusCode == 200) {

        // 🔥 DOWNLOAD FOLDER
        Directory directory;

        if (Platform.isAndroid) {

          directory =
              Directory(
                  "/storage/emulated/0/Download");

        } else {

          directory =
          await getApplicationDocumentsDirectory();
        }

        // 🔥 CREATE IF NOT EXISTS
        if (!await directory.exists()) {

          await directory.create(
            recursive: true,
          );
        }

        // 🔥 FILE PATH
        String filePath =
            "${directory.path}/UdharReport_${DateTime.now().millisecondsSinceEpoch}.xls";

        // 🔥 SAVE FILE
        File file =
        File(filePath);

        await file.writeAsBytes(
          response.bodyBytes,
          flush: true,
        );

        print(
            "FILE SAVED : $filePath");

        // 🔥 SUCCESS
        // Get.snackbar(
        //   "Success",
        //   "Udhar Excel Downloaded",
        // );

        // 🔥 OPEN FILE
        await OpenFilex.open(
          filePath,
        );

      } else {

        Get.snackbar(
          "Error",
          "Download Failed",
        );
      }

    } catch (e) {

      print(e);

      Get.snackbar(
        "Error",
        e.toString(),
      );

    } finally {

      isLoading.value = false;
    }
  }
}




class PartyExcelDownloadController
    extends GetxController {

  var isLoading = false.obs;

  Future<void> downloadPartyExcel({

    required String type,
    required String venPhone,

  }) async {

    try {

      isLoading.value = true;

      // 🔥 API URL
      String url =
          "https://smartpos.anklegaming.biz/APIs/APIs.asmx/PartyExcelDownload"
          "?token=SLDFKAJELWJLKJLKSJK"
          "&Type=$type"
          "&VenPhone=$venPhone";

      print(url);

      // 🔥 API CALL
      var response =
      await http.get(
        Uri.parse(url),
      );

      print(
          "STATUS : ${response.statusCode}");

      if (response.statusCode == 200) {

        // 🔥 DOWNLOAD FOLDER
        Directory directory;

        if (Platform.isAndroid) {

          directory =
              Directory(
                  "/storage/emulated/0/Download");

        } else {

          directory =
          await getApplicationDocumentsDirectory();
        }

        // 🔥 CREATE IF NOT EXISTS
        if (!await directory.exists()) {

          await directory.create(
            recursive: true,
          );
        }

        // 🔥 FILE PATH
        String filePath =
            "${directory.path}/PartyReport_${DateTime.now().millisecondsSinceEpoch}.xls";

        // 🔥 SAVE FILE
        File file =
        File(filePath);

        await file.writeAsBytes(

          response.bodyBytes,

          flush: true,
        );

        print(
            "FILE SAVED : $filePath");

        // 🔥 CHECK FILE SIZE
        int fileSize =
        await file.length();

        if (fileSize <= 0) {

          NeuSnackbar.error(
              "Downloaded File Empty");

          return;
        }

        // 🔥 SUCCESS
        NeuSnackbar.success(
            "Party Excel Downloaded");

        // 🔥 OPEN FILE
        await OpenFilex.open(
          filePath,
        );

      } else {

        Get.snackbar(

          "Error",

          "Download Failed",
        );
      }

    } catch (e) {

      print(e);

      Get.snackbar(

        "Error",

        e.toString(),
      );

    } finally {

      isLoading.value = false;
    }
  }
}